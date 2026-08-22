#!/usr/bin/env python3
"""Extrait la photothèque française de l'Encyclopédie de la Shoah.

Le script ne télécharge pas les fichiers image dans le dépôt. Il conserve les
URL des miniatures et des images d'affichage afin que la galerie reste légère,
et enregistre pour chaque notice son titre, une courte description, ses mots-
clés et son lien source.
"""

from __future__ import annotations

import argparse
import json
import math
import re
import sys
import time
from datetime import datetime, timezone
from html import unescape
from html.parser import HTMLParser
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode
from urllib.request import Request, urlopen


BASE_URL = "https://encyclopedia.ushmm.org/fr/a-z/photo"
SOURCE_NAME = "United States Holocaust Memorial Museum"
USER_AGENT = (
    "PantheonMemoirePhotoIndex/1.0 "
    "(+https://victeams.github.io/Le-panthon-des-heros-aushwist-41-45/)"
)


def clean_text(value: str) -> str:
    return re.sub(r"\s+", " ", unescape(value)).strip()


def shorten(value: str, maximum: int = 360) -> str:
    value = clean_text(value)
    if len(value) <= maximum:
        return value
    result = value[: maximum + 1].rsplit(" ", 1)[0].rstrip(" ,;:-")
    return f"{result}…"


def large_image_url(thumbnail_url: str) -> str:
    if "/images/thumb/" in thumbnail_url:
        return thumbnail_url.replace("/images/thumb/", "/images/large/", 1)
    return thumbnail_url


class PhotoListingParser(HTMLParser):
    """Analyse une page A-Z sans bibliothèque Python supplémentaire."""

    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.items: list[dict[str, object]] = []
        self.current: dict[str, object] | None = None
        self.item_depth = 0
        self.figure_depth = 0
        self.tags_depth = 0
        self.capture: str | None = None
        self.capture_tag: str | None = None
        self.buffer: list[str] = []

    @staticmethod
    def _attrs(attrs: list[tuple[str, str | None]]) -> dict[str, str]:
        return {key.casefold(): value or "" for key, value in attrs}

    def _start_capture(self, field: str, closing_tag: str) -> None:
        self.capture = field
        self.capture_tag = closing_tag
        self.buffer = []

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        tag = tag.casefold()
        attributes = self._attrs(attrs)
        classes = set(attributes.get("class", "").split())

        if tag == "li" and "clearfix" in classes:
            if self.current is None:
                self.current = {"tags": []}
                self.item_depth = 1
            else:
                self.item_depth += 1
            return

        if self.current is None:
            return

        if tag == "li":
            self.item_depth += 1
        if tag == "figure":
            self.figure_depth += 1
        if tag == "div" and "tags" in classes:
            self.tags_depth += 1

        if tag == "a" and self.capture is None:
            href = attributes.get("href", "")
            if "/content/fr/photo/" in href and not self.current.get("detail_url"):
                self.current["detail_url"] = href
                self._start_capture("title", "a")
            elif self.tags_depth:
                self._start_capture("tag", "a")
        elif tag == "p" and "search-overview" in classes and self.capture is None:
            self._start_capture("description", "p")
        elif tag == "img" and self.figure_depth and not self.current.get("thumbnail_url"):
            source = attributes.get("src", "")
            if source:
                self.current["thumbnail_url"] = source
                self.current["alt"] = clean_text(attributes.get("alt", ""))

    def handle_startendtag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        self.handle_starttag(tag, attrs)
        self.handle_endtag(tag)

    def handle_data(self, data: str) -> None:
        if self.capture is not None:
            self.buffer.append(data)

    def handle_endtag(self, tag: str) -> None:
        tag = tag.casefold()
        if self.current is None:
            return

        if self.capture is not None and tag == self.capture_tag:
            value = clean_text(" ".join(self.buffer))
            if self.capture == "tag":
                tags = self.current.setdefault("tags", [])
                if value and isinstance(tags, list):
                    tags.append(value)
            elif value:
                self.current[self.capture] = value
            self.capture = None
            self.capture_tag = None
            self.buffer = []

        if tag == "figure" and self.figure_depth:
            self.figure_depth -= 1
        elif tag == "div" and self.tags_depth:
            self.tags_depth -= 1
        elif tag == "li":
            self.item_depth -= 1
            if self.item_depth <= 0:
                self._finish_item()

    def _finish_item(self) -> None:
        assert self.current is not None
        required = ("title", "description", "detail_url")
        if all(self.current.get(key) for key in required):
            thumbnail = str(self.current.get("thumbnail_url") or "")
            self.current["description"] = shorten(str(self.current["description"]))
            self.current["thumbnail_url"] = thumbnail or None
            self.current["image_url"] = large_image_url(thumbnail) if thumbnail else None
            if not self.current.get("alt"):
                self.current["alt"] = str(self.current["title"])
            self.items.append(self.current)
        self.current = None
        self.item_depth = 0
        self.figure_depth = 0
        self.tags_depth = 0
        self.capture = None
        self.capture_tag = None
        self.buffer = []


def total_results(html: str) -> int:
    match = re.search(
        r"Affichage\s+des\s+r[ée]sultats.*?\bsur\s+([\d\s\u00a0]+)\s+pour",
        clean_text(html),
        flags=re.IGNORECASE,
    )
    if not match:
        raise ValueError("Le nombre total de photographies n'a pas été trouvé.")
    return int(re.sub(r"\D", "", match.group(1)))


def fetch(url: str, retries: int = 4, timeout: int = 45) -> str:
    request = Request(
        url,
        headers={
            "User-Agent": USER_AGENT,
            "Accept": "text/html,application/xhtml+xml",
            "Accept-Language": "fr-FR,fr;q=0.9",
        },
    )
    for attempt in range(1, retries + 1):
        try:
            with urlopen(request, timeout=timeout) as response:
                charset = response.headers.get_content_charset() or "utf-8"
                return response.read().decode(charset, errors="replace")
        except (HTTPError, URLError, TimeoutError) as error:
            if attempt == retries:
                raise RuntimeError(f"Échec du téléchargement de {url}: {error}") from error
            time.sleep(2 ** (attempt - 1))
    raise AssertionError("Boucle de téléchargement interrompue de manière inattendue")


def page_url(page: int, per_page: int) -> str:
    return f"{BASE_URL}?{urlencode({'query': '*:*', 'perPage': per_page, 'page': page})}"


def scrape(per_page: int = 50, delay: float = 0.4, maximum_pages: int | None = None) -> dict[str, object]:
    first_html = fetch(page_url(1, per_page))
    expected = total_results(first_html)
    page_count = math.ceil(expected / per_page)
    if maximum_pages is not None:
        page_count = min(page_count, maximum_pages)

    items_by_url: dict[str, dict[str, object]] = {}
    for page in range(1, page_count + 1):
        html = first_html if page == 1 else fetch(page_url(page, per_page))
        parser = PhotoListingParser()
        parser.feed(html)
        if not parser.items:
            raise RuntimeError(f"Aucune photographie trouvée à la page {page}.")
        for item in parser.items:
            items_by_url[str(item["detail_url"])] = item
        print(
            f"Page {page}/{page_count}: {len(parser.items)} notices "
            f"({len(items_by_url)} uniques)",
            flush=True,
        )
        if page < page_count and delay:
            time.sleep(delay)

    items = list(items_by_url.values())
    partial = maximum_pages is not None and page_count < math.ceil(expected / per_page)
    if not partial and len(items) != expected:
        raise RuntimeError(
            f"Extraction incomplète: {len(items)} notices uniques sur {expected} attendues."
        )

    return {
        "source_name": SOURCE_NAME,
        "source_url": BASE_URL,
        "terms_url": "https://www.ushmm.org/copyright-and-legal-information/terms-of-use",
        "generated_at": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "count": len(items),
        "expected_count": expected,
        "partial": partial,
        "usage_notice": (
            "Miniatures distantes présentées à des fins documentaires. "
            "La notice source liée à chaque image contient les crédits détaillés "
            "et les éventuelles restrictions d'utilisation."
        ),
        "items": items,
    }


def write_shards(payload: dict[str, object], manifest_path: Path, shard_size: int) -> None:
    items = payload.pop("items")
    if not isinstance(items, list):
        raise TypeError("La liste des photographies est invalide.")
    manifest_path.parent.mkdir(parents=True, exist_ok=True)
    for old_shard in manifest_path.parent.glob("photos-*.json"):
        old_shard.unlink()

    files: list[str] = []
    for index in range(0, len(items), shard_size):
        filename = f"photos-{index // shard_size + 1:03d}.json"
        files.append(filename)
        (manifest_path.parent / filename).write_text(
            json.dumps(items[index : index + shard_size], ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )

    payload["files"] = files
    payload["shard_size"] = shard_size
    manifest_path.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--output",
        type=Path,
        default=(
            Path(__file__).resolve().parents[1]
            / "data"
            / "ushmm-photos"
            / "manifest.json"
        ),
        help="Manifeste JSON produit ; les notices sont enregistrées en fichiers voisins.",
    )
    parser.add_argument("--per-page", type=int, default=50, choices=(10, 25, 50))
    parser.add_argument("--delay", type=float, default=0.4, help="Pause entre deux pages.")
    parser.add_argument(
        "--maximum-pages",
        type=int,
        default=None,
        help="Limite facultative pour un essai partiel.",
    )
    parser.add_argument("--shard-size", type=int, default=100, help="Notices par fichier JSON.")
    arguments = parser.parse_args(argv)
    payload = scrape(arguments.per_page, max(0.0, arguments.delay), arguments.maximum_pages)
    if arguments.shard_size < 1:
        parser.error("--shard-size doit être supérieur à zéro")
    count = payload["count"]
    write_shards(payload, arguments.output, arguments.shard_size)
    print(f"{count} notices enregistrées dans {arguments.output.parent}")
    return 0


if __name__ == "__main__":
    sys.exit(main())

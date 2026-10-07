#!/usr/bin/env python3
"""Index names and official links from the USHMM French identification-card catalog.

Only names, source URLs, and a conservative gender category are saved. The
Museum's biographies and images are not copied into the repository.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
import time
import unicodedata
from datetime import datetime, timezone
from html import unescape
from html.parser import HTMLParser
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.parse import parse_qs, urlencode, urljoin, urlparse, urlunparse
from urllib.request import Request, urlopen


SOURCE_NAME = "United States Holocaust Memorial Museum"
BASE_URL = "https://encyclopedia.ushmm.org"
INDEX_URL = f"{BASE_URL}/landing/fr/id-cards"
LETTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
USER_AGENT = (
    "PantheonMemoireLinkCatalog/1.0 "
    "(+https://memoiredesdeportes.fr/)"
)
GENDER_GROUPS = {"femmes", "hommes", "non_documente"}
NON_PERSON_TITLES = {"les femmes", "les hommes", "les jeunes"}


class ResourceNotFoundError(RuntimeError):
    """A catalog link points to a biography that is no longer available."""


def clean_text(value: str) -> str:
    return re.sub(r"\s+", " ", unescape(value)).strip()


def normalized(value: str) -> str:
    value = unicodedata.normalize("NFKD", value)
    value = "".join(char for char in value if not unicodedata.combining(char))
    return re.sub(r"[^a-z0-9]+", " ", value.casefold()).strip()


class IdCardListingParser(HTMLParser):
    """Extract only names and official links from one catalog page."""

    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.records: list[dict[str, str]] = []
        self.gender_hints: dict[str, set[str]] = {}
        self.current_url: str | None = None
        self.current_filter = ""
        self.name_depth = 0
        self.name_parts: list[str] = []

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        attributes = {key.casefold(): value or "" for key, value in attrs}
        href = attributes.get("href", "")
        parsed_href = urlparse(href)
        if tag.casefold() == "a" and parsed_href.path.startswith("/content/fr/id-card/"):
            self.current_url = href
            self.current_filter = parse_qs(parsed_href.query).get("filter", [""])[0]
            self.name_parts = []
        elif tag.casefold() == "h4" and self.current_url:
            self.name_depth += 1

    def handle_data(self, data: str) -> None:
        if self.current_url and self.name_depth:
            self.name_parts.append(data)

    def handle_endtag(self, tag: str) -> None:
        if tag.casefold() != "h4" or not self.current_url or not self.name_depth:
            return
        self.name_depth -= 1
        if self.name_depth:
            return
        name = clean_text(" ".join(self.name_parts))
        normalized_name = normalized(name)
        filter_groups = {"les femmes": ("women", "femmes"), "les hommes": ("men", "hommes")}
        if normalized_name in filter_groups:
            expected_filter, group = filter_groups[normalized_name]
            if self.current_filter == expected_filter:
                self.gender_hints.setdefault(card_url(self.current_url), set()).add(group)
        elif name and normalized_name not in NON_PERSON_TITLES:
            self.records.append({"name": name, "url": card_url(self.current_url)})
        self.current_url = None
        self.current_filter = ""
        self.name_parts = []


class BiographyTextParser(HTMLParser):
    """Read biography text only for sex classification; never persist the text."""

    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.main_text_depth = 0
        self.hidden_depth = 0
        self.parts: list[str] = []

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        tag = tag.casefold()
        attributes = {key.casefold(): value or "" for key, value in attrs}
        if tag == "div" and attributes.get("id") == "main_text":
            self.main_text_depth = 1
        elif self.main_text_depth and tag == "div":
            self.main_text_depth += 1
        if self.main_text_depth and tag in {"script", "style"}:
            self.hidden_depth += 1

    def handle_endtag(self, tag: str) -> None:
        tag = tag.casefold()
        if self.main_text_depth and tag in {"script", "style"} and self.hidden_depth:
            self.hidden_depth -= 1
        if self.main_text_depth and tag == "div":
            self.main_text_depth -= 1

    def handle_data(self, data: str) -> None:
        if self.main_text_depth and not self.hidden_depth and data.strip():
            self.parts.append(data)


def gender_group(biography_text: str, name: str | None = None) -> str:
    """Classify only from explicit, gendered terms in the lead sentence."""
    text = unicodedata.normalize("NFKC", biography_text).casefold()
    lead = re.split(r"(?<=[.!?])\s+", text, maxsplit=1)[0]
    if name:
        first_name = re.escape(name.split()[0].casefold())
        name_match = re.search(rf"(?<!\w){first_name}(?!\w)", lead)
        if not name_match:
            return "non_documente"
        lead = lead[name_match.end():name_match.end() + 100]
    feminine = re.search(
        r"\b(?:née|déportée|survivante|rescapée|assassinée|morte|"
        r"arrêtée|internée|réfugiée|aînée|cadette|la\s+(?:plus\s+)?jeune|"
        r"fille)\b",
        lead,
    )
    masculine = re.search(
        r"\b(?:né|déporté|survivant|rescapé|assassiné|mort|arrêté|"
        r"interné|réfugié|aîné|cadet|le\s+(?:plus\s+)?jeune|fils)\b",
        lead,
    )
    if feminine and masculine:
        if not name:
            return "non_documente"
        return "femmes" if feminine.start() < masculine.start() else "hommes"
    if feminine:
        return "femmes"
    if masculine:
        return "hommes"
    return "non_documente"


def card_url(href: str) -> str:
    url = urljoin(BASE_URL, href)
    parsed = urlparse(url)
    if (
        parsed.scheme != "https"
        or parsed.netloc != "encyclopedia.ushmm.org"
        or not parsed.path.startswith("/content/fr/id-card/")
    ):
        raise ValueError(f"Lien de notice USHMM invalide: {href}")
    return urlunparse((parsed.scheme, parsed.netloc, parsed.path, "", "", ""))


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
        except HTTPError as error:
            if error.code == 404:
                raise ResourceNotFoundError(f"Notice USHMM introuvable: {url}") from error
            if attempt == retries:
                raise RuntimeError(f"Échec du téléchargement de {url}: {error}") from error
            time.sleep(2 ** (attempt - 1))
        except (URLError, TimeoutError) as error:
            if attempt == retries:
                raise RuntimeError(f"Échec du téléchargement de {url}: {error}") from error
            time.sleep(2 ** (attempt - 1))
    raise AssertionError("Boucle de téléchargement interrompue de manière inattendue")


def listing_url(letter: str, page: int = 1) -> str:
    query = {"letter": letter}
    if page > 1:
        query["page"] = str(page)
    return f"{INDEX_URL}?{urlencode(query)}"


def pages_in(html: str) -> int:
    pages = [int(value) for value in re.findall(r"[?&]page=(\d+)", unescape(html))]
    return max([1, *pages])


def scrape(delay: float = 0.5) -> dict[str, object]:
    records_by_url: dict[str, dict[str, str]] = {}
    for letter in LETTERS:
        first_page = fetch(listing_url(letter))
        page_count = pages_in(first_page)
        for page in range(1, page_count + 1):
            html = first_page if page == 1 else fetch(listing_url(letter, page))
            parser = IdCardListingParser()
            parser.feed(html)
            if not parser.records:
                if page == 1:
                    break
                raise RuntimeError(
                    f"Aucune notice trouvée dans l'index USHMM "
                    f"pour la lettre {letter}, page {page}."
                )
            for item in parser.records:
                url = item["url"]
                records_by_url.setdefault(url, {"name": item["name"], "url": url})
            for url, groups in parser.gender_hints.items():
                if url in records_by_url:
                    record = records_by_url[url]
                    group = next(iter(groups)) if len(groups) == 1 else "non_documente"
                    if "gender_group" in record and record["gender_group"] != group:
                        record["gender_group"] = "non_documente"
                    else:
                        record["gender_group"] = group
            print(
                f"Lettre {letter}, page {page}/{page_count}: "
                f"{len(parser.records)} notices ({len(records_by_url)} uniques)",
                flush=True,
            )
            if delay:
                time.sleep(delay)

    if not records_by_url:
        raise RuntimeError("Aucune notice trouvée dans le catalogue USHMM.")

    records = sorted(
        records_by_url.values(),
        key=lambda item: (normalized(item["name"]), item["url"]),
    )
    for index, record in enumerate(records, start=1):
        if record.get("gender_group") in {"femmes", "hommes"}:
            print(
                f"Notice {index}/{len(records)} classée : {record['name']} "
                f"({record['gender_group']}, catégorie officielle de l’index)",
                flush=True,
            )
            continue
        try:
            html = fetch(record["url"])
        except ResourceNotFoundError:
            record["gender_group"] = "non_documente"
        else:
            parser = BiographyTextParser()
            parser.feed(html)
            biography = clean_text(" ".join(parser.parts))
            record["gender_group"] = gender_group(biography, record["name"])
            if not biography:
                record["gender_group"] = "non_documente"
        print(
            f"Notice {index}/{len(records)} classée : {record['name']} "
            f"({record['gender_group']})",
            flush=True,
        )
        if delay and index < len(records):
            time.sleep(delay)

    counts = {
        group: sum(record["gender_group"] == group for record in records)
        for group in sorted(GENDER_GROUPS)
    }
    return {
        "source_name": SOURCE_NAME,
        "source_index_url": INDEX_URL,
        "generated_at": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "count": len(records),
        "counts": counts,
        "records": records,
        "usage_notice": (
            "Ce catalogue conserve uniquement les noms, les liens directs vers "
            "les notices officielles et une catégorie de classement prudente. "
            "Les biographies et les images restent hébergées par l'USHMM."
        ),
    }


def write_catalog(payload: dict[str, object], output: Path) -> None:
    output.parent.mkdir(parents=True, exist_ok=True)
    temporary = output.with_suffix(output.suffix + ".tmp")
    temporary.write_text(
        json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    temporary.replace(output)


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--output",
        type=Path,
        default=Path(__file__).resolve().parents[1]
        / "data"
        / "ushmm-id-cards.json",
        help="Fichier JSON contenant les noms et liens officiels.",
    )
    parser.add_argument(
        "--delay",
        type=float,
        default=0.5,
        help="Pause entre les requêtes, en secondes.",
    )
    arguments = parser.parse_args(argv)
    if arguments.delay < 0:
        parser.error("--delay ne peut pas être négatif")
    payload = scrape(arguments.delay)
    write_catalog(payload, arguments.output)
    print(
        f"{payload['count']} notices enregistrées dans {arguments.output} "
        f"({payload['counts']})"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())

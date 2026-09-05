#!/usr/bin/env python3
"""Récupère les portraits féminins documentés et inscrit leurs droits.

La source primaire est la notice individuelle de Mémoire Vive. Le script ne
retient jamais une photographie contextuelle (camp, bâtiment, carte postale,
plaque, cérémonie) comme portrait. Une licence absente n'est pas inventée :
elle est explicitement signalée comme non indiquée par la source.
"""

from __future__ import annotations

import argparse
import base64
import json
import re
import ssl
import time
import unicodedata
from concurrent.futures import ThreadPoolExecutor, as_completed
from dataclasses import asdict, dataclass
from datetime import date
from html import escape, unescape
from html.parser import HTMLParser
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.parse import parse_qs, quote, unquote, urljoin, urlparse
from urllib.request import Request, urlopen


SOURCE_ROOT = "https://www.memoirevive-bis.org"
MASTER_API = f"{SOURCE_ROOT}/wp-json/wp/v2/pages/7775"
USER_AGENT = "PantheonMemoirePortraitAudit/1.0 (historical photo attribution)"
CONTEXT_TERMS = (
    "aquarelle", "bâtiment", "baraquement", "block ", "camp de", "carte postale",
    "cérémonie", "cour intérieure", "entrée", "façade", "fort de", "gare", "hospice",
    "immeuble", "maison", "monument", "paysage", "plaque", "portail", "rue ", "ville",
    "vue aérienne", "wagon",
)
PERSON_TERMS = (
    "photographiée à auschwitz", "photographie d’immatriculation", "photographie d'identité",
    "photo d’immatriculation", "portrait", "trois vues anthropométriques",
)
MANUAL_REJECTIONS = {
    "adrienne_hardenberg_31636.html": "image générique « photo non trouvée »",
    "aimee_dite_manette_doridat_nee_godefroy_31767.html": "image générique « photo non trouvée »",
    "camille_champion_31656.html": "la photographie d’immatriculation proposée représente un homme",
    "gabrielle-bergin-31798.html": "identification signalée comme incertaine par la source",
    "germaine-pican-31679.html": "la photographie représente un homme de la famille",
    "germaine_girard_31706.html": "identification signalée comme incertaine par la source",
    "gisele-laguesse-31667.html": "la source ne montre qu’un homme de la famille Laguesse",
    "helene_allaire_31807.html": "la photographie représente son fiancé Paul Allaire",
    "helene_hascoet_31755.html": "image générique « photo non trouvée »",
    "jeanne_grandperret_31770.html": "image générique « photo non trouvée »",
    "marcelle_bureau_31808.html": "image générique « photo non trouvée »",
    "marcelle_dite_paulette_gourmelon_31753.html": "l’image proposée représente Pierre-Benoît Gourmelon",
    "rose_blanc_31652.html": "l’image proposée est une plaque commémorative, pas un portrait",
    "suzanne_momon_gustave_gilbert_brustlein_refait.html": "l’image proposée représente Gilbert Brustlein",
    "suzanne_roze_31681.html": "image générique « photo non trouvée »",
    "yvonne_bonnard_31627.html": "image générique « photo non trouvée »",
}
PRESERVE_EXISTING = {
    "alice-boulet-31628.html",
    "marguerite_richier_31840.html",
    "marie_simone_alizon_31777_31776.html",
    "yvonne-blech-31000.html",
}


def normalized(value: str) -> str:
    value = unicodedata.normalize("NFKD", unescape(value))
    value = "".join(char for char in value if not unicodedata.combining(char))
    return re.sub(r"[^a-z0-9]+", " ", value.casefold()).strip()


def clean(value: str) -> str:
    return re.sub(r"\s+", " ", re.sub(r"<[^>]+>", " ", unescape(value))).strip()


def fetch_bytes(url: str, attempts: int = 3) -> tuple[bytes, str]:
    last_error: Exception | None = None
    context = ssl.create_default_context()
    request_url = quote(unicodedata.normalize("NFC", url), safe=":/?=&%#")
    for attempt in range(attempts):
        try:
            request = Request(request_url, headers={"User-Agent": USER_AGENT, "Accept": "*/*"})
            with urlopen(request, timeout=45, context=context) as response:
                return response.read(), response.headers.get_content_type()
        except (HTTPError, URLError, TimeoutError, OSError) as error:
            last_error = error
            time.sleep(1.5 * (attempt + 1))
    raise RuntimeError(f"Téléchargement impossible : {url}: {last_error}")


def fetch_json(url: str) -> dict | list:
    payload, _ = fetch_bytes(url)
    text = payload.decode("utf-8", errors="replace").lstrip("\ufeff \t\r\n")
    positions = [position for position in (text.find("{"), text.find("[")) if position >= 0]
    if not positions:
        raise ValueError("réponse JSON absente")
    value, _ = json.JSONDecoder().raw_decode(text[min(positions):])
    return value


class LinksParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.links: list[tuple[str, str]] = []
        self._href = ""
        self._text: list[str] = []

    def handle_starttag(self, tag, attrs):
        if tag.casefold() == "a":
            self._href = dict(attrs).get("href", "")
            self._text = []

    def handle_data(self, data):
        if self._href:
            self._text.append(data)

    def handle_endtag(self, tag):
        if tag.casefold() == "a" and self._href:
            self.links.append((self._href, clean(" ".join(self._text))))
            self._href = ""
            self._text = []


@dataclass
class ImageCandidate:
    url: str
    alt: str
    width: int
    height: int


class ImagesParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.images: list[ImageCandidate] = []

    def handle_starttag(self, tag, attrs):
        if tag.casefold() != "img":
            return
        values = dict(attrs)
        source = values.get("data-orig-src") or values.get("src") or ""
        if not source or source.startswith("data:"):
            return
        try:
            width = int(values.get("width", "0"))
            height = int(values.get("height", "0"))
        except ValueError:
            width = height = 0
        self.images.append(
            ImageCandidate(urljoin(SOURCE_ROOT, source), clean(values.get("alt", "")), width, height)
        )


class FirstImageParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.src = ""

    def handle_starttag(self, tag, attrs):
        if tag.casefold() == "img" and not self.src:
            self.src = dict(attrs).get("src", "")


def title_tokens(name: str) -> tuple[str, str, list[str]]:
    words = [word for word in normalized(name).split() if len(word) >= 3]
    particles = {"dite", "nee", "epouse", "veuve", "dame", "des", "les", "dit"}
    useful = [word for word in words if word not in particles]
    first = useful[0] if useful else ""
    surname = useful[-1] if useful else ""
    return first, surname, useful


def score_image(candidate: ImageCandidate, name: str, matricule: str | None) -> tuple[int, list[str]]:
    first, surname, words = title_tokens(name)
    haystack = normalized(f"{urlparse(candidate.url).path} {candidate.alt}")
    alt_norm = normalized(candidate.alt)
    score = 0
    reasons: list[str] = []
    if matricule and matricule in haystack:
        score += 120
        reasons.append("matricule")
    if first and first in haystack:
        score += 55
        reasons.append("prénom")
    if surname and surname in haystack:
        score += 55
        reasons.append("nom")
    matched = [word for word in words if word in haystack]
    if len(set(matched)) >= 2:
        score += 45
        reasons.append("nom complet")
    for term in PERSON_TERMS:
        if normalized(term) in haystack:
            score += 70
            reasons.append(term)
            break
    for term in CONTEXT_TERMS:
        if normalized(term) in haystack:
            score -= 140
            reasons.append(f"contexte:{term}")
    if candidate.width and candidate.height:
        if min(candidate.width, candidate.height) < 120:
            score -= 200
        elif candidate.height >= candidate.width * 0.72 or candidate.width >= candidate.height * 1.6:
            score += 8
    if alt_norm in {"", "transportaquarelle", "d r", "-"}:
        score -= 15
    return score, reasons


def rights_status(credit: str) -> str:
    value = normalized(credit)
    if "domaine public" in value:
        return "Domaine public selon la source"
    if "creative commons" in value or re.search(r"\bcc(?: |-)?by\b", value):
        return "Licence Creative Commons indiquée par la source"
    if "droits reserves" in value or "copyright" in value or "©" in credit or value in {"d r", "dr"}:
        return "Droits réservés"
    return "Licence ou droits non indiqués par la source ; réutilisation à vérifier"


def useful_credit(value: str) -> str:
    cleaned = clean(value)
    if not cleaned or re.fullmatch(r"(?i)(?:jpe?g|png|gif|webp)(?:\s*-\s*[\d.,]+\s*(?:ko|mo))?", cleaned):
        return "Crédit non indiqué par la source"
    return cleaned


def source_links() -> tuple[dict[str, str], list[tuple[str, str]]]:
    master = fetch_json(MASTER_API)
    content = master["content"]["rendered"]
    parser = LinksParser()
    parser.feed(content)
    by_number: dict[str, str] = {}
    for href, label in parser.links:
        numbers = re.findall(r"(?<!\d)31\d{3}(?!\d)", f"{label} {href}")
        if numbers and href.startswith(SOURCE_ROOT):
            by_number.setdefault(numbers[0], href)
    return by_number, parser.links


def post_api_from_page(page_url: str) -> str:
    parsed = urlparse(page_url)
    post_ids = parse_qs(parsed.query).get("p", [])
    if post_ids and post_ids[0].isdigit():
        return f"{SOURCE_ROOT}/wp-json/wp/v2/posts/{post_ids[0]}?_fields=id,link,title,content"
    slug = parsed.path.strip("/").split("/")[-1]
    return f"{SOURCE_ROOT}/wp-json/wp/v2/posts?slug={quote(slug)}&_fields=id,link,title,content"


def inspect_source(record: dict, by_number: dict[str, str]) -> dict:
    matricule = record.get("matricule")
    page_url = by_number.get(str(matricule or ""))
    result = {
        "name": record["name"],
        "file": unquote(record["file"]),
        "matricule": matricule,
        "source_page": page_url,
        "source_image": None,
        "credit": None,
        "rights_status": None,
        "selection_score": None,
        "selection_reasons": [],
        "state": "source introuvable",
    }
    if not page_url:
        return result
    posts = fetch_json(post_api_from_page(page_url))
    if isinstance(posts, dict):
        posts = [posts]
    if not posts:
        result["state"] = "notice API introuvable"
        return result
    content = posts[0]["content"]["rendered"]
    parser = ImagesParser()
    parser.feed(content)
    scored = sorted(
        ((score_image(image, record["name"], matricule), image) for image in parser.images),
        key=lambda item: item[0][0],
        reverse=True,
    )
    if not scored or scored[0][0][0] < 55:
        result["state"] = "aucun portrait suffisamment certain"
        return result
    (score, reasons), image = scored[0]
    result.update(
        {
            "source_page": posts[0].get("link") or page_url,
            "source_image": image.url,
            "credit": useful_credit(image.alt),
            "rights_status": rights_status(useful_credit(image.alt)),
            "selection_score": score,
            "selection_reasons": reasons,
            "state": "portrait retenu" if score >= 100 else "portrait à contrôler",
        }
    )
    return result


def data_uri(payload: bytes, content_type: str, url: str) -> str:
    if not content_type.startswith("image/"):
        suffix = Path(urlparse(url).path).suffix.casefold()
        content_type = {".png": "image/png", ".webp": "image/webp", ".gif": "image/gif"}.get(suffix, "image/jpeg")
    return f"data:{content_type};base64,{base64.b64encode(payload).decode('ascii')}"


def replace_photo(path: Path, result: dict, image_payload: tuple[bytes, str] | None) -> bool:
    content = path.read_text(encoding="utf-8", errors="replace")
    old = content
    credit_class = "photo-documentation"
    if image_payload and result["source_image"]:
        uri = data_uri(image_payload[0], image_payload[1], result["source_image"])
        image = (
            f'<figure class="portrait-documente"><img class="photo" src="{uri}" '
            f'alt="Portrait documenté de {escape(result["name"], quote=True)}" loading="lazy">'
            f'<figcaption>{escape(result["credit"] or "Crédit non indiqué")}</figcaption></figure>'
        )
    else:
        image = (
            '<div class="missing portrait-absent">Aucune photographie individuelle authentifiée '
            'n’a été retrouvée dans la source consultée.</div>'
        )
    documentation = (
        f'<aside class="{credit_class}" aria-label="Source et droits de la photographie">'
        f'<strong>Source de la photographie :</strong> '
        + (f'<a href="{escape(result["source_page"] or "", quote=True)}" target="_blank" rel="noopener noreferrer">Mémoire Vive</a>. ' if result.get("source_page") else "notice non retrouvée. ")
        + f'<strong>Statut des droits :</strong> {escape(result.get("rights_status") or "aucune photographie publiée")}.'
        + '</aside>'
    )
    content = re.sub(r"(?is)<aside\b[^>]*class=[\"']photo-documentation[\"'][^>]*>.*?</aside>", "", content)
    # Retire l'ancien premier portrait, y compris dans les anciens modèles où
    # l'image n'était pas enveloppée dans une balise figure.
    content, count = re.subn(r"(?is)<figure\b[^>]*>.*?</figure>", image, content, count=1)
    if not count:
        content, count = re.subn(r"(?is)<div\b[^>]*class=[\"'][^\"']*\bmissing\b[^\"']*[\"'][^>]*>.*?</div>", image, content, count=1)
    if not count:
        content, count = re.subn(
            r"(?is)<img\b[^>]*class=[\"'][^\"']*\bphoto\b[^\"']*[\"'][^>]*>\s*"
            r"(?:<div\b[^>]*class=[\"'][^\"']*\bcaption\b[^\"']*[\"'][^>]*>.*?</div>)?",
            image,
            content,
            count=1,
        )
    if not count:
        content = re.sub(r"(?is)(<article\b)", image + r"\1", content, count=1)
    if image not in content:
        content = re.sub(
            r"(?is)(<div\b[^>]*class=[\"'][^\"']*\btext\b[^\"']*[\"'][^>]*>)",
            image + r"\1",
            content,
            count=1,
        )
    if image not in content:
        raise RuntimeError(f"Point d'insertion du portrait introuvable dans {path.name}")
    content = content.replace(image, image + documentation, 1)
    style = (
        ".portrait-documente{text-align:center}.photo-documentation{max-width:760px;margin:0 auto 24px;"
        "padding:12px 14px;border-left:3px solid #c4a25a;background:#151515;color:#cfcfcf;font:14px/1.55 Arial,sans-serif}"
        ".photo-documentation a{color:#e0bd72}.portrait-absent{max-width:700px;margin:28px auto 12px}"
    )
    if style not in content:
        content = content.replace("</style>", style + "</style>", 1)
    if content != old:
        path.write_text(content, encoding="utf-8")
        return True
    return False


def document_existing_photo(path: Path) -> bool:
    content = path.read_text(encoding="utf-8", errors="replace")
    old = content
    documentation = (
        '<aside class="photo-documentation" aria-label="Source et droits de la photographie">'
        '<strong>Source de la photographie :</strong> archive figurant dans la fiche d’origine. '
        '<strong>Statut des droits :</strong> licence ou titulaire non indiqué ; réutilisation à vérifier.'
        '</aside>'
    )
    content = re.sub(
        r"(?is)<aside\b[^>]*class=[\"']photo-documentation[\"'][^>]*>.*?</aside>",
        "",
        content,
    )
    content, count = re.subn(r"(?is)(<figure\b[^>]*>.*?</figure>)", r"\1" + documentation, content, count=1)
    if not count:
        content, count = re.subn(
            r"(?is)(<img\b[^>]*class=[\"'][^\"']*\bphoto\b[^\"']*[\"'][^>]*>\s*"
            r"(?:<div\b[^>]*class=[\"'][^\"']*\bcaption\b[^\"']*[\"'][^>]*>.*?</div>)?)",
            r"\1" + documentation,
            content,
            count=1,
        )
    if not count:
        raise RuntimeError(f"Portrait existant introuvable dans {path.name}")
    if content != old:
        path.write_text(content, encoding="utf-8")
        return True
    return False


def main() -> int:
    arguments = argparse.ArgumentParser(description=__doc__)
    arguments.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    arguments.add_argument("--workers", type=int, default=10)
    arguments.add_argument("--apply", action="store_true")
    arguments.add_argument("--resume", action="store_true", help="Ne relance que les notices précédemment en erreur")
    args = arguments.parse_args()

    records = json.loads((args.root / "site-data.json").read_text(encoding="utf-8"))
    women = [row for row in records if row.get("group") == "femmes" and unquote(row["file"]) != "convoi-des-31000.html"]
    by_number, _ = source_links()
    output = args.root / "sources" / "portraits-femmes-droits.json"
    previous: dict[str, dict] = {}
    if args.resume and output.is_file():
        old_manifest = json.loads(output.read_text(encoding="utf-8"))
        previous = {
            row["file"]: row
            for row in old_manifest.get("records", [])
            if not row.get("state", "").startswith("erreur")
        }
    results: list[dict] = list(previous.values())
    pending = [record for record in women if unquote(record["file"]) not in previous]
    with ThreadPoolExecutor(max_workers=args.workers) as pool:
        futures = {pool.submit(inspect_source, record, by_number): record for record in pending}
        for index, future in enumerate(as_completed(futures), 1):
            record = futures[future]
            try:
                results.append(future.result())
            except Exception as error:
                results.append({
                    "name": record["name"], "file": unquote(record["file"]), "matricule": record.get("matricule"),
                    "source_page": by_number.get(str(record.get("matricule") or "")), "source_image": None,
                    "credit": None, "rights_status": None, "selection_score": None,
                    "selection_reasons": [], "state": f"erreur : {error}",
                })
            if index % 25 == 0:
                print(f"Notices contrôlées : {index}/{len(pending)}", flush=True)

    results.sort(key=lambda row: normalized(row["name"]))
    for row in results:
        image_url = (row.get("source_image") or "").casefold()
        rejected_reason = MANUAL_REJECTIONS.get(row["file"])
        unsafe_credit = normalized(row.get("credit") or "")
        if "31000anonyme" in image_url or rejected_reason or "identification incertaine" in unsafe_credit or "hypothetique" in unsafe_credit:
            row.update(
                {
                    "source_image": None,
                    "credit": None,
                    "rights_status": None,
                    "selection_score": None,
                    "selection_reasons": [rejected_reason or "identification ou image générique non suffisamment certaine"],
                    "state": "aucun portrait suffisamment certain",
                }
            )
        if row["file"] in PRESERVE_EXISTING and not row.get("source_image"):
            row.update(
                {
                    "credit": "Archive figurant dans la fiche d’origine",
                    "rights_status": "Licence ou titulaire non indiqué ; réutilisation à vérifier",
                    "selection_score": None,
                    "selection_reasons": ["portrait existant conservé après contrôle visuel"],
                    "state": "portrait existant conservé",
                }
            )
    changed = 0
    if args.apply:
        downloadable = [row for row in results if row.get("source_image")]
        images: dict[str, tuple[bytes, str] | None] = {}
        with ThreadPoolExecutor(max_workers=args.workers) as pool:
            futures = {pool.submit(fetch_bytes, row["source_image"]): row["source_image"] for row in downloadable}
            for index, future in enumerate(as_completed(futures), 1):
                url = futures[future]
                try:
                    images[url] = future.result()
                except Exception:
                    images[url] = None
                if index % 25 == 0:
                    print(f"Images téléchargées : {index}/{len(downloadable)}", flush=True)
        for row in results:
            path = args.root / row["file"]
            if row["file"] in PRESERVE_EXISTING and not row.get("source_image"):
                if path.is_file() and document_existing_photo(path):
                    changed += 1
                continue
            if path.is_file() and replace_photo(path, row, images.get(row.get("source_image"))):
                changed += 1

    manifest = {
        "source": SOURCE_ROOT,
        "checked_on": date.today().isoformat(),
        "method": "Correspondance par matricule, puis sélection du portrait par nom, matricule et légende ; exclusions des images contextuelles.",
        "rights_note": "Une attribution n'est pas une licence. Quand la source ne précise pas la licence ou le titulaire des droits, le statut reste à vérifier.",
        "count": len(results),
        "records": results,
    }
    output.write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    counts: dict[str, int] = {}
    for row in results:
        counts[row["state"]] = counts.get(row["state"], 0) + 1
    print(json.dumps({"women": len(women), "changed": changed, "states": counts, "manifest": str(output)}, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

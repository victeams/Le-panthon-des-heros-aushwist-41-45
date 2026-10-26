#!/usr/bin/env python3
"""Contrôle en lecture seule des liens internes, ancres et pages HTML du mémorial."""
from __future__ import annotations

import csv
import html
import re
import sys
from collections import defaultdict
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parents[1]
SITE_HOSTS = {"memoiredesdeportes.fr", "www.memoiredesdeportes.fr"}
SKIP_DIRS = {".git", ".github", "scripts", "tests", "portraits", "data", "assets"}
OUT = Path("rapport-liens")
PAGE_EXTENSIONS = {".html", ".htm"}


class LinkParser(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.links = []
        self.anchors = set()

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if attrs.get("id"):
            self.anchors.add(attrs["id"])
        if tag == "a" and attrs.get("name"):
            self.anchors.add(attrs["name"])
        if tag in {"a", "area", "link"} and attrs.get("href"):
            self.links.append(("lien", attrs["href"].strip()))
        if tag in {"img", "script", "iframe", "source", "video", "audio"}:
            value = attrs.get("src") or attrs.get("poster")
            if value:
                self.links.append(("ressource", value.strip()))
        if tag == "object" and attrs.get("data"):
            self.links.append(("ressource", attrs["data"].strip()))


def html_pages():
    result = []
    for path in ROOT.rglob("*"):
        if not path.is_file() or path.suffix.lower() not in PAGE_EXTENSIONS:
            continue
        if any(part in SKIP_DIRS for part in path.relative_to(ROOT).parts):
            continue
        if path.name.lower().startswith("google"):
            continue
        result.append(path)
    return sorted(result)


def parse_pages(pages):
    parsed = {}
    for page in pages:
        try:
            text = page.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        parser = LinkParser()
        parser.feed(text)
        parsed[page.resolve()] = (parser, text)
    return parsed


def local_target(source_page: Path, raw_url: str):
    raw_url = html.unescape(raw_url.strip())
    if not raw_url or raw_url.startswith(("#", "data:", "mailto:", "tel:", "javascript:", "blob:")):
        return None, "", ""
    parts = urlsplit(raw_url)
    if parts.scheme and parts.scheme.lower() not in {"http", "https"}:
        return None, "", ""
    if parts.netloc and parts.hostname and parts.hostname.lower() not in SITE_HOSTS:
        return None, "", ""
    if parts.netloc and parts.hostname and parts.hostname.lower() in SITE_HOSTS:
        path = unquote(parts.path or "/").lstrip("/")
        target = (ROOT / path) if path else (ROOT / "index.html")
    elif raw_url.startswith("//"):
        return None, "", ""
    elif parts.scheme in {"http", "https"}:
        # An absolute external URL has already been excluded above.
        target = None
    elif parts.path.startswith("/"):
        target = ROOT / unquote(parts.path.lstrip("/"))
    else:
        target = source_page.parent / unquote(parts.path)
    if target is None:
        return None, "", ""
    if target.is_dir():
        target = target / "index.html"
    elif not target.suffix and not parts.path.endswith("/"):
        # GitHub Pages may resolve extensionless URLs to an HTML page.
        if target.with_suffix(".html").is_file():
            target = target.with_suffix(".html")
        elif (target / "index.html").is_file():
            target = target / "index.html"
    try:
        target = target.resolve()
        target.relative_to(ROOT.resolve())
    except (OSError, ValueError):
        return None, "", ""
    return target, unquote(parts.fragment), parts.path


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    pages = html_pages()
    parsed = parse_pages(pages)
    issues = []
    checked_links = 0
    for page in pages:
        key = page.resolve()
        if key not in parsed:
            continue
        parser, _ = parsed[key]
        rel_page = page.relative_to(ROOT).as_posix()
        for kind, url in parser.links:
            target, fragment, path_part = local_target(page, url)
            if target is None:
                continue
            checked_links += 1
            if not target.exists() or not target.is_file():
                issues.append({
                    "type": "page_absente" if kind == "lien" else "ressource_absente",
                    "page_source": rel_page, "url": url, "cible": target.relative_to(ROOT).as_posix(),
                    "detail": "Le fichier cible n'existe pas",
                })
                continue
            if fragment and target.suffix.lower() in PAGE_EXTENSIONS and target.resolve() in parsed:
                target_parser, _ = parsed[target.resolve()]
                if fragment not in target_parser.anchors:
                    issues.append({
                        "type": "ancre_absente", "page_source": rel_page, "url": url,
                        "cible": target.relative_to(ROOT).as_posix(),
                        "detail": f"Le fragment #{fragment} n'existe pas dans la page cible",
                    })

    csv_path = OUT / "anomalies-liens.csv"
    with csv_path.open("w", newline="", encoding="utf-8-sig") as handle:
        writer = csv.DictWriter(handle, fieldnames=["type", "page_source", "url", "cible", "detail"])
        writer.writeheader()
        writer.writerows(issues)

    counts = defaultdict(int)
    for item in issues:
        counts[item["type"]] += 1
    report = [
        "# Rapport automatique — liens et pages du mémorial", "",
        f"- Pages HTML analysées : **{len(parsed)}**",
        f"- Liens internes et ressources locales contrôlés : **{checked_links}**",
        f"- Anomalies détectées : **{len(issues)}**",
        f"- Pages/ressources absentes : **{counts['page_absente'] + counts['ressource_absente']}**",
        f"- Ancres manquantes : **{counts['ancre_absente']}**", "",
    ]
    if issues:
        report.append("## Anomalies à vérifier")
        for item in issues[:500]:
            report.append(f"- **{item['type']}** — page `{item['page_source']}` — URL `{item['url']}` — cible `{item['cible']}` — {item['detail']}")
        if len(issues) > 500:
            report.append(f"- … {len(issues) - 500} anomalie(s) supplémentaire(s), détaillées dans le CSV.")
    else:
        report.append("Aucun lien interne cassé, fichier local absent ou fragment manquant détecté.")
    report.extend(["", "> Rapport de signalement uniquement : aucune page, photo ou donnée du site n'est modifiée."])
    (OUT / "rapport.md").write_text("\n".join(report) + "\n", encoding="utf-8")
    print("\n".join(report))
    print(f"\nCSV détaillé : {csv_path}")
    # The report is informational. Findings do not fail the scheduled workflow.
    return 0


if __name__ == "__main__":
    sys.exit(main())

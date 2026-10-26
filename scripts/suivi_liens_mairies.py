#!/usr/bin/env python3
"""Vérifie périodiquement que les pages de mairies suivies conservent un lien vers le mémorial."""
from __future__ import annotations

import csv
import html
import re
import urllib.error
import urllib.request
from datetime import datetime, timezone
from pathlib import Path
from html.parser import HTMLParser

ROOT = Path(__file__).resolve().parents[1]
INPUT = ROOT / "data" / "suivi-liens-mairies.csv"
OUT = ROOT / "rapport-mairies"
OUT.mkdir(parents=True, exist_ok=True)
DOMAIN = "memoiredesdeportes.fr"
USER_AGENT = "MemoireDesDeportes-LinkMonitor/1.0 (+https://memoiredesdeportes.fr/)"
TIMEOUT = 20


class LinkParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.links = []

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag.lower() in {"a", "area"} and attrs.get("href"):
            self.links.append(html.unescape(attrs["href"]))


def check_page(url: str) -> tuple[str, str, str]:
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    try:
        with urllib.request.urlopen(request, timeout=TIMEOUT) as response:
            status = str(response.status)
            final_url = response.geturl()
            content_type = response.headers.get("Content-Type", "")
            if "html" not in content_type.lower():
                return status, "À vérifier (réponse non HTML)", final_url
            raw = response.read(3_000_000)
            charset = response.headers.get_content_charset() or "utf-8"
            try:
                page = raw.decode(charset, errors="replace")
            except LookupError:
                page = raw.decode("utf-8", errors="replace")
            parser = LinkParser()
            parser.feed(page)
            for href in parser.links:
                if DOMAIN in href.lower():
                    return status, "Lien trouvé", final_url
            return status, "Lien absent", final_url
    except urllib.error.HTTPError as exc:
        return str(exc.code), "Erreur HTTP", url
    except (urllib.error.URLError, TimeoutError, OSError, ValueError) as exc:
        reason = getattr(exc, "reason", exc)
        return "—", f"Accès impossible: {str(reason)[:120]}", url


def main() -> None:
    rows = []
    if INPUT.exists():
        with INPUT.open(encoding="utf-8-sig", newline="") as f:
            for row in csv.DictReader(f):
                commune = (row.get("commune") or "").strip()
                url = (row.get("url_page_mairie") or "").strip()
                notes = (row.get("notes") or "").strip()
                if not commune and not url:
                    continue
                if not url or not url.startswith(("https://", "http://")):
                    rows.append({"commune": commune, "url_page_mairie": url, "statut_http": "—", "résultat": "URL à compléter", "url_finale": url, "notes": notes})
                    continue
                status, result, final_url = check_page(url)
                rows.append({"commune": commune, "url_page_mairie": url, "statut_http": status, "résultat": result, "url_finale": final_url, "notes": notes})

    csv_path = OUT / "suivi-liens-mairies.csv"
    fields = ["commune", "url_page_mairie", "statut_http", "résultat", "url_finale", "notes"]
    with csv_path.open("w", encoding="utf-8-sig", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fields)
        writer.writeheader()
        writer.writerows(rows)

    found = sum(r["résultat"] == "Lien trouvé" for r in rows)
    absent = sum(r["résultat"] == "Lien absent" for r in rows)
    errors = sum(r["résultat"] in {"Erreur HTTP"} or r["résultat"].startswith("Accès impossible") for r in rows)
    missing = sum(r["résultat"] == "URL à compléter" for r in rows)
    now = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    report = [
        "# Suivi des liens des mairies",
        "",
        f"Contrôle effectué : **{now}**",
        "",
        f"- Pages suivies : **{len(rows)}**",
        f"- Lien vers {DOMAIN} trouvé : **{found}**",
        f"- Lien non détecté : **{absent}**",
        f"- Pages inaccessibles ou erreurs HTTP : **{errors}**",
        f"- URL à compléter : **{missing}**",
        "",
        "## Résultats",
        "",
        "| Commune | Résultat | HTTP | Page contrôlée |",
        "|---|---|---:|---|",
    ]
    if rows:
        for r in rows:
            commune = r["commune"].replace("|", "\\|")
            result = r["résultat"].replace("|", "\\|")
            url = r["url_finale"].replace("|", "%7C")
            report.append(f"| {commune} | {result} | {r['statut_http']} | {url} |")
    else:
        report += [
            "| Aucune commune configurée | — | — | — |",
            "",
            "Ajoutez les pages exactes des mairies dans `data/suivi-liens-mairies.csv` puis relancez le workflow.",
        ]
    report += [
        "",
        "## À savoir",
        "",
        "- Ce contrôle vérifie seulement les URL saisies dans le fichier CSV : il ne découvre pas automatiquement de nouveaux backlinks.",
        "- « Lien absent » signifie que le lien n'a pas été trouvé dans le HTML reçu ; un site qui bloque les robots ou construit ses liens en JavaScript peut nécessiter une vérification manuelle.",
        "- Ce contrôle est en lecture seule : il ne modifie aucune page du site et n'envoie aucun message aux mairies.",
        "",
    ]
    (OUT / "rapport.md").write_text("\n".join(report), encoding="utf-8")
    print("\n".join(report))


if __name__ == "__main__":
    main()

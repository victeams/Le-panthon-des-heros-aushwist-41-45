#!/usr/bin/env python3
"""Inventaire exploratoire des lieux cités dans les biographies, sans publication."""
from __future__ import annotations
import csv, html, re
from collections import Counter
from html.parser import HTMLParser
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "rapport-communes"
SKIP_DIRS = {".git", ".github", "scripts", "tests", "portraits", "data", "assets", "enfants"}
EXCLUDED = {"index.html", "hommes.html", "femmes.html", "photos.html", "contact.html",
            "404.html", "sitemap.html", "tiktok.html", "mairies-partenaires.html",
            "a-propos.html", "base-documentaire.html"}
PLACE_RE = re.compile(
    r"\b(?:né[e]?\s+à|naît\s+à|naissance\s+à|originaire\s+de|demeurant\s+à|habitant\s+à|résidant\s+à)\s+"
    r"([A-ZÀ-Ö][A-Za-zÀ-ÿ'’.-]*(?:[ -][A-ZÀ-Ö][A-Za-zÀ-ÿ'’.-]*){0,4})"
    r"\s*\(([^)]{0,100}\b\d{2,3}\b[^)]*)\)", re.IGNORECASE)

class TextExtractor(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.parts, self.skip = [], 0
    def handle_starttag(self, tag, attrs):
        if tag in {"script", "style", "nav", "footer", "header"}: self.skip += 1
    def handle_endtag(self, tag):
        if tag in {"script", "style", "nav", "footer", "header"} and self.skip: self.skip -= 1
    def handle_data(self, data):
        if not self.skip: self.parts.append(data)

def main():
    OUT.mkdir(parents=True, exist_ok=True)
    candidates, scanned = {}, 0
    for path in ROOT.rglob("*.html"):
        rel = path.relative_to(ROOT)
        if any(part in SKIP_DIRS for part in rel.parts) or path.name.lower() in EXCLUDED: continue
        if path.name.lower().startswith("google") or path.stat().st_size < 500: continue
        try: source = path.read_text(encoding="utf-8", errors="replace")
        except OSError: continue
        if not re.search(r"<h1\b", source, re.I) or not re.search(r"(?<!\d)(?:31|45|46)\d{3}(?!\d)", path.stem + " " + source): continue
        scanned += 1
        parser = TextExtractor(); parser.feed(source)
        text = re.sub(r"\s+", " ", html.unescape(" ".join(parser.parts)))
        for match in PLACE_RE.finditer(text):
            place = re.sub(r"\s+", " ", match.group(1)).strip(" ,.;")
            context = re.sub(r"\s+", " ", match.group(2)).strip()
            key = (place.casefold(), context.casefold())
            row = candidates.setdefault(key, {"commune": place, "context": context, "sources": set()})
            row["sources"].add(rel.as_posix())
    rows = [{"commune_candidate": x["commune"], "contexte_departemental": x["context"],
             "nombre_fiches": len(x["sources"]), "fiches_sources": "; ".join(sorted(x["sources"])),
             "statut": "À vérifier manuellement"} for x in candidates.values()]
    rows.sort(key=lambda r: (r["commune_candidate"].casefold(), r["contexte_departemental"].casefold()))
    with (OUT / "communes-candidates.csv").open("w", newline="", encoding="utf-8-sig") as f:
        w = csv.DictWriter(f, fieldnames=["commune_candidate", "contexte_departemental", "nombre_fiches", "fiches_sources", "statut"])
        w.writeheader(); w.writerows(rows)
    distinct = len(Counter(x["commune_candidate"] for x in rows))
    report = ["# Inventaire exploratoire des communes", "",
              f"- Fiches biographiques examinées : **{scanned}**",
              f"- Candidats de lieux relevés : **{len(rows)}**",
              f"- Noms de communes distincts (candidats) : **{distinct}**", "",
              "Cet inventaire est une aide au repérage, pas une source historique validée. Les lieux doivent être vérifiés à partir des fiches et de sources documentaires.",
              "Aucune biographie ni page publiée n'est créée ou modifiée.", "",
              "Le fichier communes-candidates.csv contient les candidats et leurs fiches sources.", ""]
    if rows:
        report += ["## Premiers candidats", "", "| Commune candidate | Contexte | Fiches |", "|---|---|---:|"]
        report += [f"| {x['commune_candidate']} | {x['contexte_departemental']} | {x['nombre_fiches']} |" for x in rows[:100]]
        if len(rows) > 100: report += ["", f"{len(rows)-100} autres candidats sont disponibles dans le CSV."]
    else: report += ["Aucun candidat n'a été extrait avec les règles actuelles. Le rapport reste valide et aucune donnée n'a été publiée."]
    (OUT / "rapport.md").write_text("\n".join(report) + "\n", encoding="utf-8")
    print("\n".join(report))
if __name__ == "__main__": main()

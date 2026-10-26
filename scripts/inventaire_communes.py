#!/usr/bin/env python3
"""Construit un inventaire exploratoire des communes mentionnées dans les biographies.

Les lieux sont des candidats extraits du texte, jamais des faits validés. Le script
ne modifie aucune page du site et ne crée aucune page publiée.
"""
from __future__ import annotations

import csv
import html
import re
from collections import defaultdict
from html.parser import HTMLParser
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = Path("rapport-communes")
# Motif volontairement conservateur : un nom de lieu proche d'une parenthèse
# contenant un code départemental. Chaque occurrence reste à vérifier.
PLACE_RE = re.compile(
    r"\b(?:à|de|dans la commune de|sur la commune de|né[e]? à|naît à)\s+"
    r"([A-ZÀ-Ö][A-Za-zÀ-ÿ'’.-]*(?:[ -][A-ZÀ-Ö][A-Za-zÀ-ÿ'’.-]*){0,4})"
    r"\s*\(([^)]{0,100}\b\d{2,3}\b[^)]*)\)",
    re.IGNORECASE,
)
SKIP_DIRS = {".git", ".github", "scripts", "tests", "portraits", "data", "assets", "enfants", "hommes", "femmes"}

class Parser(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.in_h1 = False
        self.in_p = False
        self.in_script = False
        self.title = []
        self.paragraph = []
        self.paragraphs = []
    def handle_starttag(self, tag, attrs):
        tag = tag.lower()
        if tag == "script" or tag == "style":
            self.in_script = True
        if tag == "h1":
            self.in_h1 = True
        if tag == "p":
            self.in_p = True
            self.paragraph = []
    def handle_endtag(self, tag):
        tag = tag.lower()
        if tag in {"script", "style"}:
            self.in_script = False
        if tag == "h1":
            self.in_h1 = False
        if tag == "p" and self.in_p:
            value = clean(" ".join(self.paragraph))
            if value:
                self.paragraphs.append(value)
            self.in_p = False
    def handle_data(self, data):
        if self.in_script:
            return
        if self.in_h1:
            self.title.append(data)
        if self.in_p:
            self.paragraph.append(data)

def clean(value: str) -> str:
    return re.sub(r"\s+", " ", html.unescape(value)).strip()

def biography_files():
    for path in ROOT.rglob("*.html"):
        if any(part in SKIP_DIRS for part in path.relative_to(ROOT).parts[:-1]):
            continue
        if path.name in {"index.html", "femmes.html", "hommes.html", "mairies.html", "mairies-partenaires.html", "base-documentaire.html", "photos.html", "tiktok.html", "a-propos.html", "contact.html"}:
            continue
        # Exclure les pages d'interface évidentes et garder les fiches contenant un H1.
        yield path

def main():
    OUT.mkdir(parents=True, exist_ok=True)
    grouped = defaultdict(list)
    total_profiles = 0
    profiles_with_candidates = 0
    for path in sorted(biography_files()):
        try:
            source = path.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        parser = Parser()
        parser.feed(source)
        name = clean(" ".join(parser.title)) or path.stem
        if not parser.paragraphs:
            continue
        total_profiles += 1
        found_here = set()
        for paragraph in parser.paragraphs:
            for match in PLACE_RE.finditer(paragraph):
                place = clean(match.group(1)).strip(" .,:;")
                context = paragraph[max(0, match.start()-100):min(len(paragraph), match.end()+100)]
                # Ignore generic false positives caused by capitalized sentence starts.
                if len(place) < 2 or len(place.split()) > 5:
                    continue
                key = place.casefold()
                found_here.add(key)
                grouped[key].append({
                    "lieu_candidat": place,
                    "nom": name,
                    "fichier": path.relative_to(ROOT).as_posix(),
                    "url": "https://memoiredesdeportes.fr/" + path.relative_to(ROOT).as_posix(),
                    "indice_departement": clean(match.group(2)),
                    "extrait": context,
                })
        if found_here:
            profiles_with_candidates += 1

    rows = []
    for key in sorted(grouped):
        # Preserve the first spelling and keep each biography/occurrence distinct.
        for item in grouped[key]:
            rows.append(item)
    csv_path = OUT / "inventaire-candidats-communes.csv"
    with csv_path.open("w", newline="", encoding="utf-8-sig") as f:
        writer = csv.DictWriter(f, fieldnames=["lieu_candidat","indice_departement","nom","fichier","url","extrait"])
        writer.writeheader()
        writer.writerows(rows)

    lines = [
        "# Inventaire exploratoire des communes",
        "",
        "> **Brouillon de travail uniquement.** Les lieux sont extraits automatiquement de formulations présentes dans les fiches. Ils peuvent être ambigus, historiques ou mal reconnus : vérifier chaque ligne dans la source avant de créer une page publique. Aucune page du site n'est modifiée.",
        "",
        f"- Fiches HTML parcourues : **{total_profiles}**",
        f"- Fiches avec au moins un lieu candidat : **{profiles_with_candidates}**",
        f"- Occurrences de lieux candidates : **{len(rows)}**",
        f"- Noms de lieux candidats distincts (comparaison insensible à la casse) : **{len(grouped)}**",
        "",
        "## Candidats les plus souvent mentionnés",
        "",
        "| Lieu candidat (non vérifié) | Occurrences |",
        "|---|---:|",
    ]
    for key, items in sorted(grouped.items(), key=lambda item: (-len(item[1]), item[0]))[:100]:
        lines.append(f"| {items[0]['lieu_candidat'].replace('|', ' ')} | {len(items)} |")
    lines += ["", "Le fichier CSV contient les liens des fiches et les extraits permettant de contrôler chaque occurrence.", ""]
    (OUT / "rapport.md").write_text("\n".join(lines), encoding="utf-8")

    # Pages HTML de prévisualisation : livrées comme artefact GitHub Actions seulement.
    cards = []
    for key, items in sorted(grouped.items()):
        place = items[0]["lieu_candidat"]
        entries = "".join(
            '<li><a href="' + html.escape(item["url"], quote=True) + '">' +
            html.escape(item["nom"]) + '</a><p><strong>Indice à vérifier :</strong> ' +
            html.escape(item["indice_departement"]) + '</p><blockquote>' +
            html.escape(item["extrait"]) + '</blockquote></li>'
            for item in items
        )
        cards.append(f'<section><h2>{html.escape(place)}</h2><p class="notice">Lieu candidat extrait automatiquement — non vérifié, ne pas publier tel quel.</p><ul>{entries}</ul></section>')
    document = """<!doctype html><html lang="fr"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Prévisualisation — lieux candidats</title><style>body{font:16px/1.6 system-ui;max-width:1000px;margin:auto;padding:24px;background:#111;color:#eee}section{padding:18px;margin:18px 0;border:1px solid #555;border-radius:10px}a{color:#f0cb80}.notice{color:#ffd18a;font-weight:bold}blockquote{border-left:3px solid #777;padding-left:12px;color:#ccc}</style><h1>Prévisualisation des lieux candidats</h1><p><strong>Document de travail non publié sur le site.</strong> Les noms de lieux sont des candidats automatiques, pas des données historiques validées. Vérifier les fiches et les sources avant toute création de page publique.</p>""" + "".join(cards) + "</html>"
    (OUT / "previsualisation-communes.html").write_text(document, encoding="utf-8")
    print(f"Inventaire terminé : {total_profiles} fiches, {len(rows)} occurrences candidates, {len(grouped)} libellés candidats.")
    print("Aucune page publiée n'a été modifiée.")
    print(f"Fichiers produits : {OUT}/rapport.md, {OUT}/inventaire-candidats-communes.csv, {OUT}/previsualisation-communes.html")

if __name__ == "__main__":
    main()

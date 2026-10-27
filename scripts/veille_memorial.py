#!/usr/bin/env python3
"""Veille consolidée du mémorial : rapports uniquement, aucune page publiée modifiée."""
from __future__ import annotations
import csv, html, json, re
from collections import defaultdict
from datetime import datetime, timezone
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "rapports" / "veille-memorial"
PROFILE_DIRS = {"hommes", "femmes"}
SOURCE_FILES = ("sources/deportes-politiques-auschwitz-portraits.json", "sources/portraits-femmes-droits.json")
SKIP_PARTS = {".git", ".github", "scripts", "tests", "portraits", "data", "rapports"}
EXTERNAL = ("http:", "https:", "//", "data:", "blob:", "javascript:", "mailto:", "tel:")

class Parser(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.h1_depth = 0
        self.h1, self.text, self.images = [], [], []
    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        if tag == "h1": self.h1_depth += 1
        if tag == "img": self.images.append((a.get("src", "").strip(), a.get("alt", "").strip()))
    def handle_endtag(self, tag):
        if tag == "h1" and self.h1_depth: self.h1_depth -= 1
    def handle_data(self, data):
        self.text.append(data)
        if self.h1_depth: self.h1.append(data)

def clean(s):
    return re.sub(r"\s+", " ", html.unescape(s)).strip()

def read_json(rel):
    try: return json.loads((ROOT / rel).read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError): return None

def records(data):
    if not isinstance(data, dict): return []
    for key in ("portraits", "records", "people", "items"):
        if isinstance(data.get(key), list): return data[key]
    return []

def write_csv(name, rows, fields):
    with (OUT / name).open("w", encoding="utf-8-sig", newline="") as f:
        w = csv.DictWriter(f, fieldnames=fields, extrasaction="ignore")
        w.writeheader(); w.writerows(rows)

def main():
    OUT.mkdir(parents=True, exist_ok=True)
    pages = []
    for p in ROOT.rglob("*.html"):
        if p.is_file() and not any(x in SKIP_PARTS for x in p.relative_to(ROOT).parts):
            pages.append(p)
    known_mats, duplicate_map, incomplete, photo_issues = set(), defaultdict(list), [], []
    for path in sorted(pages):
        rel = path.relative_to(ROOT).as_posix()
        raw = path.read_text(encoding="utf-8", errors="replace")
        parser = Parser(); parser.feed(raw)
        title = clean(" ".join(parser.h1))
        mats = re.findall(r"(?i)(?:matricule\s*[:#-]?\s*|\b)(\d{5})(?!\d)", clean(" ".join(parser.text)))
        mat = mats[0] if mats else ""
        if title and mat:
            known_mats.add(mat)
            # Les pages racine et les copies hommes/femmes peuvent être volontaires.
            if path.parent == ROOT:
                duplicate_map[mat].append((rel, title))
        if path.parent == ROOT or path.parent.name in PROFILE_DIRS:
            if not title or not mat:
                missing = []
                if not title: missing.append("titre H1 non détecté")
                if not mat: missing.append("matricule non détecté")
                incomplete.append({"page": rel, "titre": title, "matricule": mat, "probleme": "; ".join(missing)})
        for src, alt in parser.images:
            if not src:
                photo_issues.append({"page": rel, "image": "", "probleme": "src vide"}); continue
            if src.startswith(EXTERNAL):
                if not alt: photo_issues.append({"page": rel, "image": src, "probleme": "attribut alt absent"})
                continue
            target = (path.parent / unquote(urlsplit(src).path)).resolve()
            try: target.relative_to(ROOT.resolve())
            except ValueError:
                photo_issues.append({"page": rel, "image": src, "probleme": "chemin hors du dépôt"}); continue
            if not target.is_file(): photo_issues.append({"page": rel, "image": src, "probleme": "fichier local absent"})
            elif not alt: photo_issues.append({"page": rel, "image": src, "probleme": "attribut alt absent"})
    duplicates = {m: rows for m, rows in duplicate_map.items() if len(rows) > 1}
    candidates, source_errors = [], []
    for source in SOURCE_FILES:
        data = read_json(source)
        if data is None:
            source_errors.append("Catalogue illisible : " + source); continue
        for rec in records(data):
            if not isinstance(rec, dict): continue
            name = str(rec.get("name") or rec.get("nom") or "").strip()
            mat = str(rec.get("matricule") or "").strip()
            target = str(rec.get("biography") or rec.get("file") or rec.get("local_page") or "").strip()
            if name and not ((target and (ROOT / target).is_file()) or (mat and mat in known_mats)):
                candidates.append({"nom": name, "matricule": mat, "catalogue": source,
                    "page_locale_indiquee": target,
                    "source_historique": str(rec.get("source_page") or rec.get("source") or ""),
                    "etat": "Candidat à vérifier — absence non confirmée"})
    unique, seen = [], set()
    for row in candidates:
        key = (re.sub(r"\W+", "", row["nom"].casefold()), row["matricule"])
        if key not in seen: seen.add(key); unique.append(row)
    candidates = unique
    write_csv("candidats-a-verifier.csv", candidates, ["nom","matricule","catalogue","page_locale_indiquee","source_historique","etat"])
    write_csv("portraits-a-controler.csv", incomplete, ["page","titre","matricule","probleme"])
    write_csv("photos-a-controler.csv", photo_issues, ["page","image","probleme"])
    report = [
        "# Veille automatique — Mémoire des Déportés", "",
        "Rapport généré : " + datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC"), "",
        "> Lecture seule : aucune biographie, photo, catalogue ou page publiée n'est modifié.", "",
        "## Résumé", "",
        "- Pages HTML inspectées : **" + str(len(pages)) + "**",
        "- Matricules détectés : **" + str(len(known_mats)) + "**",
        "- Candidats issus des catalogues locaux à vérifier : **" + str(len(candidates)) + "**",
        "- Pages de portraits à examiner : **" + str(len(incomplete)) + "**",
        "- Problèmes d'images / attributs alt : **" + str(len(photo_issues)) + "**",
        "- Matricules répétés à examiner : **" + str(len(duplicates)) + "**", "",
        "## Fichiers produits", "",
        "- candidats-a-verifier.csv : candidats présents dans les catalogues locaux sans correspondance locale confirmée.",
        "- portraits-a-controler.csv : pages sans titre H1 ou matricule détecté.",
        "- photos-a-controler.csv : images locales absentes, chemins douteux ou attribut alt absent.", "",
        "## Candidats à examiner (maximum 100 affichés)", ""
    ]
    if candidates:
        report += ["| Nom source | Matricule | Catalogue | Page source |", "|---|---|---|---|"]
        for row in candidates[:100]:
            vals = [row["nom"], row["matricule"] or "non indiqué", row["catalogue"], row["source_historique"] or "non indiquée"]
            vals = [v.replace("|", "\\|").replace("\n", " ") for v in vals]
            report.append("| " + " | ".join(vals) + " |")
        if len(candidates) > 100: report.append("Autres candidats disponibles dans le CSV.")
    else: report.append("Aucun candidat selon ces critères locaux. Cela ne prouve pas l'exhaustivité du mémorial.")
    report += ["", "## Matricules répétés", ""]
    if duplicates:
        for mat, rows in sorted(duplicates.items()):
            report.append("- **" + mat + "** : " + "; ".join(p + " (" + t + ")" for p,t in rows))
    else: report.append("Aucun doublon détecté par cette règle.")
    if source_errors: report += ["", "## Sources locales à réparer", ""] + ["- " + x for x in source_errors]
    report += ["", "## Limites", "",
        "- La recherche de candidats compare uniquement les catalogues JSON déjà présents dans le dépôt : elle ne parcourt pas tout Internet.",
        "- Une page manquante ou un matricule répété peut être un faux positif (variantes de noms, structure de page, copies volontaires).",
        "- Les contrôles des liens internes et des liens de mairies restent assurés par les workflows existants.",
        "- Les différences historiques doivent être vérifiées humainement avec des sources fiables.",
        "- Aucune publication ni modification automatique n'est effectuée.", ""]
    (OUT / "rapport.md").write_text("\n".join(report), encoding="utf-8")
    print("\n".join(report))

if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Repère les biographies à enrichir, sans modifier aucune page publiée."""
from __future__ import annotations
from html.parser import HTMLParser
from pathlib import Path
import html
import re
import sys
from urllib.parse import urlparse

ROOT = Path(__file__).resolve().parents[1]
PROFILE_DIRS = ("hommes", "femmes")
NON_PROFILE = {
    "index.html", "femmes.html", "hommes.html", "base-documentaire.html",
    "photos.html", "tiktok.html", "a-propos.html", "mairies-partenaires.html",
    "contact.html", "convoi-des-31000.html", "convoi-des-45000.html",
    "carte-camps.html", "carte-parcours.html", "sitemap.html",
}
MATRICULE_RE = re.compile(r"(?<!\d)(?:31|45|46)\d{3}(?!\d)")

class ProfileParser(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.title_depth = self.h1_depth = self.skip_depth = 0
        self.title_parts, self.h1_parts, self.text_parts = [], [], []
        self.links, self.images, self.meta = [], [], {}
    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag == "title": self.title_depth += 1
        if tag == "h1": self.h1_depth += 1
        if tag in ("script", "style", "noscript"): self.skip_depth += 1
        if tag == "a": self.links.append(attrs.get("href", ""))
        if tag == "img": self.images.append((attrs.get("src", ""), attrs.get("alt", "")))
        if tag == "meta":
            name = (attrs.get("name") or "").lower()
            if name: self.meta[name] = attrs.get("content", "")
    def handle_endtag(self, tag):
        if tag == "title" and self.title_depth: self.title_depth -= 1
        if tag == "h1" and self.h1_depth: self.h1_depth -= 1
        if tag in ("script", "style", "noscript") and self.skip_depth: self.skip_depth -= 1
    def handle_data(self, data):
        if self.skip_depth: return
        value = data.strip()
        if not value: return
        self.text_parts.append(value)
        if self.title_depth: self.title_parts.append(value)
        if self.h1_depth: self.h1_parts.append(value)

def clean(parts):
    return re.sub(r"\s+", " ", html.unescape(" ".join(parts))).strip()

def page_files():
    files = {p for p in ROOT.glob("*.html") if p.name not in NON_PROFILE}
    for name in PROFILE_DIRS:
        folder = ROOT / name
        if folder.is_dir(): files.update(folder.glob("*.html"))
    return sorted(p for p in files if p.is_file())

def parse(path):
    parser = ProfileParser()
    try: parser.feed(path.read_text(encoding="utf-8", errors="replace"))
    except OSError: return None
    title = clean(parser.h1_parts) or clean(parser.title_parts) or path.stem
    text = clean(parser.text_parts)
    identifier_text = f"{path.stem} {text} {parser.meta.get('convoi', '')}"
    match = MATRICULE_RE.search(identifier_text)
    if not parser.h1_parts or not (match or parser.meta.get("convoi")): return None
    signals = []
    if len(text) < 700: signals.append(f"texte court ({len(text)} caractères visibles)")
    source_words = re.search(r"\b(source|sources|bibliographie|archives|référence|références|source photo|crédit photographique)\b", text, re.I)
    external_links = [u for u in parser.links if urlparse(u).scheme in ("http", "https") and urlparse(u).netloc and "memoiredesdeportes.fr" not in urlparse(u).netloc]
    if not source_words and not external_links: signals.append("aucune source externe repérée automatiquement")
    if not re.search(r"\b(naissance|né[e]? le|né[e]? à|naît)\b", text, re.I): signals.append("naissance/date ou lieu de naissance non repéré")
    if not re.search(r"\b(décédé[e]?|mort[e]?|tué[e]?|survivant[e]?|survécu|libéré[e]?|disparu[e]?)\b", text, re.I): signals.append("issue du parcours non repérée")
    if not parser.images: signals.append("aucune image intégrée")
    elif all(not alt.strip() for _, alt in parser.images): signals.append("images sans texte alternatif")
    return title, text, signals, len(external_links), match.group(0) if match else ""

def main():
    candidates, seen = [], set()
    analysed = 0
    for path in page_files():
        parsed = parse(path)
        if not parsed: continue
        title, text, signals, links_count, matricule = parsed
        analysed += 1
        identity = matricule or path.stem.lower()
        if identity in seen: continue
        seen.add(identity)
        if signals: candidates.append((len(signals), title.casefold(), path.relative_to(ROOT).as_posix(), title, signals, links_count, len(text)))
    candidates.sort(key=lambda item: (-item[0], item[1], item[2]))
    print("# Biographies à enrichir — rapport automatique\n")
    print("> Liste indicative basée sur la structure des fichiers. Ces signaux ne prouvent pas qu'une information manque. Aucune donnée historique n'est ajoutée et aucun fichier du site n'est modifié.\n")
    print(f"- Biographies analysées : **{analysed}**")
    print(f"- Fiches présentant au moins un signal : **{len(candidates)}**\n")
    if not candidates: print("Aucune fiche à signaler selon les critères actuels.")
    for _, _, rel, title, signals, links_count, text_len in candidates:
        print(f"## {title}")
        print(f"- Fichier : {rel}")
        print(f"- Texte visible : {text_len} caractères ; liens externes repérés : {links_count}")
        for signal in signals: print(f"- À examiner : {signal}")
        print()
    print("## Méthode et précautions\n")
    print("- Les biographies ne sont jamais réécrites automatiquement.")
    print("- L'absence d'un mot-clé ne signifie pas qu'une information historique est fausse ou absente.")
    print("- Vérifier chaque fait dans une source fiable avant tout enrichissement.")
    return 0

if __name__ == "__main__":
    sys.exit(main())

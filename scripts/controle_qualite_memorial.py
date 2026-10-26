#!/usr/bin/env python3
"""Contrôle qualité en lecture seule des pages biographiques du mémorial."""
from collections import defaultdict
from html.parser import HTMLParser
from pathlib import Path
import html
import re
import sys
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parents[1]
PROFILE_DIRS = ("hommes", "femmes")


class PageParser(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.h1_depth = 0
        self.mat_depth = 0
        self.h1_parts = []
        self.mat_parts = []
        self.images = []

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        classes = (attrs.get("class") or "").lower().split()
        if tag == "h1":
            self.h1_depth += 1
        if "mat" in classes or "matricule" in classes:
            self.mat_depth += 1
        if tag == "img":
            self.images.append((attrs.get("src") or "", attrs.get("alt") or ""))

    def handle_endtag(self, tag):
        if tag == "h1" and self.h1_depth:
            self.h1_depth -= 1
        if self.mat_depth:
            self.mat_depth -= 1

    def handle_data(self, data):
        if self.h1_depth:
            self.h1_parts.append(data)
        if self.mat_depth:
            self.mat_parts.append(data)


def clean(value):
    return re.sub(r"\s+", " ", html.unescape(value)).strip()


def page_files():
    files = set(ROOT.glob("*.html"))
    for directory in PROFILE_DIRS:
        folder = ROOT / directory
        if folder.is_dir():
            files.update(folder.glob("*.html"))
    return sorted(path for path in files if path.is_file())


def parse_page(path):
    parser = PageParser()
    try:
        parser.feed(path.read_text(encoding="utf-8", errors="replace"))
    except OSError:
        return None
    title = clean(" ".join(parser.h1_parts))
    mat_text = clean(" ".join(parser.mat_parts))
    match = re.search(r"(?i)matricule\s*[:#-]?\s*(\d{3,8})|\b(\d{3,8})\b", mat_text)
    matricule = next((group for group in match.groups() if group), "") if match else ""
    return title, matricule, parser.images


def main():
    profiles = []
    image_issues = []
    for path in page_files():
        parsed = parse_page(path)
        if not parsed:
            continue
        title, matricule, images = parsed
        if not title or not matricule:
            continue
        rel = path.relative_to(ROOT).as_posix()
        profiles.append((path, rel, title, matricule))
        for src, alt in images:
            src = src.strip()
            if not src or src.startswith(("data:", "http://", "https://", "//", "blob:")):
                continue
            local_src = unquote(urlsplit(src).path)
            if not local_src:
                continue
            target = (path.parent / local_src).resolve()
            if not target.exists():
                image_issues.append((rel, src, alt or "(sans texte alternatif)"))

    # Les copies sous hommes/ et femmes/ sont volontaires : les doublons
    # de matricule sont donc recherchés uniquement dans les pages à la racine.
    root_by_matricule = defaultdict(list)
    for path, rel, title, matricule in profiles:
        if path.parent == ROOT:
            root_by_matricule[matricule].append((rel, title))
    duplicates = {m: rows for m, rows in root_by_matricule.items() if len(rows) > 1}

    print("# Rapport automatique — contrôle qualité du mémorial\n")
    print(f"- Pages biographiques analysées : **{len(profiles)}**")
    print(f"- Images locales absentes : **{len(image_issues)}**")
    print(f"- Matricules répétés parmi les pages principales : **{len(duplicates)}**\n")
    if image_issues:
        print("## Images locales à vérifier")
        for rel, src, alt in image_issues[:200]:
            print(f"- `{rel}` — image `{src}` — {alt}")
        if len(image_issues) > 200:
            print(f"- … {len(image_issues) - 200} autre(s) anomalie(s) non affichée(s).")
        print()
    if duplicates:
        print("## Matricules répétés à vérifier")
        for matricule, entries in sorted(duplicates.items()):
            details = "; ".join(f"`{rel}` ({title})" for rel, title in entries)
            print(f"- Matricule **{matricule}** : {details}")
        print()
    if not image_issues and not duplicates:
        print("Aucune anomalie de ces deux types détectée.")
    print("\n> Rapport de signalement uniquement : aucune page publiée n'est modifiée.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

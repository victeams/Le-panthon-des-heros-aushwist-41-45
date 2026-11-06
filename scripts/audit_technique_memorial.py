#!/usr/bin/env python3
"""Audit statique en lecture seule du site Mémoire des Déportés."""
import csv, html, re
from collections import Counter
from datetime import datetime, timezone
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "audit-technique"
SKIP = {".git", ".github", "node_modules", "vendor", "dist", "build", "audit-technique"}
IMG = {".jpg", ".jpeg", ".png", ".gif", ".webp", ".avif", ".bmp", ".tif", ".tiff"}

class Parser(HTMLParser):
    def __init__(self, path):
        super().__init__(convert_charrefs=True)
        self.path, self.issues = path, []
        self.images = self.no_alt = self.no_dims = self.no_link_name = 0
        self.h1 = self.title_count = 0
        self.title_parts, self.headings, self.links = [], [], []
        self.in_title = False
        self.labels, self.fields, self.label_depth = set(), [], 0

    def issue(self, level, code, detail):
        self.issues.append({"severity": level, "code": code,
            "page": self.path.relative_to(ROOT).as_posix(), "detail": detail})

    def handle_starttag(self, tag, raw):
        a = dict(raw)
        if tag == "title":
            self.title_count += 1
            self.in_title = True
        if tag == "h1":
            self.h1 += 1
        if tag in {"h1","h2","h3","h4","h5","h6"}:
            self.headings.append(int(tag[1]))
        if tag == "img":
            self.images += 1
            if "alt" not in a:
                self.no_alt += 1
                self.issue("critique","IMG_ALT_ABSENT","Image sans alt : " + a.get("src","source inconnue"))
            if not a.get("width") or not a.get("height"):
                self.no_dims += 1
                self.issue("amelioration","IMG_DIMENSIONS_ABSENTES","Dimensions absentes : " + a.get("src","source inconnue"))
        if tag == "a":
            self.links.append({"named": bool((a.get("aria-label") or "").strip() or a.get("aria-labelledby") or (a.get("title") or "").strip()), "text": ""})
        if tag == "label":
            if a.get("for"):
                self.labels.add(a["for"])
            self.label_depth += 1
        if tag in {"input","select","textarea"}:
            typ = (a.get("type") or "").lower()
            if not (tag == "input" and typ in {"hidden","submit","button","reset","image"}):
                self.fields.append((a.get("id",""), bool(a.get("aria-label") or a.get("aria-labelledby")), self.label_depth > 0))

    def handle_endtag(self, tag):
        if tag == "title":
            self.in_title = False
        if tag == "label" and self.label_depth:
            self.label_depth -= 1

    def handle_data(self, data):
        if self.in_title:
            self.title_parts.append(data)
        if self.links and data.strip():
            self.links[-1]["text"] += data.strip()

    def close(self):
        super().close()
        if not self.title_count or not "".join(self.title_parts).strip():
            self.issue("amelioration","TITLE_ABSENT","Balise title absente ou vide.")
        if self.h1 == 0:
            self.issue("amelioration","H1_ABSENT","Aucun H1 détecté.")
        elif self.h1 > 1:
            self.issue("amelioration","PLUSIEURS_H1",str(self.h1) + " titres H1 détectés.")
        prev = 0
        for level in self.headings:
            if prev and level > prev + 1:
                self.issue("amelioration","HIERARCHIE_TITRES","Saut de H" + str(prev) + " à H" + str(level) + ".")
            prev = level
        for link in self.links:
            if not link["named"] and not link["text"]:
                self.no_link_name += 1
                self.issue("critique","LIEN_SANS_INTITULE","Lien sans texte ou nom accessible.")
        for field_id, aria, wrapped in self.fields:
            if not aria and not wrapped and not (field_id and field_id in self.labels):
                self.issue("amelioration","CHAMP_LABEL_A_VERIFIER","Champ potentiellement sans label : " + (field_id or "id absent"))

def pages():
    return sorted(p for p in ROOT.rglob("*") if p.is_file() and p.suffix.lower() in {".html",".htm"}
        and not any(part in SKIP for part in p.relative_to(ROOT).parts))

def large_images(page, parser):
    text = page.read_text(encoding="utf-8", errors="replace")
    for m in re.finditer(r"""(?:src|poster)\s*=\s*["']([^"']+)["']""", text, re.I):
        raw = html.unescape(m.group(1).strip())
        u = urlsplit(raw)
        if u.scheme or u.netloc or raw.startswith(("data:","blob:","//")) or not u.path:
            continue
        target = (page.parent / unquote(u.path)).resolve()
        try:
            target.relative_to(ROOT.resolve())
        except ValueError:
            continue
        if target.is_file() and target.suffix.lower() in IMG:
            size = target.stat().st_size
            if size > 300 * 1024:
                parser.issue("amelioration","IMAGE_LOURDE",target.relative_to(ROOT).as_posix() +
                    " : " + str(round(size/1024)) + " Ko (seuil indicatif 300 Ko).")

def main():
    OUT.mkdir(parents=True, exist_ok=True)
    all_issues, stats = [], Counter()
    files = pages()
    for page in files:
        p = Parser(page)
        try:
            p.feed(page.read_text(encoding="utf-8", errors="replace"))
            p.close()
            large_images(page, p)
        except Exception as exc:
            p.issue("critique","ANALYSE_IMPOSSIBLE",str(exc))
        all_issues.extend(p.issues)
        stats["images"] += p.images
        stats["sans_alt"] += p.no_alt
        stats["sans_dimensions"] += p.no_dims
        stats["liens_sans_nom"] += p.no_link_name
    for item in all_issues:
        stats[item["severity"]] += 1
    stats["pages"] = len(files)
    with (OUT/"anomalies.csv").open("w",newline="",encoding="utf-8-sig") as f:
        w = csv.DictWriter(f,fieldnames=["severity","code","page","detail"])
        w.writeheader()
        w.writerows(all_issues)
    lines = ["# Audit technique — Mémoire des Déportés","",
        "- Date UTC : " + datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC"),
        "- Pages HTML analysées : **" + str(stats["pages"]) + "**",
        "- Images analysées : **" + str(stats["images"]) + "**",
        "- Images sans alt : **" + str(stats["sans_alt"]) + "**",
        "- Images sans dimensions : **" + str(stats["sans_dimensions"]) + "**",
        "- Liens sans intitulé accessible : **" + str(stats["liens_sans_nom"]) + "**",
        "- Anomalies critiques : **" + str(stats["critique"]) + "**",
        "- Points à vérifier : **" + str(stats["amelioration"]) + "**","",
        "> Audit statique indicatif. Il ne remplace pas les tests clavier, contraste, lecteur d’écran ou PageSpeed.",
        "> Aucune page, photo, biographie ou notice n’est modifiée.","","## Anomalies par catégorie",""]
    counts = Counter(x["code"] for x in all_issues)
    lines.extend(["- " + k + " : " + str(v) for k,v in sorted(counts.items())] or ["Aucune anomalie détectée."])
    lines += ["","## Détail des anomalies",""]
    for x in all_issues[:500]:
        lines.append("- **" + x["severity"] + " — " + x["code"] + "** — " + x["page"] + " : " + x["detail"])
    if len(all_issues) > 500:
        lines.append("Le CSV contient " + str(len(all_issues)-500) + " anomalies supplémentaires.")
    (OUT/"rapport.md").write_text("\n".join(lines)+"\n",encoding="utf-8")
    print("\n".join(lines[:16]))
if __name__ == "__main__":
    main()

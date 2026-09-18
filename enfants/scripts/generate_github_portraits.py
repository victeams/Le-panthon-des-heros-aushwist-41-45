#!/usr/bin/env python3
"""Génère les nouvelles fiches statiques du mémorial GitHub Pages."""

from __future__ import annotations

import html
import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DATA_PATH = ROOT / "data" / "github-portraits-additions.json"
INDEX_PATH = ROOT / "index.html"
PORTRAITS_DIR = ROOT / "portraits"
BASE_URL = "https://victeams.github.io/enfants-deportes-1939-1945/"
START = "          <!-- NEW_PORTRAITS_START -->"
END = "          <!-- NEW_PORTRAITS_END -->"


def esc(value: str) -> str:
    return html.escape(value, quote=True)


def add_victim_badges(index: str) -> str:
    """Place le destin en rouge sur la photo de chaque victime, sans doublon."""

    victim_card = re.compile(
        r'<article class="card"[^>]*data-outcome="victim"[^>]*>[\s\S]*?</article>'
    )

    def add_badge(match: re.Match[str]) -> str:
        card_html = match.group(0)
        if 'class="victim-badge"' in card_html:
            return card_html
        outcome = re.search(
            r'<div class="meta"><span>[^<]*</span><span>([^<]+)</span></div>',
            card_html,
        )
        label = outcome.group(1) if outcome else "Assassiné·e"
        return card_html.replace(
            '<div class="image">',
            f'<div class="image"><span class="victim-badge">{label}</span>',
            1,
        )

    return victim_card.sub(add_badge, index)


def card(person: dict[str, object]) -> str:
    return f'''          <article class="card" data-search="{esc(str(person["search"]))}" data-outcome="victim">
            <div class="image"><img src="{esc(str(person["image"]))}" alt="{esc(str(person["imageAlt"]))}" loading="lazy" /></div>
            <div class="body"><div class="meta"><span>{esc(str(person["age"]))}</span><span>{esc(str(person["outcome"]))}</span></div><h3>{esc(str(person["name"]))}</h3><p>{esc(str(person["excerpt"]))}</p><a class="story-link" href="portraits/{esc(str(person["slug"]))}.html">Lire son histoire →</a></div>
          </article>'''


def portrait_page(person: dict[str, object]) -> str:
    slug = str(person["slug"])
    name = str(person["name"])
    canonical = f"{BASE_URL}portraits/{slug}.html"
    paragraphs = "\n".join(f"          <p>{esc(str(paragraph))}</p>" for paragraph in person["biography"])
    structured = json.dumps(
        {
            "@context": "https://schema.org",
            "@type": "Person",
            "name": name,
            "birthDate": person["birthDateIso"],
            "birthPlace": person["birthPlace"],
            "deathDate": person["deathDateIso"],
            "deathPlace": person["deathPlace"],
            "image": person["image"],
            "url": canonical,
        },
        ensure_ascii=False,
    ).replace("</", "<\\/")
    return f'''<!doctype html>
<html lang="fr">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>{esc(name)} · Enfants déportés 1939-1945</title>
    <meta name="description" content="{esc(str(person["excerpt"]))}" />
    <meta name="robots" content="index, follow, max-image-preview:large" />
    <link rel="canonical" href="{canonical}" />
    <meta property="og:type" content="article" />
    <meta property="og:title" content="{esc(name)} · Enfants déportés 1939-1945" />
    <meta property="og:description" content="{esc(str(person["excerpt"]))}" />
    <meta property="og:url" content="{canonical}" />
    <meta property="og:image" content="{esc(str(person["image"]))}" />
    <link rel="stylesheet" href="portrait.css" />
    <script type="application/ld+json">{structured}</script>
  </head>
  <body>
    <header class="site-header page">
      <a class="brand" href="../index.html"><span>✦</span> Enfants déportés</a>
      <a class="back" href="../index.html#portraits">← Tous les portraits</a>
    </header>
    <main class="page">
      <article class="portrait">
        <figure class="photo-wrap">
          <img class="photo" src="{esc(str(person["image"]))}" alt="{esc(str(person["imageAlt"]))}" />
          <figcaption>{esc(str(person["imageCredit"]))}. Photographie affichée sans recadrage.</figcaption>
        </figure>
        <div>
          <p class="eyebrow">Une enfance, un nom, une mémoire</p>
          <h1>{esc(name)}</h1>
          <p class="dates">Né{esc(str(person["genderSuffix"]))} le {esc(str(person["birthDate"]))} à {esc(str(person["birthPlace"]))}<br />Mort{esc(str(person["genderSuffix"]))} le {esc(str(person["deathDate"]))} à {esc(str(person["deathPlace"]))}</p>
          <div class="facts"><span class="fact">{esc(str(person["age"]))}</span><span class="fact">{esc(str(person["outcome"]))}</span></div>
          <div class="story">
{paragraphs}
          </div>
        </div>
      </article>
      <aside class="source">
        <p>Identité, dates, liens familiaux et photographie vérifiés dans une notice mémorielle nominative. Lorsqu’un détail du trajet ou la cause médicale du décès n’est pas établi, le texte ne l’invente pas.</p>
        <a class="button" href="{esc(str(person["sourceUrl"]))}" target="_blank" rel="noopener noreferrer">Consulter la notice d’archive ↗</a>
      </aside>
    </main>
    <footer class="page">Préserver leur histoire, transmettre leur mémoire. · Aucune publicité · Aucun profilage</footer>
  </body>
</html>
'''


def main() -> None:
    people = json.loads(DATA_PATH.read_text(encoding="utf-8"))
    PORTRAITS_DIR.mkdir(parents=True, exist_ok=True)

    index = INDEX_PATH.read_text(encoding="utf-8")
    if START not in index or END not in index:
        raise SystemExit("Marqueurs des nouveaux portraits absents de index.html")
    cards = "\n".join(card(person) for person in people)
    index = re.sub(
        re.escape(START) + r"[\s\S]*?" + re.escape(END),
        START + "\n" + cards + "\n" + END,
        index,
        count=1,
    )
    index = add_victim_badges(index)
    total = len(re.findall(r'<article class="card"', index))
    index = re.sub(
        r'(<p id="count" aria-live="polite">)\d+ portraits(</p>)',
        rf"\g<1>{total} portraits\g<2>",
        index,
        count=1,
    )
    index = re.sub(
        r'(<strong class="portrait-total__number" id="hero-count">)\d+(</strong>)',
        rf"\g<1>{total}\g<2>",
        index,
        count=1,
    )
    INDEX_PATH.write_text(index, encoding="utf-8")

    for person in people:
        (PORTRAITS_DIR / f'{person["slug"]}.html').write_text(
            portrait_page(person), encoding="utf-8"
        )

    portrait_files = sorted(path.name for path in PORTRAITS_DIR.glob("*.html"))
    sitemap_urls = [BASE_URL] + [
        f"{BASE_URL}portraits/{filename}" for filename in portrait_files
    ]
    sitemap = '<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n'
    sitemap += "\n".join(f"  <url><loc>{esc(url)}</loc></url>" for url in sitemap_urls)
    sitemap += "\n</urlset>\n"
    (ROOT / "sitemap.xml").write_text(sitemap, encoding="utf-8")
    (ROOT / "sitemap-google.txt").write_text(
        "\n".join(sitemap_urls) + "\n", encoding="utf-8"
    )
    (ROOT / "robots.txt").write_text(
        f"User-agent: *\nAllow: /\n\nSitemap: {BASE_URL}sitemap.xml\n",
        encoding="utf-8",
    )
    print(f"{len(people)} fiches générées, {total} portraits affichés.")


if __name__ == "__main__":
    main()

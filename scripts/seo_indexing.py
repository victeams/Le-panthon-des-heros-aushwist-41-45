from pathlib import Path
import html
import json
import re

OLD_BASE = "https://victeams.github.io/Le-panthon-des-heros-aushwist-41-45/"
BASE = "https://memoiredesdeportes.fr/"
ROOT = Path(__file__).resolve().parents[1]

EXCLUDED = {"404.html"}
NON_PROFILE = {
    "index.html", "femmes.html", "hommes.html", "base-documentaire.html",
    "photos.html", "soutien.html", "tiktok.html", "a-propos.html",
    "contact.html", "convoi-des-31000.html", "convoi-des-45000.html",
}


def root_counterpart(path: Path) -> Path | None:
    """Retrouve la fiche principale d'une ancienne copie dans /hommes/."""
    if path.parent != ROOT / "hommes":
        return None
    direct = ROOT / path.name
    if direct.exists():
        return direct
    numbers = re.findall(r"(?<!\d)(?:31|45|46)\d{3}(?!\d)", path.stem)
    if len(numbers) != 1:
        return None
    matches = [candidate for candidate in ROOT.glob(f"*{numbers[0]}*.html")]
    return matches[0] if len(matches) == 1 else None


def canonical_url(path: Path) -> str:
    counterpart = root_counterpart(path)
    if counterpart:
        path = counterpart
    rel = path.relative_to(ROOT).as_posix()
    if rel == "index.html":
        return BASE
    if rel.endswith("/index.html"):
        return BASE + rel[:-10]
    return BASE + rel


def extract_title(text: str, fallback: str) -> str:
    m = re.search(r"<title[^>]*>(.*?)</title>", text, flags=re.I | re.S)
    if m:
        title = re.sub(r"<[^>]+>", "", m.group(1))
        title = html.unescape(re.sub(r"\s+", " ", title)).strip()
        if title:
            return title
    return fallback


def description_for(title: str) -> str:
    return (
        f"Portrait et biographie de {title}, dans le mémorial numérique consacré "
        "aux résistants et déportés de la Seconde Guerre mondiale."
    )


def seo_title(title: str, path: Path) -> str:
    if path.name == "index.html" or "Mémoire des Déportés" in title:
        return title
    suffix = " | Mémoire des Déportés"
    return title if len(title) + len(suffix) > 65 else title + suffix


def ensure_head_tags(path: Path) -> bool:
    text = path.read_text(encoding="utf-8")
    if "<head" not in text.lower() or "</head>" not in text.lower():
        return False

    original = text
    text = text.replace(OLD_BASE, BASE)
    text = text.replace(
        '<link rel="icon" href="https://memoiredesdeportes.fr/favicon.ico" sizes="any">\n  <link rel="icon" type="image/png" sizes="96x96" href="https://memoiredesdeportes.fr/favicon.png">\n  <link rel="icon" type="image/svg+xml" href="https://memoiredesdeportes.fr/favicon.svg">\n  <link rel="apple-touch-icon" sizes="96x96" href="https://memoiredesdeportes.fr/apple-touch-icon.png">',
        '<link rel="icon" href="https://memoiredesdeportes.fr/favicon.ico" sizes="any">\n  <link rel="icon" type="image/png" sizes="96x96" href="https://memoiredesdeportes.fr/favicon.png">\n  <link rel="icon" type="image/svg+xml" href="https://memoiredesdeportes.fr/favicon.svg">\n  <link rel="apple-touch-icon" sizes="96x96" href="https://memoiredesdeportes.fr/apple-touch-icon.png">',
    )
    url = canonical_url(path)
    counterpart = root_counterpart(path)
    if counterpart:
        text = re.sub(
            r'<link\s+[^>]*rel=["\']canonical["\'][^>]*>',
            f'<link rel="canonical" href="{html.escape(url, quote=True)}">',
            text,
            count=1,
            flags=re.I,
        )
    fallback = path.stem.replace("-", " ").replace("_", " ").title()
    title = extract_title(text, fallback)

    # Un titre explicite aide Google à distinguer les centaines de portraits.
    improved_title = seo_title(title, path)
    if improved_title != title:
        escaped_title = html.escape(improved_title)
        text = re.sub(
            r"<title[^>]*>.*?</title>",
            f"<title>{escaped_title}</title>",
            text,
            count=1,
            flags=re.I | re.S,
        )

    inserts = []
    if not re.search(r'<link\s+[^>]*rel=["\']icon["\']', text, flags=re.I):
        inserts.append('<link rel="icon" href="https://memoiredesdeportes.fr/favicon.ico" sizes="any">\n  <link rel="icon" type="image/png" sizes="96x96" href="https://memoiredesdeportes.fr/favicon.png">\n  <link rel="icon" type="image/svg+xml" href="https://memoiredesdeportes.fr/favicon.svg">\n  <link rel="apple-touch-icon" sizes="96x96" href="https://memoiredesdeportes.fr/apple-touch-icon.png">')
    if not re.search(r'<meta\s+[^>]*name=["\']theme-color["\']', text, flags=re.I):
        inserts.append('<meta name="theme-color" content="#0b0d10">')
    if not re.search(r'<meta\s+[^>]*name=["\']robots["\']', text, flags=re.I):
        inserts.append('<meta name="robots" content="index,follow,max-image-preview:large">')
    if not re.search(r'<link\s+[^>]*rel=["\']canonical["\']', text, flags=re.I):
        inserts.append(f'<link rel="canonical" href="{html.escape(url, quote=True)}">')
    if not re.search(r'<meta\s+[^>]*name=["\']description["\']', text, flags=re.I):
        desc = html.escape(description_for(title), quote=True)
        inserts.append(f'<meta name="description" content="{desc}">')

    description_match = re.search(
        r'<meta\s+[^>]*name=["\']description["\'][^>]*content=["\']([^"\']*)',
        text,
        flags=re.I,
    )
    description = html.unescape(description_match.group(1)) if description_match else description_for(title)
    if not re.search(r'<meta\s+[^>]*property=["\']og:title["\']', text, flags=re.I):
        inserts.extend([
            '<meta property="og:type" content="article">',
            f'<meta property="og:title" content="{html.escape(improved_title, quote=True)}">',
            f'<meta property="og:description" content="{html.escape(description, quote=True)}">',
            f'<meta property="og:url" content="{html.escape(url, quote=True)}">',
            '<meta name="twitter:card" content="summary">',
        ])
    if not re.search(r'<meta\s+[^>]*property=["\']og:image["\']', text, flags=re.I):
        inserts.extend([
            '<meta property="og:image" content="https://memoiredesdeportes.fr/assets/logo-resistants3945.webp">',
            '<meta property="og:image:alt" content="Mémoire des Déportés 1939-1945">',
        ])
    is_profile = path.name not in NON_PROFILE and not path.name.startswith("google")
    if is_profile and not re.search(r'<script\s+[^>]*type=["\']application/ld\+json["\']', text, flags=re.I):
        schema = {
            "@context": "https://schema.org",
            "@type": "ProfilePage",
            "name": title,
            "description": description,
            "url": url,
            "inLanguage": "fr-FR",
            "isPartOf": {"@type": "WebSite", "name": "Mémoire des Déportés", "url": BASE},
        }
        inserts.append(
            '<script type="application/ld+json">'
            + json.dumps(schema, ensure_ascii=False, separators=(",", ":"))
            + '</script>'
        )

    if inserts:
        text = re.sub(r"</head>", "  " + "\n  ".join(inserts) + "\n</head>", text, count=1, flags=re.I)

    if text != original:
        path.write_text(text, encoding="utf-8")
        return True
    return False


def build_sitemap(paths):
    urls = sorted({
        canonical_url(p) for p in paths
        if p.name not in EXCLUDED and not p.name.startswith("google")
    })
    body = [
        '<?xml version="1.0" encoding="UTF-8"?>',
        '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">',
    ]
    for url in urls:
        body.append(f"  <url><loc>{html.escape(url)}</loc></url>")
    body.append("</urlset>")
    body.append("")
    (ROOT / "sitemap.xml").write_text("\n".join(body), encoding="utf-8")


def main():
    pages = [
        p for p in ROOT.rglob("*.html")
        if ".git" not in p.parts and p.name not in EXCLUDED and not p.name.startswith("google")
    ]
    changed = sum(ensure_head_tags(p) for p in pages)
    build_sitemap(pages)
    robots = f"User-agent: *\nAllow: /\n\nSitemap: {BASE}sitemap.xml\n"
    (ROOT / "robots.txt").write_text(robots, encoding="utf-8")
    print(f"SEO vérifié sur {len(pages)} pages, {changed} pages modifiées.")


if __name__ == "__main__":
    main()

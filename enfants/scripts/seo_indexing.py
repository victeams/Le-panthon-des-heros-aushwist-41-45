from pathlib import Path
import html
import re

BASE = "https://victeams.github.io/enfants-deportes-1939-1945/"
ROOT = Path(__file__).resolve().parents[1]
EXCLUDED = {"404.html"}


def canonical_url(path: Path) -> str:
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
        f"Portrait et histoire de {title}, dans le mémorial numérique consacré "
        "aux enfants déportés pendant la Seconde Guerre mondiale."
    )


def ensure_head_tags(path: Path) -> bool:
    text = path.read_text(encoding="utf-8")
    if "<head" not in text.lower() or "</head>" not in text.lower():
        return False
    original = text
    url = canonical_url(path)
    fallback = path.stem.replace("-", " ").replace("_", " ").title()
    title = extract_title(text, fallback)
    inserts = []
    if not re.search(r'<meta\s+[^>]*name=["\']robots["\']', text, flags=re.I):
        inserts.append('<meta name="robots" content="index,follow,max-image-preview:large">')
    if not re.search(r'<link\s+[^>]*rel=["\']canonical["\']', text, flags=re.I):
        inserts.append(f'<link rel="canonical" href="{html.escape(url, quote=True)}">')
    if not re.search(r'<meta\s+[^>]*name=["\']description["\']', text, flags=re.I):
        inserts.append(f'<meta name="description" content="{html.escape(description_for(title), quote=True)}">')
    if inserts:
        text = re.sub(r"</head>", "  " + "\n  ".join(inserts) + "\n</head>", text, count=1, flags=re.I)
    if text != original:
        path.write_text(text, encoding="utf-8")
        return True
    return False


def build_sitemap(paths):
    urls = sorted({canonical_url(p) for p in paths if p.name not in EXCLUDED})
    body = ['<?xml version="1.0" encoding="UTF-8"?>', '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">']
    for url in urls:
        body.append(f"  <url><loc>{html.escape(url)}</loc></url>")
    body += ["</urlset>", ""]
    (ROOT / "sitemap.xml").write_text("\n".join(body), encoding="utf-8")


def main():
    pages = [p for p in ROOT.rglob("*.html") if ".git" not in p.parts and p.name not in EXCLUDED]
    changed = sum(ensure_head_tags(p) for p in pages)
    build_sitemap(pages)
    (ROOT / "robots.txt").write_text(f"User-agent: *\nAllow: /\n\nSitemap: {BASE}sitemap.xml\n", encoding="utf-8")
    print(f"SEO vérifié sur {len(pages)} pages, {changed} pages modifiées.")


if __name__ == "__main__":
    main()

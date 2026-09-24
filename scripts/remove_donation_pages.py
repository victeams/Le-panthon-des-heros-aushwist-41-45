#!/usr/bin/env python3
"""Retire les anciennes pages et les liens de soutien financier du site intégré."""

from pathlib import Path
import re


ROOT = Path(__file__).resolve().parents[1]


def remove_financial_links(path: Path) -> None:
    if not path.is_file():
        return
    text = path.read_text(encoding="utf-8")
    updated = re.sub(
        r'<a\b[^>]*href=["\'][^"\']*(?:soutien\.html|paypal\.me)[^"\']*["\'][^>]*>.*?</a>',
        "",
        text,
        flags=re.IGNORECASE | re.DOTALL,
    )
    if updated != text:
        path.write_text(updated, encoding="utf-8")


def main() -> None:
    for page in (ROOT / "soutien.html", ROOT / "enfants" / "soutien.html"):
        if page.is_file():
            page.unlink()

    for page in (ROOT / "index.html", ROOT / "enfants" / "index.html"):
        remove_financial_links(page)

    children_page = ROOT / "enfants" / "app" / "page.tsx"
    if children_page.is_file():
        text = children_page.read_text(encoding="utf-8")
        text = re.sub(
            r'\n\s*<section className="support" id="soutenir".*?</section>',
            "",
            text,
            count=1,
            flags=re.DOTALL,
        )
        children_page.write_text(text, encoding="utf-8")

    children_layout = ROOT / "enfants" / "app" / "layout.tsx"
    if children_layout.is_file():
        text = children_layout.read_text(encoding="utf-8")
        text = re.sub(r'\s*<Link href="/#soutenir">Soutenir</Link>', "", text)
        children_layout.write_text(text, encoding="utf-8")

    children_readme = ROOT / "enfants" / "README.md"
    if children_readme.is_file():
        text = children_readme.read_text(encoding="utf-8")
        text = text.replace("- section de soutien par PayPal ;\n", "")
        children_readme.write_text(text, encoding="utf-8")


if __name__ == "__main__":
    main()

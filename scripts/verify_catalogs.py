"""Vérifie que chaque biographie apparaît dans le bon catalogue public."""

from __future__ import annotations

import argparse
import json
from pathlib import Path


GROUP_PAGES = {
    "femmes": "femmes.html",
    "hommes": "hommes.html",
}


def verify(root: Path) -> tuple[int, int]:
    root = root.resolve()
    data = json.loads((root / "site-data.json").read_text(encoding="utf-8"))
    if not isinstance(data, list):
        raise ValueError("site-data.json doit contenir une liste")

    counts: dict[str, int] = {}
    for group, page_name in GROUP_PAGES.items():
        records = [record for record in data if record.get("group") == group]
        counts[group] = len(records)
        page = (root / page_name).read_text(encoding="utf-8")

        expected_counter = f"<strong>{len(records)}</strong> fiches"
        if expected_counter not in page:
            raise ValueError(f"compteur incorrect dans {page_name}")

        missing = [record["file"] for record in records if f'href="{record["file"]}"' not in page]
        if missing:
            raise ValueError(f"fiches absentes de {page_name} : {', '.join(missing)}")

    unknown = sorted({record.get("group") for record in data} - set(GROUP_PAGES))
    if unknown:
        raise ValueError(f"catégorie inconnue dans site-data.json : {unknown}")

    report = (root / "a_verifier.txt").read_text(encoding="utf-8")
    expected_lines = (
        f"Femmes 31000 : {counts['femmes']}",
        f"Hommes 45000 : {counts['hommes']}",
    )
    for line in expected_lines:
        if line not in report:
            raise ValueError(f"compteur absent du rapport : {line}")

    return counts["femmes"], counts["hommes"]


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    arguments = parser.parse_args(argv)
    women, men = verify(arguments.root)
    print(f"Catalogues contrôlés : {women} femmes, {men} hommes.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

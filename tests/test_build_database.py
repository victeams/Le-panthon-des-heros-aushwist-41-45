import json
import tempfile
import unittest
from pathlib import Path

from openpyxl import Workbook

from scripts.build_database import build_database


class BuildDatabaseTests(unittest.TestCase):
    def test_builds_static_categories_from_sql_and_workbook(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            sql = root / "source.sql"
            sql.write_text(
                """
                CREATE TABLE camps (camp_id TEXT PRIMARY KEY, name TEXT, confidence TEXT);
                INSERT INTO camps VALUES ('C01', 'Auschwitz I', 'Établi');
                CREATE TABLE french_31000 (list_id TEXT PRIMARY KEY, surname TEXT, person_label TEXT, matricule TEXT, source_url TEXT);
                INSERT INTO french_31000 VALUES ('F-1', 'EXEMPLE', 'Alice', '31802', 'https://example.test/source');
                """,
                encoding="utf-8",
            )

            workbook_path = root / "source.xlsx"
            workbook = Workbook()
            sheet = workbook.active
            sheet.title = "Bâtiments principaux"
            sheet.append(["Inventaire"])
            sheet.append(["Description"])
            sheet.append(["ID", "Bâtiment / installation", "Source URL"])
            sheet.append(["BAT-001", "Bloc 11", "Ouvrir la source"])
            sheet["C4"].hyperlink = "https://example.test/bloc-11"
            workbook.save(workbook_path)

            manifest = build_database(
                root,
                sql,
                workbook_path,
                Path("data/base-documentaire"),
                "https://example.test/memoire",
            )

            self.assertEqual(manifest["record_count"], 3)
            self.assertEqual(manifest["category_count"], 3)
            buildings = json.loads(
                (root / "data" / "base-documentaire" / "batiments.json").read_text(
                    encoding="utf-8"
                )
            )
            self.assertEqual(buildings[0]["title"], "Bloc 11")
            self.assertEqual(
                buildings[0]["values"]["Source URL"],
                "https://example.test/bloc-11",
            )
            page = (root / "base-documentaire.html").read_text(encoding="utf-8")
            self.assertIn("sans serveur payant", page)
            self.assertIn("application/ld+json", page)
            self.assertIn("soutien.html", page)


if __name__ == "__main__":
    unittest.main()

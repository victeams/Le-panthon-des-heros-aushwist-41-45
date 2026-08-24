import json
import tempfile
import unittest
from pathlib import Path

from scripts.verify_catalogs import verify


class VerifyCatalogsTests(unittest.TestCase):
    def test_accepts_synchronized_women_and_men_catalogs(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            records = [
                {"group": "femmes", "file": "alice_31802.html"},
                {"group": "hommes", "file": "hommes/pierre_45100.html"},
            ]
            (root / "site-data.json").write_text(json.dumps(records), encoding="utf-8")
            (root / "femmes.html").write_text(
                '<strong>1</strong> fiches <a href="alice_31802.html">Alice</a>', encoding="utf-8"
            )
            (root / "hommes.html").write_text(
                '<strong>1</strong> fiches <a href="hommes/pierre_45100.html">Pierre</a>', encoding="utf-8"
            )
            (root / "a_verifier.txt").write_text(
                "Femmes 31000 : 1\nHommes 45000 : 1\n", encoding="utf-8"
            )

            self.assertEqual(verify(root), (1, 1))

    def test_rejects_a_profile_missing_from_its_catalog(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            records = [{"group": "hommes", "file": "hommes/pierre_45100.html"}]
            (root / "site-data.json").write_text(json.dumps(records), encoding="utf-8")
            (root / "femmes.html").write_text("<strong>0</strong> fiches", encoding="utf-8")
            (root / "hommes.html").write_text("<strong>1</strong> fiches", encoding="utf-8")
            (root / "a_verifier.txt").write_text(
                "Femmes 31000 : 0\nHommes 45000 : 1\n", encoding="utf-8"
            )

            with self.assertRaisesRegex(ValueError, "fiches absentes"):
                verify(root)


if __name__ == "__main__":
    unittest.main()

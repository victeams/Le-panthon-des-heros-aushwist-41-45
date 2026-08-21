import base64
import json
import tempfile
import unittest
from pathlib import Path

from scripts.build_site import build


PIXEL_PNG = base64.b64encode(
    b"\x89PNG\r\n\x1a\n" + b"image-test"
).decode("ascii")


def biography(name: str, matricule: str | None, status: str, convoi: str | None = None) -> str:
    meta = f'<meta name="convoi" content="{convoi}">' if convoi else ""
    matricule_html = f'<p class="meta">Matricule {matricule}</p>' if matricule else ""
    return f"""<!doctype html><html lang="fr"><head><meta charset="utf-8">{meta}<title>{name}</title></head>
    <body><h1>{name}</h1>{matricule_html}<p class="status">{status}</p>
    <img src="data:image/png;base64,{PIXEL_PNG}" alt="Portrait">
    <div class="text"><p>Une biographie documentée pour transmettre sa mémoire.</p></div></body></html>"""


class BuildSiteTests(unittest.TestCase):
    def test_classifies_female_and_male_and_builds_seo(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "alice_31802.html").write_text(
                biography("Alice EXEMPLE", "31802", "Morte en déportation"), encoding="utf-8"
            )
            (root / "pierre.html").write_text(
                biography("Pierre EXEMPLE", "46191", "Rescapé"), encoding="utf-8"
            )

            women, men, warnings = build(root, "https://example.test/memoire", "verification-test")

            self.assertEqual((women, men), (1, 1))
            self.assertFalse(warnings)
            self.assertIn("Alice EXEMPLE", (root / "femmes.html").read_text(encoding="utf-8"))
            self.assertIn("Pierre EXEMPLE", (root / "hommes.html").read_text(encoding="utf-8"))
            self.assertIn("verification-test", (root / "index.html").read_text(encoding="utf-8"))
            self.assertIn("sitemap.xml", (root / "robots.txt").read_text(encoding="utf-8"))
            data = json.loads((root / "site-data.json").read_text(encoding="utf-8"))
            self.assertEqual({item["group"] for item in data}, {"femmes", "hommes"})
            self.assertTrue((root / "portraits" / "alice_31802.png").exists())
            self.assertTrue((root / "portraits" / "pierre.png").exists())

    def test_explicit_convoi_classifies_page_without_matricule(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "homme_sans_numero.html").write_text(
                biography("Homme SANS NUMÉRO", None, "Notice commémorative", convoi="45000"),
                encoding="utf-8",
            )
            women, men, warnings = build(root, "https://example.test", "test")
            self.assertEqual((women, men), (0, 1))
            self.assertFalse(warnings)

    def test_ambiguous_page_is_reported_without_breaking_site(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "inconnue.html").write_text(
                biography("Personne INCONNUE", None, "Notice commémorative"), encoding="utf-8"
            )
            women, men, warnings = build(root, "https://example.test", "test")
            self.assertEqual((women, men), (0, 0))
            self.assertEqual(len(warnings), 1)
            self.assertIn("NON CLASSÉ", (root / "a_verifier.txt").read_text(encoding="utf-8"))

    def test_page_from_historical_women_index_is_preserved_without_matricule(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            (root / "portraits").mkdir()
            (root / "portraits" / "jeannine.jpg").write_bytes(b"photo")
            (root / "jeannine.html").write_text(
                biography("Jeannine EXEMPLE", None, "Notice commémorative"), encoding="utf-8"
            )
            (root / "index.html").write_text(
                '<article><a href="jeannine.html"><img src="portraits/jeannine.jpg"></a></article>',
                encoding="utf-8",
            )
            women, men, warnings = build(root, "https://example.test", "test")
            self.assertEqual((women, men), (1, 0))
            self.assertFalse(warnings)
            self.assertIn("Jeannine EXEMPLE", (root / "femmes.html").read_text(encoding="utf-8"))

    def test_documented_legacy_exception_survives_every_rebuild(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            filename = "jeannine_dite_jeanne_herschtel.html"
            (root / filename).write_text(
                biography("Jeannine dite Jeanne HERSCHTEL", None, "Notice commémorative"),
                encoding="utf-8",
            )

            first = build(root, "https://example.test", "test")
            second = build(root, "https://example.test", "test")

            self.assertEqual(first[:2], (1, 0))
            self.assertEqual(second[:2], (1, 0))
            self.assertFalse(first[2])
            self.assertFalse(second[2])


if __name__ == "__main__":
    unittest.main()

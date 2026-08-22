import unittest
import xml.etree.ElementTree as element_tree
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class SupportPageTests(unittest.TestCase):
    def test_daily_work_icons_are_valid_svg_files(self):
        icons = sorted((ROOT / "assets" / "icons").glob("*.svg"))
        self.assertGreaterEqual(len(icons), 8)
        for icon in icons:
            root = element_tree.parse(icon).getroot()
            self.assertEqual(root.attrib.get("viewBox"), "0 0 64 64")

    def test_support_page_is_transparent_and_has_working_non_payment_actions(self):
        page = (ROOT / "soutien.html").read_text(encoding="utf-8")
        self.assertIn("Le travail réalisé au quotidien", page)
        self.assertIn("Aucune adresse de paiement", page)
        self.assertIn("navigator.share", page)
        self.assertIn("tiktok.html", page)
        self.assertIn("assets/logo-resistants3945.webp", page)


if __name__ == "__main__":
    unittest.main()

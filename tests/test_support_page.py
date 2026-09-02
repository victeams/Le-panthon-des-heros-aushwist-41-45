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
        self.assertIn("navigator.share", page)
        self.assertIn("tiktok.html", page)
        self.assertIn("assets/logo-resistants3945.webp", page)

    def test_paypal_support_is_external_and_transparent(self):
        page = (ROOT / "soutien.html").read_text(encoding="utf-8")
        self.assertIn("https://paypal.me/PortraitsMemoire3945", page)
        self.assertIn('target="_blank"', page)
        self.assertIn('rel="noopener noreferrer"', page)
        self.assertIn("le montant est libre", page)
        self.assertIn("aucune donnée bancaire n’est collectée par ce site", page)
        self.assertIn("ne donne pas lieu à un reçu fiscal", page)


if __name__ == "__main__":
    unittest.main()

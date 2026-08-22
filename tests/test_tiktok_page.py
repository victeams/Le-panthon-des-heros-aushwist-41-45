import json
import re
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


class TikTokPageTests(unittest.TestCase):
    def test_tiktok_page_has_logo_profile_and_secure_external_link(self):
        page = (ROOT / "tiktok.html").read_text(encoding="utf-8")
        self.assertIn("assets/logo-resistants3945.webp", page)
        self.assertIn("https://www.tiktok.com/@resistants3945", page)
        self.assertIn('rel="noopener noreferrer"', page)
        self.assertIn('width="690" height="690"', page)
        self.assertTrue((ROOT / "assets" / "logo-resistants3945.webp").is_file())

    def test_tiktok_structured_data_is_valid_json(self):
        page = (ROOT / "tiktok.html").read_text(encoding="utf-8")
        match = re.search(r'<script type="application/ld\+json">(.*?)</script>', page, re.DOTALL)
        self.assertIsNotNone(match)
        payload = json.loads(match.group(1))
        self.assertEqual(payload["@type"], "ProfilePage")


if __name__ == "__main__":
    unittest.main()

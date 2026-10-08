import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

import scripts.seo_indexing as seo_indexing


class SeoIndexingTests(unittest.TestCase):
    def test_shared_navigation_limits_brand_logo_to_edouard_profile(self):
        script = (seo_indexing.ROOT / "assets" / "memorial-ux.js").read_text(encoding="utf-8")

        self.assertIn("location.pathname==='/edouard-dumoulin-45506.html'", script)
        self.assertNotIn("logo-tourisme-territoire-nord-picardie", script)

    def test_removes_global_brand_image_except_on_edouard_profile(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            regular_page = root / "hommes.html"
            regular_page.write_text(
                '<html><head><title>Hommes</title>'
                '<meta property="og:image" content="'
                + seo_indexing.PROFILE_LOGO_URL
                + '"><meta property="og:image:alt" content="Mémorial"></head></html>',
                encoding="utf-8",
            )
            profile_page = root / seo_indexing.PROFILE_LOGO_PAGE
            profile_page.write_text(
                '<html><head><title>Édouard DUMOULIN</title></head></html>',
                encoding="utf-8",
            )

            with patch.object(seo_indexing, "ROOT", root):
                seo_indexing.ensure_head_tags(regular_page)
                seo_indexing.ensure_head_tags(profile_page)

            self.assertNotIn(seo_indexing.PROFILE_LOGO_URL, regular_page.read_text(encoding="utf-8"))
            self.assertIn(seo_indexing.PROFILE_LOGO_URL, profile_page.read_text(encoding="utf-8"))
            duplicate_profile = root / "hommes" / seo_indexing.PROFILE_LOGO_PAGE
            duplicate_profile.parent.mkdir()
            duplicate_profile.write_text(profile_page.read_text(encoding="utf-8"), encoding="utf-8")

            with patch.object(seo_indexing, "ROOT", root):
                seo_indexing.ensure_head_tags(duplicate_profile)

            self.assertNotIn(
                seo_indexing.PROFILE_LOGO_URL,
                duplicate_profile.read_text(encoding="utf-8"),
            )

    def test_preserves_non_brand_social_image(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            page = root / "photos.html"
            page.write_text(
                '<html><head><title>Photothèque</title>'
                '<meta property="og:image" content="https://example.test/photo.jpg">'
                '</head></html>',
                encoding="utf-8",
            )

            with patch.object(seo_indexing, "ROOT", root):
                seo_indexing.ensure_head_tags(page)

            self.assertIn("https://example.test/photo.jpg", page.read_text(encoding="utf-8"))


if __name__ == "__main__":
    unittest.main()

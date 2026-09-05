import tempfile
import unittest
from pathlib import Path

from scripts.update_women_portraits import ImageCandidate, replace_photo, rights_status, score_image


class UpdateWomenPortraitsTests(unittest.TestCase):
    def test_missing_license_is_not_invented(self):
        self.assertEqual(
            rights_status("Collection familiale"),
            "Licence ou droits non indiqués par la source ; réutilisation à vérifier",
        )
        self.assertEqual(rights_status("Droits réservés"), "Droits réservés")

    def test_contextual_image_is_rejected_by_scoring(self):
        score, reasons = score_image(
            ImageCandidate(
                "https://example.test/plaque-commemorative-rose-blanc.jpg",
                "Plaque commémorative Rose Blanc",
                400,
                300,
            ),
            "Rose BLANC",
            "31652",
        )
        self.assertLess(score, 55)
        self.assertIn("contexte:plaque", reasons)

    def test_replaces_portrait_in_legacy_text_template(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "alice.html"
            path.write_text(
                '<html><head><style></style></head><body><div class="text">Biographie</div></body></html>',
                encoding="utf-8",
            )
            result = {
                "name": "Alice EXEMPLE",
                "source_image": None,
                "source_page": None,
                "rights_status": None,
            }

            self.assertTrue(replace_photo(path, result, None))
            content = path.read_text(encoding="utf-8")
            self.assertIn('class="missing portrait-absent"', content)
            self.assertIn('class="photo-documentation"', content)
            self.assertLess(content.index("portrait-absent"), content.index('<div class="text">'))


if __name__ == "__main__":
    unittest.main()

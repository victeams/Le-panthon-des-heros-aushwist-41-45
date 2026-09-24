import tempfile
import unittest
from pathlib import Path

from tests.outil_windows_import import load_core

core = load_core()


class PortraitCoreTests(unittest.TestCase):
    def sample(self, **changes):
        values = dict(name="Jeanne Exemple", matricule="31600", birth_name="Martin", status="Notice commémorative", biography="Une biographie documentée suffisamment longue pour être publiée dans le mémorial.", source_url="https://example.org/notice", source_name="Archives municipales")
        values.update(changes)
        return core.PortraitData(**values)

    def test_slug_and_group_are_deterministic(self):
        self.assertEqual(core.slugify("Élise D’Àngers"), "elise-d-angers")
        self.assertEqual(core.group_for_matricule("31600"), "femmes")
        self.assertEqual(core.group_for_matricule("45800"), "hommes")

    def test_source_url_is_required(self):
        with self.assertRaises(ValueError):
            core.validate(self.sample(source_url="sans-url"))

    def test_photo_requires_credit(self):
        with tempfile.TemporaryDirectory() as directory:
            photo = Path(directory) / "portrait.jpg"
            photo.write_bytes(b"image")
            with self.assertRaises(ValueError):
                core.validate(self.sample(photo_path=str(photo), photo_credit=""))

    def test_guided_biography_keeps_memorial_order(self):
        text = core.compose_guided_biography({
            "deportation": "Troisième partie sur la déportation.",
            "origins": "Première partie sur les origines.",
            "arrest": "Deuxième partie sur l’arrestation.",
        })
        self.assertEqual(text.split("\n\n"), [
            "Première partie sur les origines.",
            "Deuxième partie sur l’arrestation.",
            "Troisième partie sur la déportation.",
        ])

    def test_guided_biography_requires_three_sections(self):
        with self.assertRaises(ValueError):
            core.compose_guided_biography({"origins": "Origines", "arrest": "Arrestation"})

    def test_html_escapes_text_and_keeps_exact_source(self):
        data = self.sample(name="Jeanne & Exemple", biography="Texte vérifié avec <document> et suffisamment de détails pour la publication.")
        page = core.portrait_html(data, "jeanne-exemple-31600.html", "portraits/test.jpg", True)
        self.assertIn("Jeanne &amp; Exemple", page)
        self.assertIn("&lt;document&gt;", page)
        self.assertIn('href="https://example.org/notice"', page)


if __name__ == "__main__":
    unittest.main()


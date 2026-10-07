import json
import tempfile
import unittest
from urllib.error import HTTPError
from pathlib import Path
from unittest.mock import patch

from scripts.scrape_ushmm_id_cards import (
    BiographyTextParser,
    IdCardListingParser,
    ResourceNotFoundError,
    card_url,
    fetch,
    gender_group,
    pages_in,
    write_catalog,
)


class ScrapeUshmmIdCardsTests(unittest.TestCase):
    def test_extracts_names_and_official_links_without_images_or_biographies(self):
        parser = IdCardListingParser()
        parser.feed(
            """
            <div id="card-display-box">
              <a aria-label="Arlette Waldmann"
                 href="https://encyclopedia.ushmm.org/content/fr/id-card/arlette-waldmann">
                <figure><img src="https://example.test/photo.gif" alt="Arlette Waldmann">
                  <figcaption><h4>Arlette Waldmann</h4></figcaption>
                </figure>
              </a>
            </div>
            """
        )
        self.assertEqual(
            parser.records,
            [{
                "name": "Arlette Waldmann",
                "url": "https://encyclopedia.ushmm.org/content/fr/id-card/arlette-waldmann",
            }],
        )
        self.assertNotIn("image", parser.records[0])

    def test_extracts_official_gender_filters_without_topic_cards(self):
        parser = IdCardListingParser()
        parser.feed(
            """
            <a href="/content/fr/id-card/bertha-adler?filter=women">
              <h4>Les femmes</h4>
            </a>
            <a href="/content/fr/id-card/rudolf-acohen?filter=men">
              <h4>Les hommes</h4>
            </a>
            <a href="/content/fr/id-card/rudolf-acohen?filter=youth">
              <h4>Les jeunes</h4>
            </a>
            <a href="/content/fr/id-card/bertha-adler">
              <h4>Bertha Adler</h4>
            </a>
            <a href="/content/fr/id-card/rudolf-acohen">
              <h4>Rudolf Acohen</h4>
            </a>
            <a href="/content/fr/id-card/les-jeunes">
              <h4>Les jeunes</h4>
            </a>
            """
        )
        self.assertEqual(
            parser.records,
            [
                {
                    "name": "Bertha Adler",
                    "url": "https://encyclopedia.ushmm.org/content/fr/id-card/bertha-adler",
                },
                {
                    "name": "Rudolf Acohen",
                    "url": "https://encyclopedia.ushmm.org/content/fr/id-card/rudolf-acohen",
                },
            ],
        )
        self.assertEqual(
            parser.gender_hints,
            {
                "https://encyclopedia.ushmm.org/content/fr/id-card/bertha-adler": {"femmes"},
                "https://encyclopedia.ushmm.org/content/fr/id-card/rudolf-acohen": {"hommes"},
            },
        )

    def test_reads_biography_text_only_from_main_text_region(self):
        parser = BiographyTextParser()
        parser.feed(
            """
            <div id="main_text"><p>Elle a été déportée. Elle a survécu.</p></div>
            <div><p>Il faut ignorer ce texte de navigation.</p></div>
            """
        )
        self.assertEqual(" ".join(parser.parts), "Elle a été déportée. Elle a survécu.")
        self.assertEqual(gender_group(" ".join(parser.parts)), "femmes")

    def test_classifies_only_clear_lead_sentence_evidence(self):
        self.assertEqual(gender_group("Il a été arrêté. Il a survécu."), "hommes")
        self.assertEqual(gender_group("Elle a été arrêtée. Elle a survécu."), "femmes")
        self.assertEqual(
            gender_group("Alice, née à Vienne, a aidé Ilan, né à Berlin."),
            "non_documente",
        )
        self.assertEqual(
            gender_group(
                "Alice, née Alice Edelstein, était la plus jeune. "
                "Il m'a dit que mon convoi devait partir."
            ),
            "femmes",
        )
        self.assertEqual(
            gender_group(
                "Alice était la plus jeune des enfants nés. "
                "Il m'a dit que mon convoi devait partir.",
                "Alice Edelstein-Friedmann",
            ),
            "femmes",
        )
        self.assertEqual(gender_group("Rudolf, né à Amsterdam."), "hommes")
        self.assertEqual(
            gender_group("Rudolf et son frère sont nés à Amsterdam."),
            "non_documente",
        )
        self.assertEqual(
            gender_group(
                "Adela était la plus jeune des cinq enfants nés.",
                "Adela Litwak",
            ),
            "femmes",
        )
        self.assertEqual(gender_group("La personne a vécu à Paris."), "non_documente")

    def test_parses_pagination_and_rejects_non_official_links(self):
        self.assertEqual(pages_in('<a href="?letter=B&amp;page=2">2</a>'), 2)
        self.assertEqual(pages_in("<ul></ul>"), 1)
        with self.assertRaises(ValueError):
            card_url("https://example.test/content/fr/id-card/personne")
        self.assertEqual(
            card_url("/content/fr/id-card/personne"),
            "https://encyclopedia.ushmm.org/content/fr/id-card/personne",
        )
        self.assertEqual(
            card_url("/content/fr/id-card/personne?filter=women#biography"),
            "https://encyclopedia.ushmm.org/content/fr/id-card/personne",
        )

    @patch(
        "scripts.scrape_ushmm_id_cards.urlopen",
        side_effect=HTTPError("https://encyclopedia.ushmm.org/card", 404, "Not found", {}, None),
    )
    def test_missing_biography_is_reported_as_not_found_without_retries(self, urlopen_mock):
        with self.assertRaises(ResourceNotFoundError):
            fetch("https://encyclopedia.ushmm.org/card")
        self.assertEqual(urlopen_mock.call_count, 1)

    def test_writes_catalog_atomically_as_json(self):
        with tempfile.TemporaryDirectory() as directory:
            output = Path(directory) / "catalog.json"
            payload = {"count": 1, "records": [{"name": "Alice", "url": "https://example.test"}]}
            write_catalog(payload, output)
            self.assertEqual(json.loads(output.read_text(encoding="utf-8")), payload)
            self.assertFalse(output.with_suffix(".json.tmp").exists())


if __name__ == "__main__":
    unittest.main()

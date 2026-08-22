import json
import tempfile
import unittest
from pathlib import Path

from scripts.scrape_ushmm_photos import (
    PhotoListingParser,
    large_image_url,
    total_results,
    write_shards,
)


LISTING = """
<div class="results-info"><span>Affichage des résultats 1-2 sur 1575 pour "Photographie"</span></div>
<ul>
  <li class="clearfix">
    <div class="text-displays">
      <h2><a href="https://encyclopedia.ushmm.org/content/fr/photo/exemple-un">Alice &amp; Léa</a></h2>
      <p class="search-overview">Une description historique   documentée.</p>
      <div class="tags"><strong>Mots-clés:</strong><a href="/tag/auschwitz">Auschwitz</a></div>
    </div>
    <figure><img alt="Portrait d'Alice" src="https://encyclopedia.ushmm.org/images/thumb/photo-1.jpeg"></figure>
  </li>
  <li class="clearfix">
    <div class="text-displays">
      <h2><a href="https://encyclopedia.ushmm.org/content/fr/photo/exemple-deux">Notice sans miniature</a></h2>
      <p class="search-overview">Cette notice reste présente dans la sortie.</p>
    </div>
  </li>
</ul>
"""


class ScrapeUshmmPhotosTests(unittest.TestCase):
    def test_extracts_complete_listing_data_and_keeps_missing_image(self):
        parser = PhotoListingParser()
        parser.feed(LISTING)

        self.assertEqual(len(parser.items), 2)
        first, second = parser.items
        self.assertEqual(first["title"], "Alice & Léa")
        self.assertEqual(first["tags"], ["Auschwitz"])
        self.assertEqual(
            first["image_url"],
            "https://encyclopedia.ushmm.org/images/large/photo-1.jpeg",
        )
        self.assertIsNone(second["thumbnail_url"])
        self.assertIsNone(second["image_url"])

    def test_reads_total_and_derives_large_image_url(self):
        self.assertEqual(total_results(LISTING), 1575)
        self.assertEqual(
            large_image_url("https://example.test/images/thumb/a.jpeg"),
            "https://example.test/images/large/a.jpeg",
        )

    def test_writes_small_shards_and_manifest(self):
        with tempfile.TemporaryDirectory() as directory:
            target = Path(directory) / "photos" / "manifest.json"
            payload = {"count": 3, "items": [{"id": 1}, {"id": 2}, {"id": 3}]}

            write_shards(payload, target, shard_size=2)

            manifest = json.loads(target.read_text(encoding="utf-8"))
            self.assertEqual(manifest["files"], ["photos-001.json", "photos-002.json"])
            first = json.loads((target.parent / "photos-001.json").read_text(encoding="utf-8"))
            self.assertEqual(len(first), 2)


if __name__ == "__main__":
    unittest.main()

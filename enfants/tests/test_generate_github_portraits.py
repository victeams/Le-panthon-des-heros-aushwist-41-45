import unittest

from scripts.generate_github_portraits import add_victim_badges


class VictimBadgeTests(unittest.TestCase):
    def test_adds_badge_to_victim_and_preserves_survivor(self):
        source = """<article class="card" data-outcome="victim">
<div class="image"><img src="victime.jpg"></div>
<div class="body"><div class="meta"><span>4 ans</span><span>Assassinée</span></div></div>
</article>
<article class="card" data-outcome="survivor">
<div class="image"><img src="survivante.jpg"></div>
<div class="body"><div class="meta"><span>4 ans</span><span>Survivante</span></div></div>
</article>"""

        result = add_victim_badges(source)

        self.assertEqual(result.count('class="victim-badge"'), 1)
        self.assertIn('class="victim-badge">Assassinée</span>', result)
        self.assertNotIn('class="victim-badge">Survivante</span>', result)

    def test_is_idempotent_for_future_rebuilds(self):
        source = """<article class="card" data-outcome="victim">
<div class="image"><img src="victime.jpg"></div>
<div class="body"><div class="meta"><span>4 ans</span><span>Assassiné</span></div></div>
</article>"""

        once = add_victim_badges(source)
        twice = add_victim_badges(once)

        self.assertEqual(once, twice)
        self.assertEqual(twice.count('class="victim-badge"'), 1)


if __name__ == "__main__":
    unittest.main()

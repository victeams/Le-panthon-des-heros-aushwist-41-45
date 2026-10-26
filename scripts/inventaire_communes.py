#!/usr/bin/env python3
"""Construit un inventaire exploratoire des communes mentionnées dans les biographies.

Les lieux sont des candidats extraits du texte, jamais des faits validés. Le script
ne modifie aucune page du site et ne crée aucune page publiée.
"""
from __future__ import annotations

import csv
import html
import re
from collections import defaultdict
from html.parser import HTMLParser
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = Path("rapport-communes")
# Motif volontairement conservateur : un nom de lieu proche d'une parenthèse
# contenant un code départemental. Chaque occurrence reste à vérifier.
PLACE_RE = re.compile(
    r"\b(?i:à|de|dans la commune de|sur la commune de|né[e]? à|naît à)\s+"
    r"([A-ZÀ-Ö][A-Za-zÀ-ÿ'’.-]*(?:[ -][A-ZÀ-Ö][A-Za-zÀ-ÿ'’.-]*){0,4})"
    r"\s*\(([^)]{0,100}\b\d{2,3}\b[^)]*)\)"
)
SKIP_DIRS = {".git", ".github", "scripts", "tests", "portraits", "data", "assets", "enfants"}



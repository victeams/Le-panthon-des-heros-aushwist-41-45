#!/usr/bin/env python3
"""Construit automatiquement les catalogues 31000/45000 et le SEO du site.

Le script ne déplace jamais une biographie existante. Il classe chaque fichier
HTML dans femmes.html ou hommes.html, extrait une miniature depuis la première
image Base64 si nécessaire, puis régénère les fichiers publics du site.
"""

from __future__ import annotations

import argparse
import base64
import json
import re
import sys
import unicodedata
from dataclasses import asdict, dataclass
from html import escape, unescape
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import quote


DEFAULT_BASE_URL = (
    "https://victeams.github.io/Le-panthon-des-heros-aushwist-41-45"
)
DEFAULT_GOOGLE_VERIFICATION = "ag4W_c6-FAZV00AVo1jU8mvPpiRYZbypbN6FLHfmds0"
GENERATED_HTML = {"index.html", "femmes.html", "hommes.html"}
EXCLUDED_DIRS = {".git", ".github", "scripts", "tests", "portraits"}
IMAGE_EXTENSIONS = (".jpg", ".jpeg", ".png", ".webp", ".gif")
# Exception historique : cette fiche publiée ne contient ni matricule ni
# balise de convoi. La conserver explicitement rend les reconstructions
# successives idempotentes, même après le remplacement de l'ancien index.
LEGACY_GROUPS = {
    "jeannine_dite_jeanne_herschtel.html": "femmes",
}


def clean_text(value: str) -> str:
    value = re.sub(r"<[^>]+>", " ", value)
    return re.sub(r"\s+", " ", unescape(value)).strip()


def normalized(value: str) -> str:
    value = unicodedata.normalize("NFKD", value)
    value = "".join(char for char in value if not unicodedata.combining(char))
    return re.sub(r"[^a-z0-9]+", " ", value.casefold()).strip()


def shorten(value: str, maximum: int = 155) -> str:
    value = clean_text(value)
    if len(value) <= maximum:
        return value
    shortened = value[: maximum + 1].rsplit(" ", 1)[0].rstrip(" ,;:-")
    return f"{shortened}…"


class BiographyHTMLParser(HTMLParser):
    """Extrait les informations utiles sans dépendance extérieure."""

    def __init__(self) -> None:
        super().__init__(convert_charrefs=True)
        self.values: dict[str, list[str]] = {
            key: [] for key in ("title", "h1", "h2", "meta", "status", "text", "paragraph")
        }
        self.started: set[str] = set()
        self.stack: list[tuple[str, set[str], bool]] = []
        self.hidden_depth = 0
        self.all_text: list[str] = []
        self.first_image: str | None = None
        self.description: str | None = None
        self.explicit_convoi: str | None = None

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        tag = tag.casefold()
        attributes = {key.casefold(): (value or "") for key, value in attrs}
        classes = set(attributes.get("class", "").casefold().split())
        captures: set[str] = set()

        if tag in {"script", "style"}:
            self.hidden_depth += 1

        for key, condition in (
            ("title", tag == "title"),
            ("h1", tag == "h1"),
            ("h2", tag == "h2"),
            ("meta", "meta" in classes),
            ("status", "status" in classes),
            ("text", "text" in classes),
            ("paragraph", tag == "p"),
        ):
            if condition and key not in self.started:
                captures.add(key)
                self.started.add(key)

        if tag == "img" and self.first_image is None:
            self.first_image = attributes.get("src") or None

        if tag == "meta":
            name = attributes.get("name", "").casefold()
            if name == "description":
                self.description = attributes.get("content") or None
            if name in {"convoi", "deportation-convoi", "groupe"}:
                self.explicit_convoi = attributes.get("content") or None

        self.stack.append((tag, captures, tag in {"script", "style"}))

    def handle_startendtag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        self.handle_starttag(tag, attrs)
        self.handle_endtag(tag)

    def handle_endtag(self, tag: str) -> None:
        tag = tag.casefold()
        if not self.stack:
            return
        # Les fiches actuelles sont bien formées. Cette recherche rend tout de
        # même l'extracteur tolérant à une balise fermante légèrement décalée.
        index = len(self.stack) - 1
        while index >= 0 and self.stack[index][0] != tag:
            index -= 1
        if index < 0:
            return
        removed = self.stack[index:]
        del self.stack[index:]
        self.hidden_depth -= sum(1 for _, _, hidden in removed if hidden)
        self.hidden_depth = max(0, self.hidden_depth)

    def handle_data(self, data: str) -> None:
        if self.hidden_depth:
            return
        if data.strip():
            self.all_text.append(data)
        for _, captures, _ in self.stack:
            for key in captures:
                self.values[key].append(data)

    def value(self, key: str) -> str:
        return clean_text(" ".join(self.values[key]))


def group_for_number(number: str) -> str | None:
    if number == "31000" or number == "45000":
        return None
    if re.fullmatch(r"31\d{3}", number):
        return "femmes"
    if re.fullmatch(r"(?:45|46)\d{3}", number):
        return "hommes"
    return None


def numbers_in(value: str) -> list[str]:
    return [number for number in re.findall(r"(?<!\d)\d{5}(?!\d)", value) if group_for_number(number)]


def classify(path: Path, parser: BiographyHTMLParser) -> tuple[str | None, str | None, str]:
    explicit = normalized(parser.explicit_convoi or "")
    if "31000" in explicit or "femme" in explicit:
        return "femmes", None, "balise convoi"
    if "45000" in explicit or "homme" in explicit:
        return "hommes", None, "balise convoi"

    parts = {part.casefold() for part in path.parts}
    if "femmes" in parts:
        return "femmes", None, "dossier femmes"
    if "hommes" in parts:
        return "hommes", None, "dossier hommes"

    for source_name, source in (
        ("nom du fichier", path.stem),
        ("ligne matricule", parser.value("meta")),
        ("titre", f"{parser.value('h1')} {parser.value('title')}"),
    ):
        candidates = numbers_in(source)
        groups = {group_for_number(number) for number in candidates}
        groups.discard(None)
        if len(groups) == 1:
            return groups.pop(), candidates[0], source_name

    visible = clean_text(" ".join(parser.all_text))
    visible_norm = normalized(visible)
    has_31000 = bool(re.search(r"convoi(?: des| dit)? 31000", visible_norm))
    has_45000 = bool(re.search(r"convoi(?: des| dit)? 45000", visible_norm))
    if has_31000 and not has_45000:
        return "femmes", None, "mention du convoi"
    if has_45000 and not has_31000:
        return "hommes", None, "mention du convoi"

    candidates = numbers_in(visible)
    groups = {group_for_number(number) for number in candidates}
    groups.discard(None)
    if len(groups) == 1:
        return groups.pop(), candidates[0] if candidates else None, "contenu visible"
    if len(groups) > 1:
        return None, None, "plusieurs matricules de groupes différents"
    return None, None, "aucun matricule 31xxx, 45xxx ou 46xxx reconnu"


def url_for(base_url: str, relative_path: str) -> str:
    return f"{base_url.rstrip('/')}/{quote(relative_path, safe='/')}"


def existing_portrait_map(index_path: Path) -> dict[str, str]:
    if not index_path.exists():
        return {}
    content = index_path.read_text(encoding="utf-8", errors="replace")
    result: dict[str, str] = {}
    for article in re.findall(r"<article\b[\s\S]*?</article>", content, re.IGNORECASE):
        href = re.search(r"href=[\"']([^\"']+\.html)[\"']", article, re.IGNORECASE)
        image = re.search(r"<img\b[^>]*src=[\"']([^\"']+)[\"']", article, re.IGNORECASE)
        if href and image and not image.group(1).startswith("data:"):
            result[href.group(1).lstrip("./")] = image.group(1).lstrip("./")
    return result


def safe_local_image(root: Path, biography: Path, source: str | None) -> Path | None:
    if not source or source.startswith(("data:", "http://", "https://", "//")):
        return None
    candidate = (biography.parent / source.split("?", 1)[0].split("#", 1)[0]).resolve()
    try:
        candidate.relative_to(root.resolve())
    except ValueError:
        return None
    return candidate if candidate.is_file() else None


def extract_data_image(source: str | None) -> tuple[bytes, str] | None:
    if not source:
        return None
    match = re.match(r"data:(image/(?:jpeg|jpg|png|webp|gif));base64,(.+)", source, re.I | re.S)
    if not match:
        return None
    mime = match.group(1).casefold()
    extension = {"image/jpeg": ".jpg", "image/jpg": ".jpg"}.get(mime, f".{mime.split('/')[-1]}")
    try:
        return base64.b64decode(re.sub(r"\s+", "", match.group(2))), extension
    except (ValueError, base64.binascii.Error):
        return None


def find_or_create_portrait(
    root: Path,
    biography: Path,
    parser: BiographyHTMLParser,
    old_map: dict[str, str],
) -> str | None:
    relative_bio = biography.relative_to(root).as_posix()
    mapped = old_map.get(relative_bio)
    if mapped and (root / mapped).is_file():
        return mapped

    portrait_dir = root / "portraits"
    portrait_dir.mkdir(exist_ok=True)
    for extension in IMAGE_EXTENSIONS:
        for candidate in (portrait_dir / f"{biography.stem}{extension}", portrait_dir / f"{biography.stem}{extension.upper()}"):
            if candidate.is_file():
                return candidate.relative_to(root).as_posix()

    local = safe_local_image(root, biography, parser.first_image)
    if local:
        return local.relative_to(root).as_posix()

    extracted = extract_data_image(parser.first_image)
    if extracted:
        payload, extension = extracted
        target = portrait_dir / f"{biography.stem}{extension}"
        if not target.exists():
            target.write_bytes(payload)
        return target.relative_to(root).as_posix()
    return None


def normalized_status(raw_status: str, group: str) -> tuple[str, str]:
    raw = normalized(raw_status)
    if any(word in raw for word in ("rescape", "survivant", "libere")):
        return ("Rescapée" if group == "femmes" else "Rescapé"), "survivor"
    if any(word in raw for word in ("morte", "mort ", "decede", "assassine", "disparu")):
        return ("Morte en déportation" if group == "femmes" else "Mort en déportation"), "death"
    return "Notice commémorative", "other"


@dataclass
class Biography:
    name: str
    file: str
    group: str
    matricule: str | None
    subtitle: str
    status: str
    status_class: str
    portrait: str | None
    description: str
    search: str


def parse_biography(root: Path, path: Path, old_map: dict[str, str]) -> tuple[Biography | None, str]:
    content = path.read_text(encoding="utf-8", errors="replace")
    parser = BiographyHTMLParser()
    parser.feed(content)
    relative = path.relative_to(root).as_posix()
    group, matricule, reason = classify(path.relative_to(root), parser)
    # L'index historique ne contenait que les femmes du convoi des 31000.
    # Ce repère protège les rares fiches déjà publiées sans matricule, comme
    # celle de Jeannine Herschtel, lors de la première reconstruction.
    if not group and relative in old_map:
        group, reason = "femmes", "index historique des 31000"
    if not group and relative.casefold() in LEGACY_GROUPS:
        group, reason = LEGACY_GROUPS[relative.casefold()], "exception historique documentée"
    if not group:
        return None, reason

    name = parser.value("h1") or parser.value("title") or parser.value("h2") or path.stem.replace("_", " ").title()
    if not matricule:
        candidates = numbers_in(parser.value("meta")) or numbers_in(" ".join(parser.all_text))
        matching = [number for number in candidates if group_for_number(number) == group]
        matricule = matching[0] if matching else None

    meta_text = parser.value("meta")
    subtitle = f"Matricule {matricule}" if matricule else (shorten(meta_text, 80) or ("Convoi des 31000" if group == "femmes" else "Convoi des 45000"))
    status, status_class = normalized_status(parser.value("status"), group)
    portrait = find_or_create_portrait(root, path, parser, old_map)
    description_source = parser.description or parser.value("text") or parser.value("paragraph")
    description = shorten(description_source) or f"Biographie commémorative de {name}."
    search = normalized(f"{name} {matricule or ''} {subtitle} {status}")
    return Biography(name, relative, group, matricule, subtitle, status, status_class, portrait, description, search), reason


def biography_paths(root: Path) -> list[Path]:
    result: list[Path] = []
    for path in root.rglob("*.html"):
        relative = path.relative_to(root)
        if path.name in GENERATED_HTML or any(part in EXCLUDED_DIRS for part in relative.parts[:-1]):
            continue
        result.append(path)
    return sorted(result, key=lambda item: normalized(item.as_posix()))


COMMON_CSS = """
:root{color-scheme:dark;--bg:#0b0d10;--panel:#15191f;--panel2:#1c222a;--text:#f4f1e8;--muted:#b9c0c8;--gold:#d4ad62;--line:#303844;--green:#8fd3a8;--rose:#e6a6ad}
*{box-sizing:border-box}html{scroll-behavior:smooth}body{margin:0;background:radial-gradient(circle at 20% 0,#202630 0,transparent 35%),var(--bg);color:var(--text);font-family:Arial,Helvetica,sans-serif;line-height:1.6}a{color:inherit}
.hero{padding:56px 22px 38px;text-align:center;border-bottom:1px solid var(--line)}.eyebrow{margin:0 0 10px;color:var(--gold);font-size:.82rem;font-weight:700;letter-spacing:.18em;text-transform:uppercase}.hero h1{max-width:900px;margin:0 auto;font-family:Georgia,serif;font-size:clamp(2rem,5vw,3.8rem);line-height:1.1}.intro{max-width:780px;margin:20px auto 0;color:var(--muted);font-size:1.05rem}
.nav{display:flex;justify-content:center;flex-wrap:wrap;gap:9px;margin:25px auto 0}.nav a,.button{display:inline-block;padding:10px 15px;border:1px solid #5b5140;border-radius:999px;color:var(--gold);text-decoration:none;font-weight:700}.nav a:hover,.button:hover{background:#d4ad6217}
.stats{display:flex;flex-wrap:wrap;justify-content:center;gap:10px;margin:26px auto 0}.stat{min-width:130px;padding:10px 16px;background:#11151a;border:1px solid var(--line);border-radius:999px}.stat strong{color:var(--gold)}
main{max-width:1180px;margin:0 auto;padding:34px 22px 64px}.collections{display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));gap:18px}.collection{padding:28px;background:linear-gradient(145deg,var(--panel2),var(--panel));border:1px solid var(--line);border-radius:15px;box-shadow:0 12px 30px #0004}.collection h2{margin:0 0 9px;font-family:Georgia,serif;font-size:1.7rem}.collection p{color:var(--muted)}
.tools{position:sticky;top:0;z-index:5;padding:14px 0;background:linear-gradient(var(--bg) 75%,transparent)}label.visually-hidden{position:absolute;width:1px;height:1px;overflow:hidden;clip:rect(0,0,0,0)}input{width:100%;padding:15px 18px;border:1px solid #414b58;border-radius:12px;background:#101419;color:var(--text);font-size:1rem;outline:none}input:focus{border-color:var(--gold);box-shadow:0 0 0 3px #d4ad6224}.result{margin:7px 4px 0;color:var(--muted);font-size:.92rem}
.grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(270px,1fr));gap:16px;margin-top:18px}.card{display:flex;min-height:405px;flex-direction:column;padding:0 22px 22px;overflow:hidden;background:linear-gradient(145deg,var(--panel2),var(--panel));border:1px solid var(--line);border-radius:14px;box-shadow:0 12px 30px #0004;transition:transform .18s,border-color .18s}.card:hover{transform:translateY(-3px);border-color:#706141}.card[hidden]{display:none}.portrait-link{display:block;height:230px;margin:0 -22px 18px;overflow:hidden;background:#080a0c}.portrait{width:100%;height:100%;object-fit:contain;display:block}.portrait-missing{display:flex;height:100%;align-items:center;justify-content:center;color:#79818b;text-align:center;padding:20px}.badge{display:inline-block;padding:4px 9px;border-radius:999px;font-size:.73rem;font-weight:700}.survivor{color:#baf2cb;background:#173824}.death{color:#ffd2d6;background:#412329}.other{color:#d7dde5;background:#303844}.card h2{margin:15px 0 8px;font-family:Georgia,serif;font-size:1.35rem;line-height:1.25}.card p{margin:0 0 18px;color:var(--muted)}.card>a:last-child{margin-top:auto;color:var(--gold);font-weight:700;text-decoration:none}.empty{padding:40px;text-align:center;color:var(--muted);border:1px dashed var(--line);border-radius:14px}footer{padding:24px;text-align:center;border-top:1px solid var(--line);color:var(--muted);font-size:.9rem}
@media(max-width:560px){.hero{padding-top:42px}.stat{min-width:105px}.grid{grid-template-columns:1fr}.card{min-height:200px}}
""".strip()


def head_markup(title: str, description: str, canonical: str, structured: dict, verification: str | None = None) -> str:
    verification_tag = (
        f'\n  <meta name="google-site-verification" content="{escape(verification, quote=True)}">'
        if verification
        else ""
    )
    structured_json = json.dumps(structured, ensure_ascii=False, separators=(",", ":")).replace("</", "<\\/")
    return f"""<meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="{escape(description, quote=True)}">
  <meta name="robots" content="index,follow,max-image-preview:large">
  <link rel="canonical" href="{escape(canonical, quote=True)}">{verification_tag}
  <meta property="og:type" content="website">
  <meta property="og:locale" content="fr_FR">
  <meta property="og:title" content="{escape(title, quote=True)}">
  <meta property="og:description" content="{escape(description, quote=True)}">
  <meta property="og:url" content="{escape(canonical, quote=True)}">
  <meta name="twitter:card" content="summary">
  <title>{escape(title)}</title>
  <script type="application/ld+json">{structured_json}</script>"""


def card_markup(person: Biography) -> str:
    href = quote(person.file, safe="/")
    if person.portrait:
        visual = f'<img class="portrait" src="{quote(person.portrait, safe="/")}" alt="Portrait de {escape(person.name, quote=True)}" loading="lazy">'
    else:
        visual = '<span class="portrait-missing">Portrait non disponible</span>'
    return f"""      <article class="card" data-search="{escape(person.search, quote=True)}">
        <a class="portrait-link" href="{href}" aria-label="Ouvrir la fiche de {escape(person.name, quote=True)}">{visual}</a>
        <div><span class="badge {person.status_class}">{escape(person.status)}</span></div>
        <h2>{escape(person.name)}</h2>
        <p>{escape(person.subtitle)}</p>
        <a href="{href}">Lire la fiche <span aria-hidden="true">→</span></a>
      </article>"""


FILTER_SCRIPT = """
  const input=document.getElementById('search');
  const cards=[...document.querySelectorAll('.card')];
  const result=document.getElementById('result');
  const normalize=value=>value.normalize('NFD').replace(/[\u0300-\u036f]/g,'').toLowerCase();
  input.addEventListener('input',()=>{
    const query=normalize(input.value.trim());let count=0;
    cards.forEach(card=>{const visible=!query||normalize(card.dataset.search).includes(query);card.hidden=!visible;if(visible)count++;});
    result.textContent=`${count} fiche${count>1?'s':''} affichée${count>1?'s':''}`;
  });
""".strip()


def collection_page(base_url: str, people: list[Biography], group: str) -> str:
    is_women = group == "femmes"
    label = "Femmes du convoi des 31000" if is_women else "Hommes du convoi des 45000"
    intro = (
        "Retrouvez les biographies commémoratives des femmes déportées depuis Compiègne vers Auschwitz le 24 janvier 1943."
        if is_women
        else "Retrouvez les biographies commémoratives des hommes déportés dans le convoi dit des 45000 vers Auschwitz le 6 juillet 1942."
    )
    filename = f"{group}.html"
    canonical = url_for(base_url, filename)
    structured = {
        "@context": "https://schema.org",
        "@type": "CollectionPage",
        "name": label,
        "description": intro,
        "url": canonical,
        "inLanguage": "fr",
        "isPartOf": {"@type": "WebSite", "name": "Le Panthéon des héros 1939-1945", "url": f"{base_url}/"},
    }
    cards = "\n".join(card_markup(person) for person in people)
    if not cards:
        cards = '<p class="empty">Aucune fiche n’est encore publiée dans cette section.</p>'
    return f"""<!DOCTYPE html>
<html lang="fr">
<head>
  {head_markup(f"{label} — Le Panthéon des héros", intro, canonical, structured)}
  <style>{COMMON_CSS}</style>
</head>
<body>
  <header class="hero">
    <p class="eyebrow">Mémoire • Résistance • Déportation</p>
    <h1>{escape(label)}</h1>
    <p class="intro">{escape(intro)}</p>
    <nav class="nav" aria-label="Navigation principale"><a href="index.html">Accueil</a><a href="femmes.html">Femmes 31000</a><a href="hommes.html">Hommes 45000</a></nav>
    <div class="stats"><span class="stat"><strong>{len(people)}</strong> fiche{'s' if len(people) != 1 else ''}</span></div>
  </header>
  <main>
    <div class="tools">
      <label class="visually-hidden" for="search">Rechercher une personne ou un matricule</label>
      <input id="search" type="search" placeholder="Rechercher un nom ou un matricule…" autocomplete="off">
      <p class="result" id="result" aria-live="polite">{len(people)} fiche{'s' if len(people) != 1 else ''} affichée{'s' if len(people) != 1 else ''}</p>
    </div>
    <section class="grid" aria-label="Liste des biographies">
{cards}
    </section>
  </main>
  <footer>Préserver leur histoire, transmettre leur mémoire.</footer>
  <script>{FILTER_SCRIPT}</script>
</body>
</html>
"""


HOME_SEARCH_SCRIPT = """
  const input=document.getElementById('global-search');
  const result=document.getElementById('global-result');
  const grid=document.getElementById('global-grid');
  const normalize=value=>value.normalize('NFD').replace(/[\u0300-\u036f]/g,'').toLowerCase();
  let people=[];
  fetch('site-data.json').then(response=>response.json()).then(data=>{people=data;});
  input.addEventListener('input',()=>{
    const query=normalize(input.value.trim());grid.replaceChildren();
    if(query.length<2){result.textContent='Saisissez au moins deux caractères.';return;}
    const matches=people.filter(person=>normalize(person.search).includes(query)).slice(0,60);
    matches.forEach(person=>{
      const article=document.createElement('article');article.className='card';
      const visual=document.createElement('a');visual.className='portrait-link';visual.href=person.file;
      if(person.portrait){const image=document.createElement('img');image.className='portrait';image.src=person.portrait;image.alt=`Portrait de ${person.name}`;image.loading='lazy';visual.append(image);}else{const missing=document.createElement('span');missing.className='portrait-missing';missing.textContent='Portrait non disponible';visual.append(missing);}
      const top=document.createElement('div');const badge=document.createElement('span');badge.className=`badge ${person.status_class}`;badge.textContent=person.status;top.append(badge);
      const title=document.createElement('h2');title.textContent=person.name;const subtitle=document.createElement('p');subtitle.textContent=person.subtitle;
      const link=document.createElement('a');link.href=person.file;link.textContent='Lire la fiche →';article.append(visual,top,title,subtitle,link);grid.append(article);
    });
    result.textContent=`${matches.length} résultat${matches.length>1?'s':''}${matches.length===60?' maximum':''}`;
  });
""".strip()


def home_page(base_url: str, women: list[Biography], men: list[Biography], verification: str) -> str:
    total = len(women) + len(men)
    title = "Le Panthéon des héros 1939-1945"
    description = "Portraits et biographies documentées de femmes et d’hommes résistants et déportés, afin de préserver leur histoire et transmettre leur mémoire."
    structured = {
        "@context": "https://schema.org",
        "@type": "WebSite",
        "name": title,
        "description": description,
        "url": f"{base_url}/",
        "inLanguage": "fr",
    }
    return f"""<!DOCTYPE html>
<html lang="fr">
<head>
  {head_markup(title, description, f"{base_url}/", structured, verification)}
  <style>{COMMON_CSS}</style>
</head>
<body>
  <header class="hero">
    <p class="eyebrow">Mémoire • Résistance • Déportation</p>
    <h1>{title}</h1>
    <p class="intro">{description}</p>
    <nav class="nav" aria-label="Navigation principale"><a href="femmes.html">Femmes 31000</a><a href="hommes.html">Hommes 45000</a></nav>
    <div class="stats"><span class="stat"><strong>{total}</strong> fiches</span><span class="stat"><strong>{len(women)}</strong> femmes</span><span class="stat"><strong>{len(men)}</strong> hommes</span></div>
  </header>
  <main>
    <section class="collections" aria-label="Collections">
      <article class="collection"><h2>Femmes du convoi des 31000</h2><p>{len(women)} biographies actuellement accessibles.</p><a class="button" href="femmes.html">Découvrir les femmes</a></article>
      <article class="collection"><h2>Hommes du convoi des 45000</h2><p>{len(men)} biographie{'s' if len(men) != 1 else ''} actuellement accessible{'s' if len(men) != 1 else ''}.</p><a class="button" href="hommes.html">Découvrir les hommes</a></article>
    </section>
    <section aria-labelledby="search-title" style="margin-top:38px">
      <h2 id="search-title">Rechercher dans toutes les biographies</h2>
      <label class="visually-hidden" for="global-search">Nom ou matricule</label>
      <input id="global-search" type="search" placeholder="Rechercher un nom ou un matricule…" autocomplete="off">
      <p class="result" id="global-result" aria-live="polite">Saisissez au moins deux caractères.</p>
      <div class="grid" id="global-grid"></div>
    </section>
  </main>
  <footer>Préserver leur histoire, transmettre leur mémoire.</footer>
  <script>{HOME_SEARCH_SCRIPT}</script>
</body>
</html>
"""


def sitemap_xml(base_url: str, people: list[Biography]) -> str:
    entries: list[tuple[str, str | None]] = [
        (f"{base_url}/", None),
        (url_for(base_url, "femmes.html"), None),
        (url_for(base_url, "hommes.html"), None),
    ]
    entries.extend((url_for(base_url, person.file), url_for(base_url, person.portrait) if person.portrait else None) for person in people)
    body: list[str] = []
    for location, image in entries:
        image_markup = f"<image:image><image:loc>{escape(image)}</image:loc></image:image>" if image else ""
        body.append(f"  <url><loc>{escape(location)}</loc>{image_markup}</url>")
    return "\n".join(
        [
            '<?xml version="1.0" encoding="UTF-8"?>',
            '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:image="http://www.google.com/schemas/sitemap-image/1.1">',
            *body,
            "</urlset>",
            "",
        ]
    )


def build(root: Path, base_url: str, verification: str) -> tuple[int, int, list[str]]:
    root = root.resolve()
    base_url = base_url.rstrip("/")
    old_map = existing_portrait_map(root / "index.html")
    biographies: list[Biography] = []
    warnings: list[str] = []

    for path in biography_paths(root):
        person, reason = parse_biography(root, path, old_map)
        if person:
            biographies.append(person)
            if not person.portrait:
                warnings.append(f"IMAGE MANQUANTE — {person.file}")
        else:
            warnings.append(f"NON CLASSÉ — {path.relative_to(root).as_posix()} — {reason}")

    biographies.sort(key=lambda person: (normalized(person.name), person.file))
    women = [person for person in biographies if person.group == "femmes"]
    men = [person for person in biographies if person.group == "hommes"]

    seen: dict[tuple[str, str], str] = {}
    for person in biographies:
        if not person.matricule:
            continue
        key = person.group, person.matricule
        if key in seen:
            warnings.append(f"DOUBLON À VÉRIFIER — matricule {person.matricule} — {seen[key]} / {person.file}")
        else:
            seen[key] = person.file

    (root / "index.html").write_text(home_page(base_url, women, men, verification), encoding="utf-8")
    (root / "femmes.html").write_text(collection_page(base_url, women, "femmes"), encoding="utf-8")
    (root / "hommes.html").write_text(collection_page(base_url, men, "hommes"), encoding="utf-8")
    (root / "sitemap.xml").write_text(sitemap_xml(base_url, biographies), encoding="utf-8")
    (root / "robots.txt").write_text(f"User-agent: *\nAllow: /\n\nSitemap: {base_url}/sitemap.xml\n", encoding="utf-8")
    public_data = [
        {
            **asdict(person),
            "file": quote(person.file, safe="/"),
            "portrait": quote(person.portrait, safe="/") if person.portrait else None,
        }
        for person in biographies
    ]
    (root / "site-data.json").write_text(json.dumps(public_data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    report = [
        "RAPPORT AUTOMATIQUE DU CLASSEMENT",
        "================================",
        f"Femmes 31000 : {len(women)}",
        f"Hommes 45000 : {len(men)}",
        f"À vérifier : {len(warnings)}",
        "",
        *(warnings or ["Aucune anomalie détectée."]),
        "",
    ]
    (root / "a_verifier.txt").write_text("\n".join(report), encoding="utf-8")
    print(f"Site reconstruit : {len(women)} femmes, {len(men)} hommes, {len(warnings)} avertissement(s).")
    return len(women), len(men), warnings


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--base-url", default=DEFAULT_BASE_URL)
    parser.add_argument("--google-verification", default=DEFAULT_GOOGLE_VERIFICATION)
    arguments = parser.parse_args(argv)
    build(arguments.root, arguments.base_url, arguments.google_verification)
    return 0


if __name__ == "__main__":
    sys.exit(main())

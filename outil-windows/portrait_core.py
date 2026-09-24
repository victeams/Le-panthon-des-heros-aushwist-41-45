from __future__ import annotations

import html
import re
import shutil
import subprocess
import unicodedata
import webbrowser
from dataclasses import dataclass
from pathlib import Path
from urllib.parse import urlparse


BASE_URL = "https://memoiredesdeportes.fr"
VALID_IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp", ".gif"}


@dataclass
class PortraitData:
    name: str
    matricule: str
    birth_name: str
    status: str
    biography: str
    source_url: str
    source_name: str
    photo_path: str = ""
    photo_credit: str = ""
    photo_rights: str = "Droits réservés"


def find_repository(start: Path | None = None) -> Path:
    candidates = []
    if start:
        candidates.append(start.resolve())
    candidates.extend([Path.cwd().resolve(), Path(__file__).resolve().parent])
    for candidate in candidates:
        for folder in (candidate, *candidate.parents):
            if (folder / ".git").is_dir() and (folder / "scripts" / "build_site.py").is_file():
                return folder
    raise ValueError("Dépôt du mémorial introuvable. Sélectionnez son dossier.")


def slugify(value: str) -> str:
    value = unicodedata.normalize("NFKD", value)
    value = "".join(char for char in value if not unicodedata.combining(char))
    return re.sub(r"[^a-z0-9]+", "-", value.casefold()).strip("-")


def group_for_matricule(matricule: str) -> str:
    if re.fullmatch(r"31\d{3}", matricule):
        return "femmes"
    if re.fullmatch(r"(?:45|46)\d{3}", matricule):
        return "hommes"
    raise ValueError("Le matricule doit commencer par 31, 45 ou 46 et contenir cinq chiffres.")


def validate(data: PortraitData) -> None:
    if len(data.name.strip()) < 3:
        raise ValueError("Indiquez le prénom et le nom.")
    group_for_matricule(data.matricule.strip())
    if len(data.biography.strip()) < 40:
        raise ValueError("Le texte biographique est trop court.")
    parsed = urlparse(data.source_url.strip())
    if parsed.scheme not in {"http", "https"} or not parsed.netloc:
        raise ValueError("Indiquez une URL de source complète commençant par http:// ou https://.")
    if not data.source_name.strip():
        raise ValueError("Indiquez le nom de l’organisme ou du site source.")
    if data.photo_path:
        photo = Path(data.photo_path)
        if not photo.is_file() or photo.suffix.casefold() not in VALID_IMAGE_EXTENSIONS:
            raise ValueError("La photographie sélectionnée est introuvable ou son format n’est pas accepté.")
        if not data.photo_credit.strip():
            raise ValueError("Indiquez obligatoirement le crédit de la photographie.")


GUIDED_SECTION_ORDER = ("origins", "engagement", "arrest", "deportation", "afterwar", "memory")


def compose_guided_biography(sections: dict[str, str]) -> str:
    """Assemble des faits rédigés par l’utilisateur dans l’ordre du mémorial."""
    blocks = [sections.get(key, "").strip() for key in GUIDED_SECTION_ORDER]
    blocks = [block for block in blocks if block]
    if len(blocks) < 3:
        raise ValueError("Le mode guidé nécessite au moins trois parties renseignées.")
    return "\n\n".join(blocks)


def paragraphs(text: str) -> str:
    blocks = [block.strip() for block in re.split(r"\n\s*\n", text.strip()) if block.strip()]
    return "\n".join(f"<p>{html.escape(block).replace(chr(10), '<br>')}</p>" for block in blocks)


def portrait_html(data: PortraitData, filename: str, image_reference: str, has_photo: bool) -> str:
    group = group_for_matricule(data.matricule)
    group_label = "Convoi des 31 000" if group == "femmes" else "Convoi des 45 000"
    status_labels = {
        "Rescapé(e) de la déportation": "🌿 Rescapé(e) de la déportation",
        "Mort(e) en déportation": "🕊️ Mort(e) en déportation",
        "Notice commémorative": "Notice commémorative",
    }
    title = html.escape(data.name.strip())
    birth = f'<div class="meta">Né(e) {html.escape(data.birth_name.strip())}</div>' if data.birth_name.strip() else ""
    source_url = html.escape(data.source_url.strip(), quote=True)
    source_name = html.escape(data.source_name.strip())
    if has_photo:
        alt = f"Portrait documenté de {title}"
        caption = f"© {html.escape(data.photo_credit.strip())}."
        photo_note = (
            f'<strong>Crédit de la photographie :</strong> {html.escape(data.photo_credit.strip())}. '
            f'<strong>Statut des droits :</strong> {html.escape(data.photo_rights.strip() or "Droits réservés")}.'
        )
        figure_class = "portrait-documente"
    else:
        alt = f"Photographie non retrouvée pour {title}"
        caption = "Photographie individuelle non retrouvée. Image de remplacement."
        photo_note = "<strong>Photographie :</strong> aucune photographie individuelle publiée."
        figure_class = "portrait-absent portrait-remplacement"
    canonical = f"{BASE_URL}/{filename}"
    return f'''<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width,initial-scale=1.0">
  <meta name="convoi" content="{group_label}">
  <title>{title} | Mémoire des Déportés</title>
  <meta name="description" content="Portrait et biographie de {title}, matricule {data.matricule}.">
  <link rel="canonical" href="{canonical}">
  <style>body{{margin:0;background:#0f0f10;color:#f2f2f2;font-family:Arial,Helvetica,sans-serif;line-height:1.72}}.page{{max-width:920px;margin:auto;padding:28px 22px 50px}}.header{{text-align:center}}h1{{margin:0 0 7px;font-size:2.15rem;letter-spacing:.4px}}.meta{{font-size:1.1rem;margin:4px}}.status{{font-weight:bold;margin-top:8px}}.photo{{display:block;width:100%;height:auto;max-width:760px;margin:28px auto 10px;border:2px solid #777}}.caption{{text-align:center;font-style:italic;color:#d8d8d8;margin-bottom:28px}}.text{{font-size:1.08rem;text-align:justify}}.text p{{margin:0 0 1.15em}}.documentation{{max-width:760px;margin:0 auto 24px;padding:12px 14px;border-left:3px solid #c4a25a;background:#151515;color:#cfcfcf;font:14px/1.55 Arial,sans-serif}}.documentation a{{color:#e0bd72}}@media(max-width:600px){{h1{{font-size:1.7rem}}.text{{text-align:left}}.page{{padding:22px 16px 38px}}}}</style>
  <link rel="stylesheet" href="{BASE_URL}/assets/memorial-ux.css?v=1">
</head>
<body>
  <main class="page">
    <header class="header"><h1>{title}</h1>{birth}<div class="meta"><strong>Matricule {data.matricule}</strong></div><div class="meta">{group_label}</div><div class="status">{status_labels[data.status]}</div></header>
    <figure class="{figure_class}"><img class="photo" src="{html.escape(image_reference, quote=True)}" alt="{alt}" loading="lazy"><figcaption class="caption">{caption}</figcaption></figure>
    <aside class="documentation" aria-label="Crédit photographique">{photo_note}</aside>
    <article class="text">{paragraphs(data.biography)}</article>
    <aside class="documentation" aria-label="Source biographique"><strong>Source biographique :</strong> <a href="{source_url}" target="_blank" rel="noopener noreferrer">{source_name}</a>. La notice reprend uniquement les informations fournies et vérifiées dans les documents indiqués.</aside>
  </main>
  <script defer src="{BASE_URL}/assets/memorial-ux.js?v=1" data-base="{BASE_URL}" data-home="{BASE_URL}/"></script>
</body>
</html>
'''


def create_portrait(repo: Path, data: PortraitData) -> tuple[Path, Path | None]:
    validate(data)
    slug = f"{slugify(data.name)}-{data.matricule}"
    html_path = repo / f"{slug}.html"
    if html_path.exists():
        raise FileExistsError(f"Une fiche existe déjà : {html_path.name}")
    image_path = None
    if data.photo_path:
        source = Path(data.photo_path)
        extension = ".jpg" if source.suffix.casefold() == ".jpeg" else source.suffix.casefold()
        image_path = repo / "portraits" / f"{slug}{extension}"
        image_path.parent.mkdir(parents=True, exist_ok=True)
        if image_path.exists():
            raise FileExistsError(f"Une image existe déjà : {image_path.name}")
        shutil.copy2(source, image_path)
        image_reference = image_path.relative_to(repo).as_posix()
    else:
        image_reference = "images/photo-non-trouvee-femmes.jpg"
    html_path.write_text(
        portrait_html(data, html_path.name, image_reference, image_path is not None),
        encoding="utf-8",
    )
    return html_path, image_path


def run_git(repo: Path, *arguments: str) -> str:
    process = subprocess.run(
        ["git", *arguments], cwd=repo, text=True, encoding="utf-8", errors="replace",
        stdout=subprocess.PIPE, stderr=subprocess.STDOUT, creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0),
    )
    if process.returncode:
        raise RuntimeError(process.stdout.strip() or f"Échec de git {' '.join(arguments)}")
    return process.stdout.strip()


def ensure_clean(repo: Path) -> None:
    if run_git(repo, "status", "--porcelain").strip():
        raise RuntimeError("Le dossier GitHub contient déjà des modifications non enregistrées. Publiez-les ou annulez-les avant de créer un nouveau portrait.")


def publish(repo: Path, html_path: Path, image_path: Path | None, name: str) -> str:
    files = [html_path.relative_to(repo).as_posix()]
    if image_path:
        files.append(image_path.relative_to(repo).as_posix())
    run_git(repo, "add", "--", *files)
    run_git(repo, "commit", "-m", f"Ajoute le portrait de {name.strip()}")
    try:
        run_git(repo, "pull", "--rebase", "origin", "main")
        output = run_git(repo, "push", "origin", "main")
    except Exception:
        try:
            run_git(repo, "rebase", "--abort")
        except Exception:
            pass
        raise
    return output


def preview(path: Path) -> None:
    webbrowser.open(path.resolve().as_uri())

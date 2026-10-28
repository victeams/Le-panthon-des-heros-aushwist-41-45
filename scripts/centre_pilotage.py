"""Rapport central en lecture seule pour Mémoire des Déportés."""
import json, os
from datetime import datetime, timezone
from pathlib import Path
from urllib.request import Request, urlopen
from urllib.error import HTTPError, URLError

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "rapports" / "centre-pilotage.md"
WORKFLOWS = [
    ("static.yml", "Construction et publication", "Déclenchements du dépôt"),
    ("controle-liens-pages.yml", "Contrôle des liens et pages", "Automatique"),
    ("controle-qualite-memorial.yml", "Contrôle qualité", "Automatique"),
    ("biographies-a-enrichir.yml", "Biographies à enrichir", "Automatique"),
    ("inventaire-communes.yml", "Inventaire des communes", "Automatique"),
    ("suivi-liens-mairies.yml", "Suivi des liens des mairies", "Automatique"),
    ("seo-indexing.yml", "SEO et indexation", "Selon le workflow"),
    ("update-photos.yml", "Actualisation des photos", "Manuel uniquement"),
    ("experience-visiteur.yml", "Expérience visiteurs", "Manuel uniquement"),
    ("fix-favicons.yml", "Gestion des favicons", "Manuel uniquement"),
    ("tiktok-memorial.yml", "Préparation quotidienne TikTok", "Automatique"),
    ("veille-memorial.yml", "Veille du mémorial", "Automatique"),
]
def html_count(path):
    return sum(1 for item in path.rglob("*.html") if item.is_file()) if path.is_dir() else 0
def latest_run(repository, token, filename):
    url = f"https://api.github.com/repos/{repository}/actions/workflows/{filename}/runs?per_page=5&branch=main"
    req = Request(url, headers={"Accept":"application/vnd.github+json", "Authorization":"Bearer "+token,
                                "X-GitHub-Api-Version":"2022-11-28", "User-Agent":"memorial-centre-pilotage"})
    with urlopen(req, timeout=20) as response:
        runs = json.loads(response.read().decode("utf-8")).get("workflow_runs", [])
    return max(runs, key=lambda r:r.get("created_at",""), default=None)
def main():
    root_html = sum(1 for item in ROOT.glob("*.html") if item.is_file())
    report = ["# Centre de pilotage — Mémoire des Déportés", "",
              "Généré le " + datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC"), "",
              "## Inventaire des pages", "", "| Emplacement | Fichiers HTML |", "|---|---:|",
              f"| Racine | {root_html} |", f"| hommes/ | {html_count(ROOT / 'hommes')} |",
              f"| femmes/ | {html_count(ROOT / 'femmes')} |", f"| enfants/ | {html_count(ROOT / 'enfants')} |", "",
              "## Dernières exécutions GitHub Actions", "",
              "| Automatisation | Statut récent | Date UTC | Mode prévu |", "|---|---|---|---|"]
    repository, token = os.getenv("GITHUB_REPOSITORY",""), os.getenv("GITHUB_TOKEN","")
    for filename, label, mode in WORKFLOWS:
        run, error = None, None
        if repository and token:
            try: run = latest_run(repository, token, filename)
            except (HTTPError, URLError, TimeoutError, json.JSONDecodeError) as exc: error = str(exc)
        else: error = "Jeton ou dépôt non disponible"
        if run:
            status = run.get("conclusion") or run.get("status") or "inconnu"
            date = run.get("created_at","—").replace("T"," ").replace("Z"," UTC")
            url = run.get("html_url","")
            status_text = f"[{status}]({url})" if url else status
        elif error:
            status_text = "Statut indisponible"
            mode += " — " + error[:90]
            date = "—"
        elif mode == "Manuel uniquement":
            status_text, date = "Aucun lancement récent (manuel)", "—"
        else:
            status_text, date = "Aucune exécution retrouvée", "—"
        report.append(f"| {label} | {status_text} | {date} | {mode} |")
    report += ["", "## Protection du mémorial", "",
               "Ce rapport est en lecture seule : il ne modifie aucune biographie, photo, catalogue ou sitemap.",
               "Les candidats de lieux et les propositions d'enrichissement doivent être vérifiés par une personne avant publication.",
               "Les workflows de mise à jour des photos, de l'expérience visiteurs et des favicons restent manuels afin d'éviter des modifications automatiques non sollicitées."]
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text("\n".join(report) + "\n", encoding="utf-8")
    print(OUT.read_text(encoding="utf-8"))
if __name__ == "__main__": main()

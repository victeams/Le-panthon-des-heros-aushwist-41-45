#!/usr/bin/env python3
"""Rapport central en lecture seule pour Mémoire des Déportés."""
import json
import os
from datetime import datetime, timezone
from pathlib import Path
from urllib.request import Request, urlopen
from urllib.error import HTTPError, URLError

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "rapports" / "centre-pilotage.md"
WORKFLOWS = {
    "static.yml": "Construction et publication",
    "controle-liens-pages.yml": "Contrôle des liens et pages",
    "controle-qualite-memorial.yml": "Contrôle qualité",
    "biographies-a-enrichir.yml": "Biographies à enrichir",
    "inventaire-communes.yml": "Inventaire des communes",
    "suivi-liens-mairies.yml": "Suivi des liens des mairies",
    "seo-indexing.yml": "SEO et indexation",
    "update-photos.yml": "Actualisation des photos",
    "experience-visiteur.yml": "Expérience visiteurs",
    "fix-favicons.yml": "Gestion des favicons",
}

def html_count(path):
    return sum(1 for item in path.rglob("*.html") if item.is_file()) if path.is_dir() else 0

def main():
    root_html = sum(1 for item in ROOT.glob("*.html") if item.is_file())
    report = ["# Centre de pilotage — Mémoire des Déportés", "",
              "Généré le " + datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC"), "",
              "## Inventaire des pages", "", "| Emplacement | Fichiers HTML |", "|---|---:|",
              f"| Racine | {root_html} |", f"| hommes/ | {html_count(ROOT / 'hommes')} |",
              f"| femmes/ | {html_count(ROOT / 'femmes')} |", f"| enfants/ | {html_count(ROOT / 'enfants')} |", "",
              "## Dernières exécutions GitHub Actions", "", "| Automatisation | Statut récent | Date UTC |", "|---|---|---|"]
    repository = os.getenv("GITHUB_REPOSITORY", "")
    token = os.getenv("GITHUB_TOKEN", "")
    error = None
    runs = []
    if repository and token:
        req = Request(f"https://api.github.com/repos/{repository}/actions/runs?per_page=100",
                      headers={"Accept": "application/vnd.github+json", "Authorization": "Bearer " + token,
                               "X-GitHub-Api-Version": "2022-11-28", "User-Agent": "memorial-centre-pilotage"})
        try:
            with urlopen(req, timeout=20) as response:
                runs = json.loads(response.read().decode("utf-8")).get("workflow_runs", [])
        except (HTTPError, URLError, TimeoutError, json.JSONDecodeError) as exc:
            error = str(exc)
    else:
        error = "Les variables GitHub nécessaires ne sont pas disponibles."
    latest = {}
    for run in runs:
        if run.get("head_branch") != "main":
            continue
        filename = run.get("path", "").rsplit("/", 1)[-1]
        if filename and (filename not in latest or run.get("created_at", "") > latest[filename].get("created_at", "")):
            latest[filename] = run
    for filename, label in WORKFLOWS.items():
        run = latest.get(filename)
        if not run:
            report.append(f"| {label} | Pas d'exécution trouvée dans les 100 dernières | — |")
        else:
            status = run.get("conclusion") or run.get("status") or "inconnu"
            date = run.get("created_at", "—").replace("T", " ").replace("Z", " UTC")
            url = run.get("html_url", "")
            report.append(f"| {label} | [{status}]({url}) | {date} |")
    report += ["", "## Protection du mémorial", "",
               "Ce rapport est en lecture seule : il ne modifie aucune biographie, photo, catalogue ou sitemap.",
               "Les propositions d'enrichissement doivent être vérifiées par une personne avant publication."]
    if error:
        report += ["", "## Avertissement", "", "Statuts Actions non récupérés : " + error]
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text("\n".join(report) + "\n", encoding="utf-8")
    print(OUT.read_text(encoding="utf-8"))

if __name__ == "__main__":
    main()

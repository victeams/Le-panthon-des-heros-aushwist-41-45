# Le Panthéon des héros 1939-1945

Site mémoriel publié gratuitement avec GitHub Pages. Les biographies sont classées automatiquement entre les femmes du convoi des 31000 et les hommes du convoi des 45000. Une base documentaire statique permet aussi de consulter les camps, bâtiments, convois, personnes, sources et inventaires historiques sans VPS.

## Ajouter une nouvelle biographie depuis Android

1. Ouvrir le dépôt GitHub.
2. Utiliser **Add file → Upload files**.
3. Déposer la fiche HTML à la racine du dépôt, à côté des autres biographies.
4. Valider l’ajout sur la branche `main`.

L’automatisation lit le matricule dans le nom du fichier ou dans la fiche :

- un matricule `31xxx` classe la personne dans `femmes.html` ;
- un matricule `45xxx` ou `46xxx` classe la personne dans `hommes.html`.

La première photo intégrée en Base64 dans le HTML est automatiquement extraite dans le dossier `portraits` pour créer la miniature. Il n’est donc normalement nécessaire de déposer que le fichier HTML.

Si aucun matricule n’est indiqué, ajouter dans le `<head>` de la fiche l’une de ces lignes :

```html
<meta name="convoi" content="31000">
```

ou

```html
<meta name="convoi" content="45000">
```

## Fichiers reconstruits automatiquement

- `index.html` : accueil et recherche générale ;
- `femmes.html` : catalogue des femmes du convoi des 31000 ;
- `hommes.html` : catalogue des hommes du convoi des 45000 ;
- `site-data.json` : moteur de recherche ;
- `sitemap.xml` et `robots.txt` : découverte par Google ;
- `a_verifier.txt` : fiches ambiguës, images manquantes et doublons possibles.

## Mettre à jour la base documentaire

La base SQL de référence se trouve dans `sources/` :

- `base-complete-auschwitz.sql` : données historiques, listes nominatives, chronologie et sources ;
- `inventaire-auschwitz-base-maitre.xlsx` : classeur maître facultatif utilisé pour régénérer les bâtiments, installations et personnels documentés.

Les données du classeur maître sont déjà converties dans `data/base-documentaire/`. Depuis Android, vous pourrez déposer une nouvelle version du classeur sous le nom exact `sources/inventaire-auschwitz-base-maitre.xlsx` lorsque vous voudrez les actualiser. En son absence, l’automatisation conserve les catégories déjà générées. GitHub Actions reconstruit automatiquement `base-documentaire.html` et les fichiers JSON découpés. Le visiteur ne charge qu’une catégorie à la fois, ce qui évite de télécharger immédiatement les 8 502 notices du registre du personnel SS.

Le script ne déplace et ne supprime aucune biographie existante. Les contrôles peuvent également être lancés manuellement depuis l’onglet **Actions** de GitHub.

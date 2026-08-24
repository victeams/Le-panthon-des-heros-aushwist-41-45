# Le Panthéon des héros 1939-1945

Site mémoriel publié gratuitement avec GitHub Pages. Les biographies sont classées automatiquement entre les femmes du convoi des 31000 et les hommes du convoi des 45000. Une base documentaire statique permet aussi de consulter les camps, bâtiments, convois, personnes, sources et inventaires historiques sans VPS.

La page `photos.html` présente également une photothèque historique issue de l’index français de l’United States Holocaust Memorial Museum. Les images restent hébergées à leur adresse d’origine ; chaque carte renvoie vers la notice, les crédits et les éventuelles restrictions d’utilisation.

## Ajouter une nouvelle biographie depuis Android

1. Ouvrir le dépôt GitHub.
2. Utiliser **Add file → Upload files**.
3. Pour un homme du convoi des 45000, ouvrir le dossier `hommes/` et y déposer la fiche HTML. Pour une femme du convoi des 31000, déposer la fiche à la racine du dépôt.
4. Valider l’ajout sur la branche `main`.

### Règle permanente de mise à jour

Chaque ajout ou modification d’une fiche reconstruit obligatoirement **les deux catalogues** : `femmes.html` et `hommes.html`. Les compteurs de l’accueil, le moteur de recherche, les portraits et le référencement sont actualisés pendant la même opération. Un contrôle automatique bloque la publication si une fiche reconnue manque dans son catalogue ou si un compteur Femmes/Hommes est incorrect.

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

## Logiciel Windows d’envoi des fiches

Le dossier [`outil-envoi-fiches`](outil-envoi-fiches/) contient un logiciel Windows pour sélectionner plusieurs fiches HTML sur un ordinateur, reconnaître leur catégorie et les envoyer dans le bon emplacement GitHub. Une copie peut être installée sur le Bureau avec le raccourci **Envoyer fiches GitHub**. Aucun mot de passe n’est enregistré par l’outil.

### Utilisation

1. Double-cliquer sur **Envoyer fiches GitHub** sur le Bureau ou sur `outil-envoi-fiches/Lancer-Outil.cmd`.
2. Lors de la première utilisation, cliquer sur **Préparer**. Le dépôt est téléchargé dans le dossier Documents de l’ordinateur.
3. Laisser le classement sur **Automatique** et cliquer sur **1. Choisir les fiches HTML**. Plusieurs fiches peuvent être sélectionnées ensemble.
4. Vérifier la catégorie indiquée à côté de chaque fichier : **Femme 31000** ou **Homme 45000**. Si elle n’est pas reconnue, choisir manuellement la bonne catégorie dans la liste.
5. Cliquer sur **2. Envoyer les fiches sur GitHub**. Lors du premier envoi, Git pour Windows peut demander une connexion au compte GitHub `victeams`.

La colonne **État** indique **Nouveau** ou **Déjà présente**. Le logiciel compare les matricules des femmes et des hommes avec les fiches déjà publiées, ignore automatiquement celles qui sont déjà faites et envoie uniquement les nouvelles. Une liste `Fiches deja presentes.txt` est créée sur le Bureau après chaque détection.

Le logiciel applique automatiquement les destinations suivantes :

- **Femme 31000** : fiche déposée à la racine du dépôt ;
- **Homme 45000** : fiche déposée dans le dossier `hommes/`.

Après l’envoi, GitHub reconstruit les catalogues Femmes et Hommes, les compteurs, les portraits, la recherche et le référencement. Le fichier [`outil-envoi-fiches/MODE-D-EMPLOI.txt`](outil-envoi-fiches/MODE-D-EMPLOI.txt) contient également ces instructions pour une consultation hors ligne.

## Actualiser la photothèque

Depuis l’onglet **Actions**, ouvrir **Actualiser la photothèque historique**, puis utiliser **Run workflow**. Le script Python parcourt toutes les pages du catalogue, détecte les nouveaux résultats, évite les doublons et reconstruit la galerie.

La même opération peut être lancée sur un ordinateur avec Python 3, sans installer de bibliothèque supplémentaire :

```bash
python scripts/scrape_ushmm_photos.py
python scripts/build_site.py
```

La sortie `data/ushmm-photos/` contient, pour chaque photographie, le nom de la notice, une description courte, les mots-clés, l’URL de la miniature, l’URL d’affichage et le lien vers la source. Les notices sont réparties en petits fichiers afin de rester rapides à charger et simples à publier sur GitHub.

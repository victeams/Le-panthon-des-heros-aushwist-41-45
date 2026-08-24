# Fiches des hommes

Ce dossier reçoit les biographies HTML des hommes déportés dans les convois dits des **45000**.

## Ajouter une fiche

1. Déposer ici le fichier HTML complet.
2. Utiliser un nom clair, par exemple `prenom_nom_45123.html`.
3. Indiquer le matricule `45xxx` ou `46xxx` dans le nom du fichier ou dans la fiche.
4. Intégrer la photographie directement dans le HTML en Base64.

L’automatisation ajoutera ensuite la personne au catalogue public `hommes.html`, créera sa miniature dans `portraits/` et mettra à jour la recherche ainsi que le plan du site.

Si le matricule est inconnu, ajouter cette balise dans le `<head>` de la fiche :

```html
<meta name="convoi" content="45000">
```


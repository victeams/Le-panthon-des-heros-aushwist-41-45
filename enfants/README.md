# Enfants déportés 1939-1945

Mémorial numérique francophone consacré aux enfants déportés pendant la
Seconde Guerre mondiale. Le projet rassemble des portraits documentés, une
galerie photographique, une recherche par nom, lieu ou camp, ainsi qu’un espace
d’hommages modéré.

## Principes éditoriaux

- aucune image générée pour représenter une personne réelle ;
- photographies affichées sans recadrage ni transformation ;
- faits accompagnés d’une notice d’archive nominative ;
- messages d’hommage relus avant publication ;
- aucune publicité ni profilage publicitaire.

## Fonctionnalités

- trois cent vingt-cinq portraits documentés, dont trois cents fiches individuelles directement accessibles sur GitHub Pages ;
- recherche et filtres par pays et destin ;
- galerie photographique avec crédits et liens vers les sources ;
- formulaire d’hommage persistant sur Cloudflare D1 ;
- section de soutien par PayPal ;
- interface responsive et accessible en français.

## Développement

Le site utilise Next.js, React, Vinext, Drizzle ORM et Cloudflare D1.

```bash
npm ci
npm run lint
npm run build
```

Les migrations de la base de données se trouvent dans `drizzle/`.

## Déploiement

La page d’accueil, les portraits statiques, le fichier d’indexation et les
fiches nouvellement générées sont publiables directement sur GitHub Pages.
L’hébergement complet nécessite toujours un environnement compatible avec
Vinext et une base D1 pour exécuter l’API dynamique des hommages.

## Sources

Chaque portrait contient un lien direct vers la notice du mémorial ou de
l’institution d’archives ayant permis d’établir les faits.

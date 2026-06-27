# Second Brain — Vault Obsidian + Claude Code

## Regles absolues

1. Ne JAMAIS modifier, renommer ou deplacer un fichier dans `raw/` — c'est l'espace humain, immutable
2. Ne JAMAIS creer de note orpheline — chaque note a au moins un wiki link entrant ou sortant
3. Ne JAMAIS ecrire dans le vault sans passer par un skill (/ingest, /save, /query, /notebooklm)
4. Ne JAMAIS supprimer une note wiki — archiver en changeant `status: archive`
5. Ne JAMAIS inventer d'information absente du vault — signaler quand la donnee manque

## Architecture 3 couches (Karpathy LLM Wiki)

| Couche           | Dossier     | Proprietaire | Regle                                             |
| ---------------- | ----------- | ------------ | ------------------------------------------------- |
| Layer 1 — Raw    | `raw/`      | Humain       | Immutable. Inputs bruts (clippings, docs, notes). |
| Layer 2 — Wiki   | `wiki/`     | LLM          | Compile via `/ingest`. Concepts, resumes, index.  |
| Layer 3 — Schema | `CLAUDE.md` | Humain       | Structure et conventions. Definit raw → wiki.     |

## Fonctionnement

Le projet est l'organisateur racine. Chaque projet a son propre espace dans `raw/` et `wiki/`.
Le contenu global (non lie a un projet) va dans `raw/global/` et `wiki/global/`.

- **raw/** contient le bordel humain : articles clippes, PDFs, notes manuscrites. Le LLM lit mais ne touche JAMAIS.
- **wiki/** contient la connaissance compilee : notes structurees, index, log. Le LLM est responsable de la qualite.
- **wiki/index.md** est le panneau de direction global. Le LLM le lit EN PREMIER.
- **wiki/<project>/index.md** est le panneau de direction du projet. Charge par `vault-context` au demarrage des agents.
- **wiki/log.md** est le journal chronologique append-only.

## Operations disponibles

| Commande  | Role                                       | Quand l'utiliser                            |
| --------- | ------------------------------------------ | ------------------------------------------- |
| `/prime`  | Charger le contexte au debut d'une session | A chaque nouvelle session Claude Code       |
| `/ingest` | Compiler raw/ → wiki/                      | Apres avoir ajoute du contenu dans raw/     |
| `/save`   | Sauvegarder l'etat de la session           | En fin de session de travail                |
| `/query`  | Recherche profonde dans le wiki            | Pour trouver de l'information dans le vault |
| `/lint`   | Health-check du vault                      | Periodiquement (1x/semaine recommande)      |
| `/notebooklm` | Vault → NotebookLM → livrable multimedia | Pour generer podcasts, mindmaps, guides depuis le wiki |

## Conventions Obsidian

- **Wiki links** : `[[Nom de la note]]` pour tout lien interne
- **Embeds** : `![[Note]]` pour inclure du contenu
- **Frontmatter YAML obligatoire** sur chaque note wiki :

```yaml
---
date: YYYY-MM-DD
tags: []
type: note | contexte | recherche | ressource | daily
status: active | archive
project: <project-name>   # omit if global
---
```

## Structure

```
raw/
  global/
    clippings/    ← articles web
    docs/         ← PDFs, documents recus
    notes/        ← notes manuelles
    learnings/    ← captures auto via /capture-learning
  <project>/
    clippings/
    docs/
    notes/
    learnings/

wiki/
  index.md        ← panneau de direction global
  log.md          ← journal chronologique
  Daily/          ← notes quotidiennes (/save)
  global/
    Context/      ← profil, objectifs
    Intelligence/ ← decisions, recherches, analyses
    Resources/    ← templates, patterns, snippets
  <project>/
    index.md      ← panneau de direction projet
    Intelligence/ ← decisions et recherches projet
    Resources/    ← patterns et snippets projet
```

Ces dossiers se creent au besoin. Ne JAMAIS creer un dossier vide.

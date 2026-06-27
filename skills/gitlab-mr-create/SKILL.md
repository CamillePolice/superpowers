---
name: gitlab-mr-create
description: Create a GitLab MR with the standardized Claranet description format. Use when the user asks to create an MR/PR ("crée la MR", "create MR", "glab mr create"), to write or rewrite an MR description, or when invoked from the /dev workflow Step 5. The structured description feeds MrAI (pr-agent) — its /describe output becomes metadata injected into /review and /improve.
---

# GitLab MR Create — format Claranet

Crée une MR GitLab avec une description structurée. Ce format est la base sur laquelle MrAI (pr-agent) s'appuie : la section **Contexte** lui donne le *pourquoi* invisible dans le diff, la section **Changements** lui permet de détecter les écarts entre intention et code.

---

## Step 1 — Titre

Format : `type(scope): description (PROJET-123)`

- `type(scope): description` — style conventional commit, reflète la feature, pas le détail technique
- `(PROJET-123)` — référence JIRA extraite du nom de branche (ex. `PMPFLOW-364/...` → `(PMPFLOW-364)`)

Exemples :
- `feat(dashboard): cross-factory UO tile (PMPFLOW-364)`
- `fix(billing): handle null milestone on declaration (PMPFLOW-412)`

## Step 2 — Description

Template Claranet (français) :

```markdown
## 🎯 Contexte
<!-- POURQUOI ce changement : problème adressé, besoin métier, lien ticket JIRA.
     C'est la seule info que MrAI ne peut pas déduire du diff — soigner cette section. -->

## 🔧 Changements
<!-- QUOI, au niveau intention — bullets des changements significatifs.
     PAS un listing fichier par fichier : MrAI génère le walkthrough détaillé. -->

## 🧪 Tests
- [ ] <étapes de vérification clés : commande, scénario manuel, test ajouté>

## ⚠️ Breaking changes / Migration
<!-- Détail + procédure de migration. Supprimer la section s'il n'y en a pas. -->
```

### Règles de rédaction

1. **Contexte** = le pourquoi. Lien JIRA obligatoire si un ticket existe. 2-4 phrases max.
2. **Changements** = le quoi, niveau intention (« ajoute le filtrage par factory au dashboard »), pas niveau fichier (« modifie dashboard.vue »). Le walkthrough fichier-par-fichier est généré automatiquement par MrAI `/describe`.
3. **Tests** = checklist actionnable. Inclure la commande de test si pertinent (`npx vitest run ...`).
4. **Pas de section vide** : supprimer une section plutôt que laisser « N/A » ou « Aucun ».
5. La description auteur est **préservée en tête** par MrAI (`add_original_user_description=true`) — il ajoute son résumé et son walkthrough après, sans écraser.

## Step 3 — Création

```bash
# Push de la branche si nécessaire
git push -u origin <current-branch>

glab mr create \
  --title "<titre Step 1>" \
  --description "$(cat <<'EOF'
<description Step 2>
EOF
)" \
  --target-branch main \
  --assignee @me \
  --draft \
  --remove-source-branch
```

Sortir l'URL de la MR à la fin.

## Step 4 — Après création

MrAI exécute automatiquement `/describe` → `/review` → `/improve` à l'ouverture de la MR (config `pr_commands`). Ne pas dupliquer son travail : ne pas lister les fichiers modifiés, ne pas générer de diagramme.

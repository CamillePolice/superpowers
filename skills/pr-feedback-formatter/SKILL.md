---
name: pr-comment
description: Formate un retour de code review / PR en markdown structuré et lisible. Utilise ce skill dès que l'utilisateur mentionne une PR, une code review, un commentaire de pull request, ou demande de "formater" / "mettre en markdown" un retour technique sur du code. Également déclenché par des phrases comme "formatte ça pour une PR", "écris un commentaire de review", "rédige un retour de PR", ou quand l'utilisateur colle du code avec une explication de bug ou suggestion.
---

# PR Comment Skill

Transforme un retour technique brut (bug trouvé, suggestion, refacto proposée) en un commentaire de PR bien structuré en markdown, prêt à coller sur GitHub, GitLab ou autre.

## Objectif

Produire un bloc markdown complet, directement utilisable, sans que l'utilisateur ait à reformater quoi que ce soit.

## Format de sortie

Toujours retourner **uniquement** un bloc de code markdown (` ```markdown ``` `), que l'utilisateur peut copier-coller tel quel.

## Structure du commentaire

### 1. Titre avec emoji

Choisir l'emoji selon la nature du retour :

| Type | Emoji | Exemples |
|------|-------|---------|
| Bug / comportement incorrect | 🐛 | état incohérent, effet de bord non géré |
| Performance / optimisation | ⚡ | lazy-load, éviter des requêtes inutiles |
| Sécurité | 🔒 | exposition de données, faille |
| Refacto / amélioration de code | 🔧 | lisibilité, découplage |
| Question / clarification | ❓ | intention pas claire |
| Suggestion non bloquante | 💡 | nit, nice-to-have |
| Breaking change | 💥 | changement d'API, migration requise |

Format du titre : `## {emoji} {Titre court et descriptif}`

### 2. Contexte / Problème

1-3 phrases max expliquant ce qui ne va pas ou pourquoi on suggère un changement. Pas de jargon inutile. Direct.

### 3. Solution proposée (si applicable)

Bloc de code avec le langage approprié. Toujours indenter proprement. Si plusieurs fichiers sont concernés, utiliser des sous-titres `###` avec le chemin du fichier.

### 4. Notes / Prérequis (optionnel)

Bloc `> **Note :**` pour signaler :
- des prérequis à vérifier
- des effets de bord potentiels
- des éléments connexes à ne pas oublier

## Règles de style

- **Titres de fichiers** : utiliser le chemin relatif complet en inline code, ex : `app/components/lot/Table.vue`
- **Noms de fonctions/variables** : toujours en inline code, ex : `clearFilter`, `isAdvancedFiltersOpen`
- **Langue** : respecter la langue de l'utilisateur (FR par défaut pour Camille)
- **Ton** : factuel, direct, bienveillant — pas de "il faudrait peut-être envisager de"
- **Longueur** : le plus court possible tout en étant complet. Pas de rembourrage.

## Exemples

### Exemple 1 — Bug avec correction de code

**Input utilisateur :**
> Cette fonction ne répercute pas le "clear" sur les filtres enfants. Je suggère de l'update pour : `const clearFilter = ...`

**Output attendu :**

```markdown
## 🐛 `clearFilter` ne répercute pas le reset sur les filtres enfants

La fonction actuelle ne réinitialise pas les filtres enfants liés lorsqu'un filtre parent est effacé.

### Comportement suggéré

Lorsqu'on clear `factorySearch` ou `productionCellSearch`, les filtres scopés associés doivent également être reset.

### Proposition

\`\`\`ts
const clearFilter = (key: FilterKey) => {
  const def = definitions.find(d => d.key === key)
  if (!def) return

  resetFilter(def)

  if (key === 'factorySearch') {
    resetFilter(definitions.find(d => d.key === 'factoryScopedSearch')!)
    resetFilter(definitions.find(d => d.key === 'factoryScopeMode')!)
  } else if (key === 'productionCellSearch') {
    resetFilter(definitions.find(d => d.key === 'cellScopedSearch')!)
    resetFilter(definitions.find(d => d.key === 'cellScopeMode')!)
  }

  resetPage()
}
\`\`\`

> **Note :** Le `if (!def) return` a également été déplacé avant le `resetFilter(def)` pour éviter un appel avec une valeur `undefined`.
```

---

### Exemple 2 — Optimisation multi-fichiers

**Input utilisateur :**
> AdvancedFiltersSlideover est toujours monté — v-if n'existe pas. Solution : déplacer les 4 fetches dans Table.vue avec immediate: false. [code sur 2 fichiers]

**Output attendu :**

```markdown
## ⚡ Lazy-load des fetches avancées — `AdvancedFiltersSlideover` toujours monté

`AdvancedFiltersSlideover` est toujours monté dans le DOM (pas de `v-if`), ce qui entraîne 4 fetches inutiles au chargement de la page alors que le slideover n'est pas ouvert.

### Solution

Déplacer les 4 fetches dans `Table.vue` où `isAdvancedFiltersOpen` est accessible, avec `immediate: false` et un chargement déclenché uniquement au premier `open`.

---

### `app/pages/lots/index.vue` — retirer les 4 props lazy

\`\`\`vue
...
\`\`\`

### `app/components/lot/Table.vue` — fetches lazy au premier open

\`\`\`ts
...
\`\`\`

---

> **À vérifier :** `useFetchWrapper` doit bien transmettre `immediate: false` à `useFetch`.
```

## Comportement selon le niveau de détail fourni

| Input | Comportement |
|-------|-------------|
| Description vague + pas de code | Demander le code ou la suggestion concrète avant de formater |
| Description + code snippet | Formater directement, inférer l'emoji et la structure |
| Plusieurs fichiers concernés | Utiliser des `###` par fichier, `---` comme séparateur |
| Simple nit / suggestion mineure | Format allégé : titre + 1-2 phrases + code si besoin |Ò

# Query — Deep Wiki Search

Searches and synthesizes information from the vault.

> Vault location: `~/vault` (default). Adjust if installed elsewhere.

> **When proposing enrichment**, apply `~/.claude/skills/obsidian-markdown/SKILL.md` to ensure proper Obsidian formatting (wikilinks, callouts, embeds).

## Steps

### 1. Read the index

Read `~/vault/wiki/index.md` to identify which category and note is most likely to contain the answer.

### 2. Navigate

Open the identified wiki note. If the answer requires multiple notes, read them all.

### 3. Synthesize

Formulate a structured response based solely on the wiki content.

### 4. Propose enrichment

If the search produces a useful new synthesis (cross-referencing multiple notes, new conclusion):

- Propose to the user to create or enrich a wiki note with this synthesis
- NEVER write without explicit user validation

### 5. Write to log

Add an entry in `~/vault/wiki/log.md`:

```
YYYY-MM-DD HH:MM — Query: "question asked" → wiki/path/note.md
```

## Rules

- NEVER invent information absent from the wiki — if the data does not exist, say so clearly
- NEVER scan all wiki files — use the index as the entry point
- NEVER modify raw/
- Always cite the source (wiki note name) in the response

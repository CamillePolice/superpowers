# Ingest — raw/ to wiki/

Compiles raw vault sources into structured wiki notes.

> Vault location: `~/Documents/obsidian/claude`

> **Always apply** `~/.claude/skills/obsidian-markdown/SKILL.md` when creating or editing wiki notes to ensure proper Obsidian formatting (wikilinks, callouts, embeds).

## Steps

### 0. Detect project scope

```bash
if [[ -n "$CLAUDE_PROJECT" && "$CLAUDE_PROJECT" != "global" ]]; then
  PROJECT="$CLAUDE_PROJECT"
else
  PROJECT=""
fi
```

### 1. Scan raw/

**If `$PROJECT` is set:**
- `~/Documents/obsidian/claude/raw/$PROJECT/` — project-specific sources (all subfolders)
- `~/Documents/obsidian/claude/raw/learnings/$PROJECT/` — auto-captures for project
- `~/Documents/obsidian/claude/raw/global/` — global sources (always scanned)
- `~/Documents/obsidian/claude/raw/learnings/global/` — global auto-captures (always scanned)

**If no project:**
- `~/Documents/obsidian/claude/raw/global/` only
- `~/Documents/obsidian/claude/raw/learnings/global/` only

Ignore README.md and .gitkeep files in each subfolder.

### 2. Identify unprocessed files

For each file in raw/:

- Search `~/Documents/obsidian/claude/wiki/` for a note whose `source:` frontmatter references this file
- If wiki note exists and is up to date → skip
- If file is new → process

### 3. Process each file

1. **Read** the full content of the raw file
2. **Extract** key concepts, facts, decisions, insights
3. **Decide**: create a new wiki note OR enrich an existing one
   - Existing topic → enrich the corresponding wiki note
   - New topic → determine destination (see step 4)

### 4. Determine destination and create/enrich wiki note

Resolve project scope for each file in this order:
1. Source path: `raw/<project>/` → project is `<project>`
2. Frontmatter `project:` field (fallback for externally exported files)
3. Default → `global`

**Routing:**

| Source path | Destination |
|-------------|-------------|
| `raw/<project>/docs/` or `raw/<project>/learnings/` | `wiki/<project>/Intelligence/` |
| `raw/learnings/<project>/` | `wiki/<project>/Intelligence/` |
| `raw/<project>/notes/` or `raw/<project>/clippings/` | `wiki/<project>/Intelligence/` or `wiki/<project>/Resources/` (by content) |
| `raw/global/**` | `wiki/global/Intelligence/` or `wiki/global/Resources/` (by content) |
| `raw/learnings/global/` | `wiki/global/Intelligence/` |

Create `wiki/<project>/` and `wiki/<project>/index.md` if they don't exist yet (see template below).

Each wiki note must have this frontmatter:

```yaml
---
date: YYYY-MM-DD
tags: []
type: research | context | resource | note | learning
status: active
source: raw/path/to/file.md
project: <project>   # omit if global
---
```

Note content:

- **Summary** — 2-3 sentences, the essential
- **Key concepts** — bullet points of main ideas
- **Details** — structured sections if the content is rich
- **Links** — wiki links to existing related notes

### 5. Create project index if missing

If `wiki/<project>/index.md` does not exist, create it:

```markdown
---
date: YYYY-MM-DD
tags: [nav, project]
type: note
status: active
project: <project>
---

# <project> — Index

## Intelligence

| Note | Description |
| ---- | ----------- |

## Resources

| Note | Description |
| ---- | ----------- |
```

### 6. Cross-reference

For each created or modified note:

- Add `[[wiki links]]` to related notes
- Verify that referenced notes have a back-link
- Notes in `wiki/<project>/` link back to `[[<project>/index]]`

### 7. Update indexes

- New notes in `wiki/<project>/` → add row to `wiki/<project>/index.md`
- New notes in `wiki/global/` → add row to `wiki/index.md`
- If new project created → add entry to `wiki/index.md` under `## Projects`

### 8. Write to log

Add an entry in `~/Documents/obsidian/claude/wiki/log.md`:

```
YYYY-MM-DD HH:MM — Ingest [<project>]: X files scanned, Y new, Z enriched
```

Omit `[<project>]` if global.

### 9. Report

Display:

```
## Ingest complete

- Project scope: <project> (or "global")
- Files scanned: X
- New: Y (list with destination)
- Enriched: Z (list)
- Skipped: W
- Indexes updated: yes/no
- Log updated: yes/no
```

## Rules

- NEVER modify, rename or move a file in raw/
- NEVER create a superficial note — if a file adds nothing new, do not create a note
- Prefer enriching an existing note over creating a new one
- Wiki notes are syntheses, not copies — reframe, structure, extract value
- NEVER create an orphan note — at least one incoming or outgoing wiki link

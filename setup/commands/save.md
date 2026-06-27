# Save — Session Save

Saves the state of the current session. Run at the end of each session.

> Vault location: `~/vault` (default). Adjust if installed elsewhere.

> **Always apply** `~/.claude/skills/obsidian-markdown/SKILL.md` when creating or editing daily notes to ensure proper Obsidian formatting (wikilinks, callouts, embeds).

## Steps

### 0. Detect project scope

```bash
if [[ -n "$CLAUDE_PROJECT" && "$CLAUDE_PROJECT" != "global" ]]; then
  PROJECT="$CLAUDE_PROJECT"
else
  PROJECT=""
fi
```

### 1. Daily note

Create or update `~/vault/wiki/Daily/YYYY-MM-DD.md` (today's date).

Frontmatter — include `project:` only when `$PROJECT` is set:

```yaml
---
date: YYYY-MM-DD
tags: [daily]
type: daily
status: active
project: <PROJECT>   # omit if PROJECT is empty
---
```

Content:

- **Project** — `$PROJECT` (omit line if empty)
- **Actions** — what was done this session (bullet points)
- **Decisions** — choices made and why
- **Next step** — what remains to be done

If the daily note already exists, append a new project section rather than overwriting:

```markdown
## <PROJECT> — HH:MM

- Actions: ...
- Decisions: ...
- Next: ...
```

### 2. Update indexes

- If `$PROJECT` is set and new wiki notes were created in `wiki/<project>/` → add missing entries to `wiki/<project>/index.md`
- If global notes were created in `wiki/global/` → add missing entries to `wiki/index.md`

### 3. Write to log

Add an entry in `~/vault/wiki/log.md`:

```
YYYY-MM-DD HH:MM — Save [<PROJECT>]: daily note created/updated, index checked
```

Omit `[<PROJECT>]` if no project scope.

### 4. Confirmation

Display a short summary of what was saved.

## Rules

- NEVER delete existing content in a daily note — only append
- NEVER modify raw/ during /save
- NEVER create an orphan note
- Execute directly without asking for confirmation

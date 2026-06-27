# Prime — Context Loading

Loads vault context at the start of each Claude Code session.

> Vault location: `/Users/cpo/Documents/obsidian/claude` (default). Adjust if installed elsewhere.

## Steps

### 0. Skip on resume

If the system context contains `resume hook` in the SessionStart reminder → respond "Context already loaded (resumed session)." and stop. Do NOT read any vault files.

### 1. Read `/Users/cpo/Documents/obsidian/claude/CLAUDE.md` — operational rules and vault schema

### 2. Read `/Users/cpo/Documents/obsidian/claude/wiki/index.md` — global directory panel

### 3. Read the latest daily note in `/Users/cpo/Documents/obsidian/claude/wiki/Daily/` — previous session summary

### 4. Load or initialize project context

Detect project name:

```bash
if [[ -n "$CLAUDE_PROJECT" && "$CLAUDE_PROJECT" != "global" ]]; then
  echo "$CLAUDE_PROJECT"
else
  echo ""   # no project scope — skip step 4
fi
```

If project name is empty → skip step 4 entirely.

**If `/Users/cpo/Documents/obsidian/claude/wiki/<project>/index.md` exists** → read it and summarize.

**If not found** → initialize:

1. Read project docs in order (skip if absent):
   - `./CLAUDE.md`
   - `./README.md`
   - `./docs/` index or any top-level `*.md`
2. Load code graph context:
   - Call `get_architecture_overview` (MCP code-review-graph) if available
   - Fallback: run `ls -la` for structural clues
3. Create `/Users/cpo/Documents/obsidian/claude/wiki/<project>/` directory and write `/Users/cpo/Documents/obsidian/claude/wiki/<project>/index.md` using the template below
4. Add entry to `## Projects` section of `/Users/cpo/Documents/obsidian/claude/wiki/index.md` (create section if absent)

### Project index template

```markdown
---
date: <YYYY-MM-DD>
tags: [nav, project]
type: note
status: active
project: <project>
---

# <project>

## Purpose
<one paragraph — what the project does and why>

## Architecture
<key layers, frameworks, entry points>

## Key Files
<3-5 most important files with purpose>

## Open Threads
<active work, known issues, next steps — leave blank if none>
```

## Expected Output

Confirm what was loaded by summarizing:

- Number of categories in the global index
- Latest daily note read (date)
- Key points from the last session
- Project context: loaded from vault, or initialized (summarize what was captured)

## Rules

- NEVER write to the vault during /prime **except** when initializing a missing project index
- NEVER scan all wiki files — use the index as the entry point
- If the index does not exist or is empty, report it to the user
- Project index absence is normal for new projects — initialize silently

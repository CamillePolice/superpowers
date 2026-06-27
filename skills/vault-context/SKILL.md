# Skill: vault-context

Loads project context from the vault at agent startup.

## When to apply

Always — first step before any task execution.

## Process

### Step 1 — Detect project scope

```bash
echo "${CLAUDE_PROJECT:-}"
```

If output is empty or `global` → skip entirely. Do not read any vault files.

### Step 2 — Load project index

Read `~/vault/wiki/$CLAUDE_PROJECT/index.md`.

If the file does not exist → skip silently. Do not warn the user.

### Step 3 — Load global index

Read `~/vault/wiki/index.md`.

This gives a map of available global patterns (Intelligence, Resources). Do NOT read the individual notes — use the index only as a directory. If the task requires a specific global pattern, read that note on demand.

### Step 4 — Use as context

The project index provides:
- **Purpose** — what the project does
- **Architecture** — key layers, frameworks, entry points
- **Key Files** — most important files and their role
- **Open Threads** — active work, known issues, next steps

The global index provides:
- A map of reusable patterns and resources available in `wiki/global/`
- Read individual global notes only when directly relevant to the current task

Use this context to:
- Prioritize relevant files when exploring the codebase
- Align recommendations with the project's architecture
- Leverage existing global patterns before reinventing solutions
- Avoid re-discovering constraints already documented

Do NOT summarize or report loaded indexes to the user — use them silently.

## Rules

- NEVER write to the vault from this skill
- NEVER block on missing project index — skip and proceed
- NEVER load more than the project index — other wiki files are out of scope

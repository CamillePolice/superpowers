---
name: capture-learning
description: |
  Persist reusable discoveries from /tmp/learning-notes-$CLAUDE_PROJECT.md into the Obsidian vault (raw/learnings/).
  Invoke after any unexpected problem resolution, pattern discovery, gotcha, or workaround.
---

# Skill: capture-learning

> **Project scope**: notes are read from `/tmp/learning-notes-${CLAUDE_PROJECT:-default}.md`.
> Set `export CLAUDE_PROJECT=<project>` in your shell before starting Claude to scope notes per project.

Evaluate discoveries and persist reusable knowledge to the appropriate vault destination.

---

## Step 0 — Filter unusable notes

Automatically reject (decision **NONE**) any note that:

- Contains unfilled placeholders: `<...>`, `<tag>`, `<description>`
- Is too generic: "Build error encountered", "edge case found"
- Is fewer than 40 characters after the `[xxx]` tag
- Does not follow the format `[tag] technology — description — solution`

Report rejected notes in the final summary.

---

## Step 1 — Read the notepad

```bash
cat "/tmp/learning-notes-${CLAUDE_PROJECT:-default}.md" 2>/dev/null || echo "(empty)"
```

---

## Step 2 — Decision matrix

| Decision    | Condition                                              | Action           |
|-------------|--------------------------------------------------------|------------------|
| **NEW**     | No existing coverage + reusable knowledge              | Write file       |
| **IMPROVE** | Existing file covers topic but incompletely            | Append to file   |
| **NONE**    | Trivial task, already covered, or note rejected        | Skip, justify    |

Check for existing coverage before writing:

```bash
grep -r "<keyword>" /Users/cpo/Documents/obsidian/claude/raw/learnings/ 2>/dev/null | head -5
```

---

## Step 2b — Classify each retained note

For each note that passes Step 2 (NEW or IMPROVE), determine the destination:

**GENERAL** — `/Users/cpo/Documents/obsidian/claude/raw/learnings/`
The note is reusable outside this project. A developer on a different project would find value in it.
Signs: framework patterns, language gotchas, tool tips, generic architecture decisions, Docker/git/CI tricks.

**PROJECT** — `/Users/cpo/Documents/obsidian/claude/raw/learnings/${CLAUDE_PROJECT:-default}/`
The note is specific to this project's context. It would not be meaningful without knowing the project.
Signs: business logic rules, project-specific naming conventions, decisions tied to this codebase's constraints, workarounds for a particular legacy system.

> If `CLAUDE_PROJECT` is not set (value is `default`), always use **GENERAL** regardless of content — there is no project context to scope to.

---

## Step 3 — Write the learning file

For each retained note, write a structured `.md` file to the destination determined in Step 2b.
Create the destination directory if it does not exist.

**Naming rule**: `<technology>-<short-slug>.md`
Examples: `angular-signal-context.md`, `symfony-cast-int.md`

```markdown
---
date: YYYY-MM-DD
tags: [tag, technology]
scope: general | project
project: <CLAUDE_PROJECT value, omit if general>
---

# <Descriptive title>

[tag] technology — precise description — solution applied

## Context

<Description of the problem encountered>

## Solution

<What was applied and why it works>

## Example

```<lang>
<code or command illustrating the solution>
```
```

---

## Step 4 — Clear the notepad

```bash
> "/tmp/learning-notes-${CLAUDE_PROJECT:-default}.md"
echo "Notepad cleared after capture."
```

---

## Step 5 — Summary

Display:

- Decision (NEW / IMPROVE / NONE) for each note
- Scope (GENERAL / PROJECT) and file path written
- Rejected notes with reason

> Run `/ingest` to compile `raw/learnings/` into `wiki/Intelligence/` when ready.

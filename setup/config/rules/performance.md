
# Rule: Performance & Context Management

> Meta-rules applied before any agent is loaded.

## Model selection

| Task                                      | Model      |
| ----------------------------------------- | ---------- |
| Planning, architecture, complex reasoning | `opus`   |
| Coding, refactoring, reviews              | `sonnet` |
| Simple edits, formatting, renaming        | `haiku`  |

Default to `sonnet` unless the task clearly requires deep reasoning.

## Session start

* Run `/prime` at the start of each session to load vault context (wiki/index.md)
* Load only the matching profile — never load all profiles simultaneously

## Context window

* Never enable more than 10 MCP servers simultaneously
* Use `strategy-compact` skill proactively at session inflection points
* Prefer targeted reads over full file reads

```bash
# Prefer this
grep -n "functionName" src/app/service.ts
# Over this
cat src/app/service.ts
```

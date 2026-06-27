---
name: git-workflow-and-versioning
description: Disciplined git workflow for AI-assisted development. Use when committing, branching, or reviewing changes.
---

# Git Workflow and Versioning

## Core Principles

**Trunk-Based Development:** Keep main always deployable. Feature branches live 1-3 days max.

**Commit Discipline:**
- Each commit addresses one logical concern
- Separate refactoring from feature work
- Messages explain intent, not obvious details

## Commit Format

```
<type>: <short description>

<optional body with rationale>
```

Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`

## Size Targets

```
~100 lines  → Optimal
~300 lines  → Acceptable for a single logical change
~1000 lines → Split it
```

## Branching

```
feature/<description>
fix/<description>
chore/<description>
```

Git worktrees for parallel agent work:
```bash
git worktree add ../project-feature-a feature/task-creation
```

## Pre-Commit Checklist

- [ ] Review staged changes
- [ ] Scan for secrets/credentials
- [ ] Run tests, linting, type checking

## Never

- Force-push to shared branches
- Use vague messages ("fix", "update", "wip")
- Mix formatting changes with behavior changes
- Commit: `node_modules/`, `dist/`, `.env`, build outputs

## Post-Change Summary Format

```
CHANGES MADE: [files modified with specific alterations]
DIDN'T TOUCH: [intentionally excluded items]
POTENTIAL CONCERNS: [assumptions requiring validation]
```

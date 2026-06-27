---
name: spec-driven-development
description: Write a structured spec before writing any code. Use for new features, ambiguous requirements, multi-file changes, or architectural decisions.
---

# Spec-Driven Development

## Principle

Write a structured spec before any code. The spec is the shared source of truth — it defines what, why, and how we'll know it's done.

## When to Use

- New project or feature
- Ambiguous requirements
- Multi-file changes
- Architectural decision

**Do not use for:** single-line fixes, unambiguous self-contained changes.

## Workflow: Specify → Plan → Tasks → Implement

### Phase 1: Specify

Document 6 axes:
1. **Objective** — what we're building and why
2. **Commands** — build, test, lint, dev
3. **Project structure** — files and folders impacted
4. **Code style** — non-standard conventions only
5. **Testing strategy** — what to test and how
6. **Boundaries** — what is out of scope

Surface assumptions explicitly before moving forward.

### Phase 2: Plan

Technical plan with architecture decisions and justifications.

### Phase 3: Tasks

Decompose into discrete tasks with acceptance criteria. See `planning-and-task-breakdown`.

### Phase 4: Implement

Execute incrementally. See `incremental-implementation`.

## Living Document

The spec stays active during development — updated when decisions change, scope evolves, or discoveries emerge. It lives in the repo alongside the code.

> "A 15-minute spec prevents hours of rework."

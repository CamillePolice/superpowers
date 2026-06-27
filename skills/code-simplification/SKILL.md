---
name: code-simplification
description: Refactor code for improved readability while preserving behavior. Use after features are working but feel unnecessarily complex.
---

# Code Simplification

## Core Principles

1. Maintain exact behavior
2. Follow project conventions
3. Prioritize clarity over cleverness
4. Avoid over-simplification
5. Limit changes to relevant scope

## When to Apply

- After features are working but feel unnecessarily complex
- When code has deep nesting, generic variable names, duplicated logic, or unnecessary abstractions

**Not appropriate for:** already-clean code, unfamiliar code you haven't fully grasped, performance-critical sections.

## The Process

1. **Understand first** — Apply Chesterton's Fence: don't remove something until you understand why it's there
2. **Identify targets** — Deep nesting, generic names, duplicated logic, unnecessary abstractions
3. **Change incrementally** — One thing at a time, verify after each step
4. **Verify** — Run tests after every change

## Key Distinctions

- **Remove** "what" comments (they restate the code)
- **Keep** "why" comments (they explain non-obvious intent)
- Fewer lines ≠ simpler. Clarity is the goal.
- Never mix refactoring with feature work

## The 500-Line Rule

For refactoring efforts exceeding ~500 lines of change, consider automation or breaking into separate PRs.

## Success Signal

Simplification succeeds when teammates recognize it as genuine improvement, not stylistic preference.

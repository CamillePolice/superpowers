---
name: incremental-implementation
description: Build in thin vertical slices. Use for multi-file changes, new features, refactoring, or any change exceeding ~100 lines.
---

# Incremental Implementation

## Concept

Build "thin vertical slices" — implement one complete piece end-to-end, test it, verify, commit, then move to the next. Each increment leaves the system in a working, testable state.

## The Cycle

```
Implement → Test → Verify → Commit → Next slice
```

## Slicing Strategies

| Strategy | Usage |
|---|---|
| **Vertical** | UI + API + database in one slice |
| **Contract-first** | Define API spec before parallel development |
| **Risk-first** | Tackle uncertain pieces earliest |

## Implementation Rules

- Simplicity first — no premature abstractions
- Only touch what the task requires (scope discipline)
- Code compilable after each increment
- Feature flags for incomplete work
- Each change must remain independently revertable

> "Three similar lines of code is better than a premature abstraction."

## Red Flags

- More than 100 lines without an intermediate test
- Unrelated changes mixed together
- Scope creep
- Verification skipped
- Broken build between steps
- Abstractions built before they're needed

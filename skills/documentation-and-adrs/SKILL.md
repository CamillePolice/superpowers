---
name: documentation-and-adrs
description: Records decisions and documentation. Use when making architectural decisions, changing public APIs, or shipping features.
---

# Documentation and ADRs

## Overview

Document the *why* — context, constraints, and trade-offs. Code shows *what* was built; documentation explains *why it was built this way* and *what alternatives were considered*.

## When to Write an ADR

- Choosing a framework, library, or major dependency
- Designing a data model or database schema
- Selecting an authentication strategy
- Any decision that would be expensive to reverse

## ADR Template

Store in `docs/decisions/` with sequential numbering:

```markdown
# ADR-001: [Decision title]

## Status
Accepted | Superseded by ADR-XXX | Deprecated

## Date
YYYY-MM-DD

## Context
[Requirements and constraints that drove this decision]

## Decision
[What was decided]

## Alternatives Considered
### [Alternative A]
- Pros: ...
- Cons: ...
- Rejected: [reason]

## Consequences
[What changes as a result]
```

**Never delete old ADRs.** When a decision changes, write a new ADR that supersedes the old one.

## Inline Comments

Comment the *why*, not the *what*:

```typescript
// BAD: Restates the code
// Increment counter by 1
counter += 1;

// GOOD: Explains non-obvious constraint
// Sliding window reset prevents burst attacks at window boundaries
if (now - windowStart > WINDOW_SIZE_MS) { counter = 0; }
```

Never leave: TODO comments for things you should just do, commented-out code (git has history).

## README Minimum

```markdown
# Project Name
One-paragraph description.

## Quick Start
## Commands
## Architecture (link to ADRs)
```

## Red Flags

- Architectural decisions with no written rationale
- TODO comments that have been there for weeks
- Commented-out code instead of deletion
- Documentation that restates code instead of explaining intent

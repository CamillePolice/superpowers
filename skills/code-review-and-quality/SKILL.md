---
name: code-review-and-quality
description: Multi-dimensional code review. Use before merging any PR, after completing a feature, or when evaluating code produced by another agent.
---

# Code Review and Quality

## Overview

Every change gets reviewed before merge — no exceptions. Review covers five axes: correctness, readability, architecture, security, and performance.

**Approval standard:** "Approve when a change definitely improves overall code health, even if it isn't perfect."

## The Five-Axis Review

### 1. Correctness
- Matches spec/task requirements?
- Edge cases handled (null, empty, boundary values)?
- Error paths handled?
- Tests pass and test the right things?

### 2. Readability
- Names descriptive and consistent with project conventions?
- Control flow straightforward?
- No clever tricks that should be simplified?
- Dead code removed?

### 3. Architecture
- Follows existing patterns?
- Clean module boundaries?
- Dependencies flowing in the right direction?

### 4. Security
- User input validated at system boundaries?
- Secrets out of code and logs?
- Auth checked where needed?
- SQL queries parameterized?
- External data treated as untrusted?

### 5. Performance
- N+1 query patterns?
- Unbounded loops or unconstrained data fetching?
- Missing pagination on list endpoints?

## Change Sizing

```
~100 lines  → Good. Reviewable in one sitting.
~300 lines  → Acceptable for a single logical change.
~1000 lines → Too large. Split it.
```

Separate refactoring from feature work. Submit them as separate changes.

## Severity Labels

| Prefix | Meaning |
|--------|---------|
| *(none)* | Required before merge |
| **Critical:** | Blocks merge (security, data loss, broken functionality) |
| **Nit:** | Minor, optional |
| **Consider:** | Suggestion, not required |
| **FYI** | Informational only |

## The Review Checklist

```markdown
- [ ] Change matches spec/task requirements
- [ ] Edge cases and error paths handled
- [ ] Tests cover the change adequately
- [ ] Names clear and consistent
- [ ] No unnecessary complexity
- [ ] No secrets in code
- [ ] Input validated at boundaries
- [ ] No injection vulnerabilities
- [ ] No N+1 patterns
- [ ] Build succeeds, tests pass
```

## Red Flags

- PRs merged without review
- "LGTM" without evidence of actual review
- Security-sensitive changes without security review
- No regression tests with bug fix PRs
- Accepting "I'll fix it later"

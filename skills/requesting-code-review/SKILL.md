---
name: requesting-code-review
description: Use when completing tasks, implementing major features, or before merging to verify work meets requirements
---

# Requesting Code Review

Dispatch a code reviewer subagent to catch issues before they cascade. The reviewer gets precisely crafted context for evaluation — never your session's history. This keeps the reviewer focused on the work product, not your thought process, and preserves your own context for continued work.

**Core principle:** Review early, review often. Every change gets reviewed before merge — no exceptions.

**Approval standard:** "Approve when a change definitely improves overall code health, even if it isn't perfect."

## When to Request Review

**Mandatory:**
- After each task in subagent-driven development
- After completing major feature
- Before merge to main

**Optional but valuable:**
- When stuck (fresh perspective)
- Before refactoring (baseline check)
- After fixing complex bug

## How to Request

**1. Get git SHAs:**
```bash
BASE_SHA=$(git rev-parse HEAD~1)  # or origin/main
HEAD_SHA=$(git rev-parse HEAD)
```

**2. Dispatch code reviewer subagent:**

Dispatch a `general-purpose` subagent, filling the template at [code-reviewer.md](code-reviewer.md)

**Placeholders:**
- `{DESCRIPTION}` - Brief summary of what you built
- `{PLAN_OR_REQUIREMENTS}` - What it should do
- `{BASE_SHA}` - Starting commit
- `{HEAD_SHA}` - Ending commit

**3. Act on feedback:**
- Fix Critical issues immediately
- Fix Important issues before proceeding
- Note Minor issues for later
- Push back if reviewer is wrong (with reasoning)

## The Five-Axis Review

When acting as reviewer, evaluate on these five axes:

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

## Review Checklist

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

## Example

```
[Just completed Task 2: Add verification function]

You: Let me request code review before proceeding.

BASE_SHA=$(git log --oneline | grep "Task 1" | head -1 | awk '{print $1}')
HEAD_SHA=$(git rev-parse HEAD)

[Dispatch code reviewer subagent]
  DESCRIPTION: Added verifyIndex() and repairIndex() with 4 issue types
  PLAN_OR_REQUIREMENTS: Task 2 from docs/superpowers/plans/deployment-plan.md
  BASE_SHA: a7981ec
  HEAD_SHA: 3df7661

[Subagent returns]:
  Strengths: Clean architecture, real tests
  Issues:
    Important: Missing progress indicators
    Minor: Magic number (100) for reporting interval
  Assessment: Ready to proceed

You: [Fix progress indicators]
[Continue to Task 3]
```

## Integration with Workflows

**Subagent-Driven Development:**
- Review after EACH task
- Catch issues before they compound
- Fix before moving to next task

**Executing Plans:**
- Review after each task or at natural checkpoints
- Get feedback, apply, continue

**Ad-Hoc Development:**
- Review before merge
- Review when stuck

## Red Flags

**Never:**
- Skip review because "it's simple"
- Ignore Critical issues
- Proceed with unfixed Important issues
- Merge PRs without review
- Accept "LGTM" without evidence of actual review
- Merge security-sensitive changes without security review
- Accept bug fix PRs with no regression tests
- Accept "I'll fix it later"
- Argue with valid technical feedback

**If reviewer wrong:**
- Push back with technical reasoning
- Show code/tests that prove it works
- Request clarification

See template at: [code-reviewer.md](code-reviewer.md)

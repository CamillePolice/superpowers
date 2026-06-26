---
name: executing-plans
description: Use when you have a written implementation plan to execute in a separate session with review checkpoints
---

# Executing Plans

## Overview

Load plan, review critically, execute all tasks as thin vertical slices, report when complete.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

**Note:** Tell your human partner that Superpowers works much better with access to subagents. The quality of its work will be significantly higher if run on a platform with subagent support (Claude Code, Codex CLI, Codex App, Copilot CLI, and Gemini CLI all qualify; see the per-platform tool refs in `../using-superpowers/references/`). If subagents are available, use superpowers:subagent-driven-development instead of this skill.

## The Concept

Build "thin vertical slices" — implement one complete piece end-to-end, test it, verify, commit, then move to the next. Each increment leaves the system in a working, testable state.

```
Implement → Test → Verify → Commit → Next slice
```

## Slicing Strategies

| Strategy | Usage |
|---|---|
| **Vertical** | UI + API + database in one slice |
| **Contract-first** | Define API spec before parallel development |
| **Risk-first** | Tackle uncertain pieces earliest |

## The Process

### Step 1: Load and Review Plan
1. Read plan file
2. Review critically — identify any questions or concerns about the plan
3. If concerns: Raise them with your human partner before starting
4. If no concerns: Create todos for the plan items and proceed

### Step 2: Execute Tasks

For each task:
1. Mark as in_progress
2. Follow each step exactly (plan has bite-sized steps)
3. Implement only what the task requires — no premature abstractions, no scope creep
4. Keep code compilable after each increment
5. Use feature flags for incomplete work
6. Run verifications as specified
7. Commit — each change must remain independently revertable
8. Mark as completed

### Step 3: Complete Development

After all tasks complete and verified:
- Announce: "I'm using the finishing-a-development-branch skill to complete this work."
- **REQUIRED SUB-SKILL:** Use superpowers:finishing-a-development-branch
- Follow that skill to verify tests, present options, execute choice

## Implementation Rules

- Simplicity first — no premature abstractions
- Only touch what the task requires (scope discipline)
- Code compilable after each increment
- Feature flags for incomplete work
- Each change must remain independently revertable

> "Three similar lines of code is better than a premature abstraction."

## Red Flags

| Flag | Risk |
|---|---|
| More than 100 lines without an intermediate test | Unverifiable progress |
| Unrelated changes mixed together | Entangled, hard to revert |
| Scope creep | Plan drift |
| Verification skipped | Silent breakage |
| Broken build between steps | Blocks the team |
| Abstractions built before they're needed | Premature complexity |

## When to Stop and Ask for Help

**STOP executing immediately when:**
- Hit a blocker (missing dependency, test fails, instruction unclear)
- Plan has critical gaps preventing starting
- You don't understand an instruction
- Verification fails repeatedly

**Ask for clarification rather than guessing.**

## When to Revisit Earlier Steps

**Return to Review (Step 1) when:**
- Partner updates the plan based on your feedback
- Fundamental approach needs rethinking

**Don't force through blockers** — stop and ask.

## Remember
- Review plan critically first
- Follow plan steps exactly
- Don't skip verifications
- Reference skills when plan says to
- Stop when blocked, don't guess
- Never start implementation on main/master branch without explicit user consent

## Integration

**Required workflow skills:**
- **superpowers:using-git-worktrees** - Ensures isolated workspace (creates one or verifies existing)
- **superpowers:writing-plans** - Creates the plan this skill executes
- **superpowers:finishing-a-development-branch** - Complete development after all tasks

---
name: context-engineering
description: Optimizes agent context setup. Use when starting a new session, when agent output quality degrades, when switching between tasks, or when you need to configure rules files and context for a project.
---

# Context Engineering

## Overview

Feed agents the right information at the right time. Context is the single biggest lever for agent output quality — too little and the agent hallucinates, too much and it loses focus. Context engineering is the practice of deliberately curating what the agent sees, when it sees it, and how it's structured.

## When to Use

- Starting a new coding session
- Agent output quality is declining (wrong patterns, hallucinated APIs, ignoring conventions)
- Switching between different parts of a codebase
- Setting up a new project for AI-assisted development
- The agent is not following project conventions

## The Context Hierarchy

Structure context from most persistent to most transient:

```
┌─────────────────────────────────────┐
│  1. Rules Files (CLAUDE.md, etc.)   │ ← Always loaded, project-wide
├─────────────────────────────────────┤
│  2. Spec / Architecture Docs        │ ← Loaded per feature/session
├─────────────────────────────────────┤
│  3. Relevant Source Files            │ ← Loaded per task
├─────────────────────────────────────┤
│  4. Error Output / Test Results      │ ← Loaded per iteration
├─────────────────────────────────────┤
│  5. Conversation History             │ ← Accumulates, compacts
└─────────────────────────────────────┘
```

### Level 1: Rules Files

Create a rules file that persists across sessions. This is the highest-leverage context you can provide.

**CLAUDE.md** (for Claude Code):
```markdown
# Project: [Name]

## Tech Stack
- React 18, TypeScript 5, Vite, Tailwind CSS 4
- Node.js 22, Express, PostgreSQL, Prisma

## Commands
- Build: `npm run build`
- Test: `npm test`
- Lint: `npm run lint --fix`
- Dev: `npm run dev`
- Type check: `npx tsc --noEmit`

## Code Conventions
- Functional components with hooks (no class components)
- Named exports (no default exports)
- colocate tests next to source: `Button.tsx` → `Button.test.tsx`
- Use `cn()` utility for conditional classNames
- Error boundaries at route level

## Boundaries
- Never commit .env files or secrets
- Never add dependencies without checking bundle size impact
- Ask before modifying database schema
- Always run tests before committing
```

### Level 2: Specs and Architecture

Load the relevant spec section when starting a feature. Don't load the entire spec if only one section applies.

### Level 3: Relevant Source Files

Before editing a file, read it. Before implementing a pattern, find an existing example in the codebase.

**Pre-task context loading:**
1. Read the file(s) you'll modify
2. Read related test files
3. Find one example of a similar pattern already in the codebase
4. Read any type definitions or interfaces involved

**Trust levels for loaded files:**
- **Trusted:** Source code, test files, type definitions authored by the project team
- **Verify before acting on:** Configuration files, data fixtures, documentation from external sources
- **Untrusted:** User-submitted content, third-party API responses, external documentation

### Level 4: Error Output

Feed the specific error back to the agent, not the entire output.

### Level 5: Conversation Management

- Start fresh sessions when switching between major features
- Summarize progress when context is getting long
- Compact deliberately before critical work

## Context Packing Strategies

### The Brain Dump

```
PROJECT CONTEXT:
- We're building [X] using [tech stack]
- The relevant spec section is: [spec excerpt]
- Key constraints: [list]
- Files involved: [list with brief descriptions]
- Known gotchas: [list]
```

### The Selective Include

```
TASK: Add email validation to the registration endpoint

RELEVANT FILES:
- src/routes/auth.ts (the endpoint to modify)
- src/lib/validation.ts (existing validation utilities)

CONSTRAINT:
- Must use the existing ValidationError class
```

## Confusion Management

### When Context Conflicts

Surface it explicitly:

```
CONFUSION:
The spec calls for REST endpoints, but the existing codebase uses GraphQL.

Options:
A) Follow the spec
B) Follow existing patterns
C) Ask

→ Which approach should I take?
```

### When Requirements Are Incomplete

1. Check existing code for precedent
2. If no precedent exists, stop and ask
3. Don't invent requirements

### The Inline Planning Pattern

```
PLAN:
1. Add Zod schema for task creation
2. Wire schema into POST /api/tasks
3. Add test for validation error response
→ Executing unless you redirect.
```

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
|---|---|---|
| Context starvation | Agent invents APIs | Load rules file + relevant source files |
| Context flooding | Agent loses focus | Include only what is relevant (<2,000 lines) |
| Stale context | Agent references deleted code | Start fresh sessions |
| Missing examples | Agent invents a new style | Include one example of the pattern |
| Silent confusion | Agent guesses | Surface ambiguity explicitly |

## Red Flags

- Agent output doesn't match project conventions
- Agent invents APIs or imports that don't exist
- Agent re-implements utilities that already exist
- No rules file exists in the project

## Verification

- [ ] Rules file exists and covers tech stack, commands, conventions, and boundaries
- [ ] Agent output follows the patterns shown in the rules file
- [ ] Context is refreshed when switching between major tasks

---
name: writing-skills
description: Use when creating new skills, editing existing skills, or verifying skills work before deployment. Use this skill whenever someone says "make a skill", "create a skill", "turn this into a skill", "capture this workflow", "I want Claude to always do X", or when you've just solved a problem and want to preserve the approach for future sessions.
---

# Writing Skills

## Overview

**Writing skills IS Test-Driven Development applied to process documentation.**

You write test cases (pressure scenarios with subagents), watch them fail (baseline behavior), write the skill (documentation), watch tests pass (agents comply), and refactor (close loopholes).

**Core principle:** If you didn't watch an agent fail without the skill, you don't know if the skill teaches the right thing.

**Personal skills live in your runtime's skills directory** — see your runtime's documentation for the path. Cross-runtime alias: `~/.agents/skills/`.

**REQUIRED BACKGROUND:** You MUST understand superpowers:test-driven-development before using this skill. That skill defines the fundamental RED-GREEN-REFACTOR cycle. This skill adapts TDD to documentation.

## What is a Skill?

A **skill** is a reference guide for proven techniques, patterns, or tools. Skills help future agents find and apply effective approaches.

**Skills are:** Reusable techniques, patterns, tools, reference guides

**Skills are NOT:** Narratives about how you solved a problem once

## The Creation Loop

The process at a high level:

1. Capture intent and understand what the skill should do
2. Write a draft of the skill
3. Run test cases with and without the skill (baseline comparison)
4. Evaluate results — qualitatively with the user, quantitatively with benchmarks
5. Rewrite based on feedback
6. Repeat until satisfied
7. Optionally optimize the description for better triggering

Figure out where the user is in this process and jump in to help them progress. Maybe they say "I want to make a skill for X" — help narrow it down, write a draft, write test cases, evaluate. Maybe they already have a draft — go straight to eval/iterate.

## Capturing Intent

Before writing anything, understand:

1. What should this skill enable Claude to do?
2. When should this skill trigger? (what user phrases/contexts)
3. What's the expected output format?
4. Are test cases appropriate? Skills with objectively verifiable outputs (file transforms, data extraction, code generation) benefit from test cases. Skills with subjective outputs (writing style, art) often don't need them.

If the current conversation already contains a workflow the user wants to capture, extract answers from the history first — tools used, sequence of steps, corrections the user made, input/output formats. Fill gaps with the user before proceeding.

## When to Create a Skill

**Create when:**
- Technique wasn't intuitively obvious to you
- You'd reference this again across projects
- Pattern applies broadly (not project-specific)
- Others would benefit

**Don't create for:**
- One-off solutions
- Standard practices well-documented elsewhere
- Project-specific conventions (put in your instructions file)
- Mechanical constraints (if enforceable with regex/validation, automate it — save documentation for judgment calls)

## Skill Types

### Technique
Concrete method with steps to follow (condition-based-waiting, root-cause-tracing)

### Pattern
Way of thinking about problems (flatten-with-flags, test-invariants)

### Reference
API docs, syntax guides, tool documentation

## Skill Architecture (Progressive Disclosure)

Skills use a three-level loading system:

1. **Metadata** (name + description) — Always in context (~100 words)
2. **SKILL.md body** — In context whenever skill triggers (<500 lines ideal)
3. **Bundled resources** — Loaded as needed (unlimited; scripts can execute without loading)

```
skill-name/
  SKILL.md              # Main reference (required)
  scripts/              # Executable code for deterministic/repetitive tasks
  references/           # Docs loaded into context as needed
  assets/               # Files used in output (templates, icons, fonts)
```

**Keep SKILL.md under 500 lines.** If you're approaching this limit, add a layer of hierarchy with clear pointers to where the model should go next.

**Separate files for:**
1. Heavy reference (100+ lines) — API docs, comprehensive syntax
2. Reusable tools — Scripts, utilities, templates

**Keep inline:**
- Principles and concepts
- Code patterns (< 50 lines)
- Everything else

**Domain organization:** When a skill supports multiple domains/frameworks:
```
cloud-deploy/
├── SKILL.md (workflow + selection)
└── references/
    ├── aws.md
    ├── gcp.md
    └── azure.md
```

## SKILL.md Structure

**Frontmatter (YAML):**
- Two required fields: `name` and `description`
- Max 1024 characters total
- `name`: Use letters, numbers, and hyphens only (no parentheses, special chars)
- `description`: Describes WHEN to use (triggering conditions)

```markdown
---
name: Skill-Name-With-Hyphens
description: Use when [specific triggering conditions and symptoms]
---

# Skill Name

## Overview
What is this? Core principle in 1-2 sentences.

## When to Use
Bullet list with SYMPTOMS and use cases
When NOT to use

## Core Pattern (for techniques/patterns)
Before/after code comparison

## Quick Reference
Table or bullets for scanning common operations

## Implementation
Inline code for simple patterns
Link to file for heavy reference or reusable tools

## Common Mistakes
What goes wrong + fixes
```

## Skill Discovery Optimization (SDO)

Future agents need to FIND your skill. Optimize for this.

### 1. Description Field

**Purpose:** Your agent reads the description to decide which skills to load. Make it answer: "Should I read this skill right now?"

**CRITICAL: Description = When to Use, NOT What the Skill Does**

The description should describe triggering conditions. Do NOT summarize the skill's process or workflow — testing revealed that when a description summarizes the skill's workflow, agents may follow the description instead of reading the full skill content, causing them to skip crucial steps.

**Also important:** Claude has a tendency to undertrigger skills — to not use them when they'd be useful. To combat this, make the skill description a little bit "pushy". Instead of just "Use when creating skills", write something that names the concrete user phrases that should trigger it.

```yaml
# BAD: Summarizes workflow
description: Use when executing plans - dispatches subagent per task with code review between tasks

# BAD: Too much process detail
description: Use for TDD - write test first, watch it fail, write minimal code, refactor

# GOOD: Just triggering conditions, no workflow summary
description: Use when executing implementation plans with independent tasks in the current session

# GOOD: Triggering conditions with concrete user phrases (pushy)
description: Use when the user says "make a skill", "create a skill", "turn this into a skill", or wants to capture a workflow
```

**Format guidelines:**
- Start with "Use when..." to focus on triggering conditions
- Use concrete triggers, symptoms, situations
- Describe the *problem* not *language-specific symptoms*
- Keep triggers technology-agnostic unless the skill is technology-specific
- Write in third person (injected into system prompt)
- NEVER summarize the skill's process or workflow

### 2. Keyword Coverage

Use words an agent would search for:
- Error messages: "Hook timed out", "ENOTEMPTY", "race condition"
- Symptoms: "flaky", "hanging", "zombie", "pollution"
- Synonyms: "timeout/hang/freeze", "cleanup/teardown/afterEach"
- Tools: Actual commands, library names, file types

### 3. Descriptive Naming

**Use active voice, verb-first:**
- `condition-based-waiting` not `async-test-helpers`
- `using-skills` not `skill-usage`
- `flatten-with-flags` not `data-structure-refactoring`

**Gerunds (-ing) work well for processes:** `creating-skills`, `testing-skills`, `debugging-with-logs`

### 4. Token Efficiency

**Target word counts:**
- Getting-started workflows: <150 words each
- Frequently-loaded skills: <200 words total
- Other skills: <500 words

**Move details to tool help; use cross-references instead of repetition; compress examples.**

```bash
wc -w skills/path/SKILL.md
```

### 5. Cross-Referencing Other Skills

Use skill name only, with explicit requirement markers:
- `**REQUIRED SUB-SKILL:** Use superpowers:test-driven-development`
- `**REQUIRED BACKGROUND:** You MUST understand superpowers:systematic-debugging`

No `@` links — `@` syntax force-loads files immediately, consuming context before you need them.

## Writing Style

**Explain the why behind everything you ask the model to do.** Today's LLMs have good theory of mind. When given a good harness and real understanding of why something matters, they go beyond rote instructions. If the user's feedback is terse or frustrated, try to understand what they actually want and transmit that understanding into the instructions.

**Yellow flags:**
- Writing ALWAYS or NEVER in all caps without explaining why
- Super rigid structures without reasoning
- Instructions that read like rules without rationale

When possible, reframe: explain *why* the thing you're asking for is important. That's more effective than prohibition.

**Prefer imperative form in instructions.** Generalize from examples — don't write skills that only work for the specific examples used in testing.

**One excellent example beats many mediocre ones.** Choose the most relevant language. Complete, runnable, well-commented explaining WHY, from a real scenario.

## Match the Form to the Failure

Before writing guidance, classify the baseline failure. The form that bulletproofs one failure type backfires on another.

| Baseline failure | Right form | Wrong form |
|---|---|---|
| Skips/violates a rule under pressure (knows better, does it anyway) | Prohibition + rationalization table + red flags | Soft guidance ("prefer...", "consider...") |
| Complies, but output has the wrong shape | Positive recipe or contract: state what the output IS | Prohibition list ("don't restate", "never narrate") |
| Omits a required element from something they already produce | Structural: REQUIRED field or slot in the template | Prose reminders near the template |
| Behavior should depend on a condition | Conditional keyed to an observable predicate | Unconditional rule + exemption clauses |

**Why prohibitions backfire on shaping problems:** under a competing incentive, agents negotiate with "don't X". A recipe leaves nothing to negotiate — the output matches the stated shape or it doesn't.

**Rules for whichever form you pick:**
- No nuance clauses. "Don't X unless it matters" reopens the negotiation.
- Exemption clauses don't scope. "This limit doesn't apply to code blocks" still suppresses code blocks.

## Bulletproofing Skills Against Rationalization

For discipline-enforcing skills (TDD, verification-before-completion, etc.), agents are smart and will find loopholes under pressure. This toolkit applies to discipline failures — an agent that knows the rule and skips it under pressure. For wrong-shaped output, use Match the Form instead.

### Close Every Loophole Explicitly

Don't just state the rule — forbid specific workarounds:

```markdown
Write code before test? Delete it. Start over.

No exceptions:
- Don't keep it as "reference"
- Don't "adapt" it while writing tests
- Don't look at it
- Delete means delete
```

### Address "Spirit vs Letter" Arguments

Add this foundational principle early:

```markdown
Violating the letter of the rules is violating the spirit of the rules.
```

This cuts off "I'm following the spirit" rationalizations.

### Build Rationalization Table

Capture rationalizations from baseline testing. Every excuse agents make goes in the table:

```markdown
| Excuse | Reality |
|--------|---------|
| "Too simple to test" | Simple code breaks. Test takes 30 seconds. |
| "I'll test after" | Tests passing immediately prove nothing. |
```

### Create Red Flags List

```markdown
## Red Flags - STOP and Start Over

- Code before test
- "I already manually tested it"
- "Tests after achieve the same purpose"
- "It's about spirit not ritual"
- "This is different because..."

All of these mean: Delete code. Start over.
```

## The Iron Law (Same as TDD)

```
NO SKILL WITHOUT A FAILING TEST FIRST
```

This applies to NEW skills AND EDITS to existing skills.

Write skill before testing? Delete it. Start over.
Edit skill without testing? Same violation.

**No exceptions:**
- Not for "simple additions"
- Not for "just adding a section"
- Not for "documentation updates"
- Don't keep untested changes as "reference"
- Don't "adapt" while running tests
- Delete means delete

## RED-GREEN-REFACTOR for Skills

### RED: Write Failing Test (Baseline)

Run pressure scenario with subagent WITHOUT the skill. Document exact behavior:
- What choices did they make?
- What rationalizations did they use (verbatim)?
- Which pressures triggered violations?

This is "watch the test fail" — you must see what agents naturally do before writing the skill.

### GREEN: Write Minimal Skill

Write skill that addresses those specific rationalizations. Don't add extra content for hypothetical cases.

Run same scenarios WITH skill. Agent should now comply.

### REFACTOR: Close Loopholes

Agent found new rationalization? Add explicit counter. Re-test until bulletproof.

### Micro-Test Wording Before Full Scenarios

Full pressure-scenario runs are the final gate but are slow. Verify wording first with micro-tests:

1. **One fresh-context sample per call** — System prompt = the realistic context the guidance will live in; user message = a task that tempts the failure.
2. **Always include a no-guidance control.** If the control doesn't exhibit the failure, there's nothing to fix.
3. **5+ reps per variant.** Single samples lie.
4. **Manually read every flagged match.** Template echoes and quoted counter-examples masquerade as hits.
5. **Variance is a metric.** Five different interpretations across five reps means the wording isn't binding.

Micro-tests verify wording; they do not replace pressure scenarios for discipline skills.

## Testing All Skill Types

### Discipline-Enforcing Skills (rules/requirements)

**Test with:**
- Academic questions: Do they understand the rules?
- Pressure scenarios: Do they comply under stress?
- Multiple pressures combined: time + sunk cost + exhaustion

**Success criteria:** Agent follows rule under maximum pressure

### Technique Skills (how-to guides)

**Test with:**
- Application scenarios: Can they apply the technique correctly?
- Variation scenarios: Do they handle edge cases?
- Missing information tests: Do instructions have gaps?

**Success criteria:** Agent successfully applies technique to new scenario

### Pattern Skills (mental models)

**Test with:**
- Recognition scenarios: Do they recognize when pattern applies?
- Counter-examples: Do they know when NOT to apply?

**Success criteria:** Agent correctly identifies when/how to apply pattern

### Reference Skills (documentation/APIs)

**Test with:**
- Retrieval scenarios: Can they find the right information?
- Gap testing: Are common use cases covered?

**Success criteria:** Agent finds and correctly applies reference information

## Running Evaluations

For each test case, spawn two subagents in the same turn — one with the skill, one without (baseline). Do not spawn with-skill runs first and come back for baselines later. Launch everything at once.

Organize results by iteration: `<skill-name>-workspace/iteration-1/eval-0/with_skill/`, etc.

While runs are in progress, draft quantitative assertions. Good assertions are objectively verifiable with descriptive names. Subjective skills are better evaluated qualitatively.

After runs complete: grade assertions, aggregate benchmark data, and show the user the results before making revisions yourself. The human review step is essential — get outputs in front of the user before you start making corrections.

## Improving the Skill

After the user reviews results:

1. **Generalize from feedback.** You're iterating on a few examples to move fast, but the skill must work across many different prompts. Avoid overfitting. If there's a stubborn issue, try different metaphors or different patterns of working rather than adding more MUSTs.

2. **Keep the skill lean.** Remove things not pulling their weight. Read the transcripts, not just final outputs — if the skill causes unproductive work, remove the parts driving it.

3. **Explain the why.** Transmit real understanding into the instructions, not just rules.

4. **Look for repeated work across test cases.** If all test runs independently wrote the same helper script, that script belongs in `scripts/` — write it once, bundle it, tell the skill to use it.

## Common Rationalizations for Skipping Testing

| Excuse | Reality |
|--------|---------|
| "Skill is obviously clear" | Clear to you ≠ clear to other agents. Test it. |
| "It's just a reference" | References can have gaps. Test retrieval. |
| "Testing is overkill" | Untested skills have issues. Always. 15 min testing saves hours. |
| "I'll test if problems emerge" | Problems = agents can't use skill. Test BEFORE deploying. |
| "Too tedious to test" | Testing is less tedious than debugging bad skill in production. |
| "I'm confident it's good" | Overconfidence guarantees issues. Test anyway. |
| "Academic review is enough" | Reading ≠ using. Test application scenarios. |
| "No time to test" | Deploying untested skill wastes more time fixing it later. |

**All of these mean: Test before deploying. No exceptions.**

## Flowchart Usage

Use flowcharts ONLY for:
- Non-obvious decision points
- Process loops where you might stop too early
- "When to use A vs B" decisions

Never use flowcharts for:
- Reference material → Tables, lists
- Code examples → Markdown blocks
- Linear instructions → Numbered lists
- Labels without semantic meaning (step1, helper2)

## Description Optimization

After creating or improving a skill, offer to optimize the description for better triggering accuracy.

Generate 20 eval queries (mix of should-trigger and should-not-trigger). Queries must be realistic and concrete — include file paths, personal context, column names, company names, casual speech, typos. Focus on edge cases, not clear-cut examples.

For **should-trigger** queries: different phrasings of the same intent, some formal some casual, cases where the user doesn't name the skill but clearly needs it.

For **should-not-trigger** queries: near-misses that share keywords but need something different. "Write a fibonacci function" as a negative for a PDF skill is too easy — make negatives genuinely tricky.

Run the optimization loop, evaluate against held-out test set, apply the best-scoring description.

## STOP: Before Moving to Next Skill

**After writing ANY skill, you MUST STOP and complete the deployment process.**

**Do NOT:**
- Create multiple skills in batch without testing each
- Move to next skill before current one is verified
- Skip testing because "batching is more efficient"

Deploying untested skills = deploying untested code.

## Skill Creation Checklist (TDD Adapted)

**RED Phase - Write Failing Test:**
- [ ] Create pressure scenarios (3+ combined pressures for discipline skills)
- [ ] Run scenarios WITHOUT skill — document baseline behavior verbatim
- [ ] Identify patterns in rationalizations/failures

**GREEN Phase - Write Minimal Skill:**
- [ ] Name uses only letters, numbers, hyphens
- [ ] YAML frontmatter with `name` and `description` (max 1024 chars)
- [ ] Description starts with "Use when..." and includes specific triggers/symptoms
- [ ] Description is "pushy" enough to combat undertriggering
- [ ] Description does NOT summarize the skill's workflow
- [ ] Description written in third person
- [ ] Keywords throughout for search (errors, symptoms, tools)
- [ ] Clear overview with core principle
- [ ] Address specific baseline failures identified in RED
- [ ] Guidance form matches the failure type (see Match the Form to the Failure)
- [ ] For behavior-shaping guidance: wording micro-tested against a no-guidance control (5+ reps)
- [ ] Code inline OR link to separate file
- [ ] One excellent example (not multi-language)
- [ ] Run scenarios WITH skill — verify agents now comply

**REFACTOR Phase - Close Loopholes:**
- [ ] Identify NEW rationalizations from testing
- [ ] Add explicit counters (if discipline skill)
- [ ] Build rationalization table from all test iterations
- [ ] Create red flags list
- [ ] Re-test until bulletproof

**Quality Checks:**
- [ ] Small flowchart only if decision non-obvious
- [ ] Quick reference table
- [ ] Common mistakes section
- [ ] No narrative storytelling
- [ ] Supporting files only for tools or heavy reference

**Deployment:**
- [ ] Commit skill to git and push to your fork (if configured)
- [ ] Consider contributing back via PR (if broadly useful)

## Anti-Patterns

**Narrative Example:** "In session 2025-10-03, we found empty projectDir caused..."
Why bad: Too specific, not reusable

**Multi-Language Dilution:** example-js.js, example-py.py, example-go.go
Why bad: Mediocre quality, maintenance burden

**Code in Flowcharts:** `step1 [label="import fs"]`
Why bad: Can't copy-paste, hard to read

**Generic Labels:** helper1, helper2, step3, pattern4
Why bad: Labels should have semantic meaning

## The Bottom Line

**Creating skills IS TDD for process documentation.**

Same Iron Law: No skill without failing test first.
Same cycle: RED (baseline) → GREEN (write skill) → REFACTOR (close loopholes).
Same benefits: Better quality, fewer surprises, bulletproof results.

If you follow TDD for code, follow it for skills. It's the same discipline applied to documentation.

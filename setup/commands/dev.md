# [343 Guilty Spark] Dev — Plan + Execute

Full development workflow. Spawns `planner` (opus), pauses for user review, then spawns `executor` (sonnet).

## Input

The feature description comes from one of:
1. Text following `/dev` in the user's message
2. A referenced task file (e.g. `cadrage/task.md`) — read it along with any screenshots in the same folder
3. The user's message directly (e.g. "Implémente la feature X")

If no description and no file → ask: "What do you want to build?"

When a task file is referenced: read it and all images in its folder before spawning the planner. Store the folder path as `TASK_FOLDER` (e.g. `cadrage/`). If no task file is used, set `TASK_FOLDER = ""`.

---

## Step −3 — Brainstorm (si pas de task file)

**Seulement si `TASK_FOLDER = ""`** (feature décrite en texte libre, sans fichier de cadrage).

Invoke the `brainstorming` skill. Follow it exactly — it will:
- Explore project context and recent commits
- Ask clarifying questions one at a time
- Propose 2–3 approaches with trade-offs and a recommendation
- Present a design for user approval
- Write a design doc to `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`

**Do NOT proceed to Step −2 until brainstorming completes and the user has approved the design.**

If a task file was provided (`TASK_FOLDER ≠ ""`): feature is already scoped — skip this step entirely.

---

## Step −2 — Rename conversation

Extract the Jira ticket code from the feature description or task file (pattern `[A-Z]+-\d+`, e.g. `PMPFLOW-369`).

If found: rename this Claude Code conversation to `<JIRA-CODE>` using the `/title` slash command.

If not yet found (no description provided): skip — rename after extraction in Step 0.

---

## Step −1 — Extract domain context

Before spawning any sub-agent, synthesize DOMAIN_CONTEXT from the current conversation:

- Business rules and domain constraints discussed (e.g. "bundle children can have mixed units")
- Technical decisions and architectural choices mentioned
- Known edge cases, invariants, gotchas surfaced during the conversation
- Any "why" behind implementation choices

Keep it concise: plain text, 100–300 words max.
If no relevant context exists, set: `DOMAIN_CONTEXT = "No additional domain context."`

Store DOMAIN_CONTEXT as a variable — it will be injected into every sub-agent prompt below.

---

## Step −0.5 — Load vault context

Read the following files and concatenate into `VAULT_CONTEXT`:

1. `/Users/cpo/Documents/obsidian/claude/wiki/index.md` — global index
2. Latest file in `/Users/cpo/Documents/obsidian/claude/wiki/Daily/` (sort by name desc, take first) — last session summary
3. `/Users/cpo/Documents/obsidian/claude/wiki/${CLAUDE_PROJECT}/index.md` — project index (skip if file absent or `$CLAUDE_PROJECT` is empty/`default`)

If all files are absent → set `VAULT_CONTEXT = "No vault context available."`

Do NOT read learnings or other wiki files — index + daily note only.

---

## Step 0 — Sync main then create feature branch

Before anything else, sync main and create a dedicated branch.

**First: switch to main and pull latest:**
```bash
git switch main && git pull
```

If this fails (dirty working tree, etc.) → report the error and stop.

**Extract from the feature description or task file:**
- **Jira ticket code** — match pattern `[A-Z]+-\d+` (e.g. `PMPFLOW-283`). If not found, ask the user: "What is the Jira ticket code?"
- **Feature slug** — a short kebab-case summary of the feature (2–4 words max, e.g. `uo-description`, `historic-bundle-actions`)

**Branch name format:** `<JIRA-CODE>/<feature-slug>`
Example: `PMPFLOW-204/uo-description`

**Steps:**
1. Check current branch: `git branch --show-current`
2. If already on a branch matching `[A-Z]+-\d+/.*` → skip branch creation, use existing branch
3. Otherwise:
   ```bash
   git checkout -b <JIRA-CODE>/<feature-slug>
   ```
4. Confirm the branch to the user before proceeding

### Worktree (optional)

If the user requested an isolated worktree (e.g. "dans un worktree", "in a worktree", "use a worktree"):

Invoke the `dev-worktree` skill — **setup phase** — passing `<JIRA-CODE>/<feature-slug>` as the branch name. Follow it exactly. Set `WORKTREE_ACTIVE=true` on success.

---

## Step 1 — Spawn planner

Use the Agent tool with:
- `subagent_type`: `planner`
- `model`: `opus`
- `description`: "Plan: <feature description>"
- `prompt`: Pass the full feature description plus:

  > ## Vault Context (project knowledge base)
  > {{VAULT_CONTEXT}}
  >
  > ## Domain Context (from conversation)
  > {{DOMAIN_CONTEXT}}
  >
  > ---
  >
  > Use the `writing-plans` skill. Follow it exactly — it will: (1) map all files to create/modify and their responsibilities before defining tasks, (2) produce bite-sized tasks each with acceptance criteria, verification steps, affected files, and a commit, (3) apply TDD, YAGNI, DRY, frequent commits. Ask clarification questions whenever something is ambiguous — return them clearly labeled before the plan. **Do NOT write code in the plan** — describe what each step does in plain language. Only include a code snippet when a precise technical choice needs illustration (e.g. a specific API signature or SQL query). Save the plan to `~/.claude/plans/${CLAUDE_PROJECT:-default}/plans/YYYY-MM-DD-<slug>.md`. Return: (1) any clarification questions if needed, (2) the saved plan path, (3) a short summary of tasks.
  >
  > ıı

**If planner returns clarification questions:**
- Display them to the user
- Wait for answers
- Re-invoke planner with the original description + answers, same instructions
- Repeat until planner returns a complete plan with no pending questions

If planner returns an error or no plan path → report and stop.

---

## Step 2 — Plan review (mandatory pause)

Read the saved plan file and display its full content to the user.

Then ask:

> **Plan ready.** Reply with one of:
> - `ok` — approve and start execution
> - `no` — cancel
> - Any other text — modification instructions (the plan will be updated before execution)

**Wait for the user's reply before proceeding.**

- `ok` → go to Step 3
- `no` → stop, output "Execution cancelled."
- Modification instructions → re-invoke planner:

  Use the Agent tool with:
  - `subagent_type`: `planner`
  - `model`: `opus`
  - `prompt`:
    > Here is the current plan: [paste full plan content]
    >
    > The user requested these modifications: [user's instructions]
    >
    > Update the plan accordingly. Keep everything else unchanged. Save the updated plan to the same file path and return the updated content.

  Show the updated plan. Ask for review again (loop back to Step 2).

---

## Step 2.5 — Detect tech stack

Read the project's `CLAUDE.md` (or `package.json` / `composer.json` if no CLAUDE.md) to detect the primary stack:

| Stack signals | `EXECUTOR_AGENT` |
|---|---|
| Nuxt, Vue, `.vue`, `nuxt.config.*` | `nuxt-expert` |
| Angular, `angular.json`, `@angular/core` | `angular-expert` |
| Symfony, PHP, `symfony.lock`, `composer.json` | `symfony-expert` |
| None match | `executor` |

Set `EXECUTOR_AGENT` to the matched value.

---

## Step 3 — Spawn executor

Use the Agent tool with:
- `subagent_type`: `<EXECUTOR_AGENT>`
- `model`: `sonnet`
- `description`: "Execute plan"
- `prompt`:

  > ## Vault Context (project knowledge base)
  > {{VAULT_CONTEXT}}
  >
  > ## Domain Context (from conversation)
  > {{DOMAIN_CONTEXT}}
  >
  > ---
  >
  > **Your role: plan executor.** Use the `subagent-driven-development` skill if tasks are mostly independent (dispatch a fresh subagent per task + task review after each). Use `executing-plans` if tasks are strongly sequential. In both cases: load the latest plan in `~/.claude/plans/${CLAUDE_PROJECT:-default}/plans/`, implement each task step by step, run each verify step, update checkboxes as you go, commit after each completed task. Do NOT pause between tasks to check in — execute continuously. Return a summary of what was done.
  >
  > **While executing:** whenever you encounter an unexpected issue, non-obvious workaround, framework gotcha, or reusable pattern, append a note to `/tmp/learning-notes-${CLAUDE_PROJECT:-default}.md` using this format:
  > ```
  > [tag] technology — precise description of the problem — solution applied
  > ```
  > Examples: `[gotcha] nuxt — definePageMeta must be called at top level — move it before any conditional`
  > Append only. One line per discovery. Skip trivial or already-known facts.

---

## Step 3.5 — Capture learnings

After the executor completes, invoke the `capture-learning` skill to persist any notes written during execution.

```bash
cat "/tmp/learning-notes-${CLAUDE_PROJECT:-default}.md" 2>/dev/null
```

If the file is non-empty, invoke the Skill tool with `capture-learning`. Otherwise skip.

---

## Step 3.6 — Verification loop

After executor completes, spawn a verification agent:

Use the Agent tool with:
- `subagent_type`: `<EXECUTOR_AGENT>`
- `model`: `sonnet`
- `description`: "Verification loop"
- `prompt`:

  > Apply the `verification-before-completion` skill first (Iron Law: no completion claim without fresh verification evidence). Then apply the `verification-loop` skill for stack-specific commands.
  >
  > **Step 1 — Change inventory**
  > ```bash
  > git diff --name-only main..HEAD
  > ```
  > Classify each file: `created | modified | deleted`
  >
  > **Step 2 — Static verification**
  > Run the appropriate build/type-check command for the detected stack (tsc --noEmit, nuxi build, phpstan, etc.)
  >
  > **Step 3 — Test verification**
  > Run the full test suite. Capture pass/fail counts.
  >
  > **Step 4 — Functional verification**
  > For each modified file: imports correct, no circular deps, no `any` introduced, no console.error at runtime.
  >
  > Return a structured report:
  > ```
  > ## Verification Report
  > ### Build: ✅ / ❌
  > ### Tests: X/Y passing
  > ### Regressions: [list or none]
  > ### Verdict: ✅ DONE / ❌ BLOCKED — [reason]
  > ```

**If verdict is `❌ BLOCKED`:**
- Display the report to the user
- Re-invoke `<EXECUTOR_AGENT>` to fix the issues, then re-run Step 3.6 (max 2 retries)
- If still blocked after 2 retries → report to user and stop

---

## Step 4 — Code Review

Before creating the MR, invoke the `code-review-and-quality` skill on the executor's output.

Use the Agent tool with:
- `subagent_type`: `code-reviewer`
- `model`: `sonnet`
- `description`: "Code review before MR"
- `prompt`:

  > Apply the `code-review-and-quality` skill to the changes introduced by the executor.
  >
  > ## Domain Context (from conversation)
  > {{DOMAIN_CONTEXT}}
  > Pay special attention to whether the code correctly handles the domain constraints and edge cases listed above.
  >
  > ---
  >
  > Run:
  > ```bash
  > git diff main..HEAD
  > ```
  > Review the diff across all five axes: **Correctness, Readability, Architecture, Security, Performance**.
  >
  > Use the severity labels from the skill:
  > - *(none)* — required before merge
  > - **Critical:** — blocks merge
  > - **Nit:** — minor, optional
  > - **Consider:** — suggestion, not required
  > - **FYI** — informational only
  >
  > Output a structured review using the checklist from the skill. If any **Critical** issues are found, list them explicitly and set `review_status: BLOCKED`. Otherwise set `review_status: APPROVED`.
  >
  > Return:
  > 1. The full review with labeled comments
  > 2. The filled checklist
  > 3. `review_status`: `APPROVED` or `BLOCKED`

**If `review_status: BLOCKED`:**
- Display the critical issues to the user
- Ask:
  > **Code review found blocking issues.** Reply with one of:
  > - `fix` — re-invoke the executor to address the issues, then re-run the review (loop back to Step 4)
  > - `skip` — bypass the review and proceed to MR creation (not recommended)
  > - `no` — cancel

**If `review_status: APPROVED`:**
- Display the review summary to the user
- Proceed to Step 4.5

---

## Step 4.5 — Security review (conditional)

Check if the diff touches security-sensitive areas:

```bash
git diff main..HEAD -- | grep -iE "auth|login|password|token|session|role|permission|crypt|hash|jwt|api.?key|secret|fetch|axios|http|external" | head -20
```

**If matches found** → spawn a security review agent:

Use the Agent tool with:
- `subagent_type`: `security-expert`
- `model`: `sonnet`
- `description`: "Security review"
- `prompt`:

  > Apply the `security-and-hardening` skill to the following diff.
  >
  > ```bash
  > git diff main..HEAD
  > ```
  >
  > Check against OWASP Top 10: injection, broken auth, XSS, broken access control, security misconfiguration.
  > Also verify: no secrets committed, no sensitive data logged, parameterized queries, proper cookie attributes, authorization on every protected endpoint.
  >
  > Return:
  > 1. Findings with severity: **Critical** / **High** / **Nit**
  > 2. `security_status`: `APPROVED` or `BLOCKED`

  If `security_status: BLOCKED` → display issues, ask user: `fix` / `skip` / `no` (same loop as Step 4).

**If no matches found** → skip, proceed to Step 5.

---

## Step 5 — Create Merge Request

After the code review is approved, invoke the `gitlab-mr-create` skill and follow it exactly. It defines the Claranet MR description format (Contexte / Changements / Tests / Breaking changes) and the `glab mr create` flags.

Title format: `<conventional-commit-style title reflecting the feature> (<project-acronym>/<task-number>)`.

Output the MR URL when done.

---

## Step 6 — Worktree cleanup (if applicable)

**Only if `WORKTREE_ACTIVE=true`.**

Invoke the `dev-worktree` skill — **cleanup phase**. Follow it exactly.

---

## Step 7 — Report

```
## /dev complete

**Branch:** <branch name>
**Plan:** <plan file path>
**Tasks:** X / Y completed
**Commits:** <list of hash + message>
**Review:** APPROVED / BLOCKED (with issue count if any)
**MR:** <MR URL>
**Worktree:** removed / n/a
**Issues:** <deviations or failures, if any>
```

---

## Step 8 — Task folder cleanup

**Only if `TASK_FOLDER` is non-empty.**

1. Delete all files and subdirectories inside `TASK_FOLDER` (keep the folder itself)
2. Create a fresh `task.md` in `TASK_FOLDER` with exactly this content:

```
{CODE-PROJET} : 
```

**Warning:** This permanently deletes all files in the task folder (screenshots, attachments, etc.). Only run after the MR is created and the work is complete.

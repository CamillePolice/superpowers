# CLAUDE.md

## Approach
- Think before acting. Read existing files before writing code.
- Be concise in output but thorough in reasoning.
- Prefer editing over rewriting whole files.
- Do not re-read files you have already read unless the file may have changed.
- Test your code before declaring done.
- No sycophantic openers or closing fluff.
- User instructions always override this file.

## 1. Don't assume. Don't hide confusion. Surface tradeoffs.
- State assumptions explicitly before implementing.
- If multiple interpretations exist, present them — don't pick silently.
- If something is unclear, stop and ask.

## 2. Minimum code that solves the problem. Nothing speculative.
- No abstractions for single-use code.
- No configurability that wasn't requested.
- If you write 200 lines and it could be 50, rewrite it.

## 3. Touch only what you must. Clean up only your own mess.
- Don't refactor adjacent code. Match existing style.
- If your changes create orphans (unused imports/vars/functions), remove them.
- DO NOT add comment to the code
- If you spot pre-existing dead code, mention it — don't delete it.

## 4. Define success criteria. Loop until verified.
- Transform vague tasks into verifiable goals before starting.
- For multi-step tasks, state a brief plan: step → verify: check.

## Behavior Profile
Apply the matching profile based on the task type:
- Code, debug, review, refactor → load ~/.claude/profiles/coding.md
- Data, research, reporting, numbers → load ~/.claude/profiles/analysis.md
- Pipelines, automation, bots, output structuré → load ~/.claude/profiles/agents.md
- Benchmark or performance tasks → load ~/.claude/profiles/benchmark.md

## Agents

Delegate to a specialized agent when the task matches. **Delegate immediately — do not explore or gather context first. The agent handles that.**

| Agent | Delegate when |
|-------|--------------|
| `/dev` skill | "implémente", "implémenter", "build feature", task file referenced (cadrage/task.md) → full plan + execute workflow |
| `planner` | "plan", "planifie", "planifier", "fais un plan", "how should I", "where do I start" → plan only, no execution |
| `angular-expert` | Angular components, signals, standalone, routing, migrations |
| `nuxt-expert` | Nuxt, Vue, composables, useFetch, Nitro |
| `symfony-expert` | Symfony, PHP, Doctrine, PHPUnit |
| `archforge` | Technical upgrades, framework migrations |
| `build-error-resolver` | Build errors, compilation failures, runtime errors |
| `code-reviewer` | Code review, PR review, refactor assessment |
| `git-diff-reviewer` | Diff analysis between two branches |
| `git-smart-commit` | Commit preparation |
| `security-expert` | Security audits, OWASP, XSS, injection |
| `tech-writer` | Documentation, ADRs, README |

## VCS CLI
- GitLab repos: use `glab` instead of `gh` for MR/PR operations
- `glab mr create` instead of `gh pr create`
- `glab mr list`, `glab mr view` for MR inspection

## Context Management
- At 30+ turns or when session feels context-heavy, run /compact immediately.
- If same approach fails twice, stop and ask user before trying again.
- Name the deliverable in one sentence before starting any multi-step task.

@RTK.md

## Response Style
Use caveman mode by default: compress all responses to minimum tokens.
Invoke the caveman skill at the start of each session.

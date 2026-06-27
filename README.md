# Superpowers

Superpowers is a complete software development methodology for your coding agents, built on top of a set of composable skills and some initial instructions that make sure your agent uses them.


## Quickstart

Give your agent Superpowers: [Claude Code](#claude-code), [OpenCode](#opencode).

## How it works

It starts from the moment you fire up your coding agent. As soon as it sees that you're building something, it *doesn't* just jump into trying to write code. Instead, it steps back and asks you what you're really trying to do. 

Once it's teased a spec out of the conversation, it shows it to you in chunks short enough to actually read and digest. 

After you've signed off on the design, your agent puts together an implementation plan that's clear enough for an enthusiastic junior engineer with poor taste, no judgement, no project context, and an aversion to testing to follow. It emphasizes true red/green TDD, YAGNI (You Aren't Gonna Need It), and DRY. 

Next up, once you say "go", it launches a *subagent-driven-development* process, having agents work through each engineering task, inspecting and reviewing their work, and continuing forward. It's not uncommon for your agent to work autonomously for a couple hours at a time without deviating from the plan you put together.

There's a bunch more to it, but that's the core of the system. And because the skills trigger automatically, you don't need to do anything special. Your coding agent just has Superpowers.

## Installation

Installation differs by harness. If you use more than one, install Superpowers separately for each one.

### Claude Code

Superpowers is available via the [official Claude plugin marketplace](https://claude.com/plugins/superpowers)

#### Official Marketplace

- Install the plugin from Anthropic's official marketplace:

  ```bash
  /plugin install superpowers@claude-plugins-official
  ```

#### Superpowers Marketplace

The Superpowers marketplace provides Superpowers and some other related plugins for Claude Code.

- Register the marketplace:

  ```bash
  /plugin marketplace add obra/superpowers-marketplace
  ```

- Install the plugin from this marketplace:

  ```bash
  /plugin install superpowers@superpowers-marketplace
  ```

### OpenCode

OpenCode uses its own plugin install; install Superpowers separately even if you
already use it in another harness.

- Tell OpenCode:

  ```
  Fetch and follow instructions from https://raw.githubusercontent.com/obra/superpowers/refs/heads/main/.opencode/INSTALL.md
  ```

- Detailed docs: [docs/README.opencode.md](docs/README.opencode.md)

---

## Personal Setup (fork CamillePolice/superpowers)

This fork extends upstream Superpowers with a complete personal Claude Code environment under `setup/`. It stays trivially synced with upstream: `main` is a pure mirror, all additions are additive-only files.

### What's added

**20 additional skills** (in `skills/`, alongside upstream):

| Skill | Purpose |
|---|---|
| `code-review-and-quality` | 5-axis review (correctness, readability, architecture, security, performance) |
| `code-simplification` | Refactor for readability while preserving behavior |
| `dev-worktree` | Worktree lifecycle for the `/dev` workflow (setup + cleanup phases) |
| `documentation-and-adrs` | ADRs and API change documentation |
| `git-diff-review` | Diff analysis between two branches |
| `git-workflow-and-versioning` | Disciplined git workflow, Conventional Commits |
| `gitlab-mr-create` | GitLab MR with structured Claranet description format |
| `gitlab-mr-review` | Full MR review loop: fetch comments → fix → test → reply |
| `idea-refine` | Lightweight clarification (1 question at a time) before planning |
| `incremental-implementation` | Thin vertical slices — implement, test, verify, commit, repeat |
| `npm-package-vetting` | Security/maintenance check before any `npm install` |
| `obsidian-markdown` | Obsidian-flavored Markdown (wikilinks, callouts, embeds) |
| `pr-feedback-formatter` | Format code review feedback as structured Markdown |
| `security` | Security-by-design (6-layer: input, identity, data, resilience, supply chain, frontend) |
| `security-and-hardening` | OWASP Top 10 review before merging security-sensitive changes |
| `source-driven-development` | Ground framework decisions in official documentation |
| `spec-driven-development` | Write spec before writing code |
| `strategy-compact` | Context compaction at session inflection points |
| `vault-context` | Load project context from Obsidian vault at agent startup |
| `verification-loop` | Stack-specific verification commands (Angular tsc/ng test, Symfony phpstan/phpunit) + report template |

**`setup/` — installer and personal config:**

```
setup/
  install.sh              # Modular installer (--core --agents --obsidian --rtk --mcp --cron --sync)
  modules/                # claude-core, agents, obsidian, rtk, mcp, cron, utils, superpowers-sync
  agents/                 # 12 specialized agents (angular-expert, symfony-expert, nuxt-expert,
                          #   planner, executor, code-reviewer, git-diff-reviewer,
                          #   git-smart-commit, build-error-resolver, security-expert,
                          #   tech-writer, archforge)
  commands/               # 9 commands: dev, prime, ingest, query, save, capture-learning,
                          #   lint, notebooklm, context-engineering
  config/                 # CLAUDE.md, RTK.md, settings.json, profiles/, rules/, hooks/
  obsidian-vault/         # Vault template (wiki/index, wiki/Daily, raw/learnings...)
  scripts/                # auto-capture-learning.sh
```

**`/dev` workflow enhancements** (guilty-spark command):

- **Step −3**: `brainstorming` skill gates execution when no task file — design approval required before planning
- **Step 1**: `writing-plans` methodology in planner — file map first, bite-sized tasks, TDD/YAGNI/DRY
- **Step 3**: `subagent-driven-development` per task + `npm-package-vetting` before any `npm install`
- **Step 3.6**: `verification-before-completion` (Iron Law) + `verification-loop` (stack-specific commands)
- **Step 4**: `code-review-and-quality` 5-axis review before MR
- **Step 4.5**: `security-and-hardening` on auth/token/API diffs
- **Step 5**: `gitlab-mr-create` with Claranet MR format

### Install

```bash
git clone git@github.com:CamillePolice/superpowers.git
cd superpowers
./setup/install.sh --all
```

Flags: `--core` · `--agents` · `--obsidian` · `--rtk` · `--mcp` · `--cron` · `--sync` · `--caveman` · `--all`

### Sync with upstream

```bash
./setup/install.sh --sync   # git fetch upstream + merge --ff-only + reinstall
```

Or manually:

```bash
git fetch upstream && git merge --ff-only upstream/main
./setup/install.sh --all
```

`--ff-only` guarantees zero conflicts as long as `main` stays a pure upstream mirror (never commit directly to `main`).
## The Basic Workflow

1. **brainstorming** - Activates before writing code. Refines rough ideas through questions, explores alternatives, presents design in sections for validation. Saves design document.

2. **using-git-worktrees** - Activates after design approval. Creates isolated workspace on new branch, runs project setup, verifies clean test baseline.

3. **writing-plans** - Activates with approved design. Breaks work into bite-sized tasks (2-5 minutes each). Every task has exact file paths, complete code, verification steps.

4. **subagent-driven-development** or **executing-plans** - Activates with plan. Dispatches fresh subagent per task with two-stage review (spec compliance, then code quality), or executes in batches with human checkpoints.

5. **test-driven-development** - Activates during implementation. Enforces RED-GREEN-REFACTOR: write failing test, watch it fail, write minimal code, watch it pass, commit. Deletes code written before tests.

6. **requesting-code-review** - Activates between tasks. Reviews against plan, reports issues by severity. Critical issues block progress.

7. **finishing-a-development-branch** - Activates when tasks complete. Verifies tests, presents options (merge/PR/keep/discard), cleans up worktree.

**The agent checks for relevant skills before any task.** Mandatory workflows, not suggestions.

## What's Inside

### Skills Library

**Testing**
- **test-driven-development** - RED-GREEN-REFACTOR cycle (includes testing anti-patterns reference)

**Debugging**
- **systematic-debugging** - 4-phase root cause process (includes root-cause-tracing, defense-in-depth, condition-based-waiting techniques)
- **verification-before-completion** - Ensure it's actually fixed

**Collaboration** 
- **brainstorming** - Socratic design refinement
- **writing-plans** - Detailed implementation plans
- **executing-plans** - Batch execution with checkpoints
- **dispatching-parallel-agents** - Concurrent subagent workflows
- **requesting-code-review** - Pre-review checklist
- **receiving-code-review** - Responding to feedback
- **using-git-worktrees** - Parallel development branches
- **finishing-a-development-branch** - Merge/PR decision workflow
- **subagent-driven-development** - Fast iteration with two-stage review (spec compliance, then code quality)

**Meta**
- **writing-skills** - Create new skills following best practices (includes testing methodology)
- **using-superpowers** - Introduction to the skills system

## Philosophy

- **Test-Driven Development** - Write tests first, always
- **Systematic over ad-hoc** - Process over guessing
- **Complexity reduction** - Simplicity as primary goal
- **Evidence over claims** - Verify before declaring success

## License

MIT License - see LICENSE file for details

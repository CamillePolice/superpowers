---
name: dev-worktree
description: Use when the dev command needs to set up or clean up an isolated git worktree for a feature branch. Two phases: setup (before planning) and cleanup (after MR created).
---

# dev-worktree

Handles worktree isolation lifecycle for the `/dev` workflow.

## Setup Phase

Called from `/dev` Step 0 after the branch name `<JIRA-CODE>/<feature-slug>` is determined.

1. Call `EnterWorktree` with `name: "<JIRA-CODE>/<feature-slug>"`
2. The tool creates branch `worktree-<JIRA-CODE>+<feature-slug>` — rename it immediately:
   ```bash
   git branch -m worktree-<JIRA-CODE>+<feature-slug> <JIRA-CODE>/<feature-slug>
   ```
3. Warn the user:
   > **Worktree ready.** Ignored files (`.env`, etc.) are not copied — copy manually if you need to run the app locally:
   > ```bash
   > cp /path/to/repo/.env .
   > ```

## Cleanup Phase

Called from `/dev` Step 6 after the MR URL is obtained.

The branch is on remote — local commits are safe to discard.

1. Call `ExitWorktree` with `action: "remove"`
   - If tool refuses (unmerged local commits), re-invoke with `discard_changes: true`
2. Inform the user:
   > **Worktree removed.** To test the feature locally:
   > ```bash
   > git fetch origin && git switch <JIRA-CODE>/<feature-slug>
   > ```

## Common Mistakes

- **Skipping branch rename** — the `worktree-*` prefix won't push cleanly to the expected remote branch name
- **Not copying `.env`** — dev server fails with missing env vars; user assumes worktree is broken
- **Cleanup before push** — always push the branch first (Step 5), then clean up (Step 6)

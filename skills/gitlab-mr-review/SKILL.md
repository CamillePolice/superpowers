---
name: gitlab-mr-review
description: Full GitLab MR review workflow — fetch comments, verify issues against real code, apply fixes, run tests, commit, and reply to each discussion thread. Use when the user asks to analyse, traiter, or respond to feedback on a GitLab MR/PR. Invoke even if the user just pastes a GitLab MR URL or says "réponds aux commentaires".
---

# GitLab MR Review

Full workflow: fetch → analyse → fix → test → commit → reply.

---

## Step 1 — Fetch MR details and discussions

```bash
# MR summary
glab mr view <MR_NUMBER> --repo <REPO_PATH>

# All discussions with IDs (needed to reply inline later)
glab api "projects/<ENCODED_REPO>/merge_requests/<MR_NUMBER>/discussions"
```

`ENCODED_REPO` = repo path with `/` replaced by `%2F`.  
Example: `claranet/dos/federalapps/biome-apps/project-flow` → `claranet%2Fdos%2Ffederalapps%2Fbiome-apps%2Fproject-flow`

Parse the API response to extract:
- `discussion.id` — needed to post replies
- `note.id`, `note.author.username`, `note.body`
- `note.resolvable` — human review comments are resolvable; bot notes are not
- `note.resolved` — skip already-resolved threads

Focus on **resolvable=true, resolved=false** threads (human reviewer) and relevant bot suggestions.

---

## Step 2 — Read referenced code

**Before evaluating any comment**, read the actual file at the referenced line.  
Never evaluate a suggestion based solely on the diff or the comment text — the reviewer may lack context, and the fix may already exist or be incorrect.

Use `sed -n 'START,ENDp' <file>` to read only the relevant range.

---

## Step 3 — Analyse each comment

Invoke `superpowers:receiving-code-review` skill.

For each comment:

| Source | Default stance |
|--------|---------------|
| Human reviewer | Trusted — implement after verifying technical correctness |
| Bot suggestion (Medium/High importance) | Evaluate — may be valid, may miss domain context |
| Bot suggestion (Low importance) | Skeptical — verify the stated rationale carefully |

**Verification checklist per comment:**
- [ ] Is the suggested change technically correct for this codebase?
- [ ] Does it require domain knowledge not visible in the diff? (business rules, invariants)
- [ ] Is the performance/correctness claim actually true? (bot suggestions often invert perf arguments)
- [ ] Does fixing it require updating tests?

**Bot suggestion traps to watch:**
- "Removing X is faster" — verify; sometimes X exists to reduce downstream work
- "Check only the first element" vs "check all elements" — think about mixed-data scenarios
- "This is redundant" — verify SQL/ORM semantics before removing

---

## Step 4 — Apply fixes

For each validated fix:
1. Edit the file (prefer `Edit` over full rewrite)
2. If the fix changes logic, update or add the corresponding test
3. Run the test suite immediately after each fix:
   ```bash
   npx vitest run <test-file>   # or the project's test runner
   ```
4. All tests must pass before moving to the next fix

Fix order: blocking correctness issues first → simple fixes → complex refactors.

---

## Step 5 — Commit

Use `generic-conventional-commits:generating-git-commits` skill (or `caveman:caveman-commit`).

One commit covering all review fixes. Include in the body:
- What changed and why (reviewer's concern)
- If multiple independent fixes, separate them with a blank line

```bash
git push
```

---

## Step 6 — Reply to each discussion thread

For every thread where an action was taken (fix applied, or reasoned pushback), post a reply:

```bash
glab api --method POST \
  "projects/<ENCODED_REPO>/merge_requests/<MR_NUMBER>/discussions/<DISCUSSION_ID>/notes" \
  --field "body=<REPLY>"
```

**Reply format:**
- Fix applied: `"Fixed in <short-sha> — <one sentence what changed and why.>"`
- Pushback: `"<Technical reason why the current implementation is correct. Reference specific code or invariant.>"`
- No change needed: `"<Explanation why existing code is correct.>"`

No thanks, no pleasantries. State the action or reasoning only.

After replying, optionally resolve the thread if the fix is complete:

```bash
glab api --method PUT \
  "projects/<ENCODED_REPO>/merge_requests/<MR_NUMBER>/discussions/<DISCUSSION_ID>" \
  --field "resolved=true"
```

---

## Step 7 — Summary

Output:

```
## MR <number> review complete

Fixes applied: <N>
Pushed: <short-sha>

| Thread | Author | Action |
|--------|--------|--------|
| <note excerpt> | <author> | Fixed / Pushed back / No change |
```

---

## Domain context note

When this skill is invoked from `/dev`, the `DOMAIN_CONTEXT` variable is already populated.
Prepend it to your analysis in Step 3 — it contains business rules and invariants that may not be visible in the diff.

If invoked standalone (direct user request), ask: "Y a-t-il du contexte domaine pertinent que je devrais connaître avant d'analyser les commentaires ?" before starting Step 3. If the user says no, proceed.

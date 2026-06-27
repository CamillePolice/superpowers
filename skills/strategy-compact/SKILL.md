# Skill: strategy-compact

Monitors context size and suggests manual compaction before saturation.

## When to trigger

Invoke this skill proactively when:
- The session exceeds ~50 exchanges
- Claude starts "forgetting" decisions made early in the session
- A new work phase begins (e.g. moving from planning to coding)
- Before tackling a long task (refactoring, complete module migration)

## Process

### Step 1 — Summarize current state

Before compacting, produce a session summary:

```
## Session Summary — [date]

### Decisions made
- [decision 1]
- [decision 2]

### Code produced / modified
- [file]: [what changed]

### Patterns discovered
- [pattern]

### Problems solved
- [problem] → [solution]

### Next steps
- [step 1]
- [step 2]

### Critical context to retain
- [info that must not be lost]
```

### Step 2 — Persist to notepad

```bash
cat >> /tmp/learning-notes.md << 'EOF'
[session-summary] Compact summary: <paste the summary above on one line>
EOF
```

### Step 3 — Suggest compaction

Inform the user:

> "Context is becoming large. I recommend running `/compact` now to preserve performance.
> I have saved a session summary. After compaction, I will reload context from the vault via `/prime`."

### Step 4 — After compaction (new session)

On restart, reload:
1. Run `/prime` to load vault context
2. The session summary from `/tmp/learning-notes.md` if present
3. Critical files identified in "Critical context to retain"

## Rules

- Never compact without producing the summary first
- Always ask for confirmation before suggesting `/compact`
- Prioritize continuity: the user should not have to re-explain context

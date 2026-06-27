# Skill: verification-loop

Verifies that a task is truly complete and no regressions have been introduced.

## When to trigger

- After a significant refactor
- After a pattern migration (e.g. BehaviorSubject → signal)
- After code deletion (dead code removal)
- Before declaring a task "done"
- When the user says "verify everything works"

## Process

### Step 1 — Change inventory

```bash
git diff --name-only HEAD~1
# or for staged changes:
git diff --staged --name-only
```

List each modified file and classify: `created | modified | deleted`

### Step 2 — Static verification

**Angular / TypeScript**
```bash
npx tsc --noEmit
npx ng build --configuration=development 2>&1 | tail -20
```

**Symfony / PHP**
```bash
php bin/console cache:clear
composer dump-autoload
php vendor/bin/phpstan analyse --level=8 src/ 2>&1 | tail -20
```

### Step 3 — Test verification

```bash
# Angular
npx ng test --watch=false --browsers=ChromeHeadless 2>&1 | tail -30

# Symfony
php bin/phpunit --testdox 2>&1 | tail -30
```

### Step 4 — Functional verification

For each modified file:
- [ ] Component/service instantiates without error
- [ ] Imports are correct (no circular dependency)
- [ ] Types are consistent (no `any` introduced)
- [ ] No console.error at runtime

### Step 5 — Report

```
## Verification Report

### Build
- TypeScript: ✅ / ❌ [errors]
- Build: ✅ / ❌ [errors]

### Tests
- Passing: X/Y
- Failed: [list]

### Regressions detected
- [regression] → [corrective action]

### Verdict
✅ DONE — no regressions
❌ BLOCKED — [reason]
```

## Rules

- Never skip the build step even if "it seems obvious"
- If a test fails, do not mark the task done
- Document any regression in the learning notepad


# Rule: Agent Delegation

> Transversal delegation rules — applies before any agent is loaded.

## When to delegate

| Situation                                       | Agent                     |
| ----------------------------------------------- | ------------------------- |
| Angular component / service / store / migration | `@angular-expert`       |
| Symfony controller / service / entity / API     | `@symfony-expert`       |
| Build or compilation error                      | `@build-error-resolver` |
| Feature touching more than 3 files              | `@planner`first         |
| Dead code removal / pattern migration           | `@refactor-cleaner`     |
| Technical upgrade (Angular, Symfony versions)   | `@archforge`            |
| Committing changes                              | `@git-smart-commit`     |
| Code review before PR                           | `@code-reviewer`        |

## Hard rules

* Run `/prime` at session start to load project context from the vault
* Always use `@planner` before coding a feature that touches more than 3 files
* Always use `@git-smart-commit` for commits — never commit manually
* If a task spans Angular and Symfony, split into two separate agent calls
* Use `strategy-compact` skill when context exceeds ~50 exchanges

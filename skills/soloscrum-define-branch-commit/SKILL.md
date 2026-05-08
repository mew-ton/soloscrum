---
name: soloscrum-define-branch-commit
description: "Reference: branch naming pattern {type}/{issue-id}-{slug} and Conventional Commits format for all soloscrum development work. Repo-specific strategy in .claude/rules/branch.md takes precedence."
user-invocable: false
---

# soloscrum-define-branch-commit

Branch naming and commit conventions.

## Branch Naming

```
{type}/{issue-id}-{slug}
```

### type

| type | Purpose |
|---|---|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Refactoring |
| `docs` | Documentation |
| `chore` | Build, tooling, dependencies |
| `test` | Test additions and fixes |

### issue-id

Identifier of the Subtask the branch implements. Format depends on the active tracker profile (per `soloscrum-define-tracker-profile`):

- `github-only` → GH Sub-issue number (e.g. `123`)
- `linear+github` → Linear subtask ID (e.g. `PRJ-42`)

### slug

- Issue title converted to kebab-case
- 30 characters maximum
- Lowercase letters, numbers, and hyphens only

### Examples

```
feat/123-user-password-reset
fix/PRJ-42-auth-token-expiry
```

## Commit Conventions

Use [Conventional Commits](https://www.conventionalcommits.org/).

```
{type}({scope}): {description}

[optional body]

[optional footer]
```

### type

`feat` / `fix` / `refactor` / `docs` / `chore` / `test` / `style` / `perf`

### Example

```
feat(auth): add password reset endpoint

Implements the POST /auth/reset-password endpoint with email
verification flow.

Closes #123
```

## Notes

- Repository-specific branch strategy in `.claude/rules/branch.md` takes precedence
- Never commit directly to main / master

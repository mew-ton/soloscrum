---
name: soloscrum-define-branch-commit
description: "Reference: branch naming ({type}/{issue-id}-{slug}, where issue-id is the Subtask or no-Subtask Issue), Conventional Commits, and parent Issue close convention (per-Subtask PRs close only the Subtask; parent closes via /refine janitor). Repo-specific strategy in .claude/rules/branch.md takes precedence."
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

Identifier of the work unit the branch implements:

- **When the parent Issue has Subtasks** (the common case for any intent that went through `/breakdown`), use the **Subtask** identifier — one branch per Subtask, one PR per Subtask. Each PR closes only its own Subtask via `Closes #<subtask>`.
- **When the Issue has no Subtasks** (per `soloscrum-define-issue-size`, an intent small enough to fit in a single `/develop` unit and that skipped `/breakdown`), use the **Issue** identifier directly. The PR closes the Issue via `Closes #<issue>` at merge.

Format depends on the active tracker profile (per `soloscrum-define-tracker-profile`):

- `github-only` → GH Issue / Sub-issue number (e.g. `123`)
- `linear+github` → Linear Issue / subtask ID (e.g. `PRJ-42`)

### slug

- Issue title converted to kebab-case
- 30 characters maximum
- Lowercase letters, numbers, and hyphens only

### Examples

```
feat/123-user-password-reset        # parent Issue with Subtasks; 123 is the Subtask
fix/PRJ-42-auth-token-expiry        # Linear subtask ID
refactor/456-cleanup-legacy-router  # Issue with no Subtasks; 456 is the Issue itself
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

## Parent Issue close

GitHub's `Closes #` keyword in a PR body auto-closes only the **directly-referenced** Issue at merge — it does not traverse a Sub-issue tree to close parents. The soloscrum contract for parent Issue close is therefore:

- Each Subtask PR body contains `Closes #<subtask>` and **only** the Subtask reference. Do not add `Closes #<parent>` to per-Subtask PRs — that would either close the parent prematurely (on the first Subtask merge) or require predicting which Subtask PR will be the chronologically last to merge.
- The parent Issue stays open while at least one of its Subtasks is open.
- The parent Issue is closed by the next `/refine` backlog janitor sweep once all its Subtasks are closed (intent-level AC sign-off having happened at that point per `soloscrum-define-issue-format`'s Subtask Body section).

See `commands/refine.md` for the janitor step details. `soloscrum-define-pr-lifecycle` ("Issue close happens at merge") documents why the parent stays open until the janitor fires.

For Issues without Subtasks, the standard `Closes #<issue>` keyword in the PR body closes the Issue directly at merge — no janitor step needed.

## Notes

- Repository-specific branch strategy in `.claude/rules/branch.md` takes precedence
- Never commit directly to main / master

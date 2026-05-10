---
title: define-branch-commit
description: Spec summary — branch naming and Conventional Commit conventions for soloscrum.
sidebar:
  order: 2
---

`soloscrum-define-branch-commit` is the naming contract for branches and commits. Both `/develop` and the review pipeline read it; if a branch or commit message does not match, that is grounds for a Fail.

## What it does

It pins:

- The branch name format `{type}/{issue-id}-{slug}`.
- The vocabulary for `{type}`: `feat`, `fix`, `refactor`, `docs`, `chore`, `test`.
- How `{issue-id}` is shaped per active tracker profile (GitHub issue number for `github-only`; Linear ID like `PRJ-42` for `linear+github`).
- The slug rules: kebab-case, lowercase letters/digits/hyphens, 30-character maximum.
- That commits follow [Conventional Commits](https://www.conventionalcommits.org/) — `{type}({scope}): {description}` with an optional body and footer.

## When it is consumed

`soloscrum-implement-task` (the engine behind `/develop`) creates the branch and the first commit using these rules. The review pipeline reads the branch name and the PR's commit list when verifying DoD; a commit that is not Conventional or a branch that does not match the format will surface as a finding.

## Key inputs and outputs

Inputs are the issue/subtask ID, its title (which becomes the slug), and the commit type (taken from the commit's intent). Output is a branch reference and one or more commit messages that follow the contract.

## Examples

```text
feat/123-user-password-reset
fix/PRJ-42-auth-token-expiry
refactor/47-concept-reference-docs
```

```text
feat(auth): add password reset endpoint

Implements the POST /auth/reset-password endpoint with email
verification flow.

Closes #123
```

## Notes

- A repository-specific branch strategy in `.claude/rules/branch.md` takes precedence.
- Never commit directly to `main` / `master`.

## See also

- Canonical contract: [`skills/soloscrum-define-branch-commit/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-branch-commit/SKILL.md).
- For where branch creation fits in the lifecycle, see [Agents and responsibilities](/concept/agent-responsibilities/).

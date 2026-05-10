---
title: define-dod
description: Spec summary — Definition of Done checklist for soloscrum subtasks.
sidebar:
  order: 5
---

`soloscrum-define-dod` is the Definition of Done — the six-item checklist every subtask has to satisfy before `/review` can render a Pass verdict.

## What it does

It pins the canonical DoD list:

- [ ] All AC are satisfied.
- [ ] Tests exist (when applicable).
- [ ] PR body contains the Issue number (`Closes #N` / `Fixes #N` / `Resolves #N`).
- [ ] Zero lint errors.
- [ ] Code review pipeline executed and findings addressed (per [`define-code-review-process`](/reference/define-code-review-process/)).
- [ ] Review has passed.

For each item, the skill spells out what counts as satisfied — for example, "tests exist" applies to business logic, API endpoints, and utility functions but not to configuration changes with no logic, and "Issue number" specifically requires one of the GitHub-recognised auto-close keywords.

## When it is consumed

Two callers:

- `soloscrum-implement-task` (`/develop`) does a self-check covering every item except "Review has passed" — the developer agent cannot self-grant the review verdict.
- `soloscrum-review-implementation` (`/review`) verifies all six items, including the review pass which it itself is about to issue.

## Key inputs and outputs

Input is the PR (its body, the diff, the commit list, lint output, test results) and the linked Issue's AC. Output is per-item OK / Not OK plus the rationale, surfaced in the `/review` comment alongside the code review findings.

## Repo-specific extras

Repositories can add their own DoD requirements in `.claude/rules/dod-extra.md`. Those entries are appended to the core list, not replacing it.

## See also

- Canonical contract: [`skills/soloscrum-define-dod/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-dod/SKILL.md).
- The Issue-number auto-close keyword is enforced because of how Issue closure interacts with merge — see [PR lifecycle](/concept/pr-lifecycle/).

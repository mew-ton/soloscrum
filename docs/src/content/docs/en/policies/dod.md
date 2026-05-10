---
title: Definition of Done
description: The Definition of Done checklist for soloscrum subtasks.
sidebar:
  order: 5
---

Every subtask must satisfy six criteria before `/review` can issue a Pass verdict. The DoD is what verdict comments check against.

## The checklist

- [ ] All AC are satisfied.
- [ ] Tests exist (when applicable).
- [ ] PR body contains the Issue number (`Closes #N` / `Fixes #N` / `Resolves #N`).
- [ ] Zero lint errors.
- [ ] Code review pipeline executed and findings addressed (per the [code review process](/concept/code-review-process/)).
- [ ] Review has passed.

For each item, the rule spells out what counts as satisfied — for example, "tests exist" applies to business logic, API endpoints, and utility functions but not to configuration changes with no logic, and "Issue number" specifically requires one of the GitHub-recognised auto-close keywords.

## When this applies

Two moments:

- During `/develop`, the developer agent self-checks every item except "Review has passed" — the developer cannot self-grant the review verdict.
- During `/review`, all six items are verified, including the review pass which `/review` itself is about to issue. The verdict comment lists per-item OK / Not OK with rationale.

## Repo-specific extras

Repositories can add their own DoD requirements in `.claude/rules/dod-extra.md`. Those entries are appended to the core list, not replacing it.

## See also

- Why the auto-close keyword matters: [PR lifecycle](/concept/pr-lifecycle/).
- Canonical contract: [`skills/soloscrum-define-dod/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-dod/SKILL.md).

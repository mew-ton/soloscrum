---
title: Definition of Done
description: The Definition of Done checklist for soloscrum subtasks.
sidebar:
  order: 5
---

Every subtask must satisfy six criteria before `/review` can issue a Pass verdict. The verdict comment checks against this list.

## The checklist

- [ ] AC verified at the appropriate layer (see *AC verification* below).
- [ ] Tests exist (when applicable).
- [ ] PR body contains the Issue number (`Closes #N` / `Fixes #N` / `Resolves #N`) — `#<subtask>` for Subtask PRs, `#<issue>` for Issues without Subtasks. Per [branch-commit](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-branch-commit/SKILL.md), per-Subtask PRs do **not** reference the parent Issue via `Closes #`.
- [ ] Zero lint errors.
- [ ] Code review pipeline executed and findings addressed (per the [code review process](/concept/code-review-process/)).
- [ ] Review has passed.

Each item has a precise rule:

- "Tests exist" applies to business logic, API endpoints, and utility functions — not to configuration changes with no logic.
- "Issue number" specifically requires one of the GitHub-recognised auto-close keywords.

## AC verification

AC verification operates at two layers because Subtasks slice work, not intent (see [issue-format](/policies/issue-format/)'s Subtask body):

- **Subtask PR.** Verify the slice was delivered (its "what" + Checklist items) and that there is no regression — no parent AC item that was previously satisfied is now broken. The parent's AC is **not** required to be fully satisfied at this PR.
- **Issue without Subtasks** (single-`/develop`-unit Issue). Verify all of the Issue's AC are met, with evidence. The PR closes the Issue directly via `Closes #<issue>`.
- **Parent Issue (with Subtasks) — intent-level AC sign-off.** The parent's full AC is verified when all of its Subtasks are closed, not at any individual Subtask PR. The last Subtask PR's merge triggers the parent's close via the `/refine` janitor; at that point the parent's AC must be satisfiable from the union of the Subtasks' deliveries.

## When this applies

Two moments:

- During `/develop`, the developer agent self-checks every item except "Review has passed" — the developer cannot self-grant the review verdict.
- During `/review`, all six items are verified, including the review pass `/review` is about to issue. The verdict comment lists per-item OK / Not OK with rationale.

## Repo-specific extras

Repositories can add DoD requirements in `.claude/rules/dod-extra.md`. Entries are appended to the core list, not replaced.

## See also

- Why the auto-close keyword matters: [PR lifecycle](/concept/pr-lifecycle/).
- Canonical contract: [`skills/soloscrum-define-dod/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-dod/SKILL.md).

---
title: /develop
description: Implements a develop Subtask. Cuts the branch, writes code, opens a draft PR, and transitions the Subtask to in-review.
sidebar:
  order: 3
---

`/develop` implements a `type:develop` Subtask. It cuts a branch following the soloscrum naming convention, writes the implementation, runs the [DoD](/policies/dod/) self-checks, and opens a **draft** PR. The Subtask transitions from `in-progress` to `in-review` once the draft is open.

## Usage

```bash
/develop <subtask-id>
```

The argument is a Subtask URL or ID (`#N` under `github-only`, `PRJ-N` under `linear+github`). If omitted, the command auto-selects an `in-progress` Subtask via the active tracker's query skill.

## What happens

1. **Read the Subtask.** The Dev agent reads the Subtask AC, parent Issue, and any `.claude/rules/*.md` overrides for stack, branch strategy, and DoD extras.
2. **Cut the branch.** A new branch follows the [branch naming](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-branch-commit/SKILL.md) convention: `<type>/<issue-id>-<slug>` (e.g. `feat/123-password-reset`).
3. **Implement.** Code lands as Conventional Commits (`feat: …`, `fix: …`, `refactor: …`).
4. **DoD self-check.** Dev verifies every DoD item it owns: AC satisfied, tests written where applicable, lint clean, PR body will contain the Issue closing keyword. "Review has passed" is the one item Dev cannot self-grant — that belongs to `/review`.
5. **Open the PR as draft.** `gh pr create --draft` is the boundary. PRs always start as draft so the local quality gate runs in a defined window before any GitHub-side reviewer fires (see [PR lifecycle](/concept/pr-lifecycle/)).
6. **Confirm CI started.** `/develop` runs the wait-for-checks script with a short timeout (e.g. 300s). The intent is to surface CI startup failures (workflow syntax errors, missing secrets) at this step rather than letting `/review` discover them later — not to gate on green.
7. **Transition state.** The Subtask state moves to `in-review` via the active tracker's transition skill.

## Typical flow

You start with a Subtask in `in-progress` — usually from a recent `/breakdown` or a previous `/develop` invocation that set the state. You invoke `/develop #50` (or just `/develop` and let it auto-pick).

The Dev agent reads the Subtask AC, opens a branch like `feat/50-email-form-integration`, writes the implementation, and commits as it goes (`feat(auth): add password reset form`, `test(auth): cover form validation cases`). Once AC is satisfied and the local self-checks pass, it runs `gh pr create --draft` with a body that includes `Closes #50` — the closing keyword is required by the DoD so GitHub auto-closes the Issue at merge time. It then runs `skills/soloscrum-tracker-github-wait-for-pr-checks/scripts/wait-for-pr-checks.sh <pr> 15 300` to confirm CI started cleanly. The Subtask moves to `in-review`.

The handoff to you is a draft PR URL and a recommendation to run `/review <pr-url>`. Promotion to ready is **not** part of `/develop` — that belongs to `/review` after a Pass verdict.

## Output

- New branch pushed to origin.
- Draft PR URL.
- DoD self-check result.
- Subtask state advanced to `in-review`.
- CI startup result (informational).

## See also

- [Agents and responsibilities](/concept/agent-responsibilities/) — Dev owns this command.
- [PR lifecycle](/concept/pr-lifecycle/) — why PRs start as draft and why `/develop` does not promote to ready.
- [DoD](/policies/dod/) — the checklist Dev self-applies before opening the draft.
- Previous: [`/breakdown`](/commands/breakdown/). Next: [`/review`](/commands/review/).
- Canonical contract: [`commands/develop.md`](https://github.com/mew-ton/soloscrum/blob/main/commands/develop.md).

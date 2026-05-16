---
title: /develop
description: Implements a develop work unit — Subtask or no-Subtask Issue. Cuts the branch, writes code, opens a draft PR, and transitions the target to in-review.
sidebar:
  order: 3
---

`/develop` implements a `type:develop` work unit — either a **Subtask** (when the parent went through `/breakdown`) or a **no-Subtask Issue** (when the Issue's intent fits one reviewable PR per [issue size](/policies/issue-size/) and skipped `/breakdown`). It cuts a branch following the soloscrum naming convention, writes the implementation, runs the [DoD](/policies/dod/) self-checks, and opens a **draft** PR. The target (Subtask or no-Subtask Issue) transitions from `in-progress` to `in-review` once the draft is open.

## Usage

```bash
/develop <subtask-id-or-issue-id>
```

The argument is a Subtask URL or ID **or** a no-Subtask Issue URL or ID (`#N` under `github-only`, `PRJ-N` under `linear+github`). The case is determined by whether the referenced Issue is a Subtask of a parent or stands alone with no Sub-issues — see the canonical [branch-commit](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-branch-commit/SKILL.md) for the contract. If omitted, the command auto-selects an `in-progress` work unit via the active tracker's query skill.

## What happens

1. **Read the target.** For a Subtask target, Dev reads the Subtask's "what" + Checklist (its slice scope per [issue format](/policies/issue-format/)'s Subtask body) and the **parent Issue's AC**. For a no-Subtask Issue target, Dev reads the Issue's AC directly. Plus any `.claude/rules/*.md` overrides for stack, branch strategy, and DoD extras.
2. **Cut the branch.** A new branch follows the [branch naming](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-branch-commit/SKILL.md) convention: `<type>/<issue-id>-<slug>` — `feat/123-password-reset` for a Subtask target, `refactor/456-cleanup-legacy-router` for a no-Subtask Issue target.
3. **Implement.** Code lands as Conventional Commits (`feat: …`, `fix: …`, `refactor: …`).
4. **DoD self-check.** Dev verifies every DoD item it owns: AC verified at the appropriate layer per [DoD](/policies/dod/) (slice delivered + no regression on parent AC for a Subtask PR; full Issue AC for a no-Subtask Issue PR), tests written where applicable, lint clean, PR body will contain the closing keyword (`Closes #<subtask>` for a Subtask target, `Closes #<issue>` for a no-Subtask Issue target — never `Closes #<parent>` for a Subtask PR per branch-commit's parent-close contract). "Review has passed" is the one item Dev cannot self-grant — that belongs to `/review`.
5. **Open the PR as draft.** `gh pr create --draft` is the boundary. PRs always start as draft so the local quality gate runs in a defined window before any GitHub-side reviewer fires (see [PR lifecycle](/concept/pr-lifecycle/)).
6. **Confirm CI started.** `/develop` runs the wait-for-checks script with a short timeout (e.g. 300s). The intent is to surface CI startup failures (workflow syntax errors, missing secrets) at this step rather than letting `/review` discover them later — not to gate on green.
7. **Transition state.** The target (Subtask or no-Subtask Issue) state moves to `in-review` via the active tracker's transition skill.

## Typical flow

**Subtask target.** You start with a Subtask in `in-progress` — usually from a recent `/breakdown` or a previous `/develop` invocation. You invoke `/develop #50` (or just `/develop` and let it auto-pick).

The Dev agent reads the Subtask's slice scope (its "what" + Checklist) and the parent Issue's AC, opens a branch like `feat/50-email-form-integration`, writes the implementation, and commits as it goes (`feat(auth): add password reset form`, `test(auth): cover form validation cases`). Once the slice is delivered (no regression on the parent's AC), it runs `gh pr create --draft` with a body that includes `Closes #50` — the Subtask number, **never the parent Issue number** per [branch-commit](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-branch-commit/SKILL.md)'s parent-close contract. It then runs `skills/soloscrum-tracker-github-wait-for-pr-checks/scripts/wait-for-pr-checks.sh <pr> 15 300` to confirm CI started cleanly. The Subtask moves to `in-review`.

**No-Subtask Issue target.** When the Issue's intent fits a single reviewable PR (small bug fix, self-contained refactor), you skip `/breakdown` and invoke `/develop` directly on the Issue (e.g. `/develop #456`). Same flow shape: branch like `refactor/456-cleanup-legacy-router`, PR body `Closes #456` (the Issue itself), state transition on the Issue. The DoD's "Issue without Subtasks" path applies — `/review` verifies the **full** Issue AC against the PR.

The handoff to you is a draft PR URL and a recommendation to run `/review <pr-url>`. Promotion to ready is **not** part of `/develop` — that belongs to `/review` after a Pass verdict.

## Output

- New branch pushed to origin.
- Draft PR URL.
- DoD self-check result.
- Target (Subtask or no-Subtask Issue) state advanced to `in-review`.
- CI startup result (informational).

## See also

- [Agents and responsibilities](/concept/agent-responsibilities/) — Dev owns this command.
- [PR lifecycle](/concept/pr-lifecycle/) — why PRs start as draft and why `/develop` does not promote to ready.
- [DoD](/policies/dod/) — the checklist Dev self-applies before opening the draft.
- Previous: [`/breakdown`](/commands/breakdown/). Next: [`/review`](/commands/review/).
- Canonical contract: [`commands/develop.md`](https://github.com/mew-ton/soloscrum/blob/main/commands/develop.md).

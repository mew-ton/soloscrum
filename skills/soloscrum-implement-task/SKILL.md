---
name: soloscrum-implement-task
description: Implements a develop work unit — Subtask or no-Subtask Issue (per soloscrum-define-branch-commit's case-split) — by creating a branch, writing code and tests, committing with Conventional Commits, generating a PR body, creating the PR as draft, and transitioning the target to In Review via the active profile's tracker operation skill.
argument-hint: <subtask-id-or-issue-id>
disable-model-invocation: true
allowed-tools:
  - Read
  - Edit
  - Write
  - Glob
  - Grep
  - Bash(git:*)
  - Bash(gh pr:*)
  - Bash(gh issue:*)
  - Bash(gh api:*)
---

# soloscrum-implement-task

Implement code and generate a draft PR for a develop work unit (Subtask or no-Subtask Issue per `soloscrum-define-branch-commit`).

## Overview

Implements code for a develop work unit and generates a **draft** PR. The target is either a **Subtask** (read its Checklist / "what" slice scope and the **parent Issue's AC** — Subtasks themselves do not carry AC per `soloscrum-define-issue-format`'s Subtask Body section) or a **no-Subtask Issue** (per `soloscrum-define-branch-commit`'s branch-per-Issue case — read the Issue's AC directly). The draft phase is the local-quality-gate window defined in `soloscrum-define-pr-lifecycle`; promotion to ready is owned by `soloscrum-review` after the review pipeline has decided every finding. Follows `soloscrum-define-branch-commit` conventions. Subtask state transitions delegate to the active profile's tracker operation skill.

## Steps

1. Read target's reference material — **for a Subtask target**: its "what" + Checklist (slice scope per `soloscrum-define-issue-format`'s Subtask Body section) and the **parent Issue's AC** (what the slice must move closer to satisfying without regression); **for a no-Subtask Issue target** (per `soloscrum-define-branch-commit`'s branch-per-Issue case): the Issue's full AC directly. Arguments: $ARGUMENTS
2. Check tech stack in `.claude/rules/stack.md`
3. Create branch following `soloscrum-define-branch-commit` conventions:
   - `{type}/{issue-id}-{slug}`
4. Implement code to deliver the slice (and to move the parent Issue's AC closer to satisfied without regression):
   - Write tests (when applicable)
   - Confirm zero lint errors
5. Commit using Conventional Commits format
6. Generate PR body:

   ```markdown
   ## Summary
   [Change summary]

   ## Changes
   - [Change 1]

   ## Test
   [How to test]

   Closes #[Subtask number for a Subtask target, OR Issue number for a no-Subtask Issue target — never `Closes #<parent>` on a Subtask PR per `soloscrum-define-branch-commit`'s parent-close contract]
   ```

7. Create the PR **as draft**: `gh pr create --draft ...`. This is a reversible transition per `soloscrum-define-pr-lifecycle` and runs without pre-confirm. If `.claude/rules/pr.md` documents a repository-level override that makes the draft window unnecessary, follow that file; otherwise default to `--draft`.
8. Confirm CI started cleanly via `soloscrum-tracker-github-wait-for-pr-checks` (short `timeout_sec`, e.g. `300`):
   ```bash
   skills/soloscrum-tracker-github-wait-for-pr-checks/scripts/wait-for-pr-checks.sh <pr-number> 15 300
   ```
   This is a startup-confirmation step, not a green-gate — surface non-`SUCCESS` conclusions if any but proceed to handoff regardless. The intent is to catch CI startup failures (workflow syntax errors, missing secrets) early. **Do not** write inline `until` loops over `gh pr view`; that pattern is the named anti-pattern in `CLAUDE.md` and the reason this skill exists (see `soloscrum-tracker-github-wait-for-pr-checks`).
9. Verify DoD self-check with `soloscrum-define-dod` (every item except "Review has passed", which is owned by `soloscrum-review`).
10. Resolve the active tracker profile via `soloscrum-define-tracker-profile`, then invoke the matching `transition-state` operation skill to move the **target** (Subtask or no-Subtask Issue) to `in-review`:
    - `github-only` → `soloscrum-tracker-github-transition-state`
    - `linear+github` → `soloscrum-tracker-linear-transition-state`
    Reversible per `soloscrum-define-pr-lifecycle`'s autonomy table; runs without pre-confirm. This is the creator-side `→ in-review` transition assigned to `dev` in `soloscrum-define-agent-responsibilities` (applies to both Subtask and no-Subtask Issue targets).
11. Hand off to `/review` (which launches `soloscrum-review-implementation`). Do **not** promote the PR to ready from this skill — `gh pr ready` is owned by the review phase.

## Depends On

- `soloscrum-define-branch-commit`
- `soloscrum-define-dod`
- `soloscrum-define-pr-lifecycle` (draft creation, autonomy of reversible transitions, handoff boundary)
- `soloscrum-define-tracker-profile` (for resolving subtask ID conventions and routing the transition)
- `soloscrum-define-agent-responsibilities` (creator-side Subtask State ownership)
- `soloscrum-tracker-{github|linear}-transition-state` (delegated `→ in-review` transition in step 10)
- `soloscrum-tracker-github-wait-for-pr-checks` (CI-startup confirmation step 8)

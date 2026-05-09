---
name: soloscrum-implement-task
description: Implements a Subtask (type develop) by creating a branch, writing code and tests, committing with Conventional Commits, generating a PR body, and creating the PR as draft. Tracker-profile-agnostic except for state transitions.
argument-hint: <subtask-id>
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

Implement code and generate a draft PR for a Subtask of type `develop`.

## Overview

Implements code for a Subtask (type: develop) based on its AC and generates a **draft** PR. The draft phase is the local-quality-gate window defined in `soloscrum-define-pr-lifecycle`; promotion to ready is owned by `soloscrum-review` after the review pipeline has decided every finding. Follows `soloscrum-define-branch-commit` conventions. Subtask state transitions delegate to the active profile's tracker operation skill.

## Steps

1. Read target Subtask AC, description, and related Issue: $ARGUMENTS
2. Check tech stack in `.claude/rules/stack.md`
3. Create branch following `soloscrum-define-branch-commit` conventions:
   - `{type}/{issue-id}-{slug}`
4. Implement code to satisfy AC:
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

   Closes #[Issue number]
   ```

7. Create the PR **as draft**: `gh pr create --draft ...`. This is a reversible transition per `soloscrum-define-pr-lifecycle` and runs without pre-confirm. If `.claude/rules/pr.md` documents a repository-level override that makes the draft window unnecessary, follow that file; otherwise default to `--draft`.
8. Confirm CI started cleanly via `soloscrum-tracker-github-wait-for-pr-checks` (short `timeout_sec`, e.g. `300`):
   ```bash
   skills/soloscrum-tracker-github-wait-for-pr-checks/scripts/wait-for-pr-checks.sh <pr-number> 15 300
   ```
   This is a startup-confirmation step, not a green-gate — surface non-`SUCCESS` conclusions if any but proceed to handoff regardless. The intent is to catch CI startup failures (workflow syntax errors, missing secrets) early. **Do not** write inline `until` loops over `gh pr view`; that pattern is the named anti-pattern in `CLAUDE.md` and the reason this skill exists (see `soloscrum-tracker-github-wait-for-pr-checks`).
9. Verify DoD self-check with `soloscrum-define-dod` (every item except "Review has passed", which is owned by `soloscrum-review`).
10. Hand off to `/review` (which launches `soloscrum-review-implementation`). Do **not** promote the PR to ready from this skill — `gh pr ready` is owned by the review phase.

## Depends On

- `soloscrum-define-branch-commit`
- `soloscrum-define-dod`
- `soloscrum-define-pr-lifecycle` (draft creation, autonomy of reversible transitions, handoff boundary)
- `soloscrum-define-tracker-profile` (for resolving subtask ID conventions)
- `soloscrum-tracker-github-wait-for-pr-checks` (CI-startup confirmation step 8)

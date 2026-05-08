---
name: soloscrum-implement-task
description: Implements a Subtask (type develop) by creating a branch, writing code and tests, committing with Conventional Commits, generating a PR body, and creating the PR. Tracker-profile-agnostic except for state transitions.
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
  - Bash(gh issue view:*)
---

# soloscrum-implement-task

Implement code and generate a PR for a Subtask of type `develop`.

## Overview

Implements code for a Subtask (type: develop) based on its AC and generates a PR. Follows `soloscrum-define-branch-commit` conventions. Subtask state transitions delegate to the active profile's tracker operation skill.

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

7. Create PR
8. Verify DoD with `soloscrum-define-dod`

## Depends On

- `soloscrum-define-branch-commit`
- `soloscrum-define-dod`
- `soloscrum-define-tracker-profile` (for resolving subtask ID conventions)

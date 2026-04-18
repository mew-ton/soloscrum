---
name: soloscrum-implement-task
description: Implements a Linear subtask (type develop) by creating a branch, writing code and tests, committing with Conventional Commits, generating a PR body, and creating the PR.
argument-hint: <subtask-id>
disable-model-invocation: true
allowed-tools: Read Edit Write Glob Grep Bash
---

# soloscrum-implement-task

Implement code and generate a PR.

## Overview

Implements code for a Linear subtask (type: develop) based on its AC, and generates a PR. Follows `soloscrum-define-branch-commit` conventions.

## Steps

1. Read target subtask AC, description, and related Issue: $ARGUMENTS
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

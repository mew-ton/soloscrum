---
name: develop
description: Implements a Subtask of type develop. Creates a branch, writes code and tests, generates a PR, and transitions the Subtask to In Review.
argument-hint: <subtask-id>
disable-model-invocation: true
effort: high
allowed-tools:
  - Read
  - Edit
  - Write
  - Glob
  - Grep
  - Bash(git:*)
  - Bash(gh issue:*)
  - Bash(gh pr:*)
  - Bash(gh api:*)
  - Bash(gh label:*)
---

# /develop

Implement a develop Subtask.

## Behavior

1. Receive target Subtask (type: develop) (`$ARGUMENTS`)
2. Launch `soloscrum-dev` to:
   - Create branch following `soloscrum-define-branch-commit` conventions
   - Implement code referencing `.claude/rules/stack.md`
   - Verify DoD with `soloscrum-define-dod` and `.claude/rules/dod-extra.md`
   - Generate PR body (issue number, change summary, test instructions)
   - Create PR
3. Resolve active tracker profile and invoke `soloscrum-tracker-{github|linear}-transition-state` to move the Subtask to `in-review`
4. Present PR URL to user

## Input

- Subtask URL or ID (GH issue number `#N` or Linear ID `PRJ-N` depending on active profile)
- (If omitted) auto-select an `in-progress` Subtask via `soloscrum-tracker-{profile}-query-state`

## Output

- Created PR URL
- Implementation summary
- DoD checklist result

## Resources

- Subagent: `soloscrum-dev`
- Skills: `soloscrum-implement-task`, `soloscrum-define-branch-commit`, `soloscrum-define-dod`, `soloscrum-define-tracker-profile`
- Rules: `.claude/rules/stack.md`, `.claude/rules/branch.md`, `.claude/rules/dod-extra.md`

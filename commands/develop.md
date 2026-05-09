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
   - Create PR **as draft** (`gh pr create --draft`) per `soloscrum-define-pr-lifecycle`
   - Confirm CI started cleanly via `soloscrum-tracker-github-wait-for-pr-checks` with a short `timeout_sec` (e.g. `300`):
     ```bash
     skills/soloscrum-tracker-github-wait-for-pr-checks/scripts/wait-for-pr-checks.sh <pr-number> 15 300
     ```
     This is a confirmation step, not a green-gate — the `/develop` handoff does not block on `SUCCESS`. The intent is to surface CI startup failures (workflow file syntax errors, missing secrets) here rather than at `/review`. If the script returns non-zero (timeout), surface the in-flight names and proceed; if it returns zero with non-`SUCCESS` conclusions, surface the conclusions and proceed. Inline `until ... gh pr view ... sleep ...` loops are an anti-pattern (per CLAUDE.md).
   - Resolve the active tracker profile and invoke `soloscrum-tracker-{github|linear}-transition-state` to move the Subtask to `in-review` (owned by `soloscrum-implement-task` step 10; reversible per `soloscrum-define-pr-lifecycle`)
3. Present draft PR URL to user and recommend `/review <pr-url>` as the next step. Promotion to ready is owned by `soloscrum-review`, not by this command.

## Input

- Subtask URL or ID (GH issue number `#N` or Linear ID `PRJ-N` depending on active profile)
- (If omitted) auto-select an `in-progress` Subtask via `soloscrum-tracker-{profile}-query-state`

## Output

- Created PR URL
- Implementation summary
- DoD checklist result

## Resources

- Subagent: `soloscrum-dev`
- Skills: `soloscrum-implement-task`, `soloscrum-define-branch-commit`, `soloscrum-define-dod`, `soloscrum-define-pr-lifecycle`, `soloscrum-define-tracker-profile`, `soloscrum-tracker-github-wait-for-pr-checks` (when confirming CI started before handoff)
- Rules: `.claude/rules/stack.md`, `.claude/rules/branch.md`, `.claude/rules/dod-extra.md`, `.claude/rules/pr.md` (optional draft-window override)

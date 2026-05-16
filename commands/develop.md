---
name: develop
description: Implements a develop work unit — either a Subtask or a no-Subtask Issue (per soloscrum-define-branch-commit's case-split). Creates a branch, writes code and tests, generates a PR, and transitions the target to In Review.
argument-hint: <subtask-id-or-issue-id>
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

Implement a develop work unit (Subtask of type `develop`, or a no-Subtask Issue going through branch-per-Issue mode per `soloscrum-define-branch-commit`).

## Behavior

1. Receive target work unit (`$ARGUMENTS`) — either:
   - a **Subtask** of type `develop` (when the parent Issue went through `/breakdown`), or
   - a **no-Subtask Issue** (when the Issue's intent fits a single reviewable PR per `soloscrum-define-issue-size` and skipped `/breakdown`). The Issue still needs `type:develop` semantically — design-ui work goes through `/design-ui` regardless of split.
2. Launch `soloscrum-dev` to:
   - Create branch following `soloscrum-define-branch-commit` conventions
   - Implement code referencing `.claude/rules/stack.md`
   - Verify DoD with `soloscrum-define-dod` and `.claude/rules/dod-extra.md`
   - Generate PR body (closing keyword: `Closes #<subtask>` for a Subtask target, `Closes #<issue>` for a no-Subtask Issue target — per `soloscrum-define-branch-commit`'s parent-close contract, never `Closes #<parent>` for a Subtask PR; plus change summary and test instructions)
   - Create PR **as draft** (`gh pr create --draft`) per `soloscrum-define-pr-lifecycle`
   - Confirm CI started cleanly via `soloscrum-tracker-github-wait-for-pr-checks` with a short `timeout_sec` (e.g. `300`):
     ```bash
     skills/soloscrum-tracker-github-wait-for-pr-checks/scripts/wait-for-pr-checks.sh <pr-number> 15 300
     ```
     This is a confirmation step, not a green-gate — the `/develop` handoff does not block on `SUCCESS`. The intent is to surface CI startup failures (workflow file syntax errors, missing secrets) here rather than at `/review`. If the script returns non-zero (timeout), surface the in-flight names and proceed; if it returns zero with non-`SUCCESS` conclusions, surface the conclusions and proceed. Inline `until ... gh pr view ... sleep ...` loops are an anti-pattern (per CLAUDE.md).
   - Resolve the active tracker profile and invoke `soloscrum-tracker-{github|linear}-transition-state` to move the **target** (Subtask or no-Subtask Issue) to `in-review` (owned by `soloscrum-implement-task` step 10; reversible per `soloscrum-define-pr-lifecycle`)
3. Present draft PR URL to user and recommend `/review <pr-url>` as the next step. Promotion to ready is owned by `soloscrum-review`, not by this command.

## Input

- Subtask URL or ID, **or** no-Subtask Issue URL or ID (GH issue number `#N` or Linear ID `PRJ-N` depending on active profile). Both share the same numeric address space on GH; the case is determined by whether the referenced Issue is a Subtask of a parent or stands alone with no Sub-issues (per `soloscrum-define-branch-commit`).
- (If omitted) auto-select an `in-progress` Subtask or no-Subtask Issue via `soloscrum-tracker-{profile}-query-state`

## Output

- Created PR URL
- Implementation summary
- DoD checklist result

## Resources

- Subagent: `soloscrum-dev`
- Skills: `soloscrum-implement-task`, `soloscrum-define-branch-commit`, `soloscrum-define-dod`, `soloscrum-define-pr-lifecycle`, `soloscrum-define-tracker-profile`, `soloscrum-tracker-github-wait-for-pr-checks` (when confirming CI started before handoff)
- Rules: `.claude/rules/stack.md`, `.claude/rules/branch.md`, `.claude/rules/dod-extra.md`, `.claude/rules/pr.md` (optional draft-window override)

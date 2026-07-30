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

# /soloscrum:develop

Implement a develop work unit (Subtask of type `develop`, or a no-Subtask Issue going through branch-per-Issue mode per `soloscrum-define-branch-commit`).

## Behavior

1. Receive target work unit (`$ARGUMENTS`) — either:
   - a **Subtask** of type `develop` (when the parent Issue went through `/soloscrum:breakdown`), or
   - a **no-Subtask Issue** (when the Issue's intent fits a single reviewable PR per `soloscrum-define-issue-size` and skipped `/soloscrum:breakdown`). The Issue still needs `type:develop` semantically — design-ui work goes through `/soloscrum:design-ui` regardless of split.
2. Reclaim merged worktrees before creating a new one, so the worktree root does not accumulate across work units:

   ```bash
   skills/soloscrum-define-worktree/scripts/reclaim-worktrees.sh <worktree_root>
   ```

   Same pass `/soloscrum:cleanup` runs; safe and non-interactive per `soloscrum-define-worktree`. Report anything it `skipped` and continue — a worktree holding unsaved work never blocks new work.
3. Launch `soloscrum-dev` to:
   - Create the work unit's **worktree and branch** per `soloscrum-define-worktree` and `soloscrum-define-branch-commit`: fetch, resolve `worktree_root`, then `git worktree add -b {type}/{issue-id}-{slug} <worktree_root>/<branch> origin/<default>` (reusing an existing worktree for the same branch rather than creating a second). Implementation, commits, and PR creation all run with that worktree as the working directory; the main checkout is never switched onto the branch.
   - Ensure the worktree root is ignored — if `.gitignore` does not cover it, add the entry inside the worktree so it lands in this unit's PR (never a direct commit to the default branch)
   - Implement code referencing `.claude/rules/stack.md`
   - Verify DoD with `soloscrum-define-dod` and `.claude/rules/dod-extra.md`
   - Generate PR body (closing keyword: `Closes #<subtask>` for a Subtask target, `Closes #<issue>` for a no-Subtask Issue target — per `soloscrum-define-branch-commit`'s parent-close contract, never `Closes #<parent>` for a Subtask PR; plus change summary and test instructions)
   - Create PR **as draft** (`gh pr create --draft`) per `soloscrum-define-pr-lifecycle`
   - Confirm CI started cleanly via `soloscrum-tracker-github-wait-for-pr-checks` with a short `timeout_sec` (e.g. `300`):
     ```bash
     skills/soloscrum-tracker-github-wait-for-pr-checks/scripts/wait-for-pr-checks.sh <pr-number> 15 300
     ```
     This is a confirmation step, not a green-gate — the `/soloscrum:develop` handoff does not block on `SUCCESS`. The intent is to surface CI startup failures (workflow file syntax errors, missing secrets) here rather than at `/soloscrum:review`. If the script returns non-zero (timeout), surface the in-flight names and proceed; if it returns zero with non-`SUCCESS` conclusions, surface the conclusions and proceed. Inline `until ... gh pr view ... sleep ...` loops are an anti-pattern (per CLAUDE.md).

     That path is repo-root-relative, so run it with the **main checkout** as the working directory, not the worktree — see `soloscrum-define-worktree`, "Paths that stay anchored to the main checkout".
   - Resolve the active tracker profile and invoke `soloscrum-tracker-{github|linear}-transition-state` to move the **target** (Subtask or no-Subtask Issue) to `in-review` (owned by `soloscrum-implement-task` step 10; reversible per `soloscrum-define-pr-lifecycle`)
4. Present draft PR URL to user and recommend `/soloscrum:review <pr-url>` as the next step. Promotion to ready is owned by `soloscrum-review`, not by this command.

## Input

- Subtask URL or ID, **or** no-Subtask Issue URL or ID (GH issue number `#N` or Linear ID `PRJ-N` depending on active profile). Both share the same numeric address space on GH; the case is determined by whether the referenced Issue is a Subtask of a parent or stands alone with no Sub-issues (per `soloscrum-define-branch-commit`).
- (If omitted) auto-select an `in-progress` Subtask or no-Subtask Issue via `soloscrum-tracker-{profile}-query-state`. **Tie-break on multiple candidates**: if more than one `in-progress` candidate exists, do **not** auto-pick — surface the candidate list and ask the user to specify (silent auto-pick on ambiguity would produce inconsistent cross-session behaviour).

## Output

- Created PR URL
- Worktree path the work landed in
- Implementation summary
- DoD checklist result

## Resources

- Subagent: `soloscrum-dev`
- Skills: `soloscrum-implement-task`, `soloscrum-define-worktree`, `soloscrum-define-branch-commit`, `soloscrum-define-dod`, `soloscrum-define-pr-lifecycle`, `soloscrum-define-tracker-profile`, `soloscrum-tracker-github-wait-for-pr-checks` (when confirming CI started before handoff)
- Rules: `.claude/rules/stack.md`, `.claude/rules/branch.md`, `.claude/rules/dod-extra.md`, `.claude/rules/pr.md` (optional draft-window override)

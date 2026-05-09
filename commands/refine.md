---
name: refine
description: Structures an idea into a GitHub Issue. Runs a backlog janitor first (closes stale Issues whose closing PR has merged), then checks size, suggests splitting when too large, determines priority and SP, and creates the Issue after confirmation.
argument-hint: <idea or feature description> [--no-janitor]
disable-model-invocation: true
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash(gh issue view:*)
  - Bash(gh issue list:*)
  - Bash(gh issue create:*)
  - Bash(gh issue edit:*)
  - Bash(gh issue close:*)
  - Bash(gh pr view:*)
  - Bash(gh pr list:*)
  - Bash(gh api:*)
  - Bash(gh label:*)
---

# /refine

Structure an idea into a GitHub Issue, after sweeping stale-open Issues whose closing PR has already merged.

## Behavior

1. **Backlog janitor** — close open Issues whose closing PR has already merged. This catches parent Issues that GitHub did not auto-close (GH's `Closes #` only auto-closes the directly-referenced Issue, not the parent of a sub-issue tree) and recovers from any other case where merge-time auto-close did not fire. Skipped when `--no-janitor` appears in `$ARGUMENTS`.
   - Resolve active tracker profile via `soloscrum-define-tracker-profile`.
   - **`github-only`**: scan open Issues; for each, find PRs that reference it via any GitHub closing keyword (`close` / `closes` / `closed` / `fix` / `fixes` / `fixed` / `resolve` / `resolves` / `resolved`) in the PR body or merging commit; if any such PR is **MERGED**, close the Issue with reason `completed`. Use `gh issue view <n> --json closedByPullRequestsReferences` (or equivalent timeline query) for the linked-PR set.
   - **`linear+github`**: skip — Linear's native sync auto-manages parent close (per `soloscrum-tracker-linear-transition-state`), so a janitor sweep on the GH side would dual-update.
   - Surface the result at the start of `/refine` output: `Closed N stale Issue(s): #X, #Y` (or `No stale Issues found`).
   - **Janitor failures MUST NOT block `/refine`**. If the scan errors (network, permission), log a one-line notice and proceed to the structuring step. The user can re-run with `--no-janitor` to bypass entirely on a flaky environment.
2. Receive idea or request from user (`$ARGUMENTS`)
3. Launch `soloscrum-po` to:
   - Structure the idea into GitHub Issue format
   - Check size against `soloscrum-define-issue-size` criteria
   - Suggest splitting if size exceeds threshold
   - Determine priority using `soloscrum-define-priority` criteria
   - Calculate Issue-level SP using `soloscrum-define-story-points` criteria (size-check only — not registered)
4. Present structured result to user for confirmation
5. Create the GitHub Issue (with priority label `priority:*` applied at creation)
6. In `linear+github` profile, Linear's native sync replicates the Issue automatically — no extra MCP call needed

## Why the janitor lives in `/refine`

`/refine` is the natural moment to clean the backlog: it's the entry point where the user touches the Issue list, and any new Issue is created against the current open set. Sweeping closed-but-still-open Issues here keeps the backlog accurate before the user picks the next thing to work on.

The janitor exists because Issue close happens at merge time (per `soloscrum-define-pr-lifecycle`, "Issue close happens at merge"), but GitHub's auto-close only fires on the directly-referenced Issue. Parent Issues in a sub-issue tree are not auto-closed when their last sub-issue's PR merges, so they need a separate sweep — which is what this step provides.

## Input

- Idea or request text (free form)
- Optional flag: `--no-janitor` (skip the backlog janitor step)

## Output

- Janitor summary (first line): `Closed N stale Issue(s): #X, #Y` or `No stale Issues found` (or `Janitor skipped` when `--no-janitor` was set)
- Created GitHub Issue URL
- Configured priority label
- Issue-level SP (size-check value only; for routing decisions like splitting)

## Resources

- Subagent: `soloscrum-po`
- Skills: `soloscrum-create-issue`, `soloscrum-define-issue-format`, `soloscrum-define-issue-size`, `soloscrum-define-priority`, `soloscrum-define-tracker-profile`, `soloscrum-define-pr-lifecycle` (for the "Issue close happens at merge" contract that motivates the janitor)

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

1. **Backlog janitor** — close open Issues that should be closed but aren't. Two detection paths run together: (a) **parent Issues whose Sub-issue tree is fully closed** (per `soloscrum-define-branch-commit`'s parent-close contract, per-Subtask PRs do not reference the parent via `Closes #`, so the parent has no closing PR of its own — the janitor is the only close path for parents), and (b) **standalone Issues** (no Sub-issues) whose direct closing PR merged without GH's auto-close firing (the original safety-net case). Skipped when `--no-janitor` appears in `$ARGUMENTS`.
   - Resolve active tracker profile via `soloscrum-define-tracker-profile`.
   - **`github-only`**: scan open Issues; for each:
     - **If the Issue has linked Sub-issues** (via the GH sub-issue feature), check whether **all** linked Sub-issues are in `state: closed`. If so, close the parent with reason `completed`. Use `gh issue view <n> --json subIssues` (or equivalent GraphQL query on `subIssues`); close eligibility is the conjunction `every(sub-issue → state == "closed")`. The PR-keyword detection below does **not** apply to parent Issues — the contract guarantees their `closedByPullRequestsReferences` is empty.
     - **Otherwise** (standalone Issue with no Sub-issues), find PRs that reference it via any GitHub closing keyword (`close` / `closes` / `closed` / `fix` / `fixes` / `fixed` / `resolve` / `resolves` / `resolved`) in the PR body or merging commit; if any such PR is **MERGED**, close the Issue with reason `completed`. Use `gh issue view <n> --json closedByPullRequestsReferences` (or equivalent timeline query) for the linked-PR set.
   - **`linear+github`**: skip — Linear's native sync auto-manages parent close (per `soloscrum-tracker-linear-transition-state`), so a janitor sweep on the GH side would dual-update.
   - Surface the result at the start of `/refine` output: `Closed N stale Issue(s): #X, #Y` (or `No stale Issues found`).
   - **Always use `gh issue close --reason completed`.** Janitor never closes with `--reason not-planned` — that is a deliberate human decision. Janitor never reopens already-closed Issues.
   - **Janitor failures MUST NOT block `/refine`**. If the scan errors (network, permission), log a one-line notice and proceed to the structuring step. The user can re-run with `--no-janitor` to bypass entirely on a flaky environment.
2. Receive idea or request from user (`$ARGUMENTS`)
3. Launch `soloscrum-po` to:
   - Structure the idea into GitHub Issue format
   - Check size against `soloscrum-define-issue-size` criteria. SP > 5 and `/breakdown` would produce > 5 Subtasks both read as **mis-scope smells** (likely multiple intents bundled), not hard work-volume limits.
   - When a size signal indicates likely intent bundling, propose Issue split via `suggest_split` along the feature / phase axes per `soloscrum-define-issue-size`. This is Issue split (multiple intents → multiple Issues), distinct from `/breakdown`'s delivery slicing (one coherent intent → multiple Subtask PRs).
   - Determine priority using `soloscrum-define-priority` criteria
   - Calculate Issue-level SP using `soloscrum-define-story-points` criteria (size-check only — not registered)
4. Present structured result to user for confirmation
5. Create the GitHub Issue (with priority label `priority:*` applied at creation)
6. In `linear+github` profile, Linear's native sync replicates the Issue automatically — no extra MCP call needed

## Why the janitor lives in `/refine`

`/refine` is the natural moment to clean the backlog: it's the entry point where the user touches the Issue list, and any new Issue is created against the current open set. Sweeping closed-but-still-open Issues here keeps the backlog accurate before the user picks the next thing to work on.

The janitor exists because Issue close happens at merge time (per `soloscrum-define-pr-lifecycle`, "Issue close happens at merge"), but GitHub's auto-close only fires on the directly-referenced Issue. Two cases need the janitor: (1) **parent Issues** in a sub-issue tree — `soloscrum-define-branch-commit`'s parent-close contract deliberately forbids per-Subtask PRs from including `Closes #<parent>` (to avoid premature close on the first Subtask merge), so the parent has no closing PR of its own; the janitor's parent-detection path catches parents whose Sub-issue tree is fully closed. (2) **standalone Issues** whose direct PR merged without GH's auto-close firing — the janitor's standalone-detection path is the safety net.

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

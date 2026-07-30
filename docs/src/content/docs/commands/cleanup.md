---
title: "/soloscrum:cleanup"
description: Reclaims the git worktrees whose branch has already merged, and reports the ones it kept. Merged state is decided mechanically from PR state, with branch ancestry as a fallback.
sidebar:
  order: 5
---

`/soloscrum:cleanup` removes the git worktrees [`/soloscrum:develop`](/commands/develop/) created, once the work in them has merged. It is the other half of the per-work-unit worktree model: `/soloscrum:develop` creates one worktree per branch so your main checkout is never switched onto a feature branch, and `/soloscrum:cleanup` reclaims them when they stop being useful.

## Usage

```bash
/soloscrum:cleanup
/soloscrum:cleanup --dry-run
```

`--dry-run` reports what would be reclaimed and removes nothing.

## What "merged" means here

The decision is mechanical, never a judgement call, and runs two tests in order:

1. **PR state.** `gh pr list --head <branch> --state merged` returns a merged PR for the branch.
2. **Branch ancestry.** The branch is an ancestor of `origin/<default>`.

The PR test leads because it is the one that survives a **squash merge**. Squashing rewrites the commits, so after it the branch tip is not an ancestor of the default branch — an ancestry-only check would report work that actually shipped as unmerged and never reclaim it. The ancestry test still earns its place: it covers branches merged without a PR, and repositories where `gh` is unavailable.

## What it will not touch

A worktree is **reported, not removed**, when:

- it has uncommitted changes (including untracked files),
- it is on a detached HEAD, so there is no branch to test, or
- a merged PR exists but the local branch tip is not the commit that PR merged — meaning commits were made locally after the push and never reached the remote.

Each of these is surfaced with its reason rather than summarised away: they are the cases where only you can decide what should happen to the work.

Removal itself uses `git worktree remove` and `git branch -d` — the forms that *refuse* a dirty worktree and an unmerged branch. That refusal is a second, independent guard behind the checks above. The forcing variants (`--force`, `-D`) defeat it and are never used.

## Autonomy

Reclamation runs without asking. A worktree that passes both the merged test and the safety conditions holds nothing that is not already on the default branch or inside a merged PR, so removing it destroys no work — and the branch can be checked out again from the remote at any time.

## When it runs

| Trigger | Behaviour |
|---|---|
| You invoke it | Full reclaim pass. |
| Start of `/soloscrum:develop` | Same pass, so the worktree root does not accumulate across work units. |
| After a `/soloscrum:review` Pass | Only **surfaced** alongside the merge command, not run. At verdict time the PR has not merged, so the just-finished worktree is correctly still in flight. |

## Output

Per worktree: its branch, path, action (`removed` / `kept` / `skipped`, or `would-remove` under `--dry-run`), and the reason. Plus a one-line summary of how many were reclaimed, how many are still in flight, and how many need your attention.

An empty worktree root reports "nothing to reclaim" — not an error.

## See also

- [`/soloscrum:develop`](/commands/develop/) — creates the worktrees this command reclaims.
- Canonical contracts: [`commands/cleanup.md`](https://github.com/mew-ton/soloscrum/blob/main/commands/cleanup.md) and [`skills/soloscrum-define-worktree`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-worktree/SKILL.md).

---
name: cleanup
description: Reclaims the git worktrees under soloscrum's worktree root whose branch has already merged, and reports the ones it kept. Merged state is decided mechanically from PR state (squash-merge safe) with branch ancestry as a fallback. Never removes a worktree holding uncommitted or unpushed work.
argument-hint: "[--dry-run]"
disable-model-invocation: true
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash(git fetch:*)
  - Bash(git rev-parse:*)
  - Bash(git worktree:*)
  - Bash(git branch:*)
  - Bash(gh pr list:*)
  - Bash(gh repo view:*)
  - Bash(skills/soloscrum-define-worktree/scripts/reclaim-worktrees.sh:*)
---

# /soloscrum:cleanup

Reclaim the worktrees `/soloscrum:develop` left behind once their work has merged.

## Behavior

1. Resolve `worktree_root` per `soloscrum-define-worktree`'s resolution order (`.claude/rules/branch.md` frontmatter → plugin `userConfig` → `.soloscrum/worktrees`).
2. `git fetch origin` — the ancestry half of the merged test compares against `origin/<default>`, which is stale without this.
3. Run the reclaim pass:

   ```bash
   skills/soloscrum-define-worktree/scripts/reclaim-worktrees.sh <worktree_root>
   ```

   Add `--dry-run` when `$ARGUMENTS` contains it: the script then reports `would-remove` instead of removing anything. Invoke from the repository root using the full path — the same allowlist-stability rule as `soloscrum-tracker-github-wait-for-pr-checks` (see that skill's Notes).

4. Present the result grouped by `action`, and say plainly what was kept and why. A `skipped` entry means the worktree holds something that would be lost; surface its `reason` rather than summarising it away, because the user is the only one who can decide what to do with it.

## Autonomy

Removal runs **without pre-confirm**. A worktree that passes the merged test and the safety conditions in `soloscrum-define-worktree` holds nothing that is not already on the default branch or in a merged PR, so reclaiming it destroys no work.

The recovery path is those two places, not the remote branch — `gh pr merge --delete-branch` deletes the remote ref, and after a squash merge the original branch tip is not an ancestor of the default branch either. Do not justify the autonomy by "the branch can be re-fetched"; justify it by "the content already merged".

That autonomy depends entirely on the safety conditions holding. `git worktree remove --force` and `git branch -D` bypass them and are **never** used, by this command or any agent acting for it; both are denied in this repository's permission settings. When plain `git worktree remove` or `git branch -d` refuses, that refusal is the answer — report it, do not escalate to the forcing variant.

## When it runs

- **Standalone** — the user invokes it directly, typically after merging a PR.
- **At the start of `/soloscrum:develop`** — reclaims merged worktrees before creating a new one, so the root does not accumulate. Non-interactive and safe by the same reasoning as above.
- **After a `/soloscrum:review` Pass** — `/soloscrum:review` *surfaces* the command alongside the merge command but does **not** run it. At verdict time the PR has not merged yet, so nothing is reclaimable; running it then would report the just-finished worktree as `kept` and read as a failure.

## Input

- Optional flag: `--dry-run` (report what would be reclaimed; remove nothing)
- No positional args

## Output

- Per worktree: branch, path, action (`removed` / `kept` / `skipped`, or `would-remove` under `--dry-run`), and reason
- A one-line summary: how many were reclaimed, how many are still in flight, how many need the user's attention

On a root with no worktrees the result is an empty set — reported as "nothing to reclaim", not as an error.

## Resources

- Skills: `soloscrum-define-worktree` (layout, `worktree_root` resolution, merged test, safety conditions), `soloscrum-define-branch-commit` (branch naming — the worktree directory is the branch name)
- Script: `skills/soloscrum-define-worktree/scripts/reclaim-worktrees.sh`
- Rules: `.claude/rules/branch.md` (optional `worktree_root` override)

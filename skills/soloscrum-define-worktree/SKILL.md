---
name: soloscrum-define-worktree
description: "Reference: where /soloscrum:develop does its work. Each work unit gets its own git worktree under a repo-internal root (default .soloscrum/worktrees), so the main checkout is never switched onto a feature branch. Defines the layout, the worktree_root resolution order, the create/reuse rules, and the merged-branch test /soloscrum:cleanup uses to reclaim them."
user-invocable: false
allowed-tools:
  - Bash(git worktree:*)
  - Bash(git rev-parse:*)
  - Bash(git fetch:*)
  - Bash(git branch:*)
---

# soloscrum-define-worktree

Where implementation happens, and what reclaims it afterwards.

## Concept

`/soloscrum:develop` works on **one** work unit at a time, but a repository accumulates many in flight. If each `/soloscrum:develop` switched the main checkout onto its branch, that checkout would become shared mutable state: an interrupted run leaves it parked on a feature branch, two work units cannot progress independently, and the user's own working tree is collateral to an agent's step.

soloscrum instead gives every work unit its **own git worktree**, created inside the repository directory. The main checkout stays on the default branch and stays clean. "Inside the repository" is deliberate — the worktrees are part of the repo's own footprint, not sibling directories the user has to know about or clean up by hand.

The cost of a per-unit worktree is that worktrees outlive the work. That is what `/soloscrum:cleanup` exists for, and why the reclaim test is mechanical rather than a judgement call.

## Layout

```text
<repo-root>/
  <worktree_root>/
    feat/123-user-password-reset/     ← worktree for branch feat/123-user-password-reset
    fix/456-auth-token-expiry/        ← worktree for branch fix/456-auth-token-expiry
```

The directory under `<worktree_root>` is the branch name verbatim. Branch names contain `/` (per `soloscrum-define-branch-commit`'s `{type}/{issue-id}-{slug}`), so the path nests one level deeper than the branch's type segment. `git worktree add` creates intermediate directories itself; no flattening or slug-mangling is needed, and the verbatim name is what makes the reverse lookup (path → branch) unambiguous.

## `worktree_root` resolution

Resolve in this order and stop at the first match — the same shape as `soloscrum-define-tracker-profile`'s Profile Resolution:

1. **Repo override** — `.claude/rules/branch.md` frontmatter `worktree_root: <path>`, if present
2. **User config** — `${user_config.worktree_root}` (set via plugin install prompt)
3. **Built-in default** — `.soloscrum/worktrees`

The value is always interpreted **relative to the repository root**, never to the current working directory. An absolute path or a path escaping the repository (`../`) is a configuration error: reject it and surface the reason rather than creating a worktree outside the repo, which is the arrangement this skill exists to avoid.

### Repo override file format

```markdown
---
worktree_root: .soloscrum/worktrees
---
```

`.claude/rules/branch.md` is the same file that already carries repository-specific branch strategy. A repository that overrides neither key does not need the file at all.

## Ignoring the worktree root

The worktree root must be ignored, or every worktree shows up as untracked content in the main checkout.

`/soloscrum:develop` ensures the entry exists. When `.gitignore` does not already cover the resolved root, it appends the top-level segment (`.soloscrum/` for the default) **inside the work unit's worktree, on its branch**, so the addition lands in that unit's PR. Never commit it directly to the default branch — `soloscrum-define-branch-commit` forbids that, and the ignore entry is not special.

Until that PR merges, the main checkout's `.gitignore` does not yet carry the entry, so `git status` there reports the worktree root as untracked. That is expected and harmless: the worktrees contain no content the repository needs to track, and the state resolves on the first merge.

## Creating the worktree

1. `git fetch origin` — the branch must be cut from current upstream state, not from whatever the main checkout last pulled.
2. Resolve the default branch: `git rev-parse --abbrev-ref origin/HEAD` (e.g. `origin/main`).
3. Resolve `worktree_root`, compute `<repo-root>/<worktree_root>/<branch>`.
4. Create or reuse:
   - **A worktree for this branch already exists** (`git worktree list --porcelain` reports it) → **reuse it**. Do not create a second one; git refuses to check the same branch out twice anyway. A reused worktree may hold work from an interrupted run — inspect it before continuing rather than assuming a clean slate.
   - **The branch exists but has no worktree** → `git worktree add <path> <branch>`
   - **Neither exists** → `git worktree add -b <branch> <path> origin/<default>`
5. Everything downstream — reading files, editing, `git add` / `git commit`, `gh pr create` — runs with the worktree as the working directory.

### Paths that stay anchored to the main checkout

A repo-root-relative script path resolves differently once the working directory is a worktree. Any invocation documented as repo-root-relative must therefore be either run before switching into the worktree, or given a root that does not depend on the current directory. `${CLAUDE_PLUGIN_ROOT:-.}`-prefixed paths are already cwd-independent when the plugin root is set; a bare relative path is not.

`git` itself is unaffected: every `git` command run inside a worktree operates on the same repository, because the worktree's `.git` file points back to the shared common directory.

## Reclaiming worktrees

A worktree is reclaimable when its branch is **merged** and it holds **nothing unsaved**. Both halves are mechanical; neither is a judgement call.

### Merged test

1. **Primary — PR state.** `gh pr list --head <branch> --state merged` returns a non-empty set → merged.
2. **Secondary — ancestry.** `git merge-base --is-ancestor <branch> origin/<default>` succeeds → merged.

The PR check leads because it is the one that survives a squash merge. Squashing rewrites the commits, so the branch tip is not an ancestor of the default branch afterwards and the ancestry test alone reports "not merged" for work that shipped. The ancestry test still earns its place: it covers branches merged without a PR, and repositories where `gh` is unavailable.

### Safety conditions

A worktree is **reported, not removed**, when any of these holds:

- `git status --porcelain` in the worktree is non-empty (uncommitted changes, including untracked files)
- the worktree is detached (no branch to test)
- a merged PR exists for the branch, but the branch's local tip is **not** the commit that PR merged (`headRefOid`) — commits were made locally after the push and never reached the remote

Each merged test carries its own "nothing is unsaved" evidence, which is why there is no separate upstream check:

- **PR path** — the PR's `headRefOid` is the commit GitHub merged. A local tip equal to it means every local commit reached the remote; a different tip is the skip case above.
- **Ancestry path** — every commit on the branch is already in the default branch, or the branch would not be an ancestor of it.

An upstream-based check (`@{upstream}`, `rev-list --count`) cannot be used here. The normal merge path is `gh pr merge --delete-branch`, which removes the remote branch, so by the time a worktree is reclaimable its upstream ref is gone — an upstream check would block exactly the case `/soloscrum:cleanup` exists to handle, and would report it as "nothing was ever pushed".

### Removal

`git worktree remove <path>` → `git branch -d <branch>` → `git worktree prune`.

Both commands are used in their **refusing** form on purpose. Plain `remove` refuses a dirty worktree; `-d` refuses an unmerged branch. They are a second, independent guard behind the safety conditions above — if the checks and the removal ever disagree, git wins and the work survives. `git worktree remove --force` and `git branch -D` defeat exactly that guard and are denied in this repository's permission settings.

`git worktree prune` clears administrative entries for worktrees whose directory disappeared some other way (the user deleted it by hand). It never touches an existing directory.

## Companion script

`scripts/reclaim-worktrees.sh`, colocated with this skill, implements the reclaim pass: enumerate, apply the merged test and the safety conditions, remove what qualifies, and report the rest as JSON.

It exists as a script for the same reason `wait-for-pr-checks.sh` does — a stable command string the harness allowlist can match once, instead of a per-branch `git worktree` invocation that re-prompts every time and re-derives the same `--porcelain` parsing in each session.

`/soloscrum:cleanup` is its user-facing entry point.

## Depends On

- `soloscrum-define-branch-commit` (branch naming — the worktree directory is the branch name)
- `soloscrum-define-tracker-profile` (the resolution-order shape `worktree_root` mirrors)

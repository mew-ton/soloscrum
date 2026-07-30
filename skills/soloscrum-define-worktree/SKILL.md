---
name: soloscrum-define-worktree
description: "Reference: where /soloscrum:develop does its work. Each work unit gets its own git worktree under a repo-internal root (default .soloscrum/worktrees), so the main checkout is never switched onto a feature branch. Defines the layout, the worktree_root resolution order, the create/reuse rules, and the merged-branch test /soloscrum:cleanup uses to reclaim them."
user-invocable: false
allowed-tools:
  - Bash(skills/soloscrum-define-worktree/scripts/reclaim-worktrees.sh:*)
  - Bash(git worktree add:*)
  - Bash(git worktree list:*)
  - Bash(git rev-parse:*)
  - Bash(git fetch:*)
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

**Resolve it from the main checkout.** `.claude/rules/branch.md` is a tracked file, so reading it from inside a worktree yields *that branch's* copy — which may predate the current setting, or belong to a work unit that changed it. Establish the main checkout as the working directory first (see "Creating the worktree" step 1), then resolve.

The value is always interpreted **relative to the repository root**, never to the current working directory. An absolute path or a path escaping the repository (`../`) is a configuration error: reject it and surface the reason rather than creating a worktree outside the repo, which is the arrangement this skill exists to avoid.

### Repo override file format

```markdown
---
worktree_root: .soloscrum/worktrees
---
```

`.claude/rules/branch.md` is the same file that already carries repository-specific branch strategy. A repository that overrides neither key does not need the file at all.

## Ignoring the worktree root

The worktree root must be ignored, and it must be ignored **immediately** — not once a PR merges. A worktree directory contains a `.git` file, so an unignored worktree root is not merely untracked noise: `git add -A` from the enclosing checkout stages the worktree as a **gitlink** (`warning: adding embedded git repository`), and a commit carrying that broken submodule reference is far harder to undo than it was to create.

`/soloscrum:develop` therefore writes the ignore in two places:

1. **`.git/info/exclude`, at creation time.** Takes effect the instant the worktree exists, is not tracked, needs no commit, and is shared by every worktree of the repository because it lives in the common directory. This is what closes the window.
2. **`.gitignore`, if not already covered** — appended **inside the work unit's worktree, on its branch**, so it lands in that unit's PR. Never commit it directly to the default branch; `soloscrum-define-branch-commit` forbids that, and the ignore entry is not special. This is what makes the ignore durable and visible to collaborators and to fresh clones.

Both entries use the **resolved root anchored to the repository root**, with a leading and trailing slash — `/.soloscrum/worktrees/` for the default, `/build/worktrees/` for a `build/worktrees` override. Do not ignore the root's top-level segment: a `build/worktrees` override would then hide all of `build/` from `git status`, including files that have nothing to do with worktrees.

The `.git/info/exclude` entry is what makes step 2's delay safe. Without it, every worktree cut before the ignore-bearing PR merged would be exposed for its entire lifetime, not just during a first-run bootstrap.

### What ignoring does not cover

`.gitignore` and `.git/info/exclude` govern **git's** view. They do not govern tooling that walks the filesystem on its own — TypeScript `include` globs, ESLint without an explicit ignore entry, Jest's default `testPathIgnorePatterns`, bundler watchers, IDE indexers. Each worktree is a complete checkout, so a broad `**/*` glob run from the main checkout will find every source file a second time, once per worktree.

A repository whose tooling globs broadly should add the worktree root to those tools' own ignore configuration. Record it in `.claude/rules/stack.md` so it is applied consistently rather than rediscovered per work unit.

## Creating the worktree

1. **Resolve the main checkout root first, and build an absolute path from it:**

   ```bash
   main_root=$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")
   ```

   Never compute the worktree path relative to the current working directory. An agent's working directory persists across steps and sessions, so after one `/soloscrum:develop` it is already *inside* a worktree — and a relative `git worktree add .soloscrum/worktrees/<branch>` from there creates the new worktree **nested inside the previous one**. That nesting is not cosmetic: the inner worktree's `.git` file makes `git add -A` in the outer one stage it as a gitlink (`warning: adding embedded git repository`), and if that commit merges, the default branch permanently carries a broken submodule reference. `--git-common-dir` resolves to the shared directory from any worktree, so this form is correct wherever it runs.

2. `git fetch origin` — the branch must be cut from current upstream state, not from whatever the main checkout last pulled.
3. Resolve the default branch into `default_ref`, a **fully-qualified remote-tracking ref**:

   ```bash
   default_ref=$(git rev-parse --abbrev-ref origin/HEAD)   # already yields e.g. origin/main
   ```

   Note the value is *already* `origin/`-prefixed. Use `${default_ref}` verbatim everywhere below — prefixing it again produces `origin/origin/main`, which fails both worktree creation and the merged test. `origin/HEAD` is unset on some clones; fall back to `origin/$(gh repo view --json defaultBranchRef --jq .defaultBranchRef.name)`, then to `origin/main`.
4. Resolve `worktree_root` and compute `${main_root}/<worktree_root>/<branch>`.
5. Create or reuse:
   - **A worktree for this branch already exists** (`git worktree list --porcelain` reports it) → **reuse it**. Do not create a second one; git refuses to check the same branch out twice anyway. A reused worktree may hold work from an interrupted run — inspect it before continuing rather than assuming a clean slate.
   - **The branch exists but has no worktree** → `git worktree add <path> <branch>`
   - **Neither exists** → `git worktree add -b <branch> <path> "$default_ref"`
6. Everything downstream — reading files, editing, `git add` / `git commit`, `gh pr create` — runs with the worktree as the working directory.

### Paths that stay anchored to the main checkout

A repo-root-relative script path resolves differently once the working directory is a worktree. Any invocation documented as repo-root-relative must therefore be either run before switching into the worktree, or given a root that does not depend on the current directory. `${CLAUDE_PLUGIN_ROOT:-.}`-prefixed paths are already cwd-independent when the plugin root is set; a bare relative path is not.

`git` itself is unaffected: every `git` command run inside a worktree operates on the same repository, because the worktree's `.git` file points back to the shared common directory.

## Reclaiming worktrees

A worktree is reclaimable when its branch is **merged** and it holds **nothing unsaved**. Both halves are mechanical; neither is a judgement call.

### Merged test

1. **Primary — PR state.** `gh pr list --head <branch> --state merged` returns a non-empty set → merged.
2. **Secondary — ancestry.** `git merge-base --is-ancestor <branch> "$default_ref"` succeeds → merged.

The PR check leads because it is the one that survives a squash merge. Squashing rewrites the commits, so the branch tip is not an ancestor of the default branch afterwards and the ancestry test alone reports "not merged" for work that shipped. The ancestry test still earns its place: it covers branches merged without a PR, and repositories where `gh` is unavailable.

### Safety conditions

A worktree is **reported, not removed**, when any of these holds:

- `git status --porcelain` in the worktree is non-empty (uncommitted changes, including untracked files)
- the worktree is detached (no branch to test)
- a merged PR exists for the branch, but the branch's local tip is **not** the commit that PR merged (`headRefOid`) — commits were made locally after the push and never reached the remote
- the reclaim pass is itself running from inside that worktree, or from a directory under it
- the worktree's status cannot be read at all — unverifiable is treated as unsafe, not as clean

The running-from-inside condition is not a git-state check. `git worktree remove` succeeds regardless of what process has the directory open; git holds no lock. Removing the directory a caller is standing in leaves it on a path that no longer exists, and every subsequent relative command fails opaquely. Git cannot see that, so it is checked separately.

The same hazard exists for a *different* live process — a second terminal idling in a merged worktree, say. That one is not detectable from here, and is the reason `/soloscrum:cleanup` reports every removal rather than working silently.

Each merged test carries its own "nothing is unsaved" evidence, which is why there is no separate upstream check:

- **PR path** — the PR's `headRefOid` is the commit GitHub merged. A local tip equal to it means every local commit reached the remote; a different tip is the skip case above.
- **Ancestry path** — every commit on the branch is already in the default branch, or the branch would not be an ancestor of it.

An upstream-based check (`@{upstream}`, `rev-list --count`) cannot be used here. The normal merge path is `gh pr merge --delete-branch`, which removes the remote branch, so by the time a worktree is reclaimable its upstream ref is gone — an upstream check would block exactly the case `/soloscrum:cleanup` exists to handle, and would report it as "nothing was ever pushed".

### Removal

`git worktree remove <path>` → `git branch -d <branch>` → `git worktree prune`.

Both commands are used in their **refusing** form on purpose. Plain `remove` refuses a dirty worktree; `-d` refuses an unmerged branch. They are a second, independent guard behind the safety conditions above — if the checks and the removal ever disagree, git wins and the work survives. `git worktree remove --force` and `git branch -D` defeat exactly that guard and are denied in this repository's permission settings.

`git worktree prune` clears administrative entries for worktrees whose directory disappeared some other way (the user deleted it by hand). It never touches an existing directory.

## Known limitation: a fresh worktree has no installed dependencies

`git worktree add` checks out tracked files only. Anything gitignored — `node_modules/`, `.venv/`, build and test caches — does **not** exist in a new worktree, and nothing in soloscrum installs it.

For a repository whose lint and test steps depend on installed dependencies, that means the first commands `soloscrum-implement-task` runs in a new worktree ("confirm zero lint errors", "write tests") will fail until the project's install step has run there. This is not a duplication concern; it is an absence. Under the previous single-checkout model the install happened once and persisted, so the worktree model shifts a cost that used to be invisible.

Until provisioning is part of the flow, a repository in this position should record its install command in `.claude/rules/stack.md` so the implementation step runs it before lint and test rather than discovering the gap. Per-worktree dependency provisioning is tracked separately (#99); it is deliberately out of scope for this skill.

## Companion script

`scripts/reclaim-worktrees.sh`, colocated with this skill, implements the reclaim pass: enumerate, apply the merged test and the safety conditions, remove what qualifies, and report the rest as JSON.

It exists as a script for the same reason `wait-for-pr-checks.sh` does — a stable command string the harness allowlist can match once, instead of a per-branch `git worktree` invocation that re-prompts every time and re-derives the same `--porcelain` parsing in each session.

`/soloscrum:cleanup` is its user-facing entry point.

## Depends On

- `soloscrum-define-branch-commit` (branch naming — the worktree directory is the branch name)
- `soloscrum-define-tracker-profile` (the resolution-order shape `worktree_root` mirrors)

---
title: Tracker operations
description: Overview of the profile-namespaced operation skills (create-subtask, transition-state, set-sp, query-backlog, query-state, add-dependency, wait-for-pr-checks).
sidebar:
  order: 14
---

Tracker operations are the layer that lets soloscrum's commands stay profile-agnostic. Every read or write that touches the tracker is delegated to a skill named `soloscrum-tracker-{profile}-{operation}` — the profile is `github` or `linear`, and the operation comes from the small fixed vocabulary below. Resolving the active profile (per [`define-tracker-profile`](/reference/define-tracker-profile/)) is the same as picking a prefix.

## Why namespaced skills, not a dispatcher

The framework deliberately does **not** ship a generic dispatcher that resolves the profile at call time. Instead, the *name* of the operation skill encodes the dispatch: `soloscrum-tracker-github-create-subtask` and `soloscrum-tracker-linear-create-subtask` are two different skills with two different bodies. An agent that has resolved `github-only` invokes the `github-` skill directly; the `linear-` skill is simply not in scope.

This keeps each operation's contract narrow (it doesn't have to handle both backends in one body) and keeps the agent's allowed-tools list honest (the agent only declares the tools its active profile actually uses).

## The operations

| Operation | github-only skill | linear+github skill | When it fires |
|---|---|---|---|
| Create subtask | `soloscrum-tracker-github-create-subtask` | `soloscrum-tracker-linear-create-subtask` | `/breakdown` register stage, once per proposed subtask |
| Transition state | `soloscrum-tracker-github-transition-state` | `soloscrum-tracker-linear-transition-state` | `/develop` (`→ in-review`), `/design-ui` (`→ in-review`), `/review` (`→ done` on Pass, `→ in-progress` on Fail) |
| Set subtask SP | `soloscrum-tracker-github-set-sp` | `soloscrum-tracker-linear-set-sp` | At subtask creation time (typically inlined). Separate calls only for later edits. |
| Query backlog | `soloscrum-tracker-github-query-backlog` | `soloscrum-tracker-linear-query-backlog` | `/next` and `/status` when listing pending work, grouped by priority |
| Query current state | `soloscrum-tracker-github-query-state` | `soloscrum-tracker-linear-query-state` | `/status` when listing in-progress / in-review items, plus PR or Figma links |
| Add dependency | `soloscrum-tracker-github-add-dependency` | `soloscrum-tracker-linear-add-dependency` | `/breakdown` when subtasks have peer-blocking relationships |
| Wait for PR checks | `soloscrum-tracker-github-wait-for-pr-checks` | (same skill — profile-agnostic, PRs live on GitHub regardless) | `/develop` after `gh pr create --draft` (CI start confirmation), `/review` after Pass (CI green gate before `gh pr ready`) |

The operation set is intentionally small: one verb per concept, plus the PR-CI wait. Anything outside this list — closing an Issue, merging a PR — is either user-gated or handled by GitHub itself (e.g. auto-close on merge via `Closes #N`).

## Two notes about specific operations

### `wait-for-pr-checks` is profile-agnostic

There is no `soloscrum-tracker-linear-wait-for-pr-checks`. PRs live on GitHub in both profiles, and Linear does not manage PR CI. The same skill (and the same colocated shell script at `skills/soloscrum-tracker-github-wait-for-pr-checks/scripts/wait-for-pr-checks.sh`) is used by both profiles.

The skill exists because inline `until ... gh pr view ... sleep ...` loops are an anti-pattern: they embed the PR number in the command string, which defeats harness allowlist matching, and they reinvent the rollup-normalisation `jq` filter every session. The script is the canonical implementation.

### `transition-state` never closes the Issue

Both profiles' `transition-state` skills move state values around but **never** call `gh issue close`. Issue closure is downstream of `gh pr merge` (via the PR body's `Closes #N` keyword) or, for parent Issues GitHub did not auto-close, by the `/refine` janitor sweep. See [PR lifecycle](/concept/pr-lifecycle/) for the full reasoning.

## See also

- For why the framework is split into a profile-agnostic core and these profile-namespaced operations, see [Tracker profiles](/concept/tracker-profile/).
- Canonical operation skills live under [`skills/`](https://github.com/mew-ton/soloscrum/tree/main/skills) — search for `soloscrum-tracker-`.
- For the wait-for-checks script's invocation contract specifically, see [`skills/soloscrum-tracker-github-wait-for-pr-checks/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-tracker-github-wait-for-pr-checks/SKILL.md).

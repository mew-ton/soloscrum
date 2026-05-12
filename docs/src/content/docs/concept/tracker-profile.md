---
title: Tracker profiles
description: Where Issues, subtasks, SP, state, and dependencies are stored, and how each command picks the right tracker.
sidebar:
  order: 1
---

A **tracker profile** selects the issue tracker each command reads and writes. soloscrum resolves the profile at the start of every command and keeps the rest of the framework profile-agnostic.

A profile bundles these decisions:

- Where the parent Issue lives
- Where subtasks live
- What an issue ID looks like
- Where SP is recorded
- How the state machine maps onto the tracker's native states
- Which API the agent uses

Two profiles ship today.

## The two profiles

### `github-only` (default)

- Issues are GitHub Issues
- Subtasks are native GH Sub-issues
- SP lives in a GitHub Projects v2 Number field
- State is encoded as `state:in-progress` / `state:in-review` / `state:done` labels
- Dependencies are written as `Depends on: #N` lines in the Issue body (GitHub renders cross-links)

Use this profile when Linear is unavailable — public OSS, GitHub-only organisations, or any single-tool workflow.

### `linear+github`

- Parent Issue stays on GitHub (so commits, PRs, and `Closes #` keep working)
- Subtasks, SP, state, and dependency relations live on Linear, synced via Linear's native GitHub integration
- Subtask IDs look like `PRJ-42`, not `#123`
- Priority labels stay on GitHub (GitHub remains canonical for parent metadata)

Use this profile when the team already runs Linear.

## Resolution order

Every command and agent that touches the tracker resolves the profile in this order:

1. Repo-level override at `.claude/rules/tracker.md` (`profile:` frontmatter).
2. User-level config from the plugin install prompt (`tracker_profile` in `.claude/settings.json`).
3. Built-in default: `github-only`.

Resolution stops at the first match. The repo-level override lets a single repo pin to a profile without changing the user-level default for every other repo.

## Why the framework stays profile-agnostic

The lifecycle, state machine, DoD, and review pipeline never name "Linear" or "GitHub" directly. Anything that touches the tracker delegates to a profile-namespaced **operation skill**: `soloscrum-tracker-{github|linear}-{operation}`. The profile selects the prefix; from there, the agent invokes the matching `create-subtask`, `transition-state`, `set-sp`, `query-state`, `query-backlog`, or `add-dependency` skill.

A `/develop` flow runs identically on a GitHub-only OSS repo and on a Linear-using product team. The verbs are the same; only the storage backend differs.

## When to set `.claude/rules/tracker.md`

Use the override when the user-level default does not match this repo. Two common cases:

- A user with `linear+github` set globally clones a public OSS repo with no Linear workspace. Pin the repo to `github-only`.
- A user with `github-only` as the default joins a Linear-using project. Pin the repo to `linear+github` so subtasks land on the team's Linear board.

The override file is minimal:

```markdown
---
profile: github-only
---
```

That single frontmatter field is the whole contract.

## See also

- The full storage matrix and the operation skill table live in [`skills/soloscrum-define-tracker-profile/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-tracker-profile/SKILL.md).

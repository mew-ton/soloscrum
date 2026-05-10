---
title: Tracker profiles
description: How soloscrum decides where Issues, subtasks, SP, state, and dependencies are stored — and how each command picks the right tracker without baking the choice in.
sidebar:
  order: 1
---

soloscrum runs on top of an issue tracker. Different teams use different trackers, and a framework that hard-codes "everything lives on GitHub" or "everything lives in Linear" has to be forked the moment that assumption breaks. soloscrum sidesteps the fork by treating the tracker as a pluggable layer and resolving the active **tracker profile** at the start of every command.

A tracker profile is a small bundle of decisions: where the parent Issue lives, where subtasks live, what an issue ID looks like, where SP is recorded, how the state machine maps onto the tracker's native states, and which API the agent uses to read and write all of that. Two profiles ship today, and the rest of the framework is profile-agnostic on purpose.

## The two profiles

**`github-only`** is the conservative default. Issues are GitHub Issues, subtasks are native GH Sub-issues, SP lives in a GitHub Projects v2 Number field, state is encoded as `state:in-progress` / `state:in-review` / `state:done` labels, and dependencies are written as `Depends on: #N` lines in the Issue body so GitHub can render them as cross-links. It works in repos where Linear is unavailable — public OSS projects, organisations with a GitHub-only constraint, or anyone who simply does not want a second tool in the loop.

**`linear+github`** is the choice for teams that already run Linear. The parent Issue is still on GitHub (it stays canonical so commits, PRs, and `Closes #` keywords keep working), but subtasks, SP, state, and dependency relations all live on Linear and get there through Linear's native GitHub sync. Subtask IDs in this profile look like `PRJ-42`, not `#123`. Priority labels remain on GitHub because GitHub is canonical for the parent.

## How the profile gets resolved

Every command and agent that needs to touch the tracker goes through the same resolution order:

1. A repo-level override at `.claude/rules/tracker.md` — if the file exists with a `profile:` frontmatter, that wins.
2. A user-level config from the plugin install prompt (`tracker_profile` in `.claude/settings.json`).
3. The built-in default, `github-only`.

Resolution stops at the first match. Pinning a single repo to one profile while keeping the user-level default for everything else is the reason the override exists; without it, two repos that share a Claude install would have to share a tracker, which is rarely what anyone wants.

## Why the framework stays profile-agnostic

The lifecycle, the state machine, the DoD, and the review pipeline never mention "Linear" or "GitHub" by name. Instead, anything that needs to talk to the tracker delegates to a profile-namespaced **operation skill**: `soloscrum-tracker-{github|linear}-{operation}`. Resolving the profile is the same as picking a prefix; from then on, the agent invokes the matching `create-subtask`, `transition-state`, `set-sp`, `query-state`, `query-backlog`, or `add-dependency` skill, and the operation works the same way regardless of where the data is stored.

This is what lets a `/develop` flow look identical on a GitHub-only OSS repo and on a Linear-using product team: the verbs are the same, only the storage backend differs.

## When to set `.claude/rules/tracker.md`

Reach for the override when the user-level default is wrong for this repo specifically. The two common cases are:

- A user with `linear+github` set globally clones a public OSS repo that has no Linear workspace. Pin that repo to `github-only` so commands do not try to reach a Linear team that does not exist for them.
- A user with `github-only` as the default joins a Linear-using project. Pin that repo to `linear+github` so subtasks land on the team's Linear board instead of staying invisible on GitHub.

The override file is intentionally minimal:

```markdown
---
profile: github-only
---
```

That single frontmatter field is the whole contract.

## See also

- The full storage matrix and the operation skill table live in the canonical contract: see [`skills/soloscrum-define-tracker-profile/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-tracker-profile/SKILL.md).
- For a per-skill summary of every tracker operation, jump to the [tracker operations reference](/reference/tracker-operations/).
- For a concise spec view of profile resolution, see the [tracker profile reference](/reference/define-tracker-profile/).

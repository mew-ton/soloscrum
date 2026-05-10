---
title: define-tracker-profile
description: Spec summary — tracker profile resolution, concept-to-storage matrix, and how operation skills are profile-namespaced.
sidebar:
  order: 12
---

`soloscrum-define-tracker-profile` defines where each soloscrum concept is stored, how to access it, and how agents and commands route tracker operations to the correct skill — per **tracker profile**.

## What it does

It pins:

- The two profile values: `github-only` (default) and `linear+github`.
- The resolution order: repo override (`.claude/rules/tracker.md`) → user config (`tracker_profile` in `.claude/settings.json`) → built-in default (`github-only`).
- The concept-to-storage matrix (where Issues, subtasks, SP, state, dependencies, etc. live in each profile).
- The operation skill naming convention: `soloscrum-tracker-{github|linear}-{operation}`. There is no separate dispatcher — naming is the dispatch.

## When it is consumed

Every command and agent that needs to read or write tracker state. The first thing they do is resolve the profile; from then on they invoke the matching `soloscrum-tracker-<profile>-<op>` skill rather than calling `gh` or Linear MCP directly.

## Concept-to-storage matrix (excerpt)

| Concept | `github-only` | `linear+github` |
|---|---|---|
| Issue (parent) | GH Issue | GH Issue (canonical) |
| Subtask | GH Sub-issue (native) | Linear subtask (synced from parent) |
| Subtask ID | `#123` | `PRJ-42` |
| Subtask SP | GH Projects v2 `SP` Number field | Linear `estimate` field |
| Priority | GH `priority:*` label | GH `priority:*` label (canonical on GH) |
| State | GH `state:*` label | Linear native state |
| Dependency | `Depends on: #N` body line | Linear "Blocked by" relation |

The Issue (parent) is **always** GH Issue in both profiles.

## Repo override

The override file format is minimal:

```markdown
---
profile: github-only
---
```

Place at `.claude/rules/tracker.md` to pin a repo to a specific profile regardless of user-level default.

## Operations

Six operations exist per profile:

- `create-subtask`
- `transition-state`
- `set-sp`
- `query-backlog`
- `query-state`
- `add-dependency`

Plus a profile-agnostic `wait-for-pr-checks` (PRs live on GitHub regardless of profile).

For the per-operation summary, see [tracker operations](/reference/tracker-operations/).

## See also

- For the human walkthrough, read [Tracker profiles](/concept/tracker-profile/).
- Canonical contract: [`skills/soloscrum-define-tracker-profile/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-tracker-profile/SKILL.md).

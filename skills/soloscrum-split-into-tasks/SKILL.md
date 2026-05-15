---
name: soloscrum-split-into-tasks
description: Breaks a GitHub Issue into subtasks with type (develop or design-ui) and story point estimates. Registers each subtask via the tracker operation skill matching the active profile.
argument-hint: <issue-url or issue-number>
disable-model-invocation: true
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash(gh issue view:*)
  - Bash(gh issue list:*)
---

# soloscrum-split-into-tasks

Decompose an Issue into subtasks with type and SP, then register them via the active profile's tracker operation.

## Overview

Decomposes an Issue into implementable subtasks based on its AC and Goal. Assigns type (develop / design-ui) and SP to each subtask, then delegates registration to the tracker operation skill that matches the active profile (`soloscrum-define-tracker-profile`).

## Steps

1. Read target Issue Goal, Acceptance Criteria, and Out of Scope: $ARGUMENTS
2. **Decompose the Issue's delivery into reviewable work slices.** Each Subtask is one slice of the parent intent that can be shipped in one reviewable PR (per `soloscrum-define-issue-format`'s Subtask Body section). Subtasks do **not** carry their own AC — they slice the parent's delivery, and their done condition is "lands an artefact the parent's AC verifiably depends on, or strictly advances the parent's AC checklist count, without regressions."
   - **Slice along reviewability seams** — file cluster, layer (backend / frontend), or phase (core / error handling / performance) when each slice produces a deliverable that can be reviewed on its own correctness/no-regression terms. Not along intent boundaries — that's an Issue split (see `soloscrum-define-issue-size`), not a Subtask split.
   - **1 Subtask = 1 reviewable PR.** Organise so dependencies between Subtasks are minimal and explicit.
   - Assign type using `soloscrum-define-task-type`.
3. Calculate SP for each subtask (see `soloscrum-define-story-points`)
4. If subtask count exceeds `max_subtasks` (5) in `soloscrum-define-issue-size`, treat as a mis-scope smell — the Issue likely bundles multiple intents. Return to `/refine` rather than proceed.
5. After user approval, resolve the active profile via `soloscrum-define-tracker-profile`, then for each subtask invoke the matching operation skill:
   - `github-only` → `soloscrum-tracker-github-create-subtask`
   - `linear+github` → `soloscrum-tracker-linear-create-subtask`
6. If any subtask depends on another, also invoke the active profile's `add-dependency` operation skill

## Output Format

```
## Subtask Breakdown Proposal

| # | Title | Type | SP |
|---|-------|------|----|
| 1 | [Title] | develop | 2 |
| 2 | [Title] | design-ui | 1 |

Total SP: 3
```

## Depends On

- `soloscrum-define-issue-format` (Subtask body contract: no AC, work slice of parent intent)
- `soloscrum-define-task-type`
- `soloscrum-define-story-points`
- `soloscrum-define-issue-size` (when `/breakdown` is the right command, and the mis-scope-smell threshold)
- `soloscrum-define-tracker-profile` (routing)
- `soloscrum-tracker-{github|linear}-create-subtask` (delegated)
- `soloscrum-tracker-{github|linear}-add-dependency` (delegated, when needed)

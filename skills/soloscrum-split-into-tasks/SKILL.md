---
name: soloscrum-split-into-tasks
description: Breaks a GitHub Issue into subtasks with type (develop or design-ui) and story point estimates. Registers each subtask via the tracker operation skill matching the active profile.
argument-hint: <issue-url or issue-number>
disable-model-invocation: true
---

# soloscrum-split-into-tasks

Decompose an Issue into subtasks with type and SP, then register them via the active profile's tracker operation.

## Overview

Decomposes an Issue into implementable subtasks based on its AC and Goal. Assigns type (develop / design-ui) and SP to each subtask, then delegates registration to the tracker operation skill that matches the active profile (`soloscrum-define-tracker-profile`).

## Steps

1. Read target Issue AC, Goal, and Out of Scope: $ARGUMENTS
2. Decompose AC into implementation units:
   - 1 subtask = 1 clear deliverable
   - Organize dependencies between subtasks
   - Assign type using `soloscrum-define-task-type`
3. Calculate SP for each subtask (see `soloscrum-define-story-points`)
4. If subtask count exceeds `max_subtasks` in `soloscrum-define-issue-size`, confirm with user
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

- `soloscrum-define-task-type`
- `soloscrum-define-story-points`
- `soloscrum-define-issue-size`
- `soloscrum-define-tracker-profile` (routing)
- `soloscrum-tracker-{github|linear}-create-subtask` (delegated)
- `soloscrum-tracker-{github|linear}-add-dependency` (delegated, when needed)

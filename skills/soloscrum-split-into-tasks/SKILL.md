---
name: soloscrum-split-into-tasks
description: Breaks a GitHub Issue into Linear subtasks with type (develop or design-ui) and story point estimates. Registers subtasks via Linear MCP after user approval.
argument-hint: <issue-url or issue-number>
disable-model-invocation: true
---

# soloscrum-split-into-tasks

Decompose an Issue into subtasks with type and SP.

## Overview

Decomposes an Issue into implementable subtasks based on its AC and Goal. Assigns type (develop / design-ui) and SP to each subtask, then registers them in Linear.

## Steps

1. Read target Issue AC, Goal, and Out of Scope: $ARGUMENTS
2. Decompose AC into implementation units:
   - 1 subtask = 1 clear deliverable
   - Organize dependencies between subtasks
   - Assign type using `soloscrum-define-task-type`
3. Calculate SP for each subtask (see `soloscrum-define-story-points`)
4. If subtask count exceeds `max_subtasks` in `soloscrum-define-issue-size`, confirm with user
5. After user approval, register subtasks in Linear MCP:
   - parent: Linear Task of target Issue
   - title: subtask title
   - type label: develop or design-ui
   - estimate: SP

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

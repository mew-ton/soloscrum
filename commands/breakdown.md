---
name: breakdown
description: Breaks a GitHub Issue into Linear subtasks with type (develop or design-ui) and story points. Proposes the breakdown for confirmation before registering in Linear.
argument-hint: <issue-url or issue-number>
disable-model-invocation: true
---

# /breakdown

Break an Issue into Linear subtasks with type and story points.

## Behavior

1. Receive target Issue (`$ARGUMENTS`)
2. `design-agent` performs size and type design:
   - Plan subtask decomposition strategy
   - Assign type to each subtask (`soloscrum-define-task-type` criteria)
   - Verify decomposition validity with `soloscrum-validate-feature`
3. Present breakdown proposal to user for confirmation
4. Upon approval, `dev-agent` registers subtasks in Linear via MCP:
   - Calculate SP (`soloscrum-define-story-points` criteria)
   - Assign task type as label

## Input

- GitHub Issue URL or issue number

## Output

- Created Linear subtask list
  - Title
  - Type (develop / design-ui)
  - SP
  - Description

## Resources

- Subagents: `design-agent` (size and type design), `dev-agent` (subtask registration)
- Skills: `soloscrum-validate-feature`, `soloscrum-define-task-type`, `soloscrum-split-into-tasks`, `soloscrum-define-story-points`

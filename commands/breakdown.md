---
name: breakdown
description: Breaks a GitHub Issue into Subtasks with type (develop or design-ui) and story points. Proposes the breakdown for confirmation, then registers each Subtask via the active tracker profile's operation skill.
argument-hint: <issue-url or issue-number>
disable-model-invocation: true
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash(gh issue:*)
  - Bash(gh api:*)
  - Bash(gh label:*)
---

# /breakdown

Break an Issue into Subtasks with type and story points.

## Behavior

1. Receive target Issue (`$ARGUMENTS`)
2. `soloscrum-design` performs size and type design:
   - Plan subtask decomposition strategy
   - Assign type to each subtask (`soloscrum-define-task-type` criteria)
   - Verify decomposition validity with `soloscrum-validate-feature`
3. Present breakdown proposal to user for confirmation
4. Upon approval, `soloscrum-dev` registers Subtasks via the active tracker profile (`soloscrum-define-tracker-profile`):
   - Calculate Subtask SP (`soloscrum-define-story-points`)
   - Invoke `soloscrum-tracker-{github|linear}-create-subtask` for each Subtask
   - Invoke `soloscrum-tracker-{github|linear}-add-dependency` for any cross-subtask blocking relations

## Input

- GitHub Issue URL or issue number

## Output

- Created Subtask list
  - Title
  - Type (develop / design-ui)
  - SP
  - ID (GH `#N` or Linear `PRJ-N` depending on profile)
  - Dependencies (if any)

## Resources

- Subagents: `soloscrum-design` (size and type design), `soloscrum-dev` (subtask registration)
- Skills: `soloscrum-validate-feature`, `soloscrum-define-task-type`, `soloscrum-split-into-tasks`, `soloscrum-define-story-points`, `soloscrum-define-tracker-profile`

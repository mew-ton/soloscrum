---
name: next
description: Recommends the next action based on backlog and active-work state — continues in-progress work, suggests review, starts the next subtask, or prompts to refine a new idea.
disable-model-invocation: true
allowed-tools:
  - Read
  - Bash(gh issue list:*)
  - Bash(gh issue view:*)
  - Bash(gh pr list:*)
  - Bash(gh api:*)
  - Bash(gh project:*)
---

# /next

Recommend the next action.

## Behavior

1. Resolve the active tracker profile via `soloscrum-define-tracker-profile`
2. Fetch active work via `soloscrum-tracker-{github|linear}-query-state`
3. Fetch backlog via `soloscrum-tracker-{github|linear}-query-backlog`
4. Determine next action considering priority, SP, and dependencies
5. Present recommended action to user

## Decision Logic

`/develop` accepts either a Subtask or a no-Subtask Issue per `soloscrum-define-branch-commit`, so the rules below consider both classes when describing `/develop` targets:

1. In Progress Subtask **or no-Subtask Issue** exists → `Continue as-is`
2. In Review Subtask **or no-Subtask Issue** exists → Suggest `/review`
3. Untouched Subtask **or untouched no-Subtask Issue** in Backlog → Suggest `/develop` (Subtask / no-Subtask Issue) or `/design-ui` (Subtask) for the highest-priority candidate
4. All Subtasks done, undecomposed Issue exists → Suggest `/breakdown` (only when the Issue's intent needs delivery slicing per `soloscrum-define-issue-size`; otherwise treat as a no-Subtask Issue and route to rule 3)
5. Backlog empty → Suggest refining a new idea with `/refine`

## Input

None

## Output

```
## Next Action

Recommended: /develop [subtask-id]
Reason: Priority High, SP: 2, no dependencies

or

Recommended: /review PR #N
Reason: There is a Subtask In Review
```

## Resources

- Skills: `soloscrum-define-tracker-profile`, `soloscrum-tracker-{github|linear}-query-backlog`, `soloscrum-tracker-{github|linear}-query-state`

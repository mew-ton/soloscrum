---
name: next
description: Recommends the next action based on backlog and active-work state — continues in-progress work, suggests review, starts the next subtask, or prompts to refine a new idea.
disable-model-invocation: true
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

1. In Progress Subtask exists → `Continue as-is`
2. In Review Subtask exists → Suggest `/review`
3. Untouched Subtask in Backlog → Suggest `/develop` or `/design-ui` for the highest-priority Subtask
4. All Subtasks done, undecomposed Issue exists → Suggest `/breakdown`
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

---
name: next
description: Recommends the next action based on Linear backlog state — continues in-progress work, suggests review, starts next subtask, or prompts to refine a new idea.
disable-model-invocation: true
---

# /next

Recommend the next action.

## Behavior

1. Fetch backlog from Linear MCP
2. Determine next action considering priority, SP, and dependencies
3. Present recommended action to user

## Decision Logic

1. In Progress subtask exists → `Continue as-is`
2. In Review subtask exists → Suggest `/review`
3. Untouched subtask in Backlog → Suggest `/develop` or `/design-ui` for highest-priority subtask
4. All subtasks done, undecomposed Issue exists → Suggest `/breakdown`
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
Reason: There is a subtask In Review
```

## Resources

- Linear MCP (direct)

---
name: status
description: Shows current work state from Linear — In Progress, In Review, and recently completed subtasks with corresponding PR or Figma links.
argument-hint: [issue-number]
disable-model-invocation: true
---

# /status

Show current work status.

## Behavior

1. Fetch current state from Linear MCP:
   - In Progress subtasks
   - In Review subtasks
   - Recently completed subtasks
2. Check corresponding PR status on GitHub
3. Present status summary

## Input

None (optionally specify issue number to filter: `$ARGUMENTS`)

## Output

```
## Work Status

### In Progress
- [subtask] Title (SP: X) — type: develop/design-ui

### In Review
- [subtask] Title — PR #N / Figma URL

### Recently Completed
- [subtask] Title — Done
```

## Resources

- Linear MCP (direct)
- GitHub MCP (PR status check)

---
name: status
description: Shows current work state — In Progress, In Review, and recently completed Subtasks with corresponding PR or Figma links.
argument-hint: [issue-number]
disable-model-invocation: true
---

# /status

Show current work status.

## Behavior

1. Resolve the active tracker profile via `soloscrum-define-tracker-profile`
2. Fetch state via `soloscrum-tracker-{github|linear}-query-state`:
   - In Progress Subtasks
   - In Review Subtasks
   - Recently Completed Subtasks (most recent first, capped at ~5)
3. Resolve corresponding PR / Figma URL for each in-review Subtask
4. Present status summary

## Input

None (optionally specify issue number to filter the subtree: `$ARGUMENTS`)

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

- Skills: `soloscrum-define-tracker-profile`, `soloscrum-tracker-{github|linear}-query-state`

---
name: soloscrum-tracker-linear-set-sp
description: "Operation: set the SP value of a Linear subtask via the estimate field. Used when active tracker profile is linear+github."
user-invocable: false
allowed-tools:
  - mcp__claude_ai_Linear__save_issue
---

# soloscrum-tracker-linear-set-sp

Sets a Linear subtask's `estimate` field with the SP value. Active when `tracker_profile = linear+github`.

## Inputs

- `linear_id` — Linear subtask ID
- `sp` — story points integer (per `soloscrum-define-story-points`)

## Steps

1. Update the subtask:
   - Linear MCP — `save_issue` with `id = <linear_id>`, `estimate = <sp>`

## Output

- Confirmation of new estimate

## Notes

- Issue-level SP (size-check from `/refine`) is **not** stored in Linear; only Subtask SP is registered (per `soloscrum-define-story-points`)
- If the team's Linear Estimation setting is disabled, prompt the user to enable a numeric estimation scheme that matches `soloscrum-define-story-points` (1, 2, 3, 5)
- This operation is usually inlined at subtask creation; use it explicitly only when correcting an existing value

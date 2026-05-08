---
name: soloscrum-tracker-linear-transition-state
description: "Operation: transition the state of a Linear subtask via Linear MCP. Used when active tracker profile is linear+github."
user-invocable: false
allowed-tools:
  - mcp__claude_ai_Linear__list_issue_statuses
  - mcp__claude_ai_Linear__save_issue
---

# soloscrum-tracker-linear-transition-state

Transitions a Linear subtask between soloscrum lifecycle states. Active when `tracker_profile = linear+github`.

## Inputs

- `linear_id` — Linear subtask ID (e.g. `PRJ-42`)
- `to_state` — one of `in-progress` / `in-review` / `done`

## State → Linear mapping

| soloscrum state | Linear state |
|---|---|
| `in-progress` | In Progress |
| `in-review` | In Review |
| `done` | Done |

## Steps

1. Resolve the team's state ID for `to_state`:
   - Linear MCP — `list_issue_statuses` for the team
2. Update the subtask:
   - Linear MCP — `save_issue` with `id = <linear_id>`, `stateId = <resolved>`

## Output

- Confirmation of new state

## Notes

- Only `soloscrum-review` may transition to `done` (per `soloscrum-define-agent-responsibilities`)
- For the parent Linear Task, transitions are typically auto-managed by Linear when all subtasks are complete; do not move the parent manually unless the user requests it
- The corresponding GH Issue does **not** need a separate state update — Linear's native sync writes the parent state back to GH on close

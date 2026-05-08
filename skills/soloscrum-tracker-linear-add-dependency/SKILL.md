---
name: soloscrum-tracker-linear-add-dependency
description: "Operation: declare a blocking relation between Linear issues using Blocks/Blocked by. Used when active tracker profile is linear+github."
user-invocable: false
allowed-tools:
  - mcp__claude_ai_Linear__save_issue
---

# soloscrum-tracker-linear-add-dependency

Declares a blocking relation between two Linear issues. Active when `tracker_profile = linear+github`.

## Inputs

- `linear_id` — Linear issue that depends on others (the dependent)
- `depends_on` — list of Linear IDs it depends on

## Steps

1. For each `<dep>` in `depends_on`, create a relation:
   - Linear MCP — `save_issue` with `id = <linear_id>`, `relationsToAdd = [{ type: "blockedBy", relatedId: "<dep>" }]`

## Output

- Confirmation that all blocking relations are recorded

## Notes

- Linear's native UI surfaces "Blocked by" prominently — no extra body editing needed
- Parent–child decomposition uses `parentId` (handled by `soloscrum-tracker-linear-create-subtask`); this operation is for **peer blocking** only
- The reverse relation (`blocks`) is auto-created by Linear on the other side

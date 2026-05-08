---
name: soloscrum-tracker-linear-query-backlog
description: "Operation: list backlog Linear Tasks and subtasks ordered by priority. Used when active tracker profile is linear+github."
user-invocable: false
allowed-tools:
  - mcp__claude_ai_Linear__list_issues
  - mcp__claude_ai_Linear__list_issue_statuses
---

# soloscrum-tracker-linear-query-backlog

Returns the Linear backlog (items in Backlog or Todo states) ordered by priority. Active when `tracker_profile = linear+github`.

## Inputs

- (none) — defaults to the user's configured team

## Steps

1. Fetch backlog items:
   - Linear MCP — `list_issues` with `filter: { state: { type: { in: ["backlog", "unstarted"] } } }`, ordered by `priority` desc then `createdAt` asc
2. Group by priority bucket: Urgent / High / Medium / Low / No priority

## Output

- Grouped backlog list:
  ```
  Urgent:
    PRJ-123 (SP 3, develop) — Add password reset
  High:
    PRJ-124 (SP 5, design-ui) — Login screen
  ...
  ```

## Notes

- This operation skill is the basis for `/next` and `/status` when in linear+github profile
- "Backlog" excludes In Progress and In Review — those are surfaced by `query-state` instead
- If the user has multiple Linear teams, prompt for which team to query (or read from `.claude/rules/tracker.md`)

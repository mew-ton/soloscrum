---
name: soloscrum-tracker-linear-query-state
description: "Operation: list Linear subtasks currently In Progress or In Review with linked PR or Figma URLs. Used when active tracker profile is linear+github."
user-invocable: false
allowed-tools:
  - mcp__claude_ai_Linear__list_issues
  - mcp__claude_ai_Linear__get_attachment
  - Bash(gh pr list:*)
---

# soloscrum-tracker-linear-query-state

Returns active Linear subtasks — items in `In Progress` or `In Review`. Active when `tracker_profile = linear+github`.

## Inputs

- `parent_issue_number` (optional) — narrow to one parent GH Issue's Linear Task subtree

## Steps

1. Fetch in-progress items:
   - Linear MCP — `list_issues` with filter `state.name = "In Progress"`
2. Fetch in-review items:
   - Linear MCP — `list_issues` with filter `state.name = "In Review"`
3. For each subtask, resolve a PR / Figma URL from its `attachments` field. The primary source for PR links is Linear's native GitHub integration (already attached as `attachments`). If `attachments` is empty for a `develop`-type subtask (sync race or integration off), fall back to `gh pr list --search "<subtask-id>"` to locate the linked PR. For `design-ui` subtasks, attachments are the Figma URL.
4. (If `parent_issue_number` given) restrict to that parent's subtree by matching `parentId`

## Output

- Two grouped lists:
  ```
  In Progress:
    PRJ-200 (develop) — Implement password reset endpoint
  In Review:
    PRJ-201 (develop) — Add reset email template → PR #45
    PRJ-202 (design-ui) — Login screen → Figma URL
  ```

## Notes

- This is the basis for `/status` in linear+github profile
- PR links are typically already attached by Linear's GH integration; falling back to `gh pr list --search` is acceptable

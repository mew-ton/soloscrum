---
name: soloscrum-tracker-linear-create-subtask
description: "Operation: create a Linear subtask under the Linear Task synced from a GitHub Issue. Used when active tracker profile is linear+github."
user-invocable: false
allowed-tools:
  - mcp__claude_ai_Linear__list_issues
  - mcp__claude_ai_Linear__save_issue
  - mcp__claude_ai_Linear__list_issue_labels
---

# soloscrum-tracker-linear-create-subtask

Creates a Linear subtask under the Linear Task that was auto-synced from a parent GH Issue. Active when `tracker_profile = linear+github`.

## Inputs

- `parent_issue_number` — parent GH Issue number (used to look up the synced Linear Task)
- `title` — subtask title
- `body` — subtask body in the lightweight work-body format per `soloscrum-define-issue-format`'s Subtask Body section (Parent / What / Checklist / Notes — Subtasks do **not** carry AC; the parent Issue owns the AC and the Subtask slices its delivery)
- `type` — `develop` or `design-ui` (per `soloscrum-define-task-type`)
- `sp` — story points (per `soloscrum-define-story-points`)

## Steps

1. Resolve the parent Linear Task ID from the synced GH Issue:
   - Linear MCP — `list_issues` with filter on `attachments.url` matching the GH Issue URL
2. Create the subtask:
   - Linear MCP — `save_issue` with:
     - `parentId` = parent Linear Task ID
     - `title` = `<title>`
     - `description` = `<body>`
     - `labelIds` = label for `type:<type>`
     - `estimate` = `<sp>`

## Output

- Linear subtask ID (e.g. `PRJ-42`)
- URL

## Notes

- The parent **GH Issue** is canonical — never create a Linear Task without a corresponding synced GH Issue
- If the GH→Linear sync hasn't completed yet, retry with backoff or prompt the user to wait
- SP is set inline at creation time via `estimate` — separate `set-sp` call only needed for later updates

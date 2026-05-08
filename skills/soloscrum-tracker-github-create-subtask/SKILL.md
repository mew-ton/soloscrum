---
name: soloscrum-tracker-github-create-subtask
description: "Operation: create a subtask of a GitHub Issue using native GH Sub-issue. Used when active tracker profile is github-only."
user-invocable: false
allowed-tools:
  - Bash(gh issue:*)
  - Bash(gh api:*)
---

# soloscrum-tracker-github-create-subtask

Creates a subtask of a parent GitHub Issue using the native Sub-issue feature. Active when `tracker_profile = github-only`.

## Inputs

- `parent_issue_number` — GH Issue number of the parent (e.g. `123`)
- `title` — subtask title
- `body` — subtask body (AC, notes)
- `type` — `develop` or `design-ui` (per `soloscrum-define-task-type`)
- `sp` — story points (per `soloscrum-define-story-points`)

## Steps

1. Create a GH Issue for the subtask
   ```
   gh issue create \
     --title "<title>" \
     --body "<body>" \
     --label "type:<type>"
   ```
2. Link as Sub-issue under the parent via GraphQL
   ```
   gh api graphql -f query='
     mutation($parent: ID!, $child: ID!) {
       addSubIssue(input: { issueId: $parent, subIssueId: $child }) { issue { id } }
     }' -F parent=<parent_node_id> -F child=<child_node_id>
   ```
3. Set SP via `soloscrum-tracker-github-set-sp` for the new subtask
4. Return the new Sub-issue number

## Output

- Sub-issue number (e.g. `#456`)
- URL

## Notes

- Sub-issue numbers are regular GH issue numbers — the same `#` references and PR linking work
- If the parent has no Project assigned, prompt the user to attach the project first (SP step requires it)

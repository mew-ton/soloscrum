---
name: soloscrum-tracker-github-set-sp
description: "Operation: set the SP value of a Subtask on a GitHub Projects v2 Number field. Used when active tracker profile is github-only."
user-invocable: false
allowed-tools:
  - Bash(gh project:*)
  - Bash(gh api:*)
---

# soloscrum-tracker-github-set-sp

Records a Subtask's SP value in a GitHub Projects v2 custom field named `SP` (Number type). Active when `tracker_profile = github-only`.

## Inputs

- `issue_number` — Sub-issue number
- `sp` — story points integer (per `soloscrum-define-story-points`)
- `project_id` — GH Project v2 ID (resolved from repo config or user prompt)
- `field_id` — Project field ID for `SP` (resolved from project)

## Steps

1. Add the issue to the project if not already added:
   ```
   gh project item-add <project_number> --owner <owner> --url <issue_url>
   ```
2. Set the SP field via GraphQL:
   ```
   gh api graphql -f query='
     mutation($project: ID!, $item: ID!, $field: ID!, $value: Float!) {
       updateProjectV2ItemFieldValue(
         input: {
           projectId: $project, itemId: $item, fieldId: $field,
           value: { number: $value }
         }
       ) { projectV2Item { id } }
     }' -F project=<project_id> -F item=<item_id> -F field=<field_id> -F value=<sp>
   ```

## Output

- Confirmation of SP set on the project item

## Notes

- The Project must have a `SP` field of type Number — if absent, prompt the user to add it once
- Issue-level SP (size-check from `/refine`) is **not** stored anywhere; only Subtask SP is registered (per `soloscrum-define-story-points`)
- Project ID and field ID can be cached in `.claude/rules/tracker.md` after first resolution to skip the lookup

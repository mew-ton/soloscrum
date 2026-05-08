---
name: soloscrum-tracker-github-query-backlog
description: "Operation: list backlog Issues and Sub-issues from GitHub, ordered by priority. Used when active tracker profile is github-only."
user-invocable: false
allowed-tools:
  - Bash(gh issue list:*)
  - Bash(gh api:*)
---

# soloscrum-tracker-github-query-backlog

Returns the backlog (open Issues and Sub-issues without state labels) ordered by priority. Active when `tracker_profile = github-only`.

## Inputs

- (none) — defaults to the current repo

## Steps

1. List open Issues without `state:in-progress` and `state:in-review` labels:
   ```
   gh issue list --state open \
     --search "no:label state:in-progress no:label state:in-review" \
     --json number,title,labels,url \
     --limit 100
   ```
2. Filter by `priority:*` label and group:
   - `priority:urgent` first, then `high`, `medium`, `low`, then unlabeled
3. (If a project is configured) fetch SP for each item via Projects v2 GraphQL
4. Return the grouped list

## Output

- Grouped backlog list:
  ```
  Urgent:
    #123 (SP 3, develop) — Add password reset
  High:
    #124 (SP 5, design-ui) — Login screen
  ...
  ```

## Notes

- This operation skill is the basis for `/next` and `/status` when in github-only profile
- "Backlog" excludes anything currently `in-progress` or `in-review` — those are surfaced by `query-state` instead
- If the repo has no `priority:*` labels yet, all items are returned ungrouped

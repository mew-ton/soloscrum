---
name: soloscrum-tracker-github-query-state
description: "Operation: list Issues and Sub-issues currently In Progress or In Review on GitHub. Used when active tracker profile is github-only."
user-invocable: false
allowed-tools:
  - Bash(gh issue list:*)
  - Bash(gh issue view:*)
  - Bash(gh pr list:*)
---

# soloscrum-tracker-github-query-state

Returns active work — items in `state:in-progress` or `state:in-review`. Active when `tracker_profile = github-only`.

## Inputs

- `issue_number` (optional) — narrow to one Issue's subtree

## Steps

1. Fetch in-progress items:
   ```
   gh issue list --state open --label "state:in-progress" \
     --json number,title,labels,url
   ```
2. Fetch in-review items:
   ```
   gh issue list --state open --label "state:in-review" \
     --json number,title,labels,url
   ```
3. For each in-review item, attach its PR via `gh issue view <n> --json closingIssuesReferences,...` or `gh pr list --search "linked:<n>"`
4. (If `issue_number` given) restrict results to that Issue's Sub-issues

## Output

- Two grouped lists:
  ```
  In Progress:
    #200 (develop) — Implement password reset endpoint
  In Review:
    #201 (develop) — Add reset email template → PR #45
  ```

## Notes

- This is the basis for `/status` in github-only profile
- For design-ui type Sub-issues in review, also surface the Figma URL if recorded in the body

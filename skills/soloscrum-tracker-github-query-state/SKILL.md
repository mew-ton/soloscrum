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
4. **For each item, classify Subtask vs no-Subtask Issue** by fetching its `parent` and `subIssuesSummary` via the Sub-issues GraphQL preview (requires the `GraphQL-Features: sub_issues` header — the same header `/refine`'s parent-detection path uses, but the per-Issue probe shape is different so the snippet is included here):

   ```bash
   gh api graphql \
     -H "GraphQL-Features: sub_issues" \
     -f query='
       query($owner: String!, $repo: String!, $number: Int!) {
         repository(owner: $owner, name: $repo) {
           issue(number: $number) {
             parent { number }
             subIssuesSummary { total }
           }
         }
       }' -F owner=<owner> -F repo=<repo> -F number=<n>
   ```

   Classification predicates: `parent != null` → **Subtask**; `parent == null AND subIssuesSummary.total == 0` → **no-Subtask Issue**; `parent == null AND subIssuesSummary.total > 0` → **parent Issue** (not a `/develop` target — surfaces only as context).
5. (If `issue_number` given) restrict results to that Issue's Sub-issues

## Output

- Two grouped lists; each entry distinguishes Subtask vs no-Subtask Issue (per `soloscrum-define-branch-commit`'s case-split — `/develop` accepts either):

  ```text
  In Progress:
    #200 (Subtask, develop) — Implement password reset endpoint
    #210 (Issue, develop) — Fix login crash on empty input
  In Review:
    #201 (Subtask, develop) — Add reset email template → PR #45
    #212 (Issue, develop) — Cleanup legacy router → PR #50
  ```

  The per-entry `(Subtask, ...)` / `(Issue, ...)` label comes from the step 4 classification.

## Notes

- This is the basis for `/status` in github-only profile
- For design-ui type Sub-issues in review, also surface the Figma URL if recorded in the body
- **Querying `state:done`**: an Issue carrying the `state:done` label can be either open (`/review` Pass verdict reached, awaiting `gh pr merge`) or closed (PR merged via `Closes #N`). To list "shippable but unmerged" Subtasks, use `gh issue list --state open --label "state:done"`. To list fully shipped (since the label-based mapping was adopted), use `gh issue list --state closed --label "state:done"`.
- **Backwards-compat: pre-label-mapping closed Subtasks have no `state:done` label.** Issues closed before this skill switched to label-based `done` are not retroactively labelled. Treat the closed-without-label cohort as "historically shipped"; do not retro-apply the label. If a per-repo report needs the old cohort included, query closed Issues without the label filter and union with the labelled-closed set. See `soloscrum-tracker-github-transition-state` for the full state mapping.

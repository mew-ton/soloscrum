---
name: soloscrum-tracker-github-add-dependency
description: "Operation: declare that one GitHub Issue depends on another by editing the body with a Depends on line. Used when active tracker profile is github-only."
user-invocable: false
allowed-tools:
  - Bash(gh issue view:*)
  - Bash(gh issue edit:*)
---

# soloscrum-tracker-github-add-dependency

Declares a blocking dependency between two Issues by editing the dependent Issue's body. Active when `tracker_profile = github-only`.

## Inputs

- `issue_number` — Issue that depends on others (the dependent)
- `depends_on` — list of Issue numbers it depends on

## Steps

1. Read the current body:
   ```
   gh issue view <issue_number> --json body -q .body
   ```
2. If a `## Dependencies` section exists, append; otherwise add the section:
   ```
   ## Dependencies

   Depends on: #<n1>, #<n2>, ...
   ```
3. Update the body:
   ```
   gh issue edit <issue_number> --body-file <updated>
   ```
4. Verify the edit succeeded — `gh issue edit` returns non-zero on failure. If it failed (auth expired, rate limit, or concurrent body mutations from another writer), re-fetch the body, recompute the Dependencies section, and retry once. Surface a clear error if the second attempt also fails so the user can resolve manually.

## Output

- Confirmation that body was updated, with the new Dependencies section

## Notes

- GitHub auto-renders `#N` references as cross-links and shows back-references on the dependency Issue
- Parent–child relationships (Sub-issues) are **not** dependencies — use `soloscrum-tracker-github-create-subtask` for those
- Use this only for **peer blocking** (e.g. "Issue B can't start until Issue A is done"), not for hierarchical decomposition

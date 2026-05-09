---
name: soloscrum-tracker-github-transition-state
description: "Operation: transition the state of a GitHub Issue or Sub-issue using state labels and open/close. Used when active tracker profile is github-only."
user-invocable: false
allowed-tools:
  - Bash(gh issue:*)
  - Bash(gh label:*)
---

# soloscrum-tracker-github-transition-state

Transitions an Issue or Sub-issue between soloscrum lifecycle states. Active when `tracker_profile = github-only`.

## Inputs

- `issue_number` — target Issue or Sub-issue number
- `to_state` — one of `in-progress` / `in-review` / `done`

## State → GH mapping

| soloscrum state | GH representation |
|---|---|
| `in-progress` | open + label `state:in-progress` |
| `in-review` | open + label `state:in-review` |
| `done` | closed (labels removed) |

## Steps

1. Remove existing `state:*` labels:
   ```
   gh issue edit <issue_number> --remove-label "state:in-progress" --remove-label "state:in-review"
   ```
2. Apply the new state:
   - `in-progress` or `in-review`:
     ```
     gh issue edit <issue_number> --add-label "state:<to_state>"
     ```
   - `done`:
     ```
     gh issue close <issue_number>
     ```

## Output

- Confirmation of new state

## Notes

- Only `soloscrum-review` may transition to `done` (per `soloscrum-define-agent-responsibilities`)
- **Subtask state transition is profile-only** — closing the underlying GitHub Issue is **not** done here. Issue closure happens at merge time via the PR body's `Closes #` keyword, or via the `/refine` janitor for parent Issues that GH auto-close did not cover. This skill operates on `state:*` labels (and `gh issue close` only as the GH representation of `state = done`); it is not invoked to close a parent Issue at verdict. See `soloscrum-define-pr-lifecycle`, "Issue close happens at merge".
- If `state:*` labels do not exist in the repo, create them once: `gh label create state:in-progress --color BFD4F2` and `gh label create state:in-review --color D4C5F9`

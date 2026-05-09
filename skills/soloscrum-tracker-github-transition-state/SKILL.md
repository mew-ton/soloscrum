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
| `done` | open + label `state:done` (verdict passed; merge pending). The Issue itself closes when the linked PR merges via its `Closes #` keyword. |

The `done` state is **deliberately decoupled from GH closed/open**. GH "closed" is reserved for "merged into main" (the GH convention everyone outside soloscrum follows). soloscrum's `done` state is "verdict passed by `/review` — work is shippable, awaiting the user's `gh pr merge`." Querying `state:done` AND `is:open` enumerates Subtasks in this intermediate state; querying `state:done` AND `is:closed` enumerates fully-shipped work.

## Steps

1. Remove existing `state:*` labels:
   ```
   gh issue edit <issue_number> \
     --remove-label "state:in-progress" \
     --remove-label "state:in-review" \
     --remove-label "state:done"
   ```
2. Apply the new state label:
   ```
   gh issue edit <issue_number> --add-label "state:<to_state>"
   ```
3. **Do not call `gh issue close` here.** GH-side close is downstream of merge; this skill never closes an Issue. (See "Notes" below.)

## Output

- Confirmation of new state

## Notes

- Only `soloscrum-review` may transition to `done` (per `soloscrum-define-agent-responsibilities`)
- **This skill never calls `gh issue close`.** Issue closure happens at merge time via the PR body's `Closes #` keyword (which is in the DoD per `soloscrum-define-dod`); parent Issues that GH does not auto-close are picked up by the `/refine` janitor sweep. See `soloscrum-define-pr-lifecycle`, "Issue close happens at merge".
- If `state:*` labels do not exist in the repo, create them once:
  ```
  gh label create state:in-progress --color BFD4F2
  gh label create state:in-review   --color D4C5F9
  gh label create state:done        --color C2E0C6
  ```
- The `state:done` label is **kept** when the linked PR merges (and GH closes the Issue). A closed Issue with `state:done` is the canonical "shipped" record; loss of the label on close would erase that signal.
- A `state:done` Issue that has been **reopened** (by the user, or because the merge was reverted) keeps the `state:done` label while transitioning back to in-progress: the agent removes `state:done` and applies `state:in-progress` per the steps above. The transition skill always treats `state:*` labels as mutually exclusive on open Issues.

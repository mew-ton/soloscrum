---
name: breakdown
description: Breaks a GitHub Issue into Subtasks with type (develop or design-ui) and story points. Proposes the breakdown for confirmation, then registers each Subtask via the active tracker profile's operation skill.
argument-hint: <issue-url or issue-number>
disable-model-invocation: true
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash(gh issue:*)
  - Bash(gh api:*)
  - Bash(gh label:*)
---

# /breakdown

Break an Issue into Subtasks with type and story points.

## Behavior

1. Receive target Issue (`$ARGUMENTS`)
2. **Verify `/breakdown` is the right command for this Issue.** Per `soloscrum-define-issue-size`, `/breakdown` fires when delivering the Issue's intent as a single PR would produce an unreviewable PR — a delivery / reviewability question, not a scope question. If the diagnosis is "multiple intents bundled" (the SP > 5 or subtasks > 5 thresholds in `soloscrum-define-issue-size` reading as a mis-scope smell), re-route to `/refine` for Issue split instead. If the Issue's intent fits one reviewable PR, skip `/breakdown` and go directly to `/develop`.
3. `soloscrum-design` performs work decomposition:
   - Plan **delivery slicing** (Subtasks are work slices of the parent intent per `soloscrum-define-issue-format`'s Subtask Body section — they do **not** carry their own Background / Goal / AC / Out of Scope; the parent owns those)
   - Slice along reviewability seams (file cluster / layer / phase with its own deliverable), not along intent boundaries (which would imply a re-`/refine` instead)
   - Assign type to each Subtask (`soloscrum-define-task-type` criteria)
   - Verify decomposition validity with `soloscrum-validate-feature`
4. Present breakdown proposal to user for confirmation
5. Upon approval, `soloscrum-dev` registers Subtasks via the active tracker profile (`soloscrum-define-tracker-profile`):
   - Calculate Subtask SP (`soloscrum-define-story-points`)
   - Invoke `soloscrum-tracker-{github|linear}-create-subtask` for each Subtask
   - Invoke `soloscrum-tracker-{github|linear}-add-dependency` for any cross-subtask blocking relations

## Input

- GitHub Issue URL or issue number

## Output

- Created Subtask list
  - Title
  - Type (develop / design-ui)
  - SP
  - ID (GH `#N` or Linear `PRJ-N` depending on profile)
  - Dependencies (if any)

## Resources

- Subagents: `soloscrum-design` (size and type design), `soloscrum-dev` (subtask registration)
- Skills: `soloscrum-define-issue-format` (Subtask body contract), `soloscrum-define-issue-size` (when `/breakdown` is the right command), `soloscrum-validate-feature`, `soloscrum-define-task-type`, `soloscrum-split-into-tasks`, `soloscrum-define-story-points`, `soloscrum-define-tracker-profile`

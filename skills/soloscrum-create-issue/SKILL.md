---
name: soloscrum-create-issue
description: Structures an idea into a GitHub Issue with Background, Goal, AC, and Out of Scope. Checks issue size, suggests splitting if over threshold, and determines priority and story points. Profile-agnostic.
argument-hint: <idea or feature description>
disable-model-invocation: true
allowed-tools:
  - Bash(gh issue create:*)
  - Bash(gh label:*)
---

# soloscrum-create-issue

Structure an idea into an Issue with size check and split proposal.

## Overview

Receives a free-form idea or request and converts it into GitHub Issue format following `soloscrum-define-issue-format`. Proposes splitting when size exceeds threshold. Tracker-profile-agnostic — Issue creation always lands on GitHub regardless of active profile.

## Steps

1. Receive the following idea or request text: $ARGUMENTS
2. Create Issue with this structure (see `soloscrum-define-issue-format`):
   - title: concise title starting with a verb
   - background: why this feature is needed
   - goal: what to achieve
   - acceptance_criteria: verifiable completion conditions (bullet list)
   - out_of_scope: explicitly state what is out of scope
3. Evaluate size with `soloscrum-define-issue-size`
4. If size exceeds threshold, create split proposal and present to user
5. Determine priority with `soloscrum-define-priority`
6. Calculate Issue-level SP (size-check) with `soloscrum-define-story-points`
7. Create the GitHub Issue:
   ```
   gh issue create --title "<title>" --body "<body>" \
     --label "priority:<level>"
   ```
   - Issue-level SP is **not** registered anywhere (size-check value only, per `soloscrum-define-story-points`)
   - In `linear+github` profile, Linear's native sync will replicate the Issue automatically; no extra step is needed here

## Output Format

```markdown
## [Issue Title]

### Background
[Background and problem]

### Goal
[Achievement target]

### Acceptance Criteria
- [ ] [Verifiable condition 1]
- [ ] [Verifiable condition 2]

### Out of Scope
- [Out of scope item 1]

---
Priority: Medium | SP: 3 (size-check only)
```

## Depends On

- `soloscrum-define-issue-format`
- `soloscrum-define-issue-size`
- `soloscrum-define-priority`
- `soloscrum-define-story-points`
- `soloscrum-define-tracker-profile` (priority label convention is shared)

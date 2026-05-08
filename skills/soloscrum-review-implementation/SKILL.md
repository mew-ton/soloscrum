---
name: soloscrum-review-implementation
description: Reviews a PR or Figma file against the DoD checklist and all Acceptance Criteria. Returns Pass or Fail with specific feedback. On Pass, transitions the Subtask to Done via the active profile's tracker operation skill and closes the Issue when all subtasks complete.
argument-hint: <pr-url or figma-url>
disable-model-invocation: true
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash(gh pr:*)
  - Bash(gh issue view:*)
---

# soloscrum-review-implementation

Verify DoD, code quality, and make close decision.

## Overview

Receives a PR or Figma file, evaluates DoD, AC, and code quality. Makes Pass / Fail verdict and executes close procedure on Pass. State transitions delegate to the active profile's `transition-state` operation skill (per `soloscrum-define-tracker-profile`).

## Steps

1. Read target PR or Figma file and corresponding Issue: $ARGUMENTS
2. Verify all items in `soloscrum-define-dod`:
   - Are all AC satisfied?
   - Do tests exist (when applicable)?
   - Does PR body contain Issue number?
   - Zero lint errors?
3. Code review (for PRs):
   - Logic correctness
   - Security: OWASP Top 10 perspective
   - Performance: no obvious bottlenecks
   - Readability and maintainability
4. Compile all evaluation results into a report
5. **On Pass:**
   - Approve PR review (`gh pr review --approve`)
   - Merge PR (`gh pr merge`)
   - Resolve active profile, then invoke the matching `transition-state` operation skill to move the Subtask to `done`:
     - `github-only` → `soloscrum-tracker-github-transition-state`
     - `linear+github` → `soloscrum-tracker-linear-transition-state`
   - Confirm all sibling Subtasks under the parent Issue are also `done`
   - If all complete, invoke the same `transition-state` skill on the parent Issue to close it
6. **On Fail:**
   - Comment specific issues and improvement suggestions on PR
   - Invoke the matching `transition-state` operation skill to revert the Subtask to `in-progress`

## Output Format

```
## Review Result

### DoD Check
- [x] All AC satisfied
- [x] Tests exist
- [x] PR body contains Issue number
- [x] Zero lint errors

### Issues
- [specific details if any]

### Verdict: Pass / Fail
```

## Depends On

- `soloscrum-define-dod`
- `soloscrum-define-tracker-profile` (routing)
- `soloscrum-tracker-{github|linear}-transition-state` (delegated)

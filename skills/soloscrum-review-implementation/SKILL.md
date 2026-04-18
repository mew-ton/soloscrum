---
name: soloscrum-review-implementation
description: Reviews a PR or Figma file against the DoD checklist and all Acceptance Criteria. Returns Pass or Fail with specific feedback. Merges the PR and closes the Issue when all subtasks pass.
argument-hint: <pr-url or figma-url>
disable-model-invocation: true
allowed-tools: Read Glob Grep
---

# soloscrum-review-implementation

Verify DoD, code quality, and make close decision.

## Overview

Receives a PR or Figma file, evaluates DoD, AC, and code quality. Makes Pass / Fail verdict and executes close procedure on Pass.

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
   - Approve PR review
   - Transition Linear subtask to Done
   - Confirm all subtasks complete
   - Close GitHub Issue if all complete
6. **On Fail:**
   - Comment specific issues and improvement suggestions on PR
   - Revert Linear subtask to In Progress

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

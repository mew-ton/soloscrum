---
name: soloscrum-review-implementation
description: Reviews a PR or Figma file against the DoD checklist and all Acceptance Criteria. PRs are expected in draft; on Pass the review agent promotes the PR to ready, transitions the Subtask to Done via the active profile's tracker operation skill, closes the Issue when all subtasks complete, and hands the merge command off to the user. Merge itself is always user-gated.
argument-hint: <pr-url or figma-url>
disable-model-invocation: true
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash(gh pr:*)
  - Bash(gh issue:*)
  - Bash(gh api:*)
  - Bash(coderabbit:*)
  - Bash(cr:*)
---

# soloscrum-review-implementation

Verify DoD, code quality, and make close decision.

## Overview

Receives a PR or Figma file, evaluates DoD, AC, and code quality. PRs arrive in **draft** (per `soloscrum-define-pr-lifecycle`); the review pipeline runs in that draft window. Makes Pass / Pass with follow-ups / Fail verdict and executes the verdict's post-actions per `soloscrum-define-code-review-process`. State transitions delegate to the active profile's `transition-state` operation skill (per `soloscrum-define-tracker-profile`). The final `gh pr merge` is always user-gated and never executed by this skill.

## Steps

1. Read target PR or Figma file and corresponding Issue: $ARGUMENTS
2. Verify all items in `soloscrum-define-dod`:
   - Are all AC satisfied?
   - Do tests exist (when applicable)?
   - Does PR body contain Issue number?
   - Zero lint errors?
3. Run the **automated code review pipeline** per `soloscrum-define-code-review-process`:
   - CodeRabbit CLI (all severities pass through; skip with stated reason or fix each)
   - Multi-agent review (apply <80 confidence filter on agent findings only)
4. Manual code review (for PRs), to complement the automated pass:
   - Logic correctness
   - Security: OWASP Top 10 perspective
   - Performance: no obvious bottlenecks
   - Readability and maintainability
5. Compile all evaluation results into a single report following the format in `soloscrum-define-code-review-process`
6. **On Pass / Pass with follow-ups** — run **all sub-steps below end-to-end without pausing**; the only stop in this entire sequence is at `gh pr merge`. Transition state first, then promote to ready so a tracker failure does not leave a ready PR with stale state:
   - For Pass with follow-ups only: programmatically check whether a follow-up Issue exists for each out-of-scope skip; create any missing Issue autonomously and record its number in the skip note before proceeding (no user prompt)
   - Approve PR review (`gh pr review --approve`) — reversible
   - Resolve active profile, then invoke the matching `transition-state` operation skill to move the Subtask to `done`:
     - `github-only` → `soloscrum-tracker-github-transition-state`
     - `linear+github` → `soloscrum-tracker-linear-transition-state`
   - Programmatically check whether all sibling Subtasks under the parent Issue are also `done` (query the tracker via the matching `query-state` skill; this is a tracker lookup, not a user prompt)
   - If all complete, invoke the same `transition-state` skill on the parent Issue to close it
   - Promote the PR to ready (`gh pr ready`) — reversible (`gh pr ready --undo`); per `soloscrum-define-pr-lifecycle` this runs without pre-confirm
   - **Stop here.** Surface the exact `gh pr merge` command for the user to run; merge is irreversible and is the user's gate. Do not run `gh pr merge`.
   - If `transition-state` fails after `gh pr ready` has happened (rare race), surface a clear notice and prompt the user to manually transition before they merge
7. **On Fail:**
   - Comment specific issues and improvement suggestions on PR
   - Invoke the matching `transition-state` operation skill to revert the Subtask to `in-progress`
   - **Leave the PR in draft** — do not call `gh pr ready`. The draft state keeps GitHub-side auto-reviewers suppressed during rework and makes the "needs more work" state externally visible.

## Output Format

Follow the comment template defined in `soloscrum-define-code-review-process` (CodeRabbit findings + filtered agent findings + verdict). The DoD checklist is included alongside.

```
## Review Result

### DoD Check
- [x] All AC satisfied
- [x] Tests exist
- [x] PR body contains Issue number
- [x] Zero lint errors

### CodeRabbit findings
- (per soloscrum-define-code-review-process)

### Agent findings (≥80 confidence)
- (per soloscrum-define-code-review-process)

### Verdict: Pass / Pass with follow-ups / Fail
```

## Depends On

- `soloscrum-define-dod`
- `soloscrum-define-code-review-process` (verdict + post-action mapping)
- `soloscrum-define-pr-lifecycle` (draft premise, `gh pr ready` autonomy, merge user-gate)
- `soloscrum-define-tracker-profile` (routing)
- `soloscrum-tracker-{github|linear}-transition-state` (delegated)

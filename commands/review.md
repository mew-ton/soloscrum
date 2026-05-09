---
name: review
description: Reviews a PR or Figma file against the DoD and all AC. On Pass, approves, transitions the Subtask to Done, promotes the PR to ready, and surfaces the merge command for the user. Issue close happens at merge time (via the PR body's Closes # keyword), not at verdict. Merge itself is always the user's gate.
argument-hint: <pr-url or figma-url>
disable-model-invocation: true
effort: high
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash(gh pr:*)
  - Bash(gh issue:*)
  - Bash(gh api:*)
  - Bash(gh label:*)
---

# /review

Review implementation or design and close the Issue.

## Authorisation scope

Invoking `/review` on a given PR constitutes **pre-authorisation for the entire post-verdict action sequence on that PR** as defined in `soloscrum-define-pr-lifecycle` and `soloscrum-define-code-review-process`. The user is asking, for this invocation, for the verdict *and* the standard follow-through it implies — including `gh pr review --approve`, the tracker `→ done` transition, and `gh pr ready`. **None** of those steps require an additional confirmation prompt; pausing on any reversible step is the failure mode the lifecycle skill exists to prevent. Issue close is not part of this sequence — it happens at merge time via the PR body's `Closes #` keyword.

The pre-authorisation applies to **this** invocation only and does not carry over to other PRs or to a re-run of `/review` on the same PR.

The scope **stops** at `gh pr merge`. Merge is irreversible and is always the user's gate, regardless of verdict. The agent surfaces the exact merge command and does not execute it.

## Behavior

1. Receive target PR or Figma file (`$ARGUMENTS`)
2. Launch `soloscrum-review` to:
   - Verify DoD with `soloscrum-define-dod` and `.claude/rules/dod-extra.md`
   - Check code quality (for PRs)
   - Verify all Issue AC (Acceptance Criteria)
   - Flag issues and post review comments
3. Optional: `soloscrum-design` checks for feature scope deviation
4. Optional: `soloscrum-ui` checks design fidelity
5. On Pass / Pass with follow-ups (per `soloscrum-define-pr-lifecycle` and `soloscrum-define-code-review-process`):
   - For Pass with follow-ups: ensure a follow-up Issue exists for each out-of-scope skip and that its number is recorded in the skip note
   - Approve PR (`gh pr review --approve`)
   - Resolve active tracker profile and invoke `soloscrum-tracker-{github|linear}-transition-state` to move the Subtask to `done`
   - **Wait for CI to complete** before promoting to ready. Invoke `soloscrum-tracker-github-wait-for-pr-checks`:
     ```bash
     skills/soloscrum-tracker-github-wait-for-pr-checks/scripts/wait-for-pr-checks.sh <pr-number>
     ```
     Then treat conclusions of `SUCCESS` / `SKIPPED` / `NEUTRAL` as acceptable. Anything else (`FAILURE` / `CANCELLED` / `TIMED_OUT` / `ERROR` / `ACTION_REQUIRED` / `STARTUP_FAILURE`) downgrades the verdict to **Fail**: post the failed conclusions on the PR, revert the Subtask to `in-progress`, and skip the remaining Pass actions. Inline `until ... gh pr view ... sleep ...` loops are an anti-pattern (per CLAUDE.md).
   - Promote the PR to ready (`gh pr ready`) — reversible; runs without pre-confirm
   - **Hand the merge off to the user** — surface the exact `gh pr merge` command. Do not run `gh pr merge`; merge is the user's gate. Issue close is downstream of merge: GH auto-closes referenced Issues via the PR body's `Closes #` keyword. Parent Issues that GH does not auto-close are picked up by the next `/refine` janitor sweep.
6. On Fail:
   - Post specific feedback on PR
   - Invoke `soloscrum-tracker-{github|linear}-transition-state` to revert the Subtask to `in-progress`
   - Leave the PR in draft (do not call `gh pr ready`)

## Input

- PR URL / number or Figma file URL
- Corresponding GitHub Issue number (extracted from PR body if omitted)

## Output

- Review report
  - DoD checklist
  - Issues list (if any)
  - Pass / Pass with follow-ups / Fail verdict
- On Pass / Pass with follow-ups: Subtask-done confirmation, PR promoted to ready, and the exact `gh pr merge` command for the user to run (Issue close is handled at merge time, not by `/review`)

## Resources

- Subagents: `soloscrum-review` (required), `soloscrum-design` (optional), `soloscrum-ui` (optional)
- Skills: `soloscrum-review-implementation`, `soloscrum-define-dod`, `soloscrum-define-code-review-process`, `soloscrum-define-pr-lifecycle`, `soloscrum-define-tracker-profile`, `soloscrum-tracker-github-wait-for-pr-checks` (call before `gh pr ready` so the user does not see a freshly-ready PR with red checks)
- Rules: `.claude/rules/dod-extra.md`

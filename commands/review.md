---
name: review
description: Reviews a PR or Figma file against the DoD and all AC. Merges the PR and closes the Issue when all subtasks pass.
argument-hint: <pr-url or figma-url>
disable-model-invocation: true
effort: high
---

# /review

Review implementation or design and close the Issue.

## Behavior

1. Receive target PR or Figma file (`$ARGUMENTS`)
2. Launch `review-agent` to:
   - Verify DoD with `soloscrum-define-dod` and `.claude/rules/dod-extra.md`
   - Check code quality (for PRs)
   - Verify all Issue AC (Acceptance Criteria)
   - Flag issues and post review comments
3. Optional: `design-agent` checks for feature scope deviation
4. Optional: `ui-agent` checks design fidelity
5. On Pass:
   - Approve and merge PR
   - Transition Linear subtask to Done
   - Close GitHub Issue when all subtasks are complete

## Input

- PR URL / number or Figma file URL
- Corresponding GitHub Issue number (extracted from PR body if omitted)

## Output

- Review report
  - DoD checklist
  - Issues list (if any)
  - Pass / Fail verdict
- On Pass: Issue close confirmation

## Resources

- Subagents: `review-agent` (required), `design-agent` (optional), `ui-agent` (optional)
- Skills: `soloscrum-review-implementation`, `soloscrum-define-dod`
- Rules: `.claude/rules/dod-extra.md`

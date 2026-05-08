---
name: review
description: Reviews a PR or Figma file against the DoD and all AC. Merges the PR and closes the Issue when all subtasks pass.
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
  - mcp__claude_ai_Linear__list_issues
  - mcp__claude_ai_Linear__list_issue_statuses
  - mcp__claude_ai_Linear__save_issue
  - mcp__claude_ai_Figma__get_design_context
  - mcp__claude_ai_Figma__get_screenshot
  - mcp__claude_ai_Figma__get_metadata
---

# /review

Review implementation or design and close the Issue.

## Behavior

1. Receive target PR or Figma file (`$ARGUMENTS`)
2. Launch `soloscrum-review` to:
   - Verify DoD with `soloscrum-define-dod` and `.claude/rules/dod-extra.md`
   - Check code quality (for PRs)
   - Verify all Issue AC (Acceptance Criteria)
   - Flag issues and post review comments
3. Optional: `soloscrum-design` checks for feature scope deviation
4. Optional: `soloscrum-ui` checks design fidelity
5. On Pass:
   - Approve and merge PR
   - Resolve active tracker profile and invoke `soloscrum-tracker-{github|linear}-transition-state` to move the Subtask to `done`
   - When all sibling Subtasks are done, invoke the same `transition-state` skill on the parent Issue to close it
6. On Fail:
   - Post specific feedback on PR
   - Invoke `soloscrum-tracker-{github|linear}-transition-state` to revert the Subtask to `in-progress`

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

- Subagents: `soloscrum-review` (required), `soloscrum-design` (optional), `soloscrum-ui` (optional)
- Skills: `soloscrum-review-implementation`, `soloscrum-define-dod`, `soloscrum-define-tracker-profile`
- Rules: `.claude/rules/dod-extra.md`

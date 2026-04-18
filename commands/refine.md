---
name: refine
description: Structures an idea into a GitHub Issue. Checks size, suggests splitting when too large, determines priority and SP, then creates the issue after confirmation.
argument-hint: <idea or feature description>
disable-model-invocation: true
---

# /refine

Structure an idea into a GitHub Issue.

## Behavior

1. Receive idea or request from user (`$ARGUMENTS`)
2. Launch `po-agent` to:
   - Structure the idea into GitHub Issue format
   - Check size against `soloscrum-define-issue-size` criteria
   - Suggest splitting if size exceeds threshold
   - Determine priority using `soloscrum-define-priority` criteria
   - Calculate SP using `soloscrum-define-story-points` criteria
3. Present structured result to user for confirmation
4. Create GitHub Issue upon approval
5. After Linear auto-sync, set SP and priority via Linear MCP

## Input

- Idea or request text (free form)

## Output

- Created GitHub Issue URL
- Linear Task URL (after sync)
- Configured SP and priority

## Resources

- Subagent: `po-agent`
- Skills: `soloscrum-create-issue`, `soloscrum-define-issue-format`, `soloscrum-define-issue-size`, `soloscrum-define-priority`

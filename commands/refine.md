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
2. Launch `soloscrum-po` to:
   - Structure the idea into GitHub Issue format
   - Check size against `soloscrum-define-issue-size` criteria
   - Suggest splitting if size exceeds threshold
   - Determine priority using `soloscrum-define-priority` criteria
   - Calculate Issue-level SP using `soloscrum-define-story-points` criteria (size-check only — not registered)
3. Present structured result to user for confirmation
4. Create the GitHub Issue (with priority label `priority:*` applied at creation)
5. In `linear+github` profile, Linear's native sync replicates the Issue automatically — no extra MCP call needed

## Input

- Idea or request text (free form)

## Output

- Created GitHub Issue URL
- Configured priority label
- Issue-level SP (size-check value only; for routing decisions like splitting)

## Resources

- Subagent: `soloscrum-po`
- Skills: `soloscrum-create-issue`, `soloscrum-define-issue-format`, `soloscrum-define-issue-size`, `soloscrum-define-priority`, `soloscrum-define-tracker-profile`

---
name: develop
description: Implements a Linear subtask of type develop. Creates a branch, writes code and tests, generates a PR, and transitions the subtask to In Review.
argument-hint: <subtask-id>
disable-model-invocation: true
effort: high
---

# /develop

Implement a develop subtask.

## Behavior

1. Receive target Linear subtask (type: develop) (`$ARGUMENTS`)
2. Launch `soloscrum-dev` to:
   - Create branch following `soloscrum-define-branch-commit` conventions
   - Implement code referencing `.claude/rules/stack.md`
   - Verify DoD with `soloscrum-define-dod` and `.claude/rules/dod-extra.md`
   - Generate PR body (issue number, change summary, test instructions)
   - Create PR
3. Transition Linear subtask to In Review
4. Present PR URL to user

## Input

- Linear subtask URL or ID
- (If omitted) auto-select the subtask in Linear In Progress state

## Output

- Created PR URL
- Implementation summary
- DoD checklist result

## Resources

- Subagent: `soloscrum-dev`
- Skills: `soloscrum-implement-task`, `soloscrum-define-branch-commit`, `soloscrum-define-dod`
- Rules: `.claude/rules/stack.md`, `.claude/rules/branch.md`, `.claude/rules/dod-extra.md`

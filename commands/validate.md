---
name: validate
description: Validates feature design for scope clarity, dependencies, and technical feasibility. Returns Pass/Conditional Pass/Fail with recommended actions.
argument-hint: <issue-url or issue-number>
disable-model-invocation: true
---

# /validate

Validate feature design for feasibility.

## Behavior

1. Receive target Issue or idea (`$ARGUMENTS`)
2. Launch `soloscrum-design` to:
   - Evaluate feature design validity (`soloscrum-define-design-criteria` criteria)
   - Check scope clarity
   - Identify dependencies
   - Assess technical feasibility
3. Present validation results to user
4. Propose fixes if issues are found

## Input

- GitHub Issue URL or issue number
- Issue body (direct text also accepted)

## Output

- Validation report
  - Scope clarity: OK / Needs revision
  - Dependency list
  - Technical concerns (if any)
  - Recommended action

## Resources

- Subagent: `soloscrum-design`
- Skills: `soloscrum-validate-feature`, `soloscrum-define-design-criteria`

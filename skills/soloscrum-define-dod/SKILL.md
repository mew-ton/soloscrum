---
name: soloscrum-define-dod
description: Reference: soloscrum Definition of Done checklist. All AC satisfied, tests exist if applicable, PR body links issue number with Closes/Fixes, lint passes, review approved.
user-invocable: false
---

# soloscrum-define-dod

Definition of Done (generic).

## DoD Checklist

- [ ] All AC are satisfied
- [ ] Tests exist (when applicable)
- [ ] PR body contains Issue number (`Closes #N` or `Fixes #N` format)
- [ ] Zero lint errors
- [ ] Review has passed

## Criteria for Each Item

### All AC are satisfied
- All AC checkboxes in the Issue are met
- Behavior has been verified with evidence (screenshots, test results, etc.)

### Tests exist (when applicable)
- Not applicable: configuration changes with no logic, documentation updates, etc.
- Applicable: business logic, API endpoints, utility functions, etc.

### PR body contains Issue number
- One of `Closes #123` / `Fixes #123` / `Resolves #123` must appear in the PR body

### Zero lint errors
- No errors from the project's lint configuration (ESLint, Prettier, Rubocop, etc.)
- Warnings are acceptable; errors are not

### Review has passed
- Pass verdict obtained from `review-agent` automated review

## Repository-Specific Additional DoD

Define in `.claude/rules/dod-extra.md` (not included in the soloscrum core).

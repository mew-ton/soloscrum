---
name: soloscrum-define-dod
description: "Reference: soloscrum Definition of Done checklist. AC verified at the appropriate layer (Subtask PR slice + no regression; Issue-without-Subtasks full AC; parent Issue intent-level sign-off when all Subtasks close). Tests exist if applicable, PR body links Issue number with Closes/Fixes (per-Subtask PRs reference only the Subtask, never the parent), lint passes, review approved."
user-invocable: false
---

# soloscrum-define-dod

Definition of Done (generic).

## DoD Checklist

- [ ] AC verified at the appropriate layer (see "AC verification (Issue-level vs Subtask-level)" below — Subtask PRs check slice delivery + no regressions; Issues without Subtasks check full Issue AC; the parent Issue's intent-level AC sign-off happens when all its Subtasks close, not at any single Subtask PR)
- [ ] Tests exist (when applicable)
- [ ] PR body contains Issue number (`Closes #N` / `Fixes #N` / `Resolves #N` format — `<subtask>` for Subtask PRs, `<issue>` for Issues without Subtasks; per `soloscrum-define-branch-commit`, per-Subtask PRs do **not** reference the parent Issue via `Closes #`)
- [ ] Zero lint errors
- [ ] Code review pipeline executed and findings addressed (per `soloscrum-define-code-review-process`)
- [ ] Review has passed

## Criteria for Each Item

### AC verification (Issue-level vs Subtask-level)

soloscrum's AC verification operates at two layers because Subtasks slice work, not intent (per `soloscrum-define-issue-format`'s Subtask Body section). Where to verify depends on the PR's relation to the parent Issue:

- **Subtask PR.** Verify the slice was delivered (its "what" + Checklist items, if any) and that there is no regression — no parent AC item that was previously satisfied is now broken. The parent Issue's AC is **not** required to be fully satisfied at this PR; only the slice's own delivery + no-regression.
- **Issue without Subtasks** (a single-`/develop`-unit Issue per `soloscrum-define-issue-size`). Verify **all** of the Issue's AC are met, with evidence (screenshots, test results, etc.). The PR closes the Issue directly via `Closes #<issue>`.
- **Parent Issue (with Subtasks) — intent-level AC sign-off.** The parent's full AC is verified when **all of its Subtasks are closed** (per `soloscrum-define-issue-format`), not at any individual Subtask PR. The last Subtask PR's merge triggers the parent's close via the `/refine` janitor; at that point the parent's AC must be satisfiable from the union of the Subtasks' deliveries. `soloscrum-review` does this sign-off on the parent Issue, not as part of any individual Subtask PR review.

### Tests exist (when applicable)
- Not applicable: configuration changes with no logic, documentation updates, etc.
- Applicable: business logic, API endpoints, utility functions, etc.

### PR body contains Issue number
- One of `Closes #123` / `Fixes #123` / `Resolves #123` must appear in the PR body

### Zero lint errors
- No errors from the project's lint configuration (ESLint, Prettier, Rubocop, etc.)
- Warnings are acceptable; errors are not

### Code review pipeline executed and findings addressed
- CodeRabbit run executed (or explicitly skipped due to environment)
- Multi-agent review run; surviving agent findings (≥80 confidence) consolidated
- Each surfaced finding (CodeRabbit any severity, agent ≥80) is decided individually: fix, or skip with a stated reason
- Severity / score is informational, not a skip reason
- See `soloscrum-define-code-review-process` for the per-item decision rules

### Review has passed
- Pass verdict obtained from `soloscrum-review` automated review

## Repository-Specific Additional DoD

Define in `.claude/rules/dod-extra.md` (not included in the soloscrum core).

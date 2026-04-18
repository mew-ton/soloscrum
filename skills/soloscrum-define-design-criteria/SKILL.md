---
name: soloscrum-define-design-criteria
description: "Reference: criteria for validating feature design across scope clarity (Goal and AC alignment), dependency identification, and technical feasibility against the project stack."
user-invocable: false
---

# soloscrum-define-design-criteria

Feature design validation criteria.

## Evaluation Perspectives

### 1. Scope Clarity

| Check | Criteria |
|---|---|
| Is the Goal stated clearly in 1-2 sentences? | OK: single purpose. NG: multiple purposes mixed |
| Is the AC in verifiable format? | OK: "user can ..." format. NG: "implement ..." format |
| Is Out of Scope explicitly stated? | OK: stated. NG: blank |
| Does scope fit within a single feature? | OK: one feature. NG: multiple features mixed |

### 2. Dependencies

| Check | Criteria |
|---|---|
| Are dependencies on other Issues stated explicitly? | If dependencies exist, are they noted in Notes? |
| Are there dependencies on external APIs or services? | If so, confirm availability |
| Does it involve data changes (schema migrations, etc.)? | If so, is migration considered? |

### 3. Technical Feasibility

| Check | Criteria |
|---|---|
| Does it align with the existing architecture? | Flag if it diverges significantly from existing patterns |
| Is it achievable with the tech stack? | Cross-reference with `.claude/rules/stack.md` |
| Are there performance concerns? | Bulk data processing, real-time processing, etc. |
| Are there security concerns? | Authentication, authorization, input validation, etc. |

## Verdict Criteria

| Verdict | Condition |
|---|---|
| **Pass** | All items OK |
| **Conditional Pass** | Issues that can be resolved with minor revisions |
| **Fail** | Scope unclear, technically infeasible, or dependency problems |

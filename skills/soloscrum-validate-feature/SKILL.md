---
name: soloscrum-validate-feature
description: Validates a feature's design for scope clarity, dependencies, and technical feasibility. Returns Pass/Conditional Pass/Fail with recommended actions.
argument-hint: <issue-url or issue-number>
disable-model-invocation: true
---

# soloscrum-validate-feature

Validate feature design for scope, dependencies, and technical feasibility.

## Overview

Receives an Issue or feature design and validates it against `soloscrum-define-design-criteria` criteria. Returns identified issues and recommended actions.

## Steps

1. Read target Issue content: $ARGUMENTS
2. Evaluate from the following perspectives (see `soloscrum-define-design-criteria`):

   **Scope evaluation**
   - Do Goal and AC align?
   - Is Out of Scope explicitly stated?
   - Are there any ambiguous parts of the scope?

   **Dependency evaluation**
   - Are there dependencies on other Issues or features?
   - Are there dependencies on external APIs or services?
   - Is there work that must be completed first?

   **Technical feasibility**
   - Does it align with the existing architecture?
   - Is it achievable with the tech stack in `.claude/rules/stack.md`?
   - Are there performance or security concerns?

3. Return structured evaluation results

## Output Format

```
## Validation Result

### Scope
- Status: OK / Needs revision
- Notes: [if any]

### Dependencies
- [Dependency 1]: [description]

### Technical Concerns
- [Concern 1]: [details and recommended action]

### Overall: Pass / Conditional Pass / Fail
Recommended action: [next step]
```

## Depends On

- `soloscrum-define-design-criteria`

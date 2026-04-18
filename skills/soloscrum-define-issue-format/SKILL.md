---
name: soloscrum-define-issue-format
description: Reference: required format for GitHub Issue titles and bodies. Title starts with a verb. Body uses Background, Goal, Acceptance Criteria, and Out of Scope sections.
user-invocable: false
---

# soloscrum-define-issue-format

Issue title and body format definition.

## Title Conventions

- Start with a verb (e.g. "Add", "Fix", "Support", "Remove")
- 50 characters or fewer
- No technical details (write the What, not the How)

Good: `Allow users to reset their password`
Bad: `Implement password_reset endpoint with Auth0 and return JWT`

## Body Structure

```markdown
## Background
[Why this feature is needed. Describe the current problem or context.]

## Goal
[State the objective of this Issue in 1-2 sentences.]

## Acceptance Criteria
- [ ] [Verifiable condition. Use "user can ..." / "... is displayed" format]
- [ ] [Write from the user's perspective]
- [ ] [Describe behavior, not technical implementation]

## Out of Scope
- [Explicitly state what is excluded. Write "None" if nothing is excluded.]

## Notes
[Supplementary info, reference links, design mock links, etc. (optional)]
```

## AC Writing Guide

| Good | Bad |
|---|---|
| User can log in with email address | Issue JWT token |
| Error message is shown on invalid input | Implement validation |
| Dashboard is inaccessible after logout | Delete session |

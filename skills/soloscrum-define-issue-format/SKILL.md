---
name: soloscrum-define-issue-format
description: "Reference: required format for GitHub Issue titles and bodies. Title starts with a verb. Body uses Background, Goal, Acceptance Criteria, and Out of Scope sections."
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

## Companion files

A copy-pastable template lives next to this skill at `templates/ISSUE_TEMPLATE.md`. It mirrors the Body Structure above and carries a self-marker so soloscrum-format Issues are recognisable in mixed setups.

### Self-marker

The template begins with the HTML comment `<!-- soloscrum-issue-format -->` (greppable, invisible when rendered) and ends with a small italic footer (`_Following the [soloscrum](https://github.com/mew-ton/soloscrum) Issue template._`). Together they let consumer projects identify Issues created from this template both in raw Markdown and in the GitHub UI.

### Consumer-project usage

Consumer projects can adopt the companion in two ways:

- **Drop into `.github/ISSUE_TEMPLATE/`** — copy the file to `.github/ISSUE_TEMPLATE/soloscrum.md` (or any name your project prefers). GitHub's "New Issue" UI will then offer it as a chooser entry. Co-existing with project-specific templates is supported because the self-marker keeps soloscrum-format Issues distinguishable.
- **Manual copy-paste** — open `templates/ISSUE_TEMPLATE.md`, copy the contents, and paste into a fresh Issue body via the GitHub web UI when no `.github/ISSUE_TEMPLATE/` setup is desired.

### Relationship to `/refine`

The template is for **human-direct Issue creation via the GitHub UI**. The `/refine` command does **not** read this file — it generates Issue bodies from the Body Structure spec text in this SKILL.md. Edits to the template do not affect `/refine` output, and edits to the spec do not auto-propagate to the template; keep them aligned manually.

### Canonical language

The template's canonical language is **English**, matching the AC Writing Guide above. Multi-language variants (e.g. Japanese) are out of scope for the current companion and tracked as follow-ups.

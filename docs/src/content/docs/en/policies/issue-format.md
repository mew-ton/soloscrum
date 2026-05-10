---
title: Issue format
description: The required Issue title and body shape (Background / Goal / Acceptance Criteria / Out of Scope) plus the companion ISSUE_TEMPLATE file.
sidebar:
  order: 1
---

Every soloscrum Issue body uses the same four-section shape: Background, Goal, Acceptance Criteria, and Out of Scope. `/refine` produces this shape; you read or edit it before approving, and `/validate` and `/breakdown` later rely on it being predictable.

## The four sections

The body is always written in this order:

```markdown
## Background
[Why this feature is needed.]

## Goal
[State the objective in 1-2 sentences.]

## Acceptance Criteria
- [ ] [Verifiable condition. Use "user can ..." format.]

## Out of Scope
- [Explicitly state what is excluded. Write "None" if nothing.]

## Notes
[Supplementary info, references, design links.]
```

Title rules:

- Starts with a verb, 50 characters or fewer
- Describes the What rather than the How

AC rules:

- Each item is independently verifiable
- Phrased in user-facing terms ("user can …", "… is displayed") — not implementation terms ("Issue JWT token", "Implement validation")

A leading `<!-- soloscrum-issue-format -->` HTML comment plus a small italic footer mark the body as soloscrum-formatted, so the janitor and `/validate` can detect it cheaply.

## When this applies

`/refine` writes Issues in this shape, and `/validate` checks an existing Issue against it before `/breakdown` runs. You read the body anytime you triage, estimate, or pick up an Issue.

## Companion template

The companion file `templates/ISSUE_TEMPLATE.md` mirrors the body structure and can be:

- copied into `.github/ISSUE_TEMPLATE/` so GitHub's "New Issue" UI offers it as a chooser entry, **or**
- pasted manually into a fresh Issue body in the GitHub web UI.

The canonical language is English. Multi-language variants are out of scope.

## See also

- The size limit on a body in this format: [`issue-size`](/policies/issue-size/).
- Canonical contract: [`skills/soloscrum-define-issue-format/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-issue-format/SKILL.md).

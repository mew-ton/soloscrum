---
title: Issue format
description: The required Issue title and body shape (Background / Goal / Acceptance Criteria / Out of Scope) and the companion ISSUE_TEMPLATE file.
sidebar:
  order: 1
---

Every soloscrum Issue uses the same four-section body shape: Background, Goal, Acceptance Criteria, Out of Scope. `/refine` writes this shape; `/validate` and `/breakdown` rely on it being predictable.

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

- Starts with a verb
- 50 characters or fewer
- Describes the What, not the How

AC rules:

- Each item is independently verifiable
- Phrased in user-facing terms (`user can …`, `… is displayed`) — not implementation terms (`Issue JWT token`, `Implement validation`)

A leading `<!-- soloscrum-issue-format -->` HTML comment plus a small italic footer mark the body as soloscrum-formatted, so the janitor and `/validate` can detect it cheaply.

## When this applies

- `/refine` writes Issues in this shape.
- `/validate` checks an existing Issue against the shape before `/breakdown` runs.
- You read the body any time you triage, estimate, or pick up an Issue.

## Companion template

`templates/ISSUE_TEMPLATE.md` mirrors the body structure. Use it in one of two ways:

- Copy it into `.github/ISSUE_TEMPLATE/` so GitHub's "New Issue" UI offers it as a chooser entry.
- Paste it manually into a fresh Issue body in the GitHub web UI.

The canonical language is English. Multi-language variants are out of scope.

## See also

- Size limit on a body in this format: [`issue-size`](/policies/issue-size/).
- Canonical contract: [`skills/soloscrum-define-issue-format/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-issue-format/SKILL.md).

---
title: define-issue-format
description: Spec summary — required Issue title and body shape (Background / Goal / Acceptance Criteria / Out of Scope) plus the companion ISSUE_TEMPLATE file.
sidebar:
  order: 6
---

`soloscrum-define-issue-format` is the structural contract every soloscrum Issue follows. `/refine` produces Issues in this shape; `/validate` and `/breakdown` rely on the shape being predictable.

## What it does

It pins:

- Title rules: starts with a verb, 50 characters or fewer, describes the What rather than the How.
- Body sections, in order: `## Background`, `## Goal`, `## Acceptance Criteria` (checkboxes), `## Out of Scope`, optional `## Notes`.
- AC writing rules — verifiable, user-facing phrasing ("user can …" / "… is displayed"), not implementation phrasing ("Issue JWT token" / "Implement validation").
- A self-marker for soloscrum-format Issues: a leading `<!-- soloscrum-issue-format -->` HTML comment plus a small italic footer at the bottom.

## When it is consumed

`soloscrum-create-issue` (`/refine`) produces Issue bodies directly from this spec. `soloscrum-validate-feature` (`/validate`) checks the produced Issue against the same shape. The companion `templates/ISSUE_TEMPLATE.md` lives next to the skill for human use through the GitHub UI — it is **not** read by `/refine` itself; the two surfaces are kept in sync manually.

## Key inputs and outputs

Input to `/refine` is a free-form idea. Output is a GitHub Issue body following the structure above:

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

## Companion template

The companion file `templates/ISSUE_TEMPLATE.md` mirrors the body structure and can be:

- copied into `.github/ISSUE_TEMPLATE/` so GitHub's "New Issue" UI offers it as a chooser entry, **or**
- pasted manually into a fresh Issue body in the GitHub web UI.

The canonical language is English. Multi-language variants are out of scope.

## See also

- Canonical contract: [`skills/soloscrum-define-issue-format/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-issue-format/SKILL.md).
- The size gate that decides whether an Issue in this format needs splitting lives in [`define-issue-size`](/reference/define-issue-size/).

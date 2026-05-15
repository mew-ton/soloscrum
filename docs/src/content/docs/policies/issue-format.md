---
title: Issue format
description: A soloscrum Issue is the durable record of intent. Parent Issues use a four-section body; Subtasks use a lighter work body. A two-condition discriminator decides which one a candidate becomes.
sidebar:
  order: 1
---

A soloscrum Issue is the durable record of **intent** — what to achieve and the conditions under which it is considered done. It is referenced from PRs, commits, and later decisions; it is not a container for execution steps, progress, or evidence. Those live in PRs, commits, branches, CI runs, and tracker labels.

The "no How" rule on titles and the "outcome, not implementation" rule on AC both follow from this — they are not stylistic choices.

## Issue vs Subtask

Two layers exist. A parent **Issue** carries intent (the why, the success condition, the scope boundary). A **Subtask** carries a slice of work that delivers part of that intent. They use different body formats.

A candidate is its own Issue when **both** hold:

1. **Self-contained, independently checkable outcome.** Its "done" can be evaluated on its own terms — either user-facing behavior or a structural / contract / capability milestone (e.g. "the auth module exposes this contract and its tests pass," "a signed build artefact is produced").
2. **Not merely a delivery slice of an existing intent.** No larger intent — already filed or currently being refined — already owns the "why" that the candidate just slices.

If either fails → the candidate is a Subtask of the parent intent.

The boundary is **relational**, not fixed. The same piece of work can be an Issue in one context (pre-release foundational work with no parent intent yet) and a Subtask in another (post-release, where it slices a user-facing feature). Release state, project maturity, and the surrounding intent landscape all shift what passes condition 2.

## The four sections (Issue body)

A parent Issue body is always written in this order:

```markdown
## Background
[Why this feature is needed.]

## Goal
[State the objective in 1-2 sentences.]

## Acceptance Criteria
- [ ] [Verifiable outcome — Shape A or Shape B; see below.]

## Out of Scope
- [Explicitly state what is excluded. Write "None" if nothing.]

## Notes
[Supplementary info, references, design links.]
```

Title rules:

- Starts with a verb
- 50 characters or fewer
- Describes the What, not the How

The same title rules apply to Subtasks — still verb-first, still What not How.

AC takes one of two shapes, picked per Issue:

- **Shape A — user-facing behavior.** `user can log in with email`, `error message is shown on invalid input`. Use for product features and observable changes.
- **Shape B — structural / contract / capability.** `auth module exposes verify(token) returning {valid, expiry}`, `build pipeline produces a signed release artefact`. Use for foundational, infrastructure, or pre-release work where no user surface exists yet, or where the outcome is best expressed as a contract.

Both shapes describe a verifiable state, not a procedure. Mixing both within one Issue is allowed when the Issue legitimately spans both surfaces.

A leading `<!-- soloscrum-issue-format -->` HTML comment plus a small italic footer mark the body as soloscrum-formatted, so the janitor and `/validate` can detect it cheaply.

## Subtask body (work)

Subtasks do not carry their own Background / Goal / Acceptance Criteria / Out of Scope — those belong to the parent. A Subtask body is intentionally light:

```markdown
Parent: #<parent-issue-number>

## What
[One sentence describing the slice — what part of the parent's intent this delivers.]

## Checklist
- [ ] [Concrete step toward the slice]
- [ ] [Another step]

## Notes
[Optional: design points, dependencies on other Subtasks, references.]
```

A Subtask's done condition is "the parent's intent moves closer to being satisfied because this slice landed, without regressions." The intent-level AC sign-off itself happens at the parent Issue when the last Subtask's PR merges.

## When this applies

- `/refine` writes parent Issues in the intent body shape.
- `/breakdown` produces Subtasks in the lighter work body shape.
- `/validate` checks an existing Issue against the intent body before `/breakdown` runs.
- You read the body any time you triage, estimate, or pick up an Issue or Subtask.

## Companion template

`templates/ISSUE_TEMPLATE.md` mirrors the four-section **intent body**. Subtasks do not use the template — they are created via `/breakdown`. Use the template in one of two ways:

- Copy it into `.github/ISSUE_TEMPLATE/` so GitHub's "New Issue" UI offers it as a chooser entry.
- Paste it manually into a fresh Issue body in the GitHub web UI.

The canonical language is English. Multi-language variants are out of scope.

## See also

- Size limit on a body in this format: [`issue-size`](/policies/issue-size/).
- Canonical contract: [`skills/soloscrum-define-issue-format/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-issue-format/SKILL.md).

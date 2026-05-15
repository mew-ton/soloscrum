---
name: soloscrum-define-issue-format
description: "Reference: Issue and Subtask format. An Issue records intent (Background / Goal / Acceptance Criteria / Out of Scope); a Subtask slices work (Parent / What / Checklist / Notes). Includes the Issue-vs-Subtask discriminator and the two AC shapes (user-facing / structural)."
user-invocable: false
---

# soloscrum-define-issue-format

Issue title and body format definition.

## Concept

A soloscrum **Issue is the durable record of intent** — what to achieve and the conditions under which it is considered done. It captures the *why*, the *success condition*, and the *scope boundary*, and is referenced from PRs, commits, and subsequent decisions that deliver against it.

The Issue is deliberately **not** a container for execution steps, progress state, or evidence. Those live in PRs, commits, branches, CI runs, and tracker labels. The Issue holds only the judgment those artefacts execute against.

This concept anchors the rules below — "no How" in titles and "outcome, not implementation" in AC are not stylistic preferences but direct consequences of Issue = intent.

Subtasks operate at a different layer (work, not intent) and use a different, lighter body format. See `## Subtask Body (work)` below.

### Issue vs Subtask: discriminator

When deciding whether a candidate work item is its own Issue or a Subtask under an existing intent, apply both conditions.

A candidate is an **Issue** (intent) when **both** hold:

1. **Self-contained, independently checkable outcome.** Its "done" can be evaluated on its own terms. The outcome may be a user-facing behavior **or** a structural / contract / capability milestone — e.g. "the auth module exposes this contract and its tests pass," "a signed build artefact is produced." Not every Issue's done condition has to be user-visible.
2. **Not merely a delivery slice of an existing intent.** No larger intent (existing or currently being refined) already owns the "why" that this candidate just slices. If such a parent intent exists and the candidate only makes sense as part of delivering it, the candidate is a **Subtask**, not a sibling Issue.

If either condition fails → the candidate is a Subtask of the parent intent.

**Tie-breaker for condition 2:** when a plausibly-parent open Issue already exists, default to **Subtask** unless that parent's "why" clearly does not subsume the candidate. The default biases toward smaller, intent-coherent units; promote to a sibling Issue only when the candidate carries its own independent "why."

The boundary is **relational, not a fixed property of the work**. The same piece of work can be an Issue in one context (e.g. pre-release foundational work with no parent intent yet) and a Subtask in another (post-release, where it slices a user-facing feature). Release state, project maturity, and the surrounding intent landscape all shift what passes condition 2.

## Title Conventions

- Start with a verb (e.g. "Add", "Fix", "Support", "Remove")
- 50 characters or fewer
- No technical details (write the What, not the How)

Good: `Allow users to reset their password`
Bad: `Implement password_reset endpoint with Auth0 and return JWT`

The same conventions apply to **Subtask** titles. A Subtask title describes what slice of the parent's intent it delivers — still verb-first, still What not How, still ≤ 50 characters.

## Body Structure (Issue / intent)

The four sections below are the **intent body** — the durable record described in the Concept section. Use this format for parent Issues created via `/refine` (or human-direct via the companion template). Subtasks use the lighter format under `## Subtask Body (work)` below.

```markdown
## Background
[Why this feature is needed. Describe the current problem or context.]

## Goal
[State the objective of this Issue in 1-2 sentences.]

## Acceptance Criteria
- [ ] [Verifiable outcome — Shape A (user-facing) or Shape B (structural). See AC Writing Guide.]
- [ ] [Describe outcome, not technical implementation]

## Out of Scope
- [Explicitly state what is excluded. Write "None" if nothing is excluded.]

## Notes
[Supplementary info, reference links, design mock links, etc. (optional)]
```

## AC Writing Guide

Acceptance Criteria describe the **outcome that holds when the Issue's intent is satisfied** — not the steps to make it true. Two shapes are allowed; pick whichever fits the Issue.

### Shape A — user-facing behavior

For product features and changes a user can observe.

| Good | Bad |
|---|---|
| User can log in with email address | Issue JWT token |
| Error message is shown on invalid input | Implement validation |
| Dashboard is inaccessible after logout | Delete session |
| Login no longer crashes on empty input | Fix null pointer in login handler |

The last row covers an absence / no-regression outcome — Shape A handles "X no longer happens" by stating the user-observable post-condition, not the implementation step that achieves it.

### Shape B — structural / contract / capability

For foundational, infrastructure, or pre-release work where no user-facing surface exists yet, or where the Issue's outcome is best expressed as a contract or capability.

| Good | Bad |
|---|---|
| Auth module exposes `verify(token)` returning `{valid, expiry}` | Refactor auth module |
| Build pipeline produces a signed release artefact | Update build script |
| Migration `0042_user_schema` runs to completion on staging data | Write migration |
| Legacy `/v1/login` endpoint no longer registered (route returns 404) | Remove old login route |

The last row covers a removal / deprecation outcome — Shape B can describe the absence of a contract just as it describes its presence.

Both shapes describe a verifiable state, not a procedure. Mixing them within one Issue is allowed when the Issue legitimately spans both surfaces.

## Subtask Body (work)

Subtasks are **work slices** of a parent Issue's intent and do **not** carry their own Background / Goal / Acceptance Criteria / Out of Scope — those belong to the parent. A Subtask body is intentionally light:

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

A Subtask's done condition is concrete: the slice **lands an artefact the parent's AC verifiably depends on, or strictly advances the parent's AC checklist count, without regressions**. A pure spike or research Subtask whose output does not feed back into the parent's AC is not done at the parent's level even if its own PR lands cleanly — promote such work into its own Issue, or restate its outcome as an artefact the parent AC depends on.

The intent-level AC sign-off itself happens at the **parent Issue** when **all of its Subtasks are closed** — which is not necessarily the chronologically last Subtask PR, since dependency ordering can put logically-last work earlier. See `soloscrum-define-dod` (the "AC verification" section) and `commands/review.md` for how that split is enforced in review.

## Companion files

A copy-pastable template for the **intent body** lives next to this skill at `templates/ISSUE_TEMPLATE.md`. It mirrors the Body Structure above and carries a self-marker so soloscrum-format Issues are recognisable in mixed setups.

Subtasks do not use this template — they are created via `/breakdown` and follow the lighter Subtask Body (work) format defined above.

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

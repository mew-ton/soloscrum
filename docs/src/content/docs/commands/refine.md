---
title: /refine
description: Structures a free-form idea into a GitHub Issue, after a janitor sweep that closes any open Issues whose closing PR has already merged.
sidebar:
  order: 1
---

`/refine` is the front door. You hand it an idea — a sentence, a paragraph, a half-formed bug report — and it produces a GitHub Issue with the Background / Goal / Acceptance Criteria / Out of Scope shape every other command in soloscrum reads against. Before it does that, it sweeps the backlog for stale-open Issues whose closing PR has already merged.

## Usage

```bash
/refine <idea or feature description> [--no-janitor]
```

The argument is free text. Pass `--no-janitor` to skip the backlog sweep — useful when the GitHub API is flaky or when you simply do not want the start-of-command output cluttered.

## What happens

1. **Backlog janitor.** `/refine` scans open Issues; for each one it looks for a referencing PR with a closing keyword (`Closes #N`, `Fixes #N`, `Resolves #N`, etc.) that has already merged. Any Issue with such a PR is closed with reason `completed`. The output's first line is either `Closed N stale Issue(s): #X, #Y` or `No stale Issues found` (or `Janitor skipped` when `--no-janitor` was passed). The janitor only ever closes — it never reopens.
2. **Idea structuring.** The PO agent reads your idea, extracts the four-section Issue body, picks a [priority](/policies/priority/) label, and computes a size-check [SP](/policies/story-points/).
3. **Size gate.** If the size-check SP exceeds 5, `/refine` flags the Issue as oversized and suggests splitting it before you create it. See [issue size](/policies/issue-size/) for the thresholds.
4. **Confirmation.** The structured Issue body is shown to you for approval.
5. **Issue creation.** On approval, the GitHub Issue is created with the priority label applied at creation time.

## Typical flow

A typical session starts with an idea like *"users should be able to reset their password by email"*. You run `/refine "users should be able to reset their password by email"`. The first line of output is the janitor result — usually `No stale Issues found` on a clean repo. Then the PO agent presents a structured Issue body: a Background paragraph explaining the user need, a single-sentence Goal, three-to-five AC checkboxes, and an explicit Out of Scope listing what this Issue intentionally does not cover. It also surfaces a priority (`high` for a feature users will hit on day one) and a size-check SP.

If the SP is at or below 5, you confirm and the Issue is created. If the SP comes back at 8 because the change spans authentication, email infrastructure, and the password form UI, the command tells you the Issue is too big and suggests splitting along feature axes — at which point you re-run `/refine` on each smaller piece, or you go to `/breakdown` to slice it into subtasks if a single Issue scope still makes sense.

`/refine` is also the natural place to start any session, even when you are not adding a new Issue — the janitor sweep keeps the backlog accurate so the next thing you pick is not already-shipped work disguised as open.

## Output

- Janitor summary on the first line.
- Created GitHub Issue URL.
- Priority label applied.
- Size-check SP (informational; not registered to any tracker storage — the registered SP belongs to the subtasks `/breakdown` writes).

## See also

- [Agents and responsibilities](/concept/agent-responsibilities/) — `/refine` is owned by the PO agent.
- [Issue format](/policies/issue-format/) — the Background / Goal / AC / Out of Scope shape `/refine` produces.
- [Issue size](/policies/issue-size/) — the thresholds that trigger `suggest_split`.
- Next in the lifecycle: [`/breakdown`](/commands/breakdown/).
- Canonical contract: [`commands/refine.md`](https://github.com/mew-ton/soloscrum/blob/main/commands/refine.md).

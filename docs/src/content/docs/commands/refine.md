---
title: "/soloscrum:refine"
description: Structures a free-form idea into a GitHub Issue, after a janitor sweep closes any open Issues whose closing PR has already merged.
sidebar:
  order: 1
---

`/soloscrum:refine` turns an idea — a sentence, a paragraph, a half-formed bug report — into a GitHub Issue with the Background / Goal / Acceptance Criteria / Out of Scope shape every other command reads against. Before structuring the idea, `/soloscrum:refine` sweeps the backlog for stale-open Issues whose closing PR has already merged.

## Usage

```bash
/soloscrum:refine <idea or feature description> [--no-janitor]
```

The argument is free text. Pass `--no-janitor` to skip the backlog sweep — useful when the GitHub API is flaky or when you want quieter start-of-command output.

## What happens

1. **Backlog janitor.** `/soloscrum:refine` scans open Issues with three detection paths. **For parent Issues** (those with linked Sub-issues): if every Sub-issue is closed, the parent is closed. The per-Subtask PRs deliberately do not reference the parent via `Closes #` (see [branch-commit](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-branch-commit/SKILL.md)'s parent-close section), so the janitor is the only close path for parents. **For standalone Issues** (no Sub-issues): if a referencing PR with a closing keyword (`Closes #N`, `Fixes #N`, `Resolves #N`, etc.) has already merged, the Issue is closed — the safety-net case for when GH's auto-close didn't fire. **For split sources**: an Issue whose AC was migrated out by an [Issue split](/policies/issue-size/) has no closing PR and never will, so the janitor reports it as a *husk candidate* — see below. The first line of output is `Closed N stale Issue(s): #X, #Y`, `No stale Issues found`, or `Janitor skipped` (with `--no-janitor`). The janitor only closes; it never reopens.
2. **Husk report.** A husk is a split source left in neither terminal state — not closed, and not reduced to its residual AC. The janitor reports one only when all of these hold: at least one Issue declares `Split from: #<this>`, the body has no unchecked AC left, and no comment other than the `Split into: #…` announcement survives on it. Comment-borne residue counts even when it predates the split, so an Issue whose AC migrated but whose comments still hold unaddressed findings is reported as `has residue — not a husk` rather than as a close candidate. **The janitor never closes a husk** — whether the intent fully migrated is your call, so it prints the `gh issue close <n> --reason completed` command and stops there.
3. **Idea structuring.** The PO agent reads your idea, extracts the four-section Issue body, picks a [priority](/policies/priority/) label, and computes a size-check [SP](/policies/story-points/).
4. **Size gate.** If the size-check SP exceeds 5 (or a planned `/soloscrum:breakdown` would produce more than 5 Subtasks), `/soloscrum:refine` flags the Issue as a *mis-scope smell* — the Issue likely bundles multiple intents — and proposes splitting into separate Issues before creating it. This is distinct from `/soloscrum:breakdown`'s delivery slicing, which fires later when one coherent intent's PR would be unreviewable. See [issue size](/policies/issue-size/).
5. **Confirmation.** The structured Issue body is shown to you for approval.
6. **Issue creation.** On approval, the GitHub Issue is created with the priority label applied.

## Typical flow

You run `/soloscrum:refine "users should be able to reset their password by email"`. The first line of output is the janitor result — usually `No stale Issues found` on a clean repo. The PO agent then presents a structured Issue body: a Background paragraph explaining the user need, a single-sentence Goal, three-to-five AC checkboxes, and an explicit Out of Scope. It surfaces a priority (`high` for a feature users hit on day one) and a size-check SP.

If the SP is 5 or below, you confirm and the Issue is created. If the SP comes back at 8 because the change actually combines authentication, email infrastructure, and the form UI as separate features (each with its own user-facing done), the command flags the Issue as bundling multiple intents and suggests splitting along feature axes — you re-run `/soloscrum:refine` on each smaller piece. If instead the change is one coherent intent (e.g. *"password reset"*) but its delivery would not fit one reviewable PR, the size gate falls through here and `/soloscrum:breakdown` slices the delivery into Subtasks at the next step.

`/soloscrum:refine` is also the natural place to start any session, even when you are not adding a new Issue. The janitor sweep keeps the backlog accurate.

## Output

- Janitor summary on the first line.
- Husk report on the second line — `Husk candidates: #X (report-only)` or `No husk candidates`, each candidate followed by the `gh issue close` command to run yourself.
- Created GitHub Issue URL.
- Priority label applied.
- Size-check SP (informational, not registered to tracker storage — the registered SP belongs to the subtasks `/soloscrum:breakdown` writes).

## See also

- [Agents and responsibilities](/concept/agent-responsibilities/) — `/soloscrum:refine` is owned by the PO agent.
- [Issue format](/policies/issue-format/) — the body shape `/soloscrum:refine` produces.
- [Issue size](/policies/issue-size/) — the thresholds that trigger `suggest_split`.
- Next in the lifecycle: [`/soloscrum:breakdown`](/commands/breakdown/).
- Canonical contract: [`commands/refine.md`](https://github.com/mew-ton/soloscrum/blob/main/commands/refine.md).

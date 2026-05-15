---
title: Agents and responsibilities
description: The five soloscrum agents (PO, Design, Dev, UI, Review), what each one creates and mutates, and how the lifecycle hands off.
sidebar:
  order: 2
---

soloscrum splits feature work across five roles, each handled by a Claude Code agent. Every concept on the board — Issues, subtasks, PRs, and verdicts — has exactly one creator role and one mutator role. This prevents two agents from filing the same subtask in parallel, or one agent from closing an Issue another agent owns.

The authoritative ownership matrix lives in [`skills/soloscrum-define-agent-responsibilities/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-agent-responsibilities/SKILL.md).

## The five agents

### `soloscrum-po` — Product Owner

PO is the entry point. It runs during `/refine` and converts a free-form idea into a structured GitHub Issue: verb-led title, Background, Goal, Acceptance Criteria, Out of Scope. PO also assigns Issue-level priority and the size-check SP — the rough estimate that decides whether the Issue enters the lifecycle or needs splitting first.

PO is the only role that mutates the parent Issue's metadata after creation. PO also runs the `/refine` janitor sweep that closes parent Issues GitHub did not auto-close because the closing PR referenced sub-issues instead of the parent.

### `soloscrum-design` — Designer

Design runs during `/validate` and the planning stage of `/breakdown`. It converts a validated Issue into an implementable plan: scope, dependencies, technical feasibility, and a list of subtasks with type and Checklist / slice scope ready for registration. (Subtasks do not carry their own AC — the parent Issue owns the AC and the Subtask slices its delivery; see [issue format](/policies/issue-format/).)

Design does **not** create subtask records on the tracker — that step belongs to Dev. This keeps the design pass as an idempotent thinking step, with tracker writes batched at the end.

### `soloscrum-dev` — Developer

Dev owns implementation. It runs in two places:

- **`/breakdown` registration stage** — writes the subtasks Design proposed to the tracker (SP, type label, parent link).
- **`/develop`** — cuts a branch, writes code, commits with Conventional Commits, opens a draft PR.

Dev also transitions a subtask from idle to `in-progress`, and from `in-progress` to `in-review` once the draft PR is open.

### `soloscrum-ui` — UI Designer

UI is the design-ui counterpart of Dev. It runs during `/design-ui` and produces Figma artifacts — components, design tokens, state variants, accessibility checks — for subtasks tagged `type:design-ui`. Like Dev, UI transitions its own subtask to `in-review` when the Figma file is ready.

UI features split into a `design-ui` subtask and a follow-up `develop` subtask. The `develop` work waits until the design subtask is reviewed.

### `soloscrum-review` — Reviewer

Review is the only role allowed to mark something done. It runs during `/review`: verifies DoD and AC, runs the CodeRabbit + multi-agent review pipeline, decides each finding, and posts the verdict comment. On Pass, Review transitions the subtask to `done`, waits for CI green, and promotes the PR from draft to ready. `gh pr merge` is always the user's gate — the agent stops at "here is the merge command."

Review is also the verifier for every other concept on the board. Any flip to a terminal status is Review's call.

## Lifecycle at a glance

```text
/refine        po       → Issue (size-check SP, priority, AC, dependencies)
/validate      design   → reads Issue, asks for refinement if invalid
/breakdown     design   → proposes subtasks (type, Checklist / slice scope — Subtasks have no AC)
               dev      → registers subtasks (SP, type label)
/develop       dev      → branch + code + draft PR; subtask → in-review
/design-ui     ui       → Figma + tokens + states; subtask → in-review
/review        review   → DoD + AC + code; promote PR to ready;
                          subtask → done; surface merge command to user
user           user     → runs `gh pr merge` (irreversible, user-gated)
/refine        po       → janitor closes any parent Issues GH missed
```

## Three rules tie this together

1. **Single creator per concept.** Two roles never create the same kind of record. PO creates Issues. Dev creates subtask records. Dev or UI creates the PR / Figma artifact. There is no path where two agents file duplicate subtasks for the same AC.
2. **State transitions are role-gated.** Only Review may transition any record to a terminal state. Dev and UI can move their own subtask to `in-review`, but only Review can move it to `done`.
3. **Review is the verifier** for every record state. Entry-gate SP is decided by PO; type labels are set by Dev or UI.

## See also

- Full ownership matrix: [`skills/soloscrum-define-agent-responsibilities/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-agent-responsibilities/SKILL.md).
- How PR transitions split between reversible (agent runs them) and irreversible (user gates them): [PR lifecycle](/concept/pr-lifecycle/).

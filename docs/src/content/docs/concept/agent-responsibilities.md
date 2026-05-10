---
title: Agents and responsibilities
description: The five soloscrum agents (PO, Design, Dev, UI, Review), what each one creates and mutates, and how the lifecycle hands off between them.
sidebar:
  order: 2
---

soloscrum splits the work of a single feature across five roles, each backed by a Claude Code agent. The split is deliberate: every concept on the board (an Issue, a subtask, a PR, a verdict) has exactly one creator and one role allowed to mutate it during the lifecycle. That single-creator rule is what stops two agents from racing to file the same subtask, or one agent from quietly closing an Issue another agent owned.

This page is the human introduction to each agent. The authoritative ownership matrix lives in [`skills/soloscrum-define-agent-responsibilities/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-agent-responsibilities/SKILL.md).

## The five agents

### `soloscrum-po` — Product Owner

The PO is the entry point. It runs during `/refine` and turns a free-form idea into a structured GitHub Issue: title that starts with a verb, Background, Goal, Acceptance Criteria, and an explicit Out of Scope. It is also the role that assigns Issue-level priority and the size-check SP — the rough estimate used to decide whether the Issue is small enough to enter the lifecycle, or whether it needs to be split first.

The PO is the only role that mutates the parent Issue's metadata once it exists, and it is also the role that runs the `/refine` janitor sweep — the cleanup pass that closes parent Issues GitHub did not auto-close because the closing PR referenced sub-issues instead of the parent.

### `soloscrum-design` — Designer

The Design agent runs during `/validate` and the planning stage of `/breakdown`. Its job is to turn a validated Issue into an implementable plan: it confirms scope, dependencies, and technical feasibility, and it proposes a list of subtasks with type and AC ready for registration. It does **not** create the subtask records on the tracker — that step belongs to Dev.

This separation between "designed the breakdown" and "registered the subtasks" is what lets the framework treat the design pass as an idempotent thinking step, with the tracker writes staying batched at the end.

### `soloscrum-dev` — Developer

Dev owns the actual implementation. It runs in two places: the registration stage of `/breakdown`, where it writes the subtasks Design proposed onto the tracker (with SP, type label, and parent link), and `/develop`, where it cuts a branch, writes code, commits with Conventional Commits, and opens a draft PR.

Dev is also the role that transitions a subtask from idle to `in-progress`, and from `in-progress` to `in-review` once the draft PR is open.

### `soloscrum-ui` — UI Designer

The UI agent is the design-ui counterpart of Dev. It runs during `/design-ui` and produces Figma artifacts — components, design tokens, state variants, accessibility checks — for subtasks tagged `type:design-ui`. Like Dev, it is the role that transitions its own subtask to `in-review` when the Figma file is ready.

UI features are split into a `design-ui` subtask and a follow-up `develop` subtask; the `develop` work waits until the design subtask is reviewed.

### `soloscrum-review` — Reviewer

Review is the only role allowed to mark something done. It runs during `/review`: it verifies DoD and AC, runs the CodeRabbit + multi-agent review pipeline, decides each finding individually, and posts the verdict comment. On Pass, it transitions the subtask to `done`, waits for CI to go green, and promotes the PR from draft to ready. The actual `gh pr merge` is always the user's gate — the agent stops at "here is the merge command."

Review is also the verifier for every other concept on the board. If a piece of state needs to flip to a terminal status, Review is the role that flips it.

## Lifecycle at a glance

```text
/refine        po       → Issue (size-check SP, priority, AC, dependencies)
/validate      design   → reads Issue, asks for refinement if invalid
/breakdown     design   → proposes subtasks (type, AC)
               dev      → registers subtasks (SP, type label)
/develop       dev      → branch + code + draft PR; subtask → in-review
/design-ui     ui       → Figma + tokens + states; subtask → in-review
/review        review   → DoD + AC + code; promote PR to ready;
                          subtask → done; surface merge command to user
user           user     → runs `gh pr merge` (irreversible, user-gated)
/refine        po       → janitor closes any parent Issues GH missed
```

## The single-creator rule

Three rules tie this together and are worth keeping in mind when reading any soloscrum command:

1. **Single creator per concept.** Two roles never create the same kind of record. The PO creates Issues; Dev creates subtask records; Dev or UI creates the PR / Figma artifact. There is no path where two agents file duplicate subtasks for the same AC.
2. **State transitions are role-gated.** Only Review may transition any record to a terminal state. Dev and UI can move their own subtask to `in-review`, but only Review can move it to `done`.
3. **The verifier is always Review** — except for the entry-gate SP (PO) and the type label (Dev / UI), which are decisions, not verifications.

## See also

- For the full ownership matrix, see [`skills/soloscrum-define-agent-responsibilities/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-agent-responsibilities/SKILL.md).
- For a quick spec summary, see the [agent responsibilities reference](/reference/define-agent-responsibilities/).
- For how PR transitions split between reversible (agent runs them) and irreversible (user gates them), see the [PR lifecycle concept](/concept/pr-lifecycle/).

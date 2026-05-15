---
title: /breakdown
description: Slices a large but coherent Issue's delivery into reviewable Subtasks. Subtasks slice work, not intent — they do not carry their own AC. Fires when one PR would be unreviewable.
sidebar:
  order: 2
---

`/breakdown` slices an Issue whose intent is coherent but whose delivery would not fit in a single reviewable PR. Each Subtask is one reviewable slice of the parent's delivery: typed (`develop` or `design-ui`), sized for one PR, but carrying no Acceptance Criteria of its own — the parent owns those.

If the size-check SP, the subtask count, or any other signal in [`issue-size`](/policies/issue-size/) instead indicates *multiple intents are bundled*, return to [`/refine`](/commands/refine/) for Issue split.

## Usage

```bash
/breakdown <issue-url or issue-number>
```

The argument is the parent Issue. URL form (`https://github.com/<owner>/<repo>/issues/<n>`) and bare number (`#48` or `48`) both work.

## What happens

1. **Verify `/breakdown` is the right command.** Per [`issue-size`](/policies/issue-size/), `/breakdown` fires only when delivering the Issue's intent as a single PR would be unreviewable. If the diagnosis is "multiple intents bundled" instead, the Design agent routes back to `/refine`.
2. **Read the Issue.** Design reads the parent's Background, Goal, AC, and Out of Scope.
3. **Plan the delivery slicing.** Design proposes a list of Subtasks — each is one reviewable PR worth of work. A Subtask has a title, type, a short "what part of the parent this slice delivers" description, an optional checklist of concrete steps, and any cross-Subtask dependencies. Subtasks do **not** carry their own Background / Goal / AC / Out of Scope — see [`issue-format`](/policies/issue-format/)'s Subtask body section.
4. **Validate.** Design re-runs the size check on the proposed split. If subtask count exceeds 5, treat as a mis-scope smell — the Issue likely bundles multiple intents — and route back to `/refine`.
5. **Confirmation.** The breakdown proposal is shown to you for approval before any tracker writes.
6. **Registration.** On approval, the Dev agent writes each Subtask via `soloscrum-tracker-{github|linear}-create-subtask`. SP is applied per-Subtask using the [story-points](/policies/story-points/) scale. Cross-Subtask dependencies are added via `soloscrum-tracker-{github|linear}-add-dependency`.

## Typical flow

You filed *"add password reset flow"* during `/refine`, and `/refine` reported size-check SP 5 — one coherent intent (let users reset their password), but the delivery touches multiple subsystems and would not fit one reviewable PR. You run `/breakdown 48`. Design returns a four-Subtask proposal — these are delivery slices, not sub-intents:

- A `design-ui` Subtask for the password reset form mockup.
- A `develop` Subtask for the email-sending backend.
- A `develop` Subtask for the form integration.
- A `develop` Subtask for rate-limit / abuse protection.

The form-integration Subtask depends on the `design-ui` one. None of them carries its own AC — the parent's AC (*"user can reset their password via email"*) is what all four together satisfy.

You approve. Dev writes the four Subtasks under the parent — GH Sub-issues under `github-only`, Linear subtasks under `linear+github`. Each carries its SP, type label, and parent link. The form-integration → design-ui dependency is recorded: a `Depends on: #N` line under `github-only`, a Linear "Blocked by" relation under `linear+github`.

When the work fits cleanly into a single PR, skip `/breakdown` — go straight from `/refine` to `/develop`.

## Output

- The proposed Subtask list (title, type, SP, dependencies) — shown for approval.
- After approval: created Subtask IDs (`#N` under `github-only`, `PRJ-N` under `linear+github`).
- Each Subtask carries the type label (`type:develop` / `type:design-ui`) and the parent-child link.

## See also

- [Agents and responsibilities](/concept/agent-responsibilities/) — Design proposes the breakdown, Dev registers it.
- [Issue size](/policies/issue-size/) — when an Issue is too big and `suggest_split` fires, vs when it merely needs `/breakdown`.
- [Issue format](/policies/issue-format/) — Subtask body contract (no AC).
- [Story points](/policies/story-points/) — the SP scale applied per-Subtask.
- [Tracker profile](/concept/tracker-profile/) — where Subtask records live.
- Previous: [`/refine`](/commands/refine/). Next: [`/develop`](/commands/develop/).
- Canonical contract: [`commands/breakdown.md`](https://github.com/mew-ton/soloscrum/blob/main/commands/breakdown.md).

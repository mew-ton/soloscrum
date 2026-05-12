---
title: /breakdown
description: Splits an Issue that exceeds the size threshold into Subtasks with type and SP, then registers them on the active tracker.
sidebar:
  order: 2
---

`/breakdown` splits an Issue that is too big for a single PR — either because its size-check SP exceeded 5, or because the work spans multiple subsystems — into a list of Subtasks. Each Subtask is typed (`develop` or `design-ui`) and sized so a single PR can satisfy it. The Subtasks are then written to the active tracker.

## Usage

```bash
/breakdown <issue-url or issue-number>
```

The argument is the parent Issue. URL form (`https://github.com/<owner>/<repo>/issues/<n>`) and bare number (`#48` or `48`) both work.

## What happens

1. **Read the Issue.** The Design agent reads the parent Issue's Background, Goal, AC, and Out of Scope.
2. **Plan the decomposition.** Design proposes a list of Subtasks: title, type (`develop` for code, `design-ui` for Figma work), AC for each, and any cross-Subtask blocking relations (e.g. *Subtask B depends on Subtask A*).
3. **Validate.** Design re-runs the size check on the proposed split. If any Subtask is still too big, or the breakdown would exceed five Subtasks, the split test fires again and the proposal comes back refined.
4. **Confirmation.** The breakdown proposal is shown to you for approval before any tracker writes.
5. **Registration.** On approval, the Dev agent writes each Subtask via `soloscrum-tracker-{github|linear}-create-subtask`. SP is applied per-Subtask after reading its AC, using the [story-points](/policies/story-points/) scale. Cross-Subtask dependencies are added via `soloscrum-tracker-{github|linear}-add-dependency`.

## Typical flow

You filed *"add password reset flow"* during `/refine`, and `/refine` reported size-check SP 8 — too big. You re-run with `/breakdown 48` against the parent Issue. Design returns a four-Subtask proposal:

- A `design-ui` subtask for the password reset form mockup.
- A `develop` subtask for the email-sending backend.
- A `develop` subtask for the form integration.
- A `develop` subtask for rate-limit / abuse protection.

The two `develop` subtasks that touch the form depend on the `design-ui` one being reviewed first.

You approve. Dev writes the four Subtasks under the parent — GH Sub-issues under `github-only`, Linear subtasks under `linear+github`. Each carries its own SP, type label, AC, and parent link. The form-integration → design-ui dependency is recorded: a `Depends on: #N` line under `github-only`, a Linear "Blocked by" relation under `linear+github`.

When the breakdown produces only one Subtask whose work fits cleanly into a single PR, skip `/breakdown` — go straight from `/refine` to `/develop`. The split exists so the PR-and-review unit stays small enough to verdict cleanly.

## Output

- The proposed Subtask list (title, type, SP, dependencies) — shown for approval.
- After approval: created Subtask IDs (`#N` under `github-only`, `PRJ-N` under `linear+github`).
- Each Subtask carries the type label (`type:develop` / `type:design-ui`) and the parent-child link.

## See also

- [Agents and responsibilities](/concept/agent-responsibilities/) — Design proposes the breakdown, Dev registers it.
- [Issue size](/policies/issue-size/) — when an Issue is too big and `suggest_split` fires.
- [Story points](/policies/story-points/) — the SP scale applied per-Subtask.
- [Tracker profile](/concept/tracker-profile/) — where Subtask records live.
- Previous: [`/refine`](/commands/refine/). Next: [`/develop`](/commands/develop/).
- Canonical contract: [`commands/breakdown.md`](https://github.com/mew-ton/soloscrum/blob/main/commands/breakdown.md).

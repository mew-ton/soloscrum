---
title: /breakdown
description: Splits an Issue that exceeds the size threshold into Subtasks with type and SP, then registers them on the active tracker.
sidebar:
  order: 2
---

`/breakdown` is the second step. It takes an Issue that is too big to land in a single PR — either because its size-check SP exceeded 5 or because the work obviously spans multiple subsystems — and turns it into a list of Subtasks, each typed (`develop` or `design-ui`) and sized so a single PR can satisfy it. The Subtasks are then written to the active tracker.

## Usage

```bash
/breakdown <issue-url or issue-number>
```

The argument is the parent Issue. URL form (`https://github.com/<owner>/<repo>/issues/<n>`) and bare number (`#48` or `48`) both work.

## What happens

1. **Read the Issue.** The Design agent reads the parent Issue's Background, Goal, AC, and Out of Scope.
2. **Plan the decomposition.** Design proposes a list of Subtasks: title, type (`develop` for code, `design-ui` for Figma work), AC for each one, and any cross-Subtask blocking relations (e.g. *Subtask B depends on Subtask A*).
3. **Validate.** Design re-runs the size check on the proposed split — if any Subtask is still too big or the breakdown would exceed five Subtasks, the split test fires again and the proposal comes back with a refined slice.
4. **Confirmation.** The breakdown proposal is shown to you for approval before any tracker writes.
5. **Registration.** On approval, the Dev agent writes each Subtask to the tracker via `soloscrum-tracker-{github|linear}-create-subtask`. The subtask SP comes from the [story-points](/policies/story-points/) scale, applied per-Subtask after carefully reading its AC. Cross-Subtask dependencies are added via `soloscrum-tracker-{github|linear}-add-dependency`.

## Typical flow

You filed an Issue *"add password reset flow"* during `/refine`, and `/refine` told you the size-check SP is 8 — too big. You re-run with `/breakdown 48` against the parent Issue. Design comes back with a four-Subtask proposal: a `design-ui` subtask for the password reset form mockup, a `develop` subtask for the email-sending backend, a `develop` subtask for the form integration, and a `develop` subtask for the rate-limit / abuse protection. The two `develop` subtasks that touch the form depend on the `design-ui` one being reviewed first.

You approve. Dev writes the four Subtasks under the parent: GH Sub-issues (under `github-only`) or Linear subtasks (under `linear+github`). Each carries its own SP, type label, AC, and parent link. The dependency between the form-integration subtask and the design-ui subtask is recorded — under `github-only` as a `Depends on: #N` line in the body, under `linear+github` as a Linear "Blocked by" relation.

When the breakdown produces only one Subtask whose work fits cleanly into a single PR, `/breakdown` is unnecessary — you can go straight from `/refine` to `/develop`. The split exists so the PR-and-review unit stays small enough to verdict cleanly; running it on an already-PR-sized Issue is not a step the framework forces.

## Output

- The proposed Subtask list (title, type, SP, dependencies) — shown for approval.
- After approval: created Subtask IDs (`#N` under `github-only`, `PRJ-N` under `linear+github`).
- Each Subtask carries the type label (`type:develop` / `type:design-ui`) and the parent-child link.

## See also

- [Agents and responsibilities](/concept/agent-responsibilities/) — Design proposes the breakdown, Dev registers it.
- [Issue size](/policies/issue-size/) — when an Issue is too big and `suggest_split` fires.
- [Story points](/policies/story-points/) — the SP scale applied per-Subtask.
- [Tracker profile](/concept/tracker-profile/) — where Subtask records live.
- Previous in the lifecycle: [`/refine`](/commands/refine/). Next: [`/develop`](/commands/develop/).
- Canonical contract: [`commands/breakdown.md`](https://github.com/mew-ton/soloscrum/blob/main/commands/breakdown.md).

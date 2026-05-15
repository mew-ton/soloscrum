---
title: Issue size
description: Issue and Subtask split criteria operate on intent coherence, not raw work volume. SP > 5 and subtask count > 5 are mis-scope smells. /breakdown fires when one PR would be unreviewable.
sidebar:
  order: 4
---

soloscrum's split criteria operate on **intent coherence**, not raw work volume. The numeric thresholds below are signals that an Issue is *probably* bundling multiple intents — not hard limits on how much work a single intent may carry.

A large but coherent single intent is not split. Its delivery is sliced by `/breakdown` into multiple reviewable PRs (Subtasks).

## The thresholds

| Metric | Threshold | What it signals |
|---|---|---|
| SP | > 5 | The (scope × uncertainty) estimate is so high that the Issue likely holds more than one independent "why + done". Re-read the AC: are there multiple "what makes this satisfied" answers that do not share a unifying intent? |
| Subtask count | > 5 | If one intent needs more than ~5 reviewable PRs to deliver, it is probably multiple intents combined by mistake. Mis-scope smell — return to `/refine`. |
| Estimated days | > 2 | Coarse calibration only. Does not by itself force a split. |

If the answer to *"are these multiple intents?"* is no — this is one coherent intent that just happens to be large — the Issue stays. The work is then handled by `/breakdown` into Subtasks (delivery slices), not by Issue split.

## `/breakdown` trigger

`/breakdown` produces Subtasks when delivering one Issue's intent as a single PR would produce an unreviewable PR — a delivery / reviewability question.

- One PR is reviewable → no `/breakdown` needed; go directly to `/develop`. (`CLAUDE.md` states the same: *"Issues that fit within a single develop unit can skip this step"*; branch-per-Issue mode in the canonical [`soloscrum-define-branch-commit`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-branch-commit/SKILL.md).)
- One PR would not be reviewable → `/breakdown` produces Subtasks, each carrying a reviewable slice. Subtasks slice the *delivery*, not the intent — see [`issue-format`](/policies/issue-format/)'s Subtask body section.

## Split axes (Issue level)

When the diagnosis is *"multiple intents bundled"*, propose splitting along one of:

- **Feature axis** — MVP vs extensions, or distinct user-facing capabilities. Each yields its own intent (own why, own done).
- **Phase axis** — only when the phase has its own independent "done" (e.g. performance hardening with its own SLO that can be verified on its own terms). A phase with no done of its own is delivery work, not a separate intent — it belongs in `/breakdown`, not Issue split.

The historical **layer axis** (backend / frontend) is **not** an Issue split axis. Backend and frontend of one feature share one intent and one done; splitting along layer produces fragments whose AC (*"user can reset password"*) cannot be satisfied independently. Layer-axis splits are valid as `/breakdown` Subtask slices instead.

## Why days is calibration-only

`max_sp: 5` operates on the scope × uncertainty scale defined in [`story-points`](/policies/story-points/). The dominant driver of the threshold is the uncertainty axis (multiple unresolved decisions across multiple subsystems), which correlates strongly with *"are these actually multiple intents?"* Raw work volume on its own does not force an Issue split.

`max_estimated_days` is a coarse calibration check during `/refine`. If the rough wall-clock feel obviously exceeds two days of solo-dev cycle time (including user review), that is a signal the scope / uncertainty estimate is probably too low. Not the primary criterion.

## Exceptions

Large-scale refactoring and tech debt reduction are exempt from these thresholds; defer to user judgment. A refactor's intent is *"the codebase is in state X"* — a single coherent intent regardless of file or PR count.

## See also

- [`issue-format`](/policies/issue-format/) — the Issue-vs-Subtask discriminator the split criteria flow from.
- [`story-points`](/policies/story-points/) — the SP scale.
- Canonical contract: [`skills/soloscrum-define-issue-size/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-issue-size/SKILL.md).

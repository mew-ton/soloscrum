---
title: Story points
description: The two-level SP structure (Issue size-check, Subtask registered) and the scope × uncertainty SP scale.
sidebar:
  order: 3
---

`soloscrum-define-story-points` is the SP definition. SP is a **size class anchored on scope × uncertainty** — not a time unit.

## What it does

It pins:

- The two-level SP structure: Issue-level SP (an entry-gate size check that the PO does at `/refine`) and Subtask-level SP (the value Dev registers on the tracker during `/breakdown`).
- The SP scale and what the rows mean.
- How the value is registered per active tracker profile (GitHub Projects v2 `SP` Number field for `github-only`; Linear `estimate` field for `linear+github`).

## The two levels

**Issue SP** is a roughness check. The PO uses it during `/refine` to decide whether the Issue is small enough to enter the lifecycle, or whether [`issue-size`](/policies/issue-size/) needs to fire `suggest_split` first. It is **not** stored anywhere — it is a decision input, not a record.

**Subtask SP** is the actual recorded value. Dev calculates it during `/breakdown` from the subtask's AC and writes it to the tracker via `soloscrum-tracker-{github|linear}-set-sp`. This is the value used for backlog planning and progress tracking.

## The SP scale

| SP | Scope | Uncertainty | Calibration (observed, not the unit) |
|----|-------|-------------|---|
| 1  | 1 file / 1 concern | All decisions known | ~30K-100K tokens, agent ~5-10 min |
| 2  | 2-3 files / single skill area | 1 minor decision | ~100K-200K tokens, agent ~10-20 min |
| 3  | Single subsystem cross-cut | 1-2 design decisions | ~200K-500K tokens, agent ~20-45 min |
| 5  | Multi-subsystem cross-cut | Multiple design decisions | ~500K-1M tokens, agent ~45 min-2h |
| >5 | (over-budget) | (over-budget) | Do not assign — split per `define-issue-size` |

## Why scope × uncertainty, not time

Time anchors are intentionally not the unit. Model speed shifts release-to-release (today's "2 hours" becomes next month's "20 minutes"), agents run in parallel which warps wall-clock comparisons, and human time vs AI agent time do not map linearly. Pinning SP to a clock unit made the scale unstable. The Calibration column exists for sanity-checking, not as the input.

## Estimation procedure

For both levels:

1. Read AC / Goal to identify scope: how many subsystems / concerns are touched?
2. Identify uncertainty: how many open design decisions remain after AC? Is anything novel?
3. Map (scope, uncertainty) to the SP table. Both axes have to fit; pick the higher row when in doubt.
4. If the result exceeds 5, the Issue is over-budget — split per [`issue-size`](/policies/issue-size/) and re-estimate.

## See also

- Canonical contract: [`skills/soloscrum-define-story-points/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-story-points/SKILL.md).
- For where the SP value is stored per tracker profile, see the [tracker profiles concept](/concept/tracker-profile/).

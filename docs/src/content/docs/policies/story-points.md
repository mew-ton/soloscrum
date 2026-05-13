---
title: Story points
description: The two-level SP structure (Issue size-check and Subtask registered) and the scope x uncertainty SP scale.
sidebar:
  order: 3
---

Story points (SP) measure scope x uncertainty — not time. soloscrum uses a 1/2/3/5 scale. SP > 5 means the Issue must be split before `/develop` runs.

## The scale

| SP | Scope | Uncertainty | Calibration (observed, not the unit) |
|----|-------|-------------|---|
| 1  | 1 file / 1 concern | All decisions known | ~30K-100K tokens, agent ~5-10 min |
| 2  | 2-3 files / single skill area | 1 minor decision | ~100K-200K tokens, agent ~10-20 min |
| 3  | Single subsystem cross-cut | 1-2 design decisions | ~200K-500K tokens, agent ~20-45 min |
| 5  | Multi-subsystem cross-cut | Multiple design decisions | ~500K-1M tokens, agent ~45 min-2h |
| >5 | (over-budget) | (over-budget) | Do not assign — split per [`issue-size`](/policies/issue-size/) and re-estimate |

## The two levels

SP appears at two points in the lifecycle:

**Issue SP** is a size check. The PO uses it during `/refine` to decide whether the Issue is small enough to enter the lifecycle, or whether [`issue-size`](/policies/issue-size/) needs to fire `suggest_split` first. Issue SP is **not** stored — it is a decision input, not a record.

**Subtask SP** is the actual recorded value. Dev calculates it during `/breakdown` from the subtask's AC and writes it to the tracker via `soloscrum-tracker-{github|linear}-set-sp`. This value is used for backlog planning and progress tracking.

## Why scope x uncertainty, not time

Time anchors are deliberately excluded:

- Model speed shifts release-to-release. Today's "2 hours" becomes next month's "20 minutes".
- Agents run in parallel, which warps wall-clock comparisons.
- Human time and AI agent time do not map linearly.

Pinning SP to a clock unit made the scale unstable. The Calibration column exists for sanity-checking, not as input.

## Estimation procedure

For both levels:

1. Read AC / Goal to identify scope: how many subsystems / concerns are touched?
2. Identify uncertainty: how many open design decisions remain after AC? Is anything novel?
3. Map (scope, uncertainty) to the SP table. Both axes have to fit; pick the higher row when in doubt.
4. If the result exceeds 5, the Issue is over-budget — split per [`issue-size`](/policies/issue-size/) and re-estimate.

## See also

- Where the SP value is stored per tracker profile: [tracker profiles](/concept/tracker-profile/).
- Canonical contract: [`skills/soloscrum-define-story-points/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-story-points/SKILL.md).

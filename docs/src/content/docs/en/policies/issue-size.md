---
title: define-issue-size
description: Spec summary — Issue size thresholds (max SP 5, max 5 subtasks; days are a coarse calibration signal only) and the suggest_split action.
sidebar:
  order: 4
---

`soloscrum-define-issue-size` is the size gate. It exists because tasks can be decomposed indefinitely and the framework needs a concrete bar for "this Issue is too big to enter the lifecycle as one unit."

## What it does

It pins the thresholds and the action that fires when any are exceeded:

| Metric | Threshold | What it means |
|---|---|---|
| SP | > 5 | Estimate exceeds the SP scale's maximum row |
| Subtask count | > 5 | Breakdown would produce more than 5 subtasks |
| Estimated days | > 2 days | Coarse calibration signal only — does not by itself force a split |

When any threshold is exceeded, `/refine` triggers `suggest_split`: present split proposals (by feature axis, layer axis, or phase axis), confirm each split fits within thresholds, and obtain user approval before creating the new Issues.

## When it is consumed

- `soloscrum-create-issue` (`/refine`) checks the size gate at Issue creation time using the size-check SP from the PO.
- `soloscrum-split-into-tasks` (`/breakdown`) re-checks the gate when proposing subtasks — if the breakdown would exceed five subtasks, the split test fires again.

## Key inputs and outputs

Input is a candidate Issue and its size-check SP / subtask count. Output is either OK or a `suggest_split` action with concrete split proposals.

## Why days is calibration-only

`max_sp: 5` operates on the scope × uncertainty SP scale defined by [`story-points`](/policies/story-points/). The split test is therefore "can this Issue fit in one PR's scope and decision-set without compounding?" If a single PR would have to span multiple subsystems **and** carry multiple unresolved design decisions, the Issue is over-budget regardless of how fast a model could draft it.

`max_estimated_days` is retained as a coarse calibration check during `/refine`: if the rough wall-clock feel obviously exceeds two days of solo-dev cycle time (including user review), that is a signal the scope/uncertainty estimate is probably too low. It is not the primary criterion.

## Exceptions

Large-scale refactoring and tech debt reduction are exempt from these thresholds; defer to user judgment.

## See also

- Canonical contract: [`skills/soloscrum-define-issue-size/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-issue-size/SKILL.md).
- For the SP scale itself, see [`story-points`](/policies/story-points/).

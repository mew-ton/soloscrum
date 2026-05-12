---
title: Issue size
description: Issue size thresholds (max SP 5, max 5 subtasks; days are a calibration signal) and the suggest_split action.
sidebar:
  order: 4
---

An Issue is too big when SP > 5, or when `/breakdown` would produce more than 5 subtasks. Either threshold triggers `suggest_split`, and you decide how to slice the work.

## The thresholds

| Metric | Threshold | What it means |
|---|---|---|
| SP | > 5 | Estimate exceeds the SP scale's maximum row |
| Subtask count | > 5 | Breakdown would produce more than 5 subtasks |
| Estimated days | > 2 days | Calibration signal only — does not by itself force a split |

When any threshold is exceeded, `suggest_split` presents split proposals (by feature axis, layer axis, or phase axis), confirms each split fits within thresholds, and asks for approval before creating the new Issues.

## When this applies

- `/refine` checks the size gate when the Issue is first written, using the size-check SP from the PO.
- `/breakdown` re-checks the gate when proposing subtasks. If the breakdown would exceed five subtasks, the split test fires again.

## Why days is calibration-only

`max_sp: 5` operates on the scope x uncertainty scale defined in [`story-points`](/policies/story-points/). The split test asks: can this Issue fit in one PR's scope and decision set without compounding? If a single PR would span multiple subsystems **and** carry multiple unresolved design decisions, the Issue is too big regardless of how fast a model can draft it.

`max_estimated_days` is a coarse calibration check during `/refine`. If the rough wall-clock feel obviously exceeds two days of solo-dev cycle time (including user review), that is a signal the scope/uncertainty estimate is probably too low. It is not the primary criterion.

## Exceptions

Large-scale refactoring and tech debt reduction are exempt from these thresholds; defer to user judgment.

## See also

- The SP scale: [`story-points`](/policies/story-points/).
- Canonical contract: [`skills/soloscrum-define-issue-size/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-issue-size/SKILL.md).

---
title: Issue size
description: Issue size thresholds (max SP 5, max 5 subtasks; days are a coarse calibration signal only) and the suggest_split action.
sidebar:
  order: 4
---

An Issue is too big when SP > 5 OR when `/breakdown` produces > 5 subtasks. When either threshold trips, `/refine` or `/breakdown` calls `suggest_split`, and you decide how to slice the work.

## The thresholds

| Metric | Threshold | What it means |
|---|---|---|
| SP | > 5 | Estimate exceeds the SP scale's maximum row |
| Subtask count | > 5 | Breakdown would produce more than 5 subtasks |
| Estimated days | > 2 days | Coarse calibration signal only — does not by itself force a split |

When any threshold is exceeded, `suggest_split` presents split proposals (by feature axis, layer axis, or phase axis), confirms each split fits within thresholds, and asks for your approval before creating the new Issues.

## When this applies

- `/refine` checks the size gate when the Issue is first written, using the size-check SP from the PO.
- `/breakdown` re-checks the gate when proposing subtasks — if the breakdown would exceed five subtasks, the split test fires again.

## Why days is calibration-only

`max_sp: 5` operates on the scope × uncertainty SP scale defined by [`story-points`](/policies/story-points/). The split test is therefore "can this Issue fit in one PR's scope and decision-set without compounding?" If a single PR would have to span multiple subsystems **and** carry multiple unresolved design decisions, the Issue is too big regardless of how fast a model could draft it.

`max_estimated_days` is retained as a coarse calibration check during `/refine`: if the rough wall-clock feel obviously exceeds two days of solo-dev cycle time (including user review), that is a signal the scope/uncertainty estimate is probably too low. It is not the primary criterion.

## Exceptions

Large-scale refactoring and tech debt reduction are exempt from these thresholds; defer to user judgment.

## See also

- The SP scale itself: [`story-points`](/policies/story-points/).
- Canonical contract: [`skills/soloscrum-define-issue-size/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-issue-size/SKILL.md).

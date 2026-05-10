---
name: soloscrum-define-issue-size
description: "Reference: issue size thresholds (max SP 5, max subtasks 5, max days 2). Defines the suggest_split action triggered when any threshold is exceeded."
user-invocable: false
---

# soloscrum-define-issue-size

Issue size gate thresholds.

## Thresholds

```yaml
max_sp: 5
max_subtasks: 5
max_estimated_days: 2
action_on_exceed: suggest_split
```

## Evaluation

Trigger `suggest_split` when any of the following is exceeded:

| Metric | Threshold | Description |
|---|---|---|
| SP | > 5 | Estimates exceeding SP 5 |
| Subtask count | > 5 | When breakdown would produce more than 5 subtasks |
| Estimated days | > 2 days | When implementation is expected to take more than 2 days |

## suggest_split Action

1. Present split proposals for the Issue:
   - By feature axis (MVP vs. extensions)
   - By layer axis (backend / frontend)
   - By phase axis (core / error handling / performance)
2. Confirm each split Issue falls within thresholds
3. Obtain user approval before creating split Issues

## Notes

`max_sp: 5` operates on the scope x uncertainty SP scale defined in `soloscrum-define-story-points` — not on a time budget. The split test is therefore "can this Issue fit in one PR's scope and decision-set without compounding?" If a single PR would have to span multiple subsystems **and** carry multiple unresolved design decisions, the Issue is over-budget regardless of how fast a model could draft it.

`max_estimated_days` is retained as a coarse calibration check for the PO during `/refine`: if the rough wall-clock feel obviously exceeds two days of solo-dev cycle time (including user review), that is a signal the scope/uncertainty estimate is probably too low. It is not the primary criterion.

## Exceptions

- Large-scale refactoring and tech debt reduction are exempt from these thresholds; defer to user judgment.

---
name: soloscrum-define-priority
description: Reference: priority levels Urgent/High/Medium/Low and decision criteria. Urgent=blocker or outage, High=user impact or dependency, Medium=normal dev, Low=tech debt.
user-invocable: false
---

# soloscrum-define-priority

Priority level definitions and decision criteria.

## Priority Table

| Priority | Decision criteria | Response target |
|---|---|---|
| **Urgent** | Blocker, production outage, security vulnerability | Immediate |
| **High** | High user impact, other Issues depend on this | Next cycle |
| **Medium** | Normal feature development and improvements | Process in backlog order |
| **Low** | Tech debt, refactoring, nice-to-have | When capacity allows |

## Decision Flow

```
Production down or risk of data loss?
  → YES: Urgent

Other tasks are waiting on this, or high user impact?
  → YES: High

Normal feature development or improvement?
  → YES: Medium

Other (tech debt, future improvements)?
  → Low
```

## Notes

- In solo development, Urgent and High often overlap. Reserve Urgent for genuinely time-critical situations only.
- If Medium items accumulate too much, consider downgrading to Low and deferring them.

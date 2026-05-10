---
title: Priority
description: Priority levels (Urgent / High / Medium / Low) and decision criteria.
sidebar:
  order: 2
---

When you file an Issue, you (or `/refine`) pick one of four priority levels. Priority drives ordering in the backlog and signals urgency to anyone picking up the work.

## The four levels

| Priority | Decision criteria | Response target |
|---|---|---|
| **Urgent** | Blocker, production outage, security vulnerability | Immediate |
| **High** | High user impact, other Issues depend on this | Next cycle |
| **Medium** | Normal feature development and improvements | Process in backlog order |
| **Low** | Tech debt, refactoring, nice-to-have | When capacity allows |

The level is stored as a `priority:{urgent|high|medium|low}` label on the GitHub Issue. The label lives on GitHub regardless of the active tracker profile (GitHub stays canonical for parent metadata in both profiles).

## Decision flow

```text
Production down or risk of data loss?
  → YES: Urgent

Other tasks are waiting on this, or high user impact?
  → YES: High

Normal feature development or improvement?
  → YES: Medium

Other (tech debt, future improvements)?
  → Low
```

## When this applies

`/refine` sets the label when the Issue is created. After that the level is sticky — soloscrum never re-decides priority automatically; you change it by editing the label on the Issue.

## Notes

- In solo development, Urgent and High often overlap. Reserve Urgent for genuinely time-critical situations only.
- If Medium items accumulate too much, consider downgrading some to Low and deferring them.

## See also

- Where priority sits in the lifecycle (PO assigns it at `/refine`): [Agents and responsibilities](/concept/agent-responsibilities/).
- Canonical contract: [`skills/soloscrum-define-priority/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-priority/SKILL.md).

---
title: Priority
description: Priority levels (Urgent / High / Medium / Low) and decision criteria.
sidebar:
  order: 2
---

Each Issue carries one of four priority levels. Priority drives backlog ordering and signals urgency to whoever picks up the work.

## The four levels

| Priority | Decision criteria | Response target |
|---|---|---|
| **Urgent** | Blocker, production outage, security vulnerability | Immediate |
| **High** | High user impact, other Issues depend on this | Next cycle |
| **Medium** | Normal feature development and improvements | Process in backlog order |
| **Low** | Tech debt, refactoring, nice-to-have | When capacity allows |

The level is stored as a `priority:{urgent|high|medium|low}` label on the GitHub Issue. The label lives on GitHub regardless of the active tracker profile — GitHub stays canonical for parent metadata in both profiles.

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

`/refine` sets the label at Issue creation. After that the level is sticky — soloscrum does not re-decide priority automatically. Change it by editing the label on the Issue.

## Notes

- In solo development, Urgent and High often overlap. Reserve Urgent for genuinely time-critical situations.
- If Medium items accumulate, downgrade some to Low and defer them.

## See also

- Where priority sits in the lifecycle (PO assigns it at `/refine`): [Agents and responsibilities](/concept/agent-responsibilities/).
- Canonical contract: [`skills/soloscrum-define-priority/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-priority/SKILL.md).

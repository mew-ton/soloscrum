---
title: define-priority
description: Spec summary — priority levels (Urgent / High / Medium / Low) and decision criteria.
sidebar:
  order: 9
---

`soloscrum-define-priority` is the four-level priority taxonomy and the decision flow for placing an Issue on it.

## What it does

It pins the priority scale and what each level means.

| Priority | Decision criteria | Response target |
|---|---|---|
| **Urgent** | Blocker, production outage, security vulnerability | Immediate |
| **High** | High user impact, other Issues depend on this | Next cycle |
| **Medium** | Normal feature development and improvements | Process in backlog order |
| **Low** | Tech debt, refactoring, nice-to-have | When capacity allows |

## When it is consumed

`soloscrum-create-issue` (`/refine`) calls this skill to label a fresh Issue. The label is `priority:{urgent|high|medium|low}` and lives on the GitHub Issue regardless of active tracker profile (GitHub stays canonical for parent metadata in both profiles).

## Key inputs and outputs

Input is the Issue's nature (problem type, who is impacted, whether anything else is blocked). Output is one of the four priority labels.

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

## Notes

- In solo development, Urgent and High often overlap. Reserve Urgent for genuinely time-critical situations only.
- If Medium items accumulate too much, consider downgrading some to Low and deferring them.

## See also

- Canonical contract: [`skills/soloscrum-define-priority/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-priority/SKILL.md).
- For where priority sits in the lifecycle (PO assigns at `/refine`, never re-decided automatically), see [Agents and responsibilities](/concept/agent-responsibilities/).

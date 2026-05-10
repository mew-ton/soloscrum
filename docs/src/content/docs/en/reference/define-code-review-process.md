---
title: define-code-review-process
description: Spec summary — review pipeline (CodeRabbit + multi-agent), per-finding decision rules, draft-window override, and verdict mapping.
sidebar:
  order: 3
---

`soloscrum-define-code-review-process` is the contract `/review` follows when running its automated review pipeline and turning the findings into a verdict.

## What it does

It pins:

- The two parallel review sources: **CodeRabbit** (`coderabbit review --plain --base main`) and the **multi-agent review** (via the `code-review:code-review` slash command).
- The pre-filter rules: CodeRabbit findings have **no** pre-filter; multi-agent findings drop those scoring below 80.
- The per-item decision: every surviving finding is decided as **Fix** or **Skip with stated reason**. Severity is informational, not a skip reason.
- The draft-window override: when invoked from soloscrum, the multi-agent command's "skip if draft" eligibility check is bypassed because soloscrum runs `/review` on a draft PR by design.
- The verdict legend: Pass / Pass with follow-ups / Fail.
- The PR comment template that consolidates both sources.
- The post-verdict action sequence per verdict.

## When it is consumed

`soloscrum-review-implementation` (the engine behind `/review`) is the primary caller. The skill is also referenced ad hoc by callers who run `code-review:code-review` directly on a branch outside the soloscrum lifecycle.

## Key inputs and outputs

Input is a PR (in draft, by design) and the running tracker profile. Output is:

- A consolidated PR comment containing CodeRabbit findings + filtered agent findings + verdict.
- A verdict that drives the next-action sequence (approve / transition state / wait for CI / promote to ready, or post feedback / revert state / leave draft).

## Verdict to next-action

| Verdict | Sequence |
|---|---|
| Pass | approve → subtask `→ done` → wait for CI green → `gh pr ready` → surface merge command |
| Pass with follow-ups | confirm follow-up Issues exist → same as Pass |
| Fail | post per-finding feedback → subtask `→ in-progress` → leave PR in draft |

`gh pr merge` is **not** in the table — it is always user-gated.

## Self-approve refusal

`gh pr review --approve` failing in solo-dev with "Can not approve your own pull request" is the **default expected outcome**, not a failure. The verdict comment is the formal Pass record; the rest of the sequence still runs. The implementation pattern is try-and-fall-through.

## See also

- For the human walkthrough, read [Code review process](/concept/code-review-process/).
- Canonical contract: [`skills/soloscrum-define-code-review-process/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-code-review-process/SKILL.md).
- The lifecycle phases the verdict drives are described in [PR lifecycle](/concept/pr-lifecycle/).

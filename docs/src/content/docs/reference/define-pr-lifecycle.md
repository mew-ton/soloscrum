---
title: define-pr-lifecycle
description: Spec summary — PR phases, reversible vs irreversible transitions, and the user merge gate.
sidebar:
  order: 8
---

`soloscrum-define-pr-lifecycle` is the autonomy contract for everything PR-shaped. It establishes which transitions an agent runs without asking and which ones require the user as the gate.

## What it does

It pins three rules:

1. **Reversible transitions are autonomous.** `gh pr create --draft`, `gh pr ready`, `gh pr review --approve`, `gh pr comment`, label edits, tracker state transitions — execute, then report. No pre-confirm.
2. **Irreversible transitions are user-gated.** `gh pr merge`, force-push to a shared branch, branch deletion. The agent surfaces the exact command and stops.
3. **The verdict is the decision point.** Once `/review` produces a verdict, the post-verdict sequence runs end-to-end without further prompts.

It also pins the four lifecycle phases — `draft`, `review`, `ready`, `merge-handoff` — and which role owns each, the rationale for the draft window, the self-approve refusal handling for solo-dev, and the rule that **Issue close happens at merge**, not at verdict.

## When it is consumed

Every command and skill that does anything PR-shaped:

- `soloscrum-implement-task` reads the rule that the PR is created in draft.
- `soloscrum-review-implementation` reads the verdict-to-action mapping and the self-approve fallback.
- The tracker `transition-state` skills reference it for the agent autonomy contract.

## Key inputs and outputs

Inputs are: the current PR phase, the verdict (when applicable), and the active tracker profile (only for routing the state-transition step). Outputs are decisions about what to run next and whether to pre-confirm. The skill has no side effects of its own; it is the rulebook.

## Verdict to next-action

| Verdict | Sequence | User pre-confirm? |
|---|---|---|
| Pass | approve → subtask `→ done` → wait for CI green → `gh pr ready` → surface merge command | No |
| Pass with follow-ups | confirm follow-up Issues → same as Pass | No |
| Fail | post feedback → subtask `→ in-progress` → leave PR in draft | No |
| → merge | user runs `gh pr merge` | **Yes** |

CI red during the wait step retroactively downgrades Pass to Fail.

## Anti-patterns this skill prevents

- Re-prompting on reversible post-verdict steps ("may I run `gh pr ready`?").
- Running `gh pr merge` autonomously because the verdict was Pass.
- Treating self-approve refusal as a Fail.
- Closing the parent Issue as part of the post-verdict sequence (close happens at merge).

## See also

- For the human walkthrough, read [PR lifecycle](/concept/pr-lifecycle/).
- Canonical contract: [`skills/soloscrum-define-pr-lifecycle/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-pr-lifecycle/SKILL.md).
- For how findings are turned into the verdict that drives this lifecycle, see [`define-code-review-process`](/reference/define-code-review-process/).

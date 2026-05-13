---
title: Code review process
description: How `/review` runs CodeRabbit and the multi-agent review pipeline, why severity is informational, and how each finding resolves into a verdict.
sidebar:
  order: 4
---

`/review` runs two reviewers in parallel and consolidates their output into a single PR comment. Every finding, from either source, ends at one of two outcomes: **fix it**, or **skip it with a stated reason**. There is no third "ignore because severity is low" path.

## The two review sources

**CodeRabbit** runs via `coderabbit review --plain --base main`. It produces findings tagged `critical` / `major` / `minor` / `nitpick`. The tags describe what kind of issue it is, not whether to skip. A correct, in-scope `nitpick` is still worth fixing.

**The multi-agent review** runs via the `code-review:code-review` slash command. That command spins up several Sonnet agents in parallel, each with a focused lens (security, architecture, bug scan, history, in-file rules, coverage gaps). A separate Haiku agent scores each finding 0–100. The score is calibrated for the noise pattern of fresh agents, which tend to invent constraints and mis-cite rules.

Both sources' findings are consolidated into one PR comment with a single verdict line at the bottom.

## Why two thresholds exist

The two sources fail differently, so they get different filters:

- **CodeRabbit findings are already filtered by the tool.** Its severity classification is informational, and even its lowest tier corresponds to documented patterns. Re-filtering by severity silently drops legitimate signal.
- **Multi-agent reviewers spawn fresh per PR.** They are prone to hallucinating constraints and flagging intentional changes. The 80-confidence pre-filter is the noise gate calibrated for that.

The pre-filter applies only to the multi-agent side. After it, every surviving finding goes through the same per-item decision.

Mixing the two — applying the agent confidence filter to CodeRabbit, or accepting agent findings below 80 because they "look plausible" — is a named anti-pattern.

## The per-item decision

For every finding that reaches the decision step, the reviewer chooses **fix** or **skip with stated reason**.

**Fix** when all three are true:

1. The finding is **in scope** — it touches code or behavior introduced or directly modified by this PR's diff.
2. The suggestion is correct — it identifies a real issue and the proposed change addresses it.
3. The fix is **well-bounded** — it can be applied within files already touched by the PR (or trivially adjacent ones), without cascading into an unrelated refactor.

If those three hold and the cost is small, even a `nitpick` should be fixed.

**Skip with stated reason** when at least one is true:

- Out of scope — track as a follow-up Issue and write the issue number in the skip note.
- The suggestion is wrong or based on a misread of the diff. Cite the specific misread.
- Conflicts with an explicit project convention. Cite which one.

Not a valid skip reason:

- "It's a nitpick" or "minor severity" — severity is not a skip reason.
- "Solo dev, so I'll skip" without a specific argument — explain *why* solo-dev makes this finding inapplicable.
- "I'll fix later" without a tracking link — convert to an Issue and reference it.

## The draft-window override

The `code-review:code-review` command ships with an eligibility check that skips PRs still in draft. soloscrum **bypasses** that check. The PR is intentionally in draft when `/review` runs, because the [draft window](/concept/pr-lifecycle/) is where the local quality gate fires. Honouring the upstream skip would drop half the review pipeline.

If `code-review:code-review` exposes an explicit override argument, use it. Until then, soloscrum's review treats draft PRs as eligible by design.

## The verdict

Three verdicts are possible. The choice depends only on what happened to the surfaced findings:

- **Pass** — every surfaced finding was decided to fix and the fix has landed in this PR (or there were no findings).
- **Pass with follow-ups** — every finding was decided, but one or more were skipped *as out of scope* and tracked as separate follow-up Issues. The PR is mergeable; the follow-ups exist.
- **Fail** — at least one finding identifies a real correctness, security, or DoD violation that has not been fixed and is not legitimately out of scope.

If both sources produce zero findings to decide on (CodeRabbit "No findings ✔" and no agent finding scoring 80 or higher), the canonical "No issues found" comment is posted.

## What happens after the verdict

The post-verdict actions are described in detail on the [PR lifecycle](/concept/pr-lifecycle/). Short version:

| Verdict | Next |
|---|---|
| Pass | approve → subtask `→ done` → wait for CI green → `gh pr ready` → surface merge command |
| Pass with follow-ups | confirm follow-up Issues exist → same as Pass |
| Fail | post feedback → subtask `→ in-progress` → leave PR in draft |

Two details worth knowing:

- `gh pr review --approve` fails in solo-dev with "Can not approve your own pull request." This is not a verdict change — the verdict comment is the formal Pass record, and the rest of the sequence runs anyway.
- The CI-green wait between `→ done` and `gh pr ready` is part of the Pass contract. If a check goes red, the Pass retroactively downgrades to Fail. Promoting a ready PR with red checks is the failure mode that step prevents.

## See also

- Canonical contract — PR comment template, severity tables, full anti-pattern list: [`skills/soloscrum-define-code-review-process/SKILL.md`](https://github.com/mew-ton/soloscrum/blob/main/skills/soloscrum-define-code-review-process/SKILL.md).
- How the verdict drives the PR's state machine: [PR lifecycle](/concept/pr-lifecycle/).

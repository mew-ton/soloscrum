---
name: soloscrum-define-code-review-process
description: "Reference: standard code review pipeline (CodeRabbit + multi-agent review) and how findings from each source are filtered. CodeRabbit findings pass through verbatim regardless of severity; only agent-generated findings apply a confidence filter. Mixing the two thresholds is a recurring failure mode and is explicitly forbidden."
user-invocable: false
---

# soloscrum-define-code-review-process

Defines the standard code review pipeline run during `/review`, plus the rules for handling findings from each source.

## Pipeline

A code review combines two complementary sources, run in parallel:

1. **CodeRabbit** (`coderabbit review --plain --base main`) — produces findings with its own severity classification: `critical` / `major` / `minor` / `nitpick`.
2. **Multi-agent review** — N parallel Sonnet agents, each with a focused lens (security, architecture, bug scan, history, in-file rules, coverage gap), produces free-text findings.

Both sources' findings are then consolidated into a single PR comment.

## Finding Handling Rules

The two sources have different reliability characteristics and **MUST be filtered with different thresholds**.

### CodeRabbit findings → pass through verbatim

- **All severities are surfaced**, including `nitpick` and `minor`.
- CodeRabbit has its own quality controls and human-feedback loop; do **not** re-score, re-classify, or apply a confidence filter to its output.
- For each CodeRabbit finding the reviewer takes one of two actions:
  - **fix** — apply the suggested change in the same PR
  - **skip with stated reason** — write a one-line justification (e.g. "race condition irrelevant in solo-dev workflow"; "stylistic preference, codebase uses different convention")
- A silent drop is a process failure.

### Agent-generated findings → confidence filter

- Each finding is scored 0–100 by a separate Haiku scoring agent (per the rubric in `code-review:code-review`).
- **Filter out findings with score < 80.**
- The filter does **NOT** apply to CodeRabbit findings — only to the agent reviewers' output.

## Why two different thresholds

- CodeRabbit is a focused linter with humans in its training/feedback loop. Its `nitpick` and `minor` findings correspond to documented standards or known anti-patterns. Treating them as "low confidence" silently drops legitimate signal.
- Multi-agent reviewers spawn fresh and are prone to inventing constraints, mis-citing rules, or flagging intentional changes. The 80-confidence threshold is empirically calibrated for that noise.
- Mixing the two thresholds is a recurring failure mode — never apply the agent threshold to CodeRabbit output, and never accept agent findings below 80 just because they look plausible.

## PR Comment Format

A single comment combining both sources:

```
### Code review

#### CodeRabbit findings

1. <severity> <one-line description> — <action: fix | skip + reason>
   <link to file with full SHA + line range>

#### Agent findings (≥80 confidence)

1. <one-line description> (<rule or rationale>)
   <link to file with full SHA + line range>

#### Verdict

Pass | Pass with follow-ups | Fail
```

If both sources produce zero actionable findings (CodeRabbit "No findings ✔" and no agent finding ≥80), post the canonical "No issues found" comment.

## When to run

- Triggered by `/review` after the PR has been created and the `soloscrum-review` agent has completed DoD/AC verification.
- May also be invoked ad-hoc on any branch via the `code-review:code-review` skill — the same handling rules apply.

## Skipping CodeRabbit

If `coderabbit` CLI is not installed or the user is not authenticated, skip its run and proceed with multi-agent only. Note the skip explicitly in the PR comment ("CodeRabbit unavailable in this environment, multi-agent only").

## Notes

- CodeRabbit auth is per-user; the plugin assumes the user has run `coderabbit auth login`.
- This skill is profile-agnostic — the pipeline is the same regardless of `tracker_profile`.

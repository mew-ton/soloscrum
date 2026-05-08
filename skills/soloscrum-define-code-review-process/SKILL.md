---
name: soloscrum-define-code-review-process
description: "Reference: standard code review pipeline (CodeRabbit + multi-agent review) and the per-finding decision rules. Severity and confidence scores are inputs to a per-item decision, NOT auto-skip filters. Every CodeRabbit finding is surfaced and judged individually; only agent-generated findings have an additional confidence pre-filter to suppress hallucinations."
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

Severity and confidence scores are **inputs to a per-item decision**, never auto-skip filters. Every finding from either source goes through the same decision: fix it, or skip it with a stated reason. The only difference between the two sources is whether a pre-filter runs *before* the decision, to suppress hallucinated findings.

### CodeRabbit findings — every finding is decided individually

- **No pre-filter.** Every CodeRabbit finding (any severity, including `nitpick`) is surfaced and put to the same per-item decision below.
- Severity from CodeRabbit is **informational only** — it tells you what *kind* of issue it is, not whether to skip. A `nitpick` that is in scope and correct is still worth fixing.
- A silent drop based on severity is a process failure.

### Agent-generated findings — pre-filter, then decide

- Each agent finding is scored 0–100 by a separate Haiku scoring agent (per the rubric in `code-review:code-review`).
- **Pre-filter: drop findings with score < 80** (high false-positive rate from fresh agents).
- Surviving findings then go through the same per-item decision below.

### The per-item decision

For every surfaced finding, choose one:

- **Fix** — when:
  - The finding is in scope of the current PR
  - The suggestion is correct and well-bounded
  - Even if it's a `nitpick`, fix it if the cost is small and it improves the diff
- **Skip with stated reason** — when:
  - Out of scope (track as a follow-up Issue and write the issue number in the skip note)
  - The suggestion is wrong or based on a misread of the diff
  - Conflicts with an explicit project convention (cite which one)

**Reasons that are not valid skip rationale:**

- "It's a nitpick" / "minor severity" — severity is not a skip reason
- "Solo dev so I'll skip" without a specific argument — explain *why* solo-dev makes this finding inapplicable
- "I'll fix later" without a tracking link — convert to an Issue and reference it

## Why two different thresholds

- CodeRabbit findings have already been filtered by the tool itself; its severity classification is informational, and even its lowest tier corresponds to documented patterns. Re-filtering by severity silently drops legitimate signal.
- Multi-agent reviewers spawn fresh per PR and are prone to inventing constraints, mis-citing rules, or flagging intentional changes. The 80-confidence pre-filter is calibrated for that noise. After the pre-filter, the decision is still per-item.
- Mixing the two — applying the agent confidence pre-filter to CodeRabbit output, or accepting agent findings below 80 because they "look plausible" — is the failure mode this skill exists to prevent.

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

If both sources produce zero findings to decide on (CodeRabbit "No findings ✔" and no agent finding ≥80), post the canonical "No issues found" comment.

## When to run

- Triggered by `/review` after the PR has been created and the `soloscrum-review` agent has completed DoD/AC verification.
- May also be invoked ad-hoc on any branch via the `code-review:code-review` skill — the same handling rules apply.

## Skipping CodeRabbit

If `coderabbit` CLI is not installed or the user is not authenticated, skip its run and proceed with multi-agent only. Note the skip explicitly in the PR comment ("CodeRabbit unavailable in this environment, multi-agent only").

## Notes

- CodeRabbit auth is per-user; the plugin assumes the user has run `coderabbit auth login`.
- This skill is profile-agnostic — the pipeline is the same regardless of `tracker_profile`.

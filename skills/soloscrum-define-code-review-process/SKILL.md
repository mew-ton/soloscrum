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
2. **Multi-agent review** — implemented via the `code-review:code-review` slash command (N parallel Sonnet agents, each with a focused lens: security, architecture, bug scan, history, in-file rules, coverage gap). Produces free-text findings, scored 0–100 by a Haiku agent per the rubric in that command.

Both sources' findings are then consolidated into a single PR comment.

### Draft-window override for `code-review:code-review`

`code-review:code-review` ships with an eligibility check (its step 1) that **skips PRs still in draft**. In soloscrum, that check MUST be bypassed: the PR is *intentionally* in draft when `/review` runs, because the draft window is where the local quality gate fires (see `soloscrum-define-pr-lifecycle`, "Why a draft window exists"). Honouring the upstream skip here silently drops half the review pipeline and defeats the draft-window design.

When invoking `code-review:code-review` from the soloscrum review pipeline (i.e. from `soloscrum-review-implementation` step 3 or any caller of this skill):

- **Treat `draft` as eligible** — proceed past step 1 as if the PR were ready.
- All other eligibility checks (closed, automated, already reviewed by you) still apply.

If `code-review:code-review` later exposes an explicit override argument, prefer that argument; until then, this directive is the authoritative override for soloscrum's `/review`.

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

- **Fix** — when **all** of the following hold:
  1. The finding is in scope (see definition below)
  2. The suggestion is correct (it identifies a real issue and the proposed change addresses it)
  3. The fix is well-bounded (see definition below)
  Even a `nitpick` should be fixed when these three hold and the cost is small.
- **Skip with stated reason** — when at least one of the following:
  - Out of scope — track as a follow-up Issue and write the issue number in the skip note
  - The suggestion is wrong or based on a misread of the diff (cite the specific misread)
  - Conflicts with an explicit project convention (cite which one)

**In scope** means the finding touches code or behavior introduced or directly modified by this PR's diff. A finding that points to pre-existing code outside the diff is out of scope by default unless the PR explicitly intended to refactor it.

**Well-bounded** means the fix can be applied within files already touched by the PR (or trivially adjacent ones), without cascading into unrelated refactors that would balloon the diff.

**Reasons that are not valid skip rationale:**

- "It's a nitpick" / "minor severity" — severity is not a skip reason
- "Solo dev so I'll skip" without a specific argument — explain *why* solo-dev makes this finding inapplicable
- "I'll fix later" without a tracking link — convert to an Issue and reference it

## Why two different thresholds

- CodeRabbit findings have already been filtered by the tool itself; its severity classification is informational, and even its lowest tier corresponds to documented patterns. Re-filtering by severity silently drops legitimate signal.
- Multi-agent reviewers spawn fresh per PR and are prone to inventing constraints, mis-citing rules, or flagging intentional changes. The 80-confidence pre-filter is calibrated for that noise. After the pre-filter, the decision is still per-item.
- Mixing the two — applying the agent confidence pre-filter to CodeRabbit output, or accepting agent findings below 80 because they "look plausible" — is the failure mode this skill exists to prevent.

## PR Comment Format

A single comment combining both sources. Every surfaced finding records the action taken (fix or skip + reason) — agent and CodeRabbit rows use the same shape.

```
### Code review

#### CodeRabbit findings

1. <severity> <one-line description> — <action: fix | skip + reason>
   <link to file with full SHA + line range>

#### Agent findings (≥80 confidence)

1. <one-line description> (<rule or rationale>) — <action: fix | skip + reason>
   <link to file with full SHA + line range>

#### Verdict

Pass | Pass with follow-ups | Fail
```

### Verdict legend

- **Pass** — every surfaced finding was decided to fix and the fix has landed in this PR (or was already correct and no fix needed).
- **Pass with follow-ups** — every finding was decided, but one or more were skipped *as out-of-scope* and tracked as follow-up Issues. The PR is mergeable; the follow-ups exist as separate Issues.
- **Fail** — at least one finding identifies a real correctness, security, or DoD violation that has not been fixed and is not legitimately out of scope.

If both sources produce zero findings to decide on (CodeRabbit "No findings ✔" and no agent finding ≥80), post the canonical "No issues found" comment.

### Post-verdict actions

The verdict is the input to a defined sequence of next actions. The full lifecycle phases and the reversible-vs-irreversible autonomy classification live in `soloscrum-define-pr-lifecycle`; this section names the actions and cites that skill for autonomy.

| Verdict | Who acts next | Actions (in order) | Pre-confirm? |
|---|---|---|---|
| **Pass** | `soloscrum-review` | (1) `gh pr review --approve` — falls through on self-approve refusal; the verdict comment posted per "PR Comment Format" above is the formal Pass record (2) tracker Subtask `→ done` via `soloscrum-tracker-{profile}-transition-state` (3) close parent Issue if all sibling Subtasks are done (4) `gh pr ready` (5) report the merge command to the user | No — every step is reversible per `soloscrum-define-pr-lifecycle` |
| **Pass with follow-ups** | `soloscrum-review` | (1) confirm a follow-up Issue exists for each out-of-scope skip and that its number appears in the skip note; create any missing ones (2) then identical to **Pass** | No — same reversibility |
| **Fail** | `soloscrum-review` → `soloscrum-dev` | (1) post per-finding feedback on the PR (2) tracker Subtask `→ in-progress` via `soloscrum-tracker-{profile}-transition-state` (3) **leave the PR in draft** — do not call `gh pr ready` (4) hand back to `soloscrum-dev` to address findings | No for the review-side actions; the dev rework loop then re-enters this pipeline |

Notes on autonomy:

- `gh pr ready` after Pass / Pass with follow-ups is a reversible transition (`gh pr ready --undo`) and runs without pre-confirm. Pausing here to ask the user is the over-cautious failure mode that motivated this skill — see `soloscrum-define-pr-lifecycle` for the full classification.
- `gh pr merge` is **not** in the table above. Merge is always user-gated; the agent stops after step 5 of Pass and surfaces the merge command for the user to run.
- On Fail, the PR is intentionally left in draft so that the "needs more work" state is externally visible and GitHub-side auto-reviewers stay suppressed during rework.
- Step 1 (`gh pr review --approve`) is **expected to fail in solo-dev** with "Can not approve your own pull request"; this is the default state, not an error condition. The verdict comment posted per "PR Comment Format" above is the formal Pass record, and steps 2–4 still run. See `soloscrum-define-pr-lifecycle`, "Self-approve refusal in solo-dev contexts" for the full contract and the try-and-fall-through implementation pattern.

## When to run

- Triggered by `/review` after the PR has been created and the `soloscrum-review` agent has completed DoD/AC verification.
- May also be invoked ad-hoc on any branch via the `code-review:code-review` skill — the same handling rules apply.

## Skipping CodeRabbit

If `coderabbit` CLI is not installed or the user is not authenticated, skip its run and proceed with multi-agent only. Note the skip explicitly in the PR comment ("CodeRabbit unavailable in this environment, multi-agent only").

## Notes

- CodeRabbit auth is per-user; the plugin assumes the user has run `coderabbit auth login`.
- This skill is profile-agnostic — the pipeline is the same regardless of `tracker_profile`.

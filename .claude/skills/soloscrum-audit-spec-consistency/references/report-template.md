<!--
  Markdown template emitted by `/audit` (orchestrator) after aggregating
  N parallel `soloscrum-auditor` passes per `soloscrum-audit-spec-consistency`.

  Placeholders use angle brackets (e.g. `<repo>`); the orchestrator substitutes
  literal values when emitting the report. Sections for rules with zero
  findings still appear, with the finding list replaced by a single line:
  `(no findings)`. The Summary line totals MUST agree with the per-rule
  section counts.

  Per-finding numbering is `<rule>.<index>` (e.g. F1.1 = first R1 finding,
  F2.3 = third R2 finding). Indices restart per rule.

  `Appeared in: K/N runs` is **informational only** — not an auto-skip filter
  and not a quorum gate. See `soloscrum-audit-spec-consistency` "Multi-pass
  union, no quorum filter" for the contract. Findings with K = 1 are still
  surfaced and still go through the per-item decision in
  `soloscrum-define-code-review-process`.
-->

## soloscrum spec audit

Repo: <repo>
Commit: <sha>
Scope: <skill | agent | command | docs | all>

### Summary

- Total parallel runs: N
- R1 (leaked session context): N findings
- R2 (cross-file contradictions): N findings
- R3 (fresh-memory completability): N findings
- R4 (automation blockers): N findings

### R1 — Leaked session context

#### F1.1 <one-line description>
- Appeared in: K/N runs
- Files:
  - `<path>:<line-range>` — <prose excerpt>
  - (additional locations when the same drift appears in N files; one bullet per location)
- Why: <which heuristic matched>
- Suggested fix: <concrete edit, or "track as follow-up Issue">
- Variants: (optional — when prose excerpt or suggested fix differed across passes, list the alternates that the orchestrator did not pick as the canonical surface)

#### F1.2 ...

### R2 — Cross-file contradictions

#### F2.1 <one-line description of the concept that drifted>
- Appeared in: K/N runs
- File A: `<path-a>:<line-range>` claims: <claim-a>
- File B: `<path-b>:<line-range>` claims: <claim-b>
- Inconsistency: <what disagrees>
- Suggested fix: <which file is canonical, what to change in the other>
- Variants: (optional, same semantics as R1)

#### F2.2 ...

### R3 — Fresh-memory completability

(same shape as R1)

### R4 — Automation blockers

(same shape as R1)

### Verdict

- Clean — no findings (across all N passes)
- Findings present — <total> (<errors> errors, <warnings> warnings) across N passes — see per-rule sections above. Per-pass appearance counts are annotated on each finding for reviewer reference; they do **not** auto-filter.

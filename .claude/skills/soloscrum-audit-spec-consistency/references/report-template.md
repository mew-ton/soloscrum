<!--
  Markdown template emitted by `soloscrum-auditor` after running an audit
  pass per `soloscrum-audit-spec-consistency`.

  Placeholders use angle brackets (e.g. `<repo>`); the auditor substitutes
  literal values when emitting the report. Sections for rules with zero
  findings still appear, with the finding list replaced by a single line:
  `(no findings)`. The Summary line totals MUST agree with the per-rule
  section counts.

  Per-finding numbering is `<rule>.<index>` (e.g. F1.1 = first R1 finding,
  F2.3 = third R2 finding). Indices restart per rule.
-->

## soloscrum spec audit

Repo: <repo>
Commit: <sha>
Scope: <skill | agent | command | docs | all>

### Summary

- R1 (leaked session context): N findings
- R2 (cross-file contradictions): N findings
- R3 (fresh-memory completability): N findings
- R4 (automation blockers): N findings

### R1 — Leaked session context

#### F1.1 <one-line description>
- File: `<path>:<line-range>`
- Snippet: > <prose excerpt>
- Why: <which heuristic matched>
- Suggested fix: <concrete edit, or "track as follow-up Issue">

#### F1.2 ...

### R2 — Cross-file contradictions

#### F2.1 <one-line description of the concept that drifted>
- File A: `<path-a>:<line-range>` claims: <claim-a>
- File B: `<path-b>:<line-range>` claims: <claim-b>
- Inconsistency: <what disagrees>
- Suggested fix: <which file is canonical, what to change in the other>

#### F2.2 ...

### R3 — Fresh-memory completability

(same shape as R1)

### R4 — Automation blockers

(same shape as R1)

### Verdict

- Clean — no findings
- Findings present — <total> (<errors> errors, <warnings> warnings) — see per-rule sections above

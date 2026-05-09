---
name: audit
description: Audits the soloscrum plugin-distributed spec corpus (skills/, agents/, commands/, CLAUDE.md, README.md) for leaked session context, cross-file contradictions, fresh-memory completability, and automation blockers. Read-only — proposes fixes, never edits. Repo-local; not part of the plugin distribution.
argument-hint: "[--scope skill|agent|command|docs|all] [--passes N]"
disable-model-invocation: true
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash(gh repo view:*)
  - Bash(git rev-parse:*)
---

# /audit

Run a consistency audit on this repo's plugin-distributed spec corpus, per the rules in `soloscrum-audit-spec-consistency`.

## Locality

This command lives at `.claude/commands/audit.md`. It is **soloscrum's own repo-local dev tooling**, not part of the plugin distribution. Mirrors the relocations in:

- `.claude/skills/soloscrum-audit-spec-consistency/SKILL.md` (the rule definitions)
- `.claude/agents/soloscrum-auditor.md` (the read-only subagent that emits the report)

`/audit` is therefore **not** registered in `README.md`'s Commands table or in `soloscrum-define-agent-responsibilities`'s Lifecycle Summary — those describe the plugin surface; `/audit` is local-only.

## Prerequisites

`/audit` requires the following files to be present on the working tree (all repo-local):

- `.claude/skills/soloscrum-audit-spec-consistency/SKILL.md` — the rule definitions
- `.claude/skills/soloscrum-audit-spec-consistency/references/report-template.md` — the report shape
- `.claude/agents/soloscrum-auditor.md` — the read-only subagent that emits the report

If any of these is missing (e.g. on a checkout before all sub-issues of #18 have merged), `/audit` will fail at step 3 below. Confirm the three files exist before invoking; do not paper over a missing prerequisite with a runtime fallback — a missing file means the audit pipeline is genuinely incomplete and the user should resolve that first.

## Behavior

1. Parse `$ARGUMENTS` for `--scope <skill|agent|command|docs|all>` (default `all`) and `--passes N` (default `3`, must be ≥ 1).
2. Resolve the report header inputs:
   - `<repo>` = `gh repo view --json nameWithOwner --jq .nameWithOwner` (read-only)
   - `<sha>` = `git rev-parse HEAD`
3. **Launch N parallel `soloscrum-auditor` subagent invocations** with identical inputs (scope, `<repo>`, `<sha>`). Each pass runs independently; do **not** chain them. Each subagent reads `soloscrum-audit-spec-consistency`, sweeps the in-scope corpus per R1–R4, and emits its own Markdown report substituted into `references/report-template.md`. The auditor is implemented by an LLM and is non-deterministic — same corpus / same rules can yield slightly different findings sets per pass; that is the explicit reason for running N (see "Why multiple passes" below).
4. **Aggregate the N reports into one** via union with deduplication. Aggregation rules:
   - **Dedup key** for R1 / R3 / R4 findings: `(rule, primary file path, line-range overlap)`. Two findings on the same `(rule, path)` whose line ranges share **at least one line** are the same finding. This is overlap-based, not exact-string match — `file.md:154` and `file.md:152-156` are the same finding because line 154 is in both.
   - For R2 (cross-file) findings: `(rule, sorted pair of file paths)`. The sorted pair makes order-independence explicit (same-content findings reported as `(file-A, file-B)` and `(file-B, file-A)` collapse).
   - When a finding key appears in K of N passes, surface it **once** with `Appeared in: K/N runs` annotation. K can be 1.
   - When `prose excerpt` / `suggested fix` differ across passes for the same dedup key, pick the most actionable variant (most concrete suggested fix; longest excerpt covering the same line range). Tiebreaker: lexicographically first excerpt. Optionally include `Variants: ...` listing the alternates the orchestrator did not pick.
   - **Primary file path / line range** for R1 / R3 / R4: when a single finding lists multiple `Files:` locations (de-dup within a single pass per Guideline 4 of the auditor agent), the **first listed location** is the primary key; subsequent locations are merged into the union finding's `Files:` list across passes.
   - **Do not apply a quorum filter.** A finding that appears in only 1 of N passes is still surfaced — the per-finding decision (fix / skip) is the gate, not appearance count. Quorum filtering would discard real signal; see `soloscrum-audit-spec-consistency` "Per-finding decision rules" for the rationale.
5. Render the aggregated report against `references/report-template.md`, populating `Total parallel runs: N` in the Summary and `Appeared in: K/N runs` per finding. Print to stdout. Do **not** write to a file by default; do **not** open Issues for findings automatically.

## Why multiple passes

The auditor's heuristics (R1 prose pattern matches, R3 fresh-memory judgements, R4 autonomy cross-checks) and per-finding decision (in-scope / suggestion-correct / well-bounded) are LLM judgements, not mechanical rules. Same corpus + same rules → slightly different findings per pass. Single-pass `/audit` runs miss findings that surface in other passes' samples; running N passes and surfacing the union catches more real drift. Cost is N× LLM tokens; benefit is materially fewer false-negatives. The reviewer's per-finding decision (per `soloscrum-define-code-review-process`) drops false-positives at decision time, so the union is safe to surface raw.

`Appeared in: K/N runs` is **informational only** — not an auto-skip filter, not a confidence proxy. It is parallel to `severity` in the code-review-process: an input to the per-item decision, never a gate.

## Input

- Optional flag: `--scope <skill|agent|command|docs|all>` (default `all`)
- Optional flag: `--passes N` (default `3`; `--passes 1` reproduces single-pass behaviour for backward compat)
- No positional args

## Output

A single aggregated Markdown report covering all N passes. On a clean run with no findings, the per-rule sections show `(no findings)` and the Verdict line reads "Clean — no findings". The Summary always records `Total parallel runs: N`.

## Per-finding decision

The reviewer (or the user reading the report) applies the per-item decision rules from `soloscrum-define-code-review-process` (fix or skip-with-reason) to each surfaced finding. `Appeared in: K/N runs` is informational; it does **not** preempt the decision. There is no confidence pre-filter — the auditor is a single-rule-set deterministic-spec applied by an LLM, not a fresh multi-agent reviewer pool, so the 80-confidence floor in code-review-process does not apply.

## Following up on findings

`/audit` itself does not file Issues. If findings warrant action:

1. Review the report
2. For each finding worth fixing, run `/refine` to convert it into a properly-structured GitHub Issue
3. `/develop` the resulting Issue per the standard flow

This is the **dogfooding loop** referenced in #18: audit → refine → develop. Do **not** edit files directly from the report — every fix goes through the flow per `CLAUDE.md`.

## Resources

- Subagent: `soloscrum-auditor` (`.claude/agents/soloscrum-auditor.md`)
- Skills: `soloscrum-audit-spec-consistency` (`.claude/skills/soloscrum-audit-spec-consistency/`), `soloscrum-define-code-review-process`, `soloscrum-define-pr-lifecycle`
- Reference template: `.claude/skills/soloscrum-audit-spec-consistency/references/report-template.md`

---
name: audit
description: Audits the soloscrum plugin-distributed spec corpus (skills/, agents/, commands/, CLAUDE.md, README.md) for leaked session context, cross-file contradictions, fresh-memory completability, and automation blockers. Read-only — proposes fixes, never edits. Repo-local; not part of the plugin distribution.
argument-hint: "[--scope skill|agent|command|docs|all]"
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

## Behavior

1. Parse `$ARGUMENTS` for `--scope <skill|agent|command|docs|all>`. Default `all`.
2. Resolve the report header inputs:
   - `<repo>` = `gh repo view --json nameWithOwner --jq .nameWithOwner` (read-only)
   - `<sha>` = `git rev-parse HEAD`
3. Launch the `soloscrum-auditor` subagent (under `.claude/agents/`) with:
   - the resolved scope
   - the resolved `<repo>` and `<sha>`
4. The subagent reads `soloscrum-audit-spec-consistency`, sweeps the in-scope corpus per R1–R4, and emits a Markdown report substituted into `references/report-template.md`.
5. Print the report to stdout. Do **not** write it to a file by default; do **not** open Issues for findings automatically. The report is the artifact.

## Input

- Optional flag: `--scope <skill|agent|command|docs|all>` (default `all`)
- No positional args

## Output

A single Markdown report (the report template populated). On a clean run with no findings, the per-rule sections show `(no findings)` and the Verdict line reads "Clean — no findings".

## Per-finding decision

The subagent applies the per-item decision rules from `soloscrum-define-code-review-process` (fix or skip-with-reason). Severity is informational only; there is no confidence pre-filter (the auditor is deterministic on a fixed corpus).

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

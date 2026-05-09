---
name: soloscrum-audit-spec-consistency
description: "Reference: detection rules and report format for auditing the soloscrum spec corpus (skills/, agents/, commands/, CLAUDE.md, README.md) for leaked session context, cross-file contradictions, fresh-memory completability, and automation blockers. Consumed by soloscrum-auditor and the /audit command."
user-invocable: false
---

# soloscrum-audit-spec-consistency

Defines the four detection rule sets the `soloscrum-auditor` subagent applies when sweeping soloscrum's own spec corpus. Each rule set names the symptom, the heuristic that detects it, the file scope, and how it is reported.

## Why this skill exists

soloscrum's behaviour is defined by the prose body of files under `skills/`, `agents/`, `commands/`, `CLAUDE.md`, and `README.md`. The corpus spans dozens of files; cross-file consistency cannot be enforced by per-PR human review alone, and PR review only catches what reviewers happen to look at — not the long tail of drift introduced as new Issues, agents, or commands are added over time.

This skill formalises four classes of drift the auditor must detect, so that the audit pass is reproducible and not reliant on whoever happens to be reviewing.

## File scope

Unless the caller restricts via `--scope`, the audit covers the **plugin-distributed corpus** of this repo — what consumers get when they install soloscrum:

- `skills/**/SKILL.md` — every plugin-distributed skill spec
- `agents/**/*.md` — every plugin-distributed agent definition
- `commands/**/*.md` — every plugin-distributed command definition
- `CLAUDE.md` — repo-level dogfooding rules (part of the public surface)
- `README.md` — public-facing entry doc

Not in scope (regardless of `--scope`):

- `.claude/skills/`, `.claude/agents/`, `.claude/commands/` — **this skill, the auditor subagent, and the `/audit` command live under `.claude/`**; they are soloscrum's *own* repo-local dev tooling, not shipped in the plugin. Auditing the auditor is a tail-chase that adds no signal.
- `.claude/rules/*` (consumer-side overrides; soloscrum core does not own their content)
- `.github/`, `.git/`, `.claude-plugin/` (config / metadata, not behavior prose)
- Memory, Issue / PR bodies, commit messages (transient by design)

## Rule R1 — Leaked session context

**Symptom**: prose that was authored in a specific conversation has been merged into the spec without being depersonalised. Future readers (with no access to that conversation) cannot interpret the text correctly.

**Heuristics** (any single match is a candidate finding):

- Time-relative phrasing without an absolute anchor: *"今回"* / *"先ほど"* / *"上記の通り"* / *"the recent fix"* / *"this PR"* (when *this PR* is the spec file, not the change adding it) / *"recently observed"*.
- Observation-log fingerprints: a `(observed YYYY-MM-DD)` stamp **inside a normative spec file** (CLAUDE.md anti-patterns are a deliberate exception — they cite incidents — but spec body should not).
- First-person session voice: *"I noticed"* / *"we discussed"* / *"as we agreed earlier"*.
- Narration of edits to the file itself: *"changed X to Y in this commit"* / *"updated above"* / *"removed the old foo block"*.
- Workaround prose without rationale: *"a quick workaround"* / *"for now we just"* / *"as a stopgap"* without an issue link or sunset condition.

**Severity**: warning (not blocker). Even legitimate prose can match heuristically; the auditor's per-finding decision (per `soloscrum-define-code-review-process`) is the gate.

**File scope**: all in-scope files. CLAUDE.md anti-pattern bullets that cite a specific incident with `(observed YYYY-MM-DD)` are explicitly **allowed**; only the spec-body occurrence is flagged.

## Rule R2 — Cross-file contradictions

**Symptom**: the same concept (a verdict action, a state transition, a draft-window rationale, etc.) is described in two or more files in mutually inconsistent ways. A reader landing on either file alone gets a coherent story; reading both reveals the drift.

**Heuristics**:

- The concept index is **closed for v1**. The auditor checks only these seven concepts; expanding the list is a separate spec change, not an in-audit decision:
  1. **Issue close timing** — verdict-time vs merge-time
  2. **Subtask state mapping** — open + label vs closed
  3. **Post-verdict actions sequence** — exact ordered step list (approve / tracker `→ done` / `gh pr ready` / merge surface)
  4. **Draft-window purpose** — auto-reviewer suppression vs self-quality-gate
  5. **Self-approve refusal handling** — verdict comment as Pass record + try-and-fall-through
  6. **`/refine` janitor scope and trigger** — what it closes, when, with which `--reason`
  7. **Merge handoff** — who runs `gh pr merge` (always user)
- For each concept, extract the prose snippet from each file that mentions it (concept index → file → snippet). If two snippets state different rules / classifications / sequences for the same concept, the pair is a finding.
- Detection compares specific snippets against specific snippets — not free-form paraphrase. Worked example: if `soloscrum-define-pr-lifecycle` says *"`gh pr review --approve` is reversible"* and a hypothetical `agents/foo.md` says *"`gh pr review --approve` requires user confirmation,"* both snippets are extracted and the auditor flags the disagreement on the autonomy classification of that exact command.
- A concept absent from a file is **not** a finding (silence is allowed). Only mutually inconsistent presence triggers R2.

**Severity**: error. Cross-file contradictions silently mislead agents and need a fix (which file is correct? update the other).

**File scope**: all in-scope files. CLAUDE.md vs `soloscrum-define-pr-lifecycle` is a particularly important pairing because CLAUDE.md restates rules; drift between them is the canonical motivating case.

## Rule R3 — Fresh-memory completability

**Symptom**: a skill / agent / command, when read in isolation by an agent with no prior context, omits enough information that the agent cannot complete the task end-to-end without consulting memory or prior conversation.

**Heuristics**:

- Unresolved references: phrases like *"as discussed previously"* / *"see earlier"* / *"the issue we filed last week"* without a concrete file or Issue link.
- Implied prerequisites: the file refers to a state ("when the Subtask is in `state:done`") without saying how that state was reached or which skill produces it.
- Missing exit conditions: a procedure ends with *"and so on"* / *"continue as appropriate"* / no terminal step.
- Skill referenced only by half its name: *"the transition skill"* (no file path) when the cross-reference must be a specific `soloscrum-tracker-{profile}-transition-state` invocation.
- Profile-dispatch silence: a procedure that depends on `tracker_profile` but does not call out the dispatch step (resolve profile → invoke profile-prefixed skill).

**Severity**: warning. False positives are common (the prose may be intentionally terse because the immediate cross-reference covers it). The per-finding decision filters these.

**File scope**: skill / agent / command files (not CLAUDE.md or README.md, which are summary docs that intentionally rely on referenced skills for full detail).

## Rule R4 — Automation blockers

**Symptom**: a step in a skill / agent / command implies a manual stop ("ask the user", "pause for confirmation", "check before proceeding") in a context where the autonomy contract in `soloscrum-define-pr-lifecycle` says the step is reversible and should run autonomously.

**Heuristics**:

- Phrases: *"ask the user"* / *"prompt the user"* / *"confirm with the user"* / *"pause and wait"* / *"check before proceeding"* / *"surface to the user and stop"*.
- Cross-check each match against the autonomy classification in `soloscrum-define-pr-lifecycle`:
  - Reversible transitions (gh pr ready, approve, tracker state, label edits, etc.): a "wait for user" phrase here is a finding.
  - Irreversible transitions (gh pr merge, force-push, branch deletion): a "wait for user" phrase here is **expected** — not a finding.
  - Unclassified transitions: surface as a low-confidence finding for human triage.
- Specific named anti-patterns from `soloscrum-define-pr-lifecycle` "Anti-patterns" section MUST NOT appear as instructions (they are the failure modes the contract exists to prevent).

**Severity**: error. Automation blockers silently break dogfooding by stalling the agent at a reversible step.

**File scope**: all in-scope files. CLAUDE.md "Anti-patterns" section bullets are **expected** to mention these phrases (in the negation form, e.g. *"❌ Asking the user before X"*); only the positive instruction occurrence is flagged.

## Per-finding decision rules

Every finding from any of R1–R4 goes through the same per-item decision as `soloscrum-define-code-review-process`:

- **Fix** — the finding identifies a real drift, the suggested correction is correct, and the fix is well-bounded
- **Skip with stated reason** — the finding is a false positive (heuristic match but not actually a drift), out-of-scope (e.g. the matching prose is in a CLAUDE.md anti-pattern citation, which is allowed), or conflicts with an explicit project convention

Severity (warning / error) is **informational only** — never an auto-skip filter. A warning that is a real drift is still worth fixing; an error that is a false positive is still skipped with reason.

There is no confidence pre-filter on auditor findings. The agent-finding pre-filter in `soloscrum-define-code-review-process` exists because multi-agent reviewers spawn fresh per PR and are prone to inventing constraints — that is a hallucination floor specific to that pipeline. The auditor is a single deterministic subagent applying a fixed rule set against a fixed corpus; it has no equivalent floor, so every match goes straight to the per-item decision.

## Report format

The auditor emits a single Markdown report. The canonical template is colocated with this skill at:

```
.claude/skills/soloscrum-audit-spec-consistency/references/report-template.md
```

The auditor reads that file, substitutes the angle-bracket placeholders (`<repo>` / `<sha>` / `<scope>` / `<finding-fields>`) with concrete values, and writes the result to stdout. Editing the template file is the only way to change the report shape; the SKILL.md does not duplicate the template body.

Required substitutions per finding:

- **R1 / R3 / R4** (single-file findings): `<one-line description>`, `<path>:<line-range>`, `<prose excerpt>`, `<which heuristic matched>`, `<concrete edit, or "track as follow-up Issue">`
- **R2** (cross-file findings): `<one-line description of the concept that drifted>`, `<path-a>:<line-range>` + `<claim-a>`, `<path-b>:<line-range>` + `<claim-b>`, `<what disagrees>`, `<which file is canonical, what to change in the other>`

Sections for rules with zero findings MUST still appear, with the finding list replaced by `(no findings)`. The Summary line totals MUST agree with the per-rule section counts.

The auditor is read-only; **all fixes go through normal `/develop` cycles**. The report is the artifact, not file edits.

## Notes

- This skill is profile-agnostic. The audit corpus is soloscrum's own docs, which are profile-independent.
- This skill is `disable-model-invocation: true` and `user-invocable: false`. It is consumed by the `soloscrum-auditor` subagent; the user-facing entry point is the `/audit` command. (Both are tracked separately under #18's breakdown.)
- The auditor MUST NOT edit any file. The report is the output; per-finding fixes go through `/refine` → `/develop`.
- When a finding repeats across multiple files (e.g. same workaround prose copied to three skills), report once with all locations listed; do not generate N separate findings.
- **Self-applicability**: the audit corpus does not include `.claude/skills/`, `.claude/agents/`, or `.claude/commands/`, where this skill and its consumers live (see "File scope" above). The auditor never audits itself. Within the in-scope corpus, however, the same kind of false positive can arise from any spec body that legitimately quotes a heuristic phrase as an example: phrases that appear inside Markdown quotes (`*"..."*`) or fenced code blocks as illustrations of a heuristic are not findings, in any in-scope file.

## Depends On

- `soloscrum-define-code-review-process` — per-finding decision rules; report format follows the same pattern
- `soloscrum-define-pr-lifecycle` — autonomy classification (the source of truth for R4 cross-checks)
- `soloscrum-define-issue-format` — for the format of follow-up Issues filed from Audit findings during the dogfood smoke run

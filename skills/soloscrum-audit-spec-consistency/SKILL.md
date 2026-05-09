---
name: soloscrum-audit-spec-consistency
description: "Reference: detection rules and report format for auditing the soloscrum spec corpus (skills/, agents/, commands/, CLAUDE.md, README.md) for leaked session context, cross-file contradictions, fresh-memory completability, and automation blockers. Consumed by soloscrum-auditor and the /audit command."
user-invocable: false
---

# soloscrum-audit-spec-consistency

Defines the four detection rule sets the `soloscrum-auditor` subagent applies when sweeping soloscrum's own spec corpus. Each rule set names the symptom, the heuristic that detects it, the file scope, and how it is reported.

## Why this skill exists

soloscrum's behaviour is defined by the prose body of files under `skills/`, `agents/`, `commands/`, `CLAUDE.md`, and `README.md`. Every Issue / PR cycle adds, modifies, or removes prose across multiple files. The corpus has grown to a size where a human cannot reliably check end-to-end consistency on every change, and Issue / PR review only catches what reviewers happen to look at — not the long tail of drift.

This skill formalises four classes of drift the auditor must detect, so that the audit pass is reproducible and not reliant on whoever happens to be reviewing.

## File scope

Unless the caller restricts via `--scope`, the audit covers:

- `skills/**/SKILL.md` — every skill spec
- `agents/**/*.md` — every agent definition
- `commands/**/*.md` — every command definition
- `CLAUDE.md` — repo-level dogfooding rules
- `README.md` — public-facing entry doc

Not in scope (regardless of `--scope`):

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

- Build a concept index across files. Concepts to track at minimum:
  - "Issue close timing" (verdict vs merge)
  - "Subtask state mapping" (closed vs open + label)
  - "Post-verdict actions sequence" (approve / tracker → done / gh pr ready)
  - "Draft-window purpose"
  - "Self-approve refusal handling"
  - "Janitor scope and trigger"
  - "Merge handoff: who runs `gh pr merge`"
- For each concept, extract the prose snippet from each file that mentions it. If two snippets disagree on the rule, classification, or sequence, that pair is a finding.
- Detection is structural, not regex-based: the auditor reads the relevant sections and judges agreement at the claim level (e.g. "file A says X is reversible, file B says X is irreversible" → finding).

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

There is no confidence pre-filter on auditor findings. The auditor is run on the soloscrum repo, not on a fresh PR diff, so there is no corresponding noise floor; every match goes through the per-item decision.

## Report format

The auditor emits a single Markdown report:

```markdown
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
```

The auditor is read-only; **all fixes go through normal `/develop` cycles**. The report is the artifact, not file edits.

## Notes

- This skill is profile-agnostic. The audit corpus is soloscrum's own docs, which are profile-independent.
- This skill is `disable-model-invocation: true` and `user-invocable: false`. It is consumed by `soloscrum-auditor` (per sub-issue #24); the user-facing entry point is `/audit` (per sub-issue #25).
- The auditor MUST NOT edit any file. The report is the output; per-finding fixes go through `/refine` → `/develop`.
- When a finding repeats across multiple files (e.g. same workaround prose copied to three skills), report once with all locations listed; do not generate N separate findings.

## Depends On

- `soloscrum-define-code-review-process` — per-finding decision rules; report format follows the same pattern
- `soloscrum-define-pr-lifecycle` — autonomy classification (the source of truth for R4 cross-checks)
- `soloscrum-define-issue-format` — for the format of follow-up Issues filed from Audit findings (sub-issue #26 dogfooding round)

# CLAUDE.md

This repository **is** the soloscrum framework. All non-trivial work on this repo MUST be routed through soloscrum's own flow — anything else is a dogfooding failure.

## Tracker profile

**`github-only`.** There is no `.claude/rules/tracker.md`, so the default applies:

- Issues live on GitHub: <https://github.com/mew-ton/soloscrum/issues>
- Subtasks use native GH Sub-issues when needed (see `soloscrum-tracker-github-create-subtask`)
- State transitions go through `soloscrum-tracker-github-transition-state`
- Linear is **not** in use here — do not invoke any `soloscrum-tracker-linear-*` skill

## Required flow

For every change other than the explicit exemptions below, route through:

1. **`/refine`** — turn the idea into a GitHub Issue with Background / Goal / Acceptance Criteria / Out of Scope per `soloscrum-define-issue-format`. User feedback that produces a discrete unit of work counts as the trigger.
2. **`/breakdown`** — if the Issue exceeds the size threshold in `soloscrum-define-issue-size` (SP > 5, > 5 subtasks, or > 2 days), split into Sub-issues. Issues that fit within a single develop unit can skip this step.
3. **`/develop`** — branch per `soloscrum-define-branch-commit`, implement, open a **draft** PR with `Closes #<issue>` in the body. PRs always start as draft (per `soloscrum-define-pr-lifecycle`).
4. **`/review`** — DoD + AC verification, CodeRabbit + multi-agent pipeline, per-finding decisions, verdict, post-verdict actions through to the merge handoff.

`/review` runs to **verdict completion** — not to draft-PR-creation. Stopping at "draft PR pushed" is the named anti-pattern this file exists to prevent.

## Anti-patterns

These are the specific failure modes this file exists to prevent. Each has been observed at least once on this repo; do not reintroduce.

- ❌ **Skipping `/refine` and editing files / pushing PRs ad-hoc** because the change "is small". Even small docs changes go through the flow — this repo's flow IS its product. (Observed 2026-05-09 on issues #8 and #9; the framework's silent-skip pattern reproduced inside the framework's own repo.)
- ❌ **Stopping at `gh pr create --draft` and handing back to the user.** When the user invokes a soloscrum command, that constitutes pre-authorisation for the full sequence to the merge handoff (per `soloscrum-define-pr-lifecycle` "Authorisation scope"). Stop at the merge command surface, not before.
- ❌ **Skipping the multi-agent review pipeline because the PR is small or docs-only.** CodeRabbit + multi-agent are the quality gate; bypassing them defeats `soloscrum-define-code-review-process`. CodeRabbit returning "No findings ✔" still requires the multi-agent pass.
- ❌ **Treating `gh pr review --approve` failing with self-approve refusal as Fail / abort.** Solo-dev IS the default context on this repo; the verdict comment is the formal Pass record (per `soloscrum-define-pr-lifecycle` "Self-approve refusal in solo-dev contexts"). Use the documented try-and-fall-through pattern.
- ❌ **Treating `code-review:code-review`'s draft-skip as authoritative inside soloscrum's `/review`.** soloscrum's draft window is where the local quality gate fires by design; the bypass is mandated (per `soloscrum-define-code-review-process` "Draft-window override").
- ❌ **Running `gh pr merge` autonomously.** Merge is always the user's gate, regardless of verdict — `gh pr merge` is irreversible. Surface the exact command and stop.
- ❌ **Re-prompting on reversible post-verdict steps** ("may I run `gh pr ready`?"). The verdict is the decision point; reversible steps execute without pre-confirm per `soloscrum-define-pr-lifecycle`.
- ❌ **Writing inline `until ... gh pr view ... sleep ...` loops to wait for PR CI.** Use `soloscrum-tracker-github-wait-for-pr-checks` (invoke its colocated script from the repo root). Inline loops embed the PR number in the command string, defeat harness allowlist matching (causing per-PR re-prompts), and reinvent the rollup-normalisation `jq` filter every session.

## When the flow does NOT apply

These exemptions exist so the flow stays cheap to follow elsewhere:

- README / typo / one-character fixes that touch no behavior
- Reverting a clearly broken commit (the original commit went through the flow; the revert is mechanical)
- Repository housekeeping that does not touch `skills/`, `agents/`, `commands/`, or framework behavior — `.gitignore` updates, license file additions, `.editorconfig`, etc.

Anything that touches `skills/`, `agents/`, `commands/`, `marketplace.json`, or repository structure goes through the full flow.

## References

Skills (the soloscrum spec — read these for the contract):

- `skills/soloscrum-define-pr-lifecycle/SKILL.md` — autonomy contract, reversible-vs-irreversible, anti-patterns, self-approve fallback
- `skills/soloscrum-define-code-review-process/SKILL.md` — review pipeline, per-finding decision, verdict mapping, draft-window override
- `skills/soloscrum-define-issue-format/SKILL.md` — Issue body format
- `skills/soloscrum-define-issue-size/SKILL.md` — size thresholds and split criteria
- `skills/soloscrum-define-branch-commit/SKILL.md` — branch naming and Conventional Commits
- `skills/soloscrum-define-dod/SKILL.md` — DoD checklist
- `skills/soloscrum-define-tracker-profile/SKILL.md` — profile resolution

Commands the user invokes:

- `/refine`, `/breakdown`, `/develop`, `/review` — see `commands/`

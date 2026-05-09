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

## Permission settings

Two layered files under `.claude/`:

- **`.claude/settings.json`** — repo-shared, **committed**. Curated allowlist of safe / reversible operations (read-only `gh` queries, `gh pr create` / `gh pr ready` / `gh pr review` / `gh pr comment`, `gh issue create` / `gh issue edit` / `gh issue comment`, `gh api` / `gh label`, all `git` operations except force-push / hard-reset, `coderabbit review`, `find` / `grep` / `rg` / `ls` / `cat` / `jq`, `Write(/tmp/**)`, the `wait-for-pr-checks.sh` script). Plus a `deny` list for truly destructive ops (`rm`, force-push, `git reset --hard`, `gh repo delete`, `gh issue delete`).
- **`.claude/settings.local.json`** — per-user, **gitignored**. Personal additions (e.g. paths to local plugin caches, ad-hoc `tee` patterns picked up during a session). Never committed.

Operations **deliberately not pre-approved** (require per-invocation user prompt by design):

- `gh pr merge` — always user-gated per `soloscrum-define-pr-lifecycle`
- `gh issue close` — `/refine` janitor uses it but each invocation should be visible to the user (per #20 discussion: closing is reversible but its semantics matter)
- `gh pr close` — same reasoning

Operations **denied entirely** (cannot be approved without editing settings):

- `rm` / `rmdir` family — destructive filesystem changes
- `git push --force` / `git push -f` / `git push --force-with-lease` — overwrites shared history
- `git reset --hard` / `git clean -f` — discards uncommitted work
- `git branch -D` — force-deletes branches without merge check
- `gh repo delete` / `gh issue delete` — irreversible
- `gh api -X DELETE:*` / `gh api --method DELETE:*` — REST DELETE through the generic gh client (since `gh api:*` itself is allowed, the explicit deny is required to block destructive verbs)

**Caveat about `gh api`**: the allow entry `Bash(gh api:*)` covers read-mostly use (REST queries, GraphQL queries-and-mutations) but inherently includes writes via `--method PUT/POST/PATCH`. The deny rules above cover DELETE; PUT/POST/PATCH writes are left to per-call user judgment because some are routine (e.g. dismissing reviews) and some are not (e.g. modifying repo settings). When unsure, prefer specific `gh issue …` / `gh pr …` subcommands over generic `gh api`.

When the user accepts an unfamiliar command at the harness prompt, that decision applies to that invocation only — it does not persist to `settings.json` automatically. Patterns observed across multiple sessions and judged universally safe should be promoted from `settings.local.json` (or per-prompt acceptance) into the committed `settings.json` via a `/develop` flow that explains the addition.

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

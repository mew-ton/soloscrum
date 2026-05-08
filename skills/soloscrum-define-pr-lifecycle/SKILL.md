---
name: soloscrum-define-pr-lifecycle
description: "Reference: PR phases (draft → review → ready → merge-handoff) and per-transition autonomy rules. Reversible transitions (gh pr create --draft, gh pr ready) run without pre-confirm; irreversible transitions (gh pr merge) are gated to the user. Used by implement-task, review-implementation, and the code-review-process verdict mapping."
user-invocable: false
---

# soloscrum-define-pr-lifecycle

Defines how a PR moves from creation to merge handoff, and which transitions an agent may execute autonomously vs which require the user as the final gate.

## Contract (read this first)

This skill establishes a project-specific autonomy contract that **overrides** any general default of "ask before doing anything PR-related." When the agent executes a soloscrum command (`/develop`, `/review`), the user has already authorised the full action sequence the command implies. Re-prompting for individual reversible steps inside that sequence is the failure mode this skill exists to prevent.

The contract has three rules:

1. **Reversible transitions are autonomous.** `gh pr create --draft`, `gh pr ready`, `gh pr review --approve`, `gh pr comment`, label edits, tracker state transitions — execute, then report. Do not ask.
2. **Irreversible transitions are user-gated.** `gh pr merge`, force-push to a shared branch, branch deletion. The agent surfaces the exact command and stops.
3. **The verdict is the decision point.** Once `soloscrum-review` produces a verdict, the post-verdict action sequence in `soloscrum-define-code-review-process` runs through to completion (or to the merge handoff) without further prompts. There is no "I'll just double-check" detour for reversible steps.

The autonomy table below is the authoritative classification for every PR-side transition in soloscrum. If a transition is in the reversible table, the agent executes it without pre-confirm. If it is in the irreversible table, the agent stops and surfaces the command. Any transition not listed defaults to **irreversible until classified here**.

## Phases

A PR moves through four phases. Each phase has a single owner role and a defined exit transition.

| Phase | State on GitHub | Owner role | Purpose | Exit transition |
|---|---|---|---|---|
| `draft` | PR open, marked draft | `soloscrum-dev` | Implementation lands; GitHub-side auto-reviewers are suppressed; local quality gate runs in this window | `/review` is launched |
| `review` | PR open, draft (still) | `soloscrum-review` | DoD + AC verification; CodeRabbit CLI + multi-agent pipeline; per-finding decisions | Verdict reached |
| `ready` | PR open, ready (non-draft) | `soloscrum-review` | Verdict was Pass / Pass with follow-ups; PR is mergeable; tracker state is `done` | `gh pr ready` lands |
| `merge-handoff` | PR open, ready, approved | **user** | Final human gate before merge — agent does not run `gh pr merge` | User runs `gh pr merge` |

The PR is created directly in `draft` (step in `soloscrum-implement-task`). It does **not** start as ready and get demoted; agents never demote a ready PR back to draft on their own.

### Why a draft window exists

Two independent reasons. Either alone is sufficient justification:

1. **Auto-reviewer suppression** — GitHub-side reviewers (CodeRabbit, etc.) typically do not run on draft PRs. Holding the PR in draft until local review has decided every finding avoids redundant or conflicting GitHub-side comments and avoids burning paid review credits on a PR that the local pipeline will likely require changes to.
2. **Self-quality gate** — even when no GitHub-side reviewer exists for the org, the draft phase is the explicit window for the local CodeRabbit CLI + multi-agent pipeline to run before the PR is "presented as ready." This gives the verdict semantics in `soloscrum-define-code-review-process` a concrete state to attach to.

### CodeRabbit availability and the draft window

CodeRabbit may be configured per organisation as **paid** (auto-reviews on PR open / ready), **free** (limited triggers), or **absent**. The draft window is robust to all three:

- paid / free → draft suppresses the auto-review until the local pipeline has already addressed findings
- absent → the draft window still exists for the self-quality-gate reason above; the `gh pr ready` step is then a near-no-op signal to humans, but autonomy rules still apply

A repository may override the default (always start as `--draft`) via `.claude/rules/pr.md` if the org-specific reviewer setup makes the draft window genuinely unnecessary. The override surface is intentionally not specified in the soloscrum core; repositories that need it document the rule locally and consume it from `soloscrum-implement-task`. Until that override is set, treat `--draft` as the default.

## Autonomy rules

Each transition is classified as **reversible** or **irreversible**. The classification determines whether an agent may execute it without first asking the user.

### Reversible transitions — execute without pre-confirm

A transition is reversible when undoing it requires only one further command and leaves no externally visible side effect that cannot be retracted in the same session. Agents may run these autonomously as part of their normal flow:

| Transition | Command | How to undo |
|---|---|---|
| Create draft PR | `gh pr create --draft` | `gh pr close` — the PR is closed; because it was never marked ready, no reviewer notifications were ever fired |
| Promote to ready | `gh pr ready` | `gh pr ready --undo` (returns the PR to draft) |
| Approve PR review | `gh pr review --approve` | dismiss the review (`gh api --method PUT .../reviews/<id>/dismissals`) |
| Comment on PR | `gh pr comment` | `gh api --method DELETE` on the comment |
| Add / remove labels | `gh issue edit --add-label / --remove-label` | reverse the edit |
| Tracker state transition | (delegated to `soloscrum-tracker-{profile}-transition-state`) | call again with previous state |

Reversibility is the contract. An agent that pauses to ask "may I run `gh pr ready`?" after a Pass verdict is over-cautious — the action is reversible, the verdict is the decision. Pausing here is the failure mode this skill exists to prevent.

### Irreversible transitions — require user pre-confirm

A transition is irreversible when undoing it is impossible, requires admin intervention, or has externally visible side effects (notifications, downstream automation, cost) that cannot be cleanly retracted. Agents must surface a clear summary and obtain explicit user confirmation before running:

| Transition | Why irreversible |
|---|---|
| `gh pr merge` | Commits land on the base branch; downstream CI / deploys / notifications fire; cannot be cleanly undone |
| `git push --force` to a shared branch | Overwrites others' history |
| `gh pr close` *with* `--delete-branch` on a PR with no other backup | Branch is gone |
| Anything that triggers paid external automation | Cost is incurred |

`gh pr merge` is **always** user-gated in soloscrum, regardless of verdict. The agent's role ends at "PR is ready, tracker is `done`, here is the merge command." The user runs the merge.

### How agents apply this

- Before executing a transition, classify it by the table above.
- If reversible: execute, then report what was done in one line.
- If irreversible: surface a one-line summary + the exact command, and wait.
- Do **not** invent a third "I'll ask just to be safe" path for reversible transitions. The autonomy rules are the contract.

## Verdict → next-action mapping

This is the bridge between `soloscrum-define-code-review-process` (which produces the verdict) and the lifecycle phases above. The full per-finding decision rules live in that skill; this section only covers what happens **after** the verdict.

| Verdict | Next action by `soloscrum-review` | User pre-confirm? |
|---|---|---|
| **Pass** | `gh pr review --approve` → tracker Subtask `→ done` → `gh pr ready` → report merge command to user | No (all reversible) |
| **Pass with follow-ups** | Confirm follow-up Issues exist for each out-of-scope skip → same actions as Pass | No (all reversible) |
| **Fail** | Post per-finding feedback → tracker Subtask `→ in-progress` → leave PR in `draft` (do **not** call `gh pr ready`) | No (all reversible) |
| (any verdict) → merge | User runs `gh pr merge` | **Yes (user gate)** |

On Fail, leaving the PR in draft is intentional: it makes the "needs more work" state externally visible and avoids accidentally inviting a GitHub-side review on an unfinished PR.

## Anti-patterns

These are the specific failure modes this skill exists to prevent. Each one has caused a real incident; do not reintroduce them.

- ❌ **After a Pass verdict, asking the user "may I run `gh pr ready`?"** This is the canonical failure (observed in `pplevrc/cms#17`). The verdict is the decision; `gh pr ready` is a reversible mechanical follow-up. Just run it.
- ❌ **Mid-sequence pause after `gh pr review --approve` or after the tracker `→ done` transition, "to check before promoting".** The post-verdict sequence runs end-to-end. The only stop is at the merge handoff.
- ❌ **On Fail, calling `gh pr ready` anyway** because the PR "looks close enough" or because the user might want to review the diff on GitHub. Fail keeps the PR in draft — that signal is part of the contract.
- ❌ **On Fail, asking the user before reverting the Subtask state to `in-progress`.** State transitions are reversible per the autonomy table; revert and report.
- ❌ **Running `gh pr merge` autonomously** because the verdict was Pass and the user invoked `/review`. Merge is irreversible and is **always** the user's gate, regardless of how clean the PR looks or how recently the user authorised something else.
- ❌ **Treating `gh pr create --draft` as needing pre-confirm** because "creating a PR affects shared state". Draft creation is reversible (close removes it from active state with no notifications having fired) and is the standard opening move of `/develop`.
- ❌ **Inventing a fourth verdict** (e.g. "Pass but I'll wait for the user to look at it first"). The verdict legend in `soloscrum-define-code-review-process` is exhaustive; pick one and execute its mapped sequence.

## Repository-specific overrides

Repository-specific rules in `.claude/rules/pr.md` (when present) take precedence — typically used to document org-level CodeRabbit configuration, alternative auto-reviewer setups, or branch-protection-imposed differences. The soloscrum core does not specify this file's schema.

## Notes

- This skill is profile-agnostic — phases and autonomy are the same under `github-only` and `linear+github`.
- For who-may-mutate-what at the concept level, see `soloscrum-define-agent-responsibilities`. This skill governs *how* the PR-side mutations are executed; that one governs *which agent* may execute them.

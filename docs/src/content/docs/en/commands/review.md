---
title: /review
description: Verifies DoD and AC, runs CodeRabbit + multi-agent review, decides each finding, posts a verdict, and on Pass promotes the PR to ready and surfaces the merge command.
sidebar:
  order: 4
---

`/review` is the quality gate. It reads the draft PR opened by `/develop`, verifies the [DoD](/policies/dod/) and every Issue AC, runs CodeRabbit and a multi-agent review pipeline, decides each finding individually, and posts a Pass / Pass with follow-ups / Fail verdict. On Pass it transitions the Subtask to `done`, waits for CI green, promotes the PR to ready, and surfaces the exact `gh pr merge` command for you to run. The merge itself is **always** your gate.

## Usage

```bash
/review <pr-url or figma-url>
```

For PR review, pass the PR URL or number. For design-fidelity review of a Figma file (`type:design-ui` Subtasks), pass the Figma URL.

## What happens

1. **DoD verification.** Every checklist item in the [DoD](/policies/dod/) is checked. The PR body must contain a closing keyword (`Closes #N`); lint must be clean; tests must exist where applicable; AC must be satisfied.
2. **AC verification.** Every checkbox in the parent Issue's AC is verified against the diff and the running build.
3. **CodeRabbit run.** The CodeRabbit CLI runs against the diff. Even a "No findings" result still requires the multi-agent pass — skipping the multi-agent step because the PR is small or docs-only is a named anti-pattern.
4. **Multi-agent review.** Specialist agents (security, accessibility, performance, etc.) review the diff in parallel. Findings with confidence ≥ 80 are consolidated.
5. **Per-finding decision.** Each surviving finding is decided individually: fix it, or skip it with a stated reason. Severity is informational, not a skip reason.
6. **Verdict.** Pass / Pass with follow-ups / Fail is posted as a structured PR comment. The verdict comment is the formal record.
7. **Post-verdict actions.** On Pass: approve the PR (`gh pr review --approve`, see the self-approve note below), transition the Subtask to `done`, wait for CI to go green, promote the PR to ready (`gh pr ready`), and surface the merge command. On Fail: post per-finding feedback, revert the Subtask to `in-progress`, leave the PR in draft.

## Typical flow

You finished `/develop` and have a draft PR URL like `https://github.com/<owner>/<repo>/pull/123`. You run `/review https://github.com/<owner>/<repo>/pull/123`. The Review agent walks the DoD checklist, ticks AC against the diff, runs CodeRabbit, runs the multi-agent pipeline, and decides every flagged finding. Each one ends as either "fixed in commit X" or "skipped because <reason>" — there is no "I'll think about this later" path; the verdict resolves every finding.

If the verdict is Pass, the agent runs `gh pr review --approve` (which fails with a self-approve refusal in solo-dev — that is expected; the verdict comment is the formal Pass record). It transitions the Subtask to `done` via the active tracker, waits for CI via `skills/soloscrum-tracker-github-wait-for-pr-checks/scripts/wait-for-pr-checks.sh <pr>`, and runs `gh pr ready`. If CI goes red during the wait, the Pass retroactively downgrades to Fail. Finally, the agent surfaces the merge command — `gh pr merge <pr-number> --squash` or whatever the repo prefers — and stops. **Running `gh pr merge` is your job, not the agent's**, regardless of how clean the verdict was.

If the verdict is Fail, the agent posts per-finding feedback to the PR, reverts the Subtask state to `in-progress`, and leaves the PR in draft so the "needs more work" signal is externally visible. You then run `/develop` again to address the findings, and re-run `/review` once the next iteration is ready.

### Self-approve refusal

GitHub does not let a PR's author approve their own PR. In solo-dev — the default soloscrum is built around — `gh pr review --approve` fails with `Can not approve your own pull request`. This is **not** a Fail. The verdict comment posted on the PR is the formal Pass record; the API-side approval is a duplicate signal solo-dev structurally cannot produce. The implementation is a try-and-fall-through:

```bash
gh pr review --approve "$PR_URL" \
  || echo "approve skipped (likely self-approve refusal); verdict comment is the formal Pass record"
```

The post-verdict sequence — tracker `→ done`, CI wait, `gh pr ready`, surfacing the merge command — runs anyway.

## Output

- A structured verdict comment on the PR: DoD checklist, AC checklist, per-finding decisions, verdict.
- On Pass: Subtask state advanced to `done`, PR promoted to ready, the `gh pr merge` command surfaced for you to run.
- On Fail: per-finding feedback posted to the PR, Subtask reverted to `in-progress`, PR left in draft.

The Issue itself is **not** closed by `/review` — closure happens at merge time via the PR body's `Closes #N` keyword and GitHub's auto-close. See [PR lifecycle](/concept/pr-lifecycle/) for why.

## See also

- [Agents and responsibilities](/concept/agent-responsibilities/) — Review is the only role that issues a Pass.
- [PR lifecycle](/concept/pr-lifecycle/) — autonomy contract, reversible vs irreversible, why merge is always your gate.
- [Code review process](/concept/code-review-process/) — the per-finding decision rules and verdict mapping.
- [DoD](/policies/dod/) — the checklist `/review` decides against.
- Previous in the lifecycle: [`/develop`](/commands/develop/).
- Canonical contract: [`commands/review.md`](https://github.com/mew-ton/soloscrum/blob/main/commands/review.md).

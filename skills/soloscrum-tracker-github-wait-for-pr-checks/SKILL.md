---
name: soloscrum-tracker-github-wait-for-pr-checks
description: "Operation: poll a GitHub PR's CI status checks until all of them complete (or until a timeout) and return their conclusions. Used by /develop and /review when the next step depends on green CI. Profile-agnostic — PRs live on GitHub regardless of tracker_profile, so both `github-only` and `linear+github` route here."
user-invocable: false
allowed-tools:
  - Bash(gh pr view:*)
  - Bash(sleep:*)
---

# soloscrum-tracker-github-wait-for-pr-checks

Wait for all status checks on a GitHub PR to complete (success or failure), then return the per-check conclusions. Active in **both** `github-only` and `linear+github` profiles — PRs are on GitHub in either case.

## Why this is a skill, not an inline shell loop

Until now, agents (Claude Code et al.) wrote a bespoke `until` loop with the PR number embedded in the command string and an inline `jq` filter. That has two problems:

1. **Permission allowlist cannot match.** Each PR has a different number, so the command string changes per PR; a harness allowlist like `Bash(gh pr view:*)` matches but the user gets prompted for every distinct invocation. Wrapping the wait in a stable skill surface lets harnesses match on the skill name and skip per-PR re-prompting.
2. **The `jq` filter drifts.** Each agent writes the filter slightly differently (e.g. handling of `null`-named rollup entries), so allowlist matching at the command-string level breaks. A canonical implementation here removes the variance.

Beyond allowlist hygiene, this also stops the same loop from being reinvented every session.

## Inputs

- `pr_number` — the PR number on the active GitHub repo (e.g. `42`)
- (optional) `poll_interval_sec` — default `15`. How often to re-query.
- (optional) `timeout_sec` — default `1800` (30 minutes). Hard cap on wait time. `0` disables the cap (wait forever — only set when the user knows the CI tail is long).

## Steps

1. Query the PR's status check rollup:

   ```bash
   gh pr view "$pr_number" --json statusCheckRollup \
     --jq '[.statusCheckRollup[] | select(.name != null)]'
   ```

   The `select(.name != null)` filter drops the rollup overall summary (which has no `name`).

2. If every check has `.status == "COMPLETED"`, stop. Otherwise sleep `poll_interval_sec` and re-query.

3. If the elapsed wall-clock time exceeds `timeout_sec` (and `timeout_sec > 0`), exit with a non-zero status and surface the in-flight check names so the caller can decide whether to extend the wait or fail the parent step.

4. On completion, return the conclusions:

   ```bash
   gh pr view "$pr_number" --json statusCheckRollup \
     --jq '[.statusCheckRollup[] | select(.name != null) | {name: .name, conclusion: .conclusion}]'
   ```

## Output

A JSON array of `{name, conclusion}` entries — one per check. Conclusions are GitHub's standard set: `SUCCESS`, `FAILURE`, `CANCELLED`, `SKIPPED`, `TIMED_OUT`, `NEUTRAL`, `ACTION_REQUIRED`, `STARTUP_FAILURE`.

Example:

```json
[
  {"name": "typecheck", "conclusion": "SUCCESS"},
  {"name": "test", "conclusion": "SUCCESS"},
  {"name": "lint", "conclusion": "FAILURE"}
]
```

The caller is responsible for deciding what to do with non-`SUCCESS` conclusions — this skill only waits for completion, it does not interpret pass/fail.

## When to invoke

- **`/develop`**: after `gh pr create --draft`, before handing off to `/review`. Lets `/develop` confirm CI started cleanly (typically only the first check or two are surfaced this early; setting a short `timeout_sec` like `300` is reasonable here).
- **`/review`**: as part of step 6 (Pass post-verdict actions) before `gh pr ready`. The PR is about to be promoted to ready; waiting for green CI here means the user does not see a freshly-ready PR with red checks.
- **Post-merge handoff**: not applicable — once `gh pr merge` runs, the user is in control.

## Notes

- This skill is the **only** sanctioned way to wait for PR CI inside soloscrum. Inline `until` loops over `gh pr view` are an anti-pattern (permission allowlist + reinvention).
- `gh pr view --json statusCheckRollup` returns checks both for the head SHA's `commit_status` API and the `check_runs` API; both are flattened into `statusCheckRollup`. The `select(.name != null)` filter is required because the rollup overall summary entry has no name and would otherwise pollute results.
- Both tracker profiles route here. There is **no** `soloscrum-tracker-linear-wait-for-pr-checks` because the operation has no Linear-side variant — Linear does not manage PR CI; PRs live on GitHub regardless of profile.
- For `--draft` PRs, `statusCheckRollup` still populates as soon as workflows run on the head ref. This skill works on draft and ready PRs alike.

## Depends On

- `soloscrum-define-pr-lifecycle` — the `/review` Pass-action sequence is the primary caller
- `soloscrum-define-tracker-profile` — both profiles route here, documented above

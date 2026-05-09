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

## Why the rollup is two-shaped

`gh pr view --json statusCheckRollup` returns a mixed array of two GraphQL types:

- **`CheckRun`** — modern Checks API. Has `name` (string), `status` (`QUEUED` / `IN_PROGRESS` / `WAITING` / `PENDING` / `REQUESTED` / `COMPLETED`), `conclusion` (`SUCCESS` / `FAILURE` / `CANCELLED` / `SKIPPED` / `TIMED_OUT` / `NEUTRAL` / `ACTION_REQUIRED` / `STARTUP_FAILURE` / `null` while in flight).
- **`StatusContext`** — legacy commit-status API (e.g. `vercel`, `ci/codesandbox`, `coderabbit`). Has `context` (string, **not** `name`), `state` (`PENDING` / `EXPECTED` / `SUCCESS` / `FAILURE` / `ERROR`). No `status` / `conclusion` fields.

A naive `select(.name != null)` filter drops every `StatusContext` entry, which makes the loop falsely "complete" the moment a PR's checks are entirely commit-status (legacy CI providers, common CodeRabbit-only configs). The skill MUST normalize the two shapes before deciding completion.

## Steps

1. Query the PR's status check rollup, normalizing into a single `{name, status, conclusion}` shape:

   ```bash
   gh pr view "$pr_number" --json statusCheckRollup --jq '
     [.statusCheckRollup[] | {
       name: (.name // .context),
       status: (.status // (
         if (.state == "PENDING" or .state == "EXPECTED")
         then "IN_PROGRESS"
         else "COMPLETED"
         end
       )),
       conclusion: (.conclusion // .state)
     }]
   '
   ```

   - `name` falls back to `context` for legacy commit-status entries.
   - `status` for StatusContext is synthesized: `PENDING` / `EXPECTED` → `IN_PROGRESS`, anything else → `COMPLETED`.
   - `conclusion` for StatusContext falls back to `state` (so `SUCCESS` / `FAILURE` / `ERROR` surface in the output).

2. **Empty-rollup guard.** If the normalized array is empty, the PR has not yet registered any check (typical right after `gh pr create --draft` — workflows take a few seconds to dispatch). Treat this as "not ready" rather than "all complete": sleep `poll_interval_sec` and re-query. Without this guard, the all-complete check is vacuously true on an empty array and the loop would exit before any CI starts. The empty-rollup state is bounded by `timeout_sec` like any other in-flight state.

3. **Completion check.** If the normalized array is non-empty AND every entry has `status == "COMPLETED"`, stop. Otherwise sleep `poll_interval_sec` and re-query.

4. **Timeout.** If elapsed wall-clock time exceeds `timeout_sec` (and `timeout_sec > 0`), exit non-zero and surface the names of any entries with `status != "COMPLETED"` so the caller can decide whether to extend the wait or fail the parent step.

5. **On completion**, return:

   ```bash
   gh pr view "$pr_number" --json statusCheckRollup --jq '
     [.statusCheckRollup[] | {
       name: (.name // .context),
       conclusion: (.conclusion // .state)
     }]
   '
   ```

## Output

A JSON array of `{name, conclusion}` entries — one per check. Conclusions are normalized across both shapes:

- CheckRun: GitHub's standard set (`SUCCESS`, `FAILURE`, `CANCELLED`, `SKIPPED`, `TIMED_OUT`, `NEUTRAL`, `ACTION_REQUIRED`, `STARTUP_FAILURE`)
- StatusContext: `SUCCESS`, `FAILURE`, `ERROR` (the `state` value)

Example:

```json
[
  {"name": "typecheck", "conclusion": "SUCCESS"},
  {"name": "test", "conclusion": "SUCCESS"},
  {"name": "vercel", "conclusion": "SUCCESS"},
  {"name": "lint", "conclusion": "FAILURE"}
]
```

The caller is responsible for deciding what to do with non-`SUCCESS` conclusions — this skill only waits for completion, it does not interpret pass/fail. Callers that want green-only should treat `SUCCESS`, `SKIPPED`, and `NEUTRAL` as acceptable; everything else as fail.

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

---
name: soloscrum-tracker-github-wait-for-pr-checks
description: "Operation: poll a GitHub PR's CI status checks until all of them complete (or until a timeout) and return their conclusions. Used by /develop and /review when the next step depends on green CI. Profile-agnostic — PRs live on GitHub regardless of tracker_profile, so both `github-only` and `linear+github` route here."
user-invocable: false
allowed-tools:
  - Bash(./scripts/wait-for-pr-checks.sh:*)
---

# soloscrum-tracker-github-wait-for-pr-checks

Wait for all status checks on a GitHub PR to complete (success or failure), then return the per-check conclusions. Active in **both** `github-only` and `linear+github` profiles — PRs are on GitHub in either case.

## How it works

The implementation is a single shell script colocated with this skill at `./scripts/wait-for-pr-checks.sh`. The script encapsulates the polling loop, the `gh pr view` invocation, the rollup-normalisation `jq` filter, the empty-rollup guard, and the timeout logic. The skill itself is documentation; agents invoke the script directly.

```
./scripts/wait-for-pr-checks.sh <pr_number> [poll_interval_sec] [timeout_sec]
```

### Why a script and not an inline loop

Two practical reasons beyond reinvention:

1. **Permission allowlist matches a stable surface.** An inline `until ...; do gh pr view <N> ... ; sleep ...` loop has the PR number in the command string, so a harness allowlist on `Bash(gh pr view:*)` re-prompts the user on every distinct invocation. With the wait extracted to `./scripts/wait-for-pr-checks.sh`, the allowlist entry `Bash(./scripts/wait-for-pr-checks.sh:*)` matches every call regardless of PR number, and the inner `gh` / `sleep` calls happen inside the already-allowed script.
2. **The polling logic is fixed.** The script is the canonical implementation of the rollup normalisation (see "Why the rollup is two-shaped" below); agents do not re-derive the `jq` filter per session.

This is also why the skill's `allowed-tools` lists only the script path — not `gh pr view` or `sleep`. Inner calls are a script-private concern.

## Inputs

- `pr_number` — the PR number on the active GitHub repo (e.g. `42`)
- (optional) `poll_interval_sec` — default `15`. How often to re-query.
- (optional) `timeout_sec` — default `1800` (30 minutes). Hard cap on wait time. `0` disables the cap (wait forever — only set when the user knows the CI tail is long).

## Output

On success (exit `0`): a JSON array of `{name, conclusion}` entries — one per check — written to stdout.

On timeout (exit `1`): nothing on stdout; the names of in-flight checks are written to stderr.

On argument error (exit `2`): a usage message on stderr.

Conclusions are normalized across the two GraphQL types `gh pr view --json statusCheckRollup` mixes (see next section):

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

The caller decides what to do with non-`SUCCESS` conclusions — this skill only waits for completion, it does not interpret pass/fail. Callers that want green-only should treat `SUCCESS`, `SKIPPED`, and `NEUTRAL` as acceptable; everything else as fail.

## Why the rollup is two-shaped

`gh pr view --json statusCheckRollup` returns a mixed array of two GraphQL types. The script normalises both into `{name, status, conclusion}` before deciding completion, so callers do not need to know about the difference:

- **`CheckRun`** — modern Checks API. Has `name` (string), `status` (`QUEUED` / `IN_PROGRESS` / `WAITING` / `PENDING` / `REQUESTED` / `COMPLETED`), `conclusion` (`SUCCESS` / `FAILURE` / `CANCELLED` / `SKIPPED` / `TIMED_OUT` / `NEUTRAL` / `ACTION_REQUIRED` / `STARTUP_FAILURE` / `null` while in flight).
- **`StatusContext`** — legacy commit-status API (e.g. `vercel`, `ci/codesandbox`, `coderabbit`). Has `context` (string, **not** `name`), `state` (`PENDING` / `EXPECTED` / `SUCCESS` / `FAILURE` / `ERROR`). No `status` / `conclusion` fields.

A naive `select(.name != null)` filter would drop every `StatusContext` entry, falsely "completing" the loop the moment a PR's checks are entirely commit-status. The script normalisation maps `name = .name // .context`, synthesises `status` from `.state` for StatusContext (`PENDING` / `EXPECTED` → `IN_PROGRESS`, else `COMPLETED`), and falls back `conclusion = .conclusion // .state`.

The empty-rollup case (workflows have not yet registered, typical right after `gh pr create --draft`) is treated as "not ready" rather than "all complete" — without that guard, the all-complete predicate is vacuously true on an empty array and the loop would exit before any CI starts.

## When to invoke

- **`/develop`**: after `gh pr create --draft`, before handing off to `/review`. Lets `/develop` confirm CI started cleanly (typically only the first check or two are surfaced this early; setting a short `timeout_sec` like `300` is reasonable here).
- **`/review`**: as part of step 6 (Pass post-verdict actions) before `gh pr ready`. The PR is about to be promoted to ready; waiting for green CI here means the user does not see a freshly-ready PR with red checks.
- **Post-merge handoff**: not applicable — once `gh pr merge` runs, the user is in control.

## Notes

- This skill is the **only** sanctioned way to wait for PR CI inside soloscrum. Inline `until` loops over `gh pr view` are an anti-pattern (permission-allowlist churn + reinvention).
- Both tracker profiles route here. There is **no** `soloscrum-tracker-linear-wait-for-pr-checks` because the operation has no Linear-side variant — Linear does not manage PR CI; PRs live on GitHub regardless of profile.
- For `--draft` PRs, `statusCheckRollup` populates as soon as workflows run on the head ref. The script works on draft and ready PRs alike.
- The script has no external dependencies beyond `gh`, `jq`, and a POSIX shell — these are already required by every soloscrum operation.

## Depends On

- `soloscrum-define-pr-lifecycle` — the `/review` Pass-action sequence is the primary caller
- `soloscrum-define-tracker-profile` — both profiles route here, documented above

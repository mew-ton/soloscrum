#!/usr/bin/env bash
#
# wait-for-pr-checks.sh — poll a GitHub PR's status checks until all are
# COMPLETED, then output the per-check conclusions as JSON.
#
# Usage (invoke from the repository root, using the full path):
#   skills/soloscrum-tracker-github-wait-for-pr-checks/scripts/wait-for-pr-checks.sh \
#     <pr_number> [poll_interval_sec] [timeout_sec]
#
# Do NOT cd into the skill directory and do NOT call as ./scripts/...
# The harness allowlist matches the literal command string; using a single
# canonical full-path form avoids per-form re-prompting.
#
# Args:
#   pr_number          GitHub PR number on the active repo (required).
#   poll_interval_sec  Seconds between polls. Default: 15.
#   timeout_sec        Hard cap on total wait time. Default: 1800. Set to
#                      0 to disable (wait forever).
#
# Output (stdout, on success):
#   JSON array of {name, conclusion} entries — one per check. The names
#   and conclusions are normalized across the two GraphQL types that
#   gh's statusCheckRollup mixes:
#     - CheckRun (modern Checks API): has .name, .status, .conclusion.
#     - StatusContext (legacy commit status, e.g. vercel, ci/codesandbox):
#       has .context, .state. No .status / .conclusion.
#
#   Normalization: name = .name // .context; status synthesized from
#   .state for StatusContext (PENDING/EXPECTED → IN_PROGRESS, else
#   COMPLETED); conclusion = .conclusion // .state.
#
# Exit:
#   0  All checks COMPLETED, conclusions on stdout.
#   1  Timeout reached. The names of in-flight checks are written to
#      stderr; nothing on stdout.
#   2  Argument or runtime error.
#
# Why this is a script and not an inline loop:
#   Inline `until ...; do gh pr view ...; sleep ...; done` constructs
#   embed the PR number in the command string and use bespoke jq
#   filters per agent. Harness allowlists cannot match per-PR strings,
#   so the user is re-prompted on every invocation. A stable script
#   path lets the harness allow Bash(.../wait-for-pr-checks.sh:*) once
#   and skip subsequent prompts. See the SKILL.md for full rationale.

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "usage: wait-for-pr-checks.sh <pr_number> [poll_interval_sec] [timeout_sec]" >&2
  exit 2
fi

pr_number="$1"
poll_interval_sec="${2:-15}"
timeout_sec="${3:-1800}"

# Validate numeric args.
case "$pr_number"         in ''|*[!0-9]*) echo "pr_number must be a positive integer" >&2; exit 2 ;; esac
case "$poll_interval_sec" in ''|*[!0-9]*) echo "poll_interval_sec must be a non-negative integer" >&2; exit 2 ;; esac
case "$timeout_sec"       in ''|*[!0-9]*) echo "timeout_sec must be a non-negative integer (0 disables)" >&2; exit 2 ;; esac

# Normalizing jq filter — produces [{name, status, conclusion}, ...]
# from statusCheckRollup, handling both CheckRun and StatusContext.
read -r -d '' NORMALIZE <<'JQ' || true
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
JQ

start_epoch=$(date +%s)

while :; do
  rollup=$(gh pr view "$pr_number" --json statusCheckRollup --jq "$NORMALIZE")
  count=$(printf '%s' "$rollup" | jq 'length')

  # Empty rollup means workflows have not registered yet — typical
  # right after `gh pr create --draft`. Treat as "not ready" rather
  # than "all complete" so the loop does not exit before any CI runs.
  if [ "$count" -gt 0 ]; then
    pending=$(printf '%s' "$rollup" | jq '[.[] | select(.status != "COMPLETED")] | length')
    if [ "$pending" -eq 0 ]; then
      # All complete — emit the conclusions and exit successfully.
      printf '%s' "$rollup" | jq '[.[] | {name: .name, conclusion: .conclusion}]'
      exit 0
    fi
  fi

  # Timeout check (skip when timeout_sec == 0).
  if [ "$timeout_sec" -gt 0 ]; then
    elapsed=$(( $(date +%s) - start_epoch ))
    if [ "$elapsed" -ge "$timeout_sec" ]; then
      echo "timeout: PR #${pr_number} still in flight after ${elapsed}s" >&2
      if [ "$count" -gt 0 ]; then
        printf '%s' "$rollup" | jq -r '.[] | select(.status != "COMPLETED") | .name' >&2
      else
        echo "(rollup is still empty — no checks have registered)" >&2
      fi
      exit 1
    fi
  fi

  sleep "$poll_interval_sec"
done

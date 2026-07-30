#!/usr/bin/env bash
#
# reclaim-worktrees.sh — remove the git worktrees under soloscrum's worktree
# root whose branch has merged, and report the ones that were kept.
#
# Usage (invoke from the repository root, using the full path):
#   skills/soloscrum-define-worktree/scripts/reclaim-worktrees.sh \
#     [--dry-run] [worktree_root]
#
# Do NOT cd into the skill directory and do NOT call as ./scripts/...
# The harness allowlist matches the literal command string; using a single
# canonical full-path form avoids per-form re-prompting.
#
# Args:
#   --dry-run      Report what would happen; remove nothing.
#   worktree_root  Repo-root-relative directory holding the worktrees.
#                  Default: .soloscrum/worktrees. The caller resolves this
#                  per soloscrum-define-worktree's resolution order and
#                  passes the result; this script does not read config.
#
# Output (stdout):
#   JSON array of {branch, path, action, reason} — one entry per worktree
#   found under the root. `action` is one of:
#     removed  — branch merged and nothing unsaved; worktree and local
#                branch deleted.
#     kept     — branch not merged yet. Normal for work in flight.
#     skipped  — something unsaved or unverifiable. `reason` says what.
#                Never removed; this is the safety path.
#   With --dry-run, "removed" becomes "would-remove" and nothing is deleted.
#
#   Paths are absolute. An empty array means the root holds no worktrees
#   (or does not exist yet), which is not an error.
#
# Exit:
#   0  Pass completed; report on stdout. Skipped entries do not fail the run.
#   2  Argument or runtime error (bad root, not a git repository).
#
# Merged test, in order (see soloscrum-define-worktree, "Merged test"):
#   1. `gh pr list --head <branch> --state merged` non-empty. Leads because
#      it survives a squash merge, which rewrites the commits and breaks the
#      ancestry test for work that actually shipped.
#   2. `git merge-base --is-ancestor <branch> origin/<default>`. Covers
#      branches merged without a PR, and environments without `gh`.
#
# Removal uses `git worktree remove` and `git branch -d` — the forms that
# refuse a dirty worktree and an unmerged branch. That refusal is a second,
# independent guard behind the checks below; the --force / -D variants
# defeat it and are deliberately not used.

set -euo pipefail

dry_run=false
worktree_root=".soloscrum/worktrees"

while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) dry_run=true; shift ;;
    -h|--help)
      echo "usage: reclaim-worktrees.sh [--dry-run] [worktree_root]"
      exit 0
      ;;
    -*) echo "unknown option: $1" >&2; exit 2 ;;
    *)  worktree_root="$1"; shift ;;
  esac
done

case "$worktree_root" in
  /*)    echo "worktree_root must be repo-root-relative, got absolute: $worktree_root" >&2; exit 2 ;;
  ../*|*/../*|*/..) echo "worktree_root must not escape the repository: $worktree_root" >&2; exit 2 ;;
  "")    echo "worktree_root must not be empty" >&2; exit 2 ;;
esac

# Normalise before building the prefix. `git worktree list --porcelain` reports
# canonical paths, so any un-normalised form here fails the containment test at
# process_record and every worktree under a slightly-misconfigured root vanishes
# from the report entirely — neither reclaimed nor flagged. Trailing slashes
# would build a "//" prefix; a leading "./" would build a "/./" segment.
while [ "${worktree_root#./}" != "$worktree_root" ]; do
  worktree_root="${worktree_root#./}"
done
while [ "${worktree_root%/}" != "$worktree_root" ]; do
  worktree_root="${worktree_root%/}"
done
if [ -z "$worktree_root" ]; then
  echo "worktree_root must not resolve to the repository root itself" >&2
  exit 2
fi

# Reject dot segments after normalisation. A bare "." or ".." survives the
# checks above (neither is absolute, and neither matches the ../ patterns), but
# builds a root_abs of "<main>/." or "<main>/.." — the first never matches the
# canonical paths git reports, so every worktree is silently omitted; the second
# points outside the repository entirely. An interior "/./" or "/../" has the
# same effect. Reject rather than resolve: a root that needs normalising to be
# understood is a misconfiguration worth surfacing.
case "/${worktree_root}/" in
  */./*|*/../*)
    echo "worktree_root must not contain '.' or '..' path segments: $worktree_root" >&2
    exit 2
    ;;
esac

# The main checkout's root, resolved from the shared common directory so this
# works identically whether invoked from the main checkout or from a worktree.
common_dir=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || {
  echo "not inside a git repository" >&2
  exit 2
}
main_root=$(dirname "$common_dir")
root_abs="${main_root}/${worktree_root}"

# Default branch, for the ancestry fallback. origin/HEAD is not always set on
# a fresh clone; fall back to the remote's advertised default, then to main.
default_ref=""
if default_ref=$(git rev-parse --abbrev-ref origin/HEAD 2>/dev/null); then
  :
elif command -v gh >/dev/null 2>&1 &&
     db=$(gh repo view --json defaultBranchRef --jq .defaultBranchRef.name 2>/dev/null) &&
     [ -n "$db" ]; then
  default_ref="origin/${db}"
else
  default_ref="origin/main"
fi

has_gh=false
if command -v gh >/dev/null 2>&1; then
  has_gh=true
fi

# The directory this pass is running from. Removing a worktree that a live
# process is sitting in succeeds on Linux — git holds no lock — and leaves that
# process on a path that no longer exists, with every later relative command
# failing opaquely. Git state cannot see this, so it is checked separately.
cwd_real=$(pwd -P 2>/dev/null || true)

# Collect results as ASCII-separator-delimited records (US between fields, RS
# between entries) so branch names and paths never need quoting until jq builds
# the JSON. Git refs cannot contain control characters, so the separators are
# unambiguous.
results=""

emit() { # branch path action reason
  results="${results}$1"$'\x1f'"$2"$'\x1f'"$3"$'\x1f'"$4"$'\x1e'
}

# Walk `git worktree list --porcelain`. Records are blank-line separated;
# within a record we need `worktree <path>` and either `branch <ref>` or
# `detached`.
wt_path=""
wt_branch=""
wt_detached=false

process_record() {
  local local_tip merged reason pr_json pr_number pr_head status_out
  [ -n "$wt_path" ] || return 0

  # Only worktrees under the configured root are ours to reclaim.
  case "$wt_path" in
    "${root_abs}"/*) ;;
    *) return 0 ;;
  esac

  if [ "$wt_detached" = true ] || [ -z "$wt_branch" ]; then
    emit "" "$wt_path" "skipped" "detached HEAD — no branch to test for merge"
    return 0
  fi

  # Never reclaim the worktree the caller is inside, or an ancestor of it.
  case "$cwd_real" in
    "$wt_path"|"$wt_path"/*)
      emit "$wt_branch" "$wt_path" "skipped" "this pass is running from inside this worktree"
      return 0
      ;;
  esac

  # Unsaved work: uncommitted changes (including untracked files). A failing
  # status check is "unverifiable", not "clean" — an empty stdout from a git
  # error would otherwise read identically to a clean tree.
  if ! status_out=$(git -C "$wt_path" status --porcelain 2>/dev/null); then
    emit "$wt_branch" "$wt_path" "skipped" "could not read the worktree's status — state unverifiable"
    return 0
  fi
  if [ -n "$status_out" ]; then
    emit "$wt_branch" "$wt_path" "skipped" "uncommitted changes in the worktree"
    return 0
  fi

  local_tip=$(git -C "$wt_path" rev-parse HEAD 2>/dev/null || true)

  # Merged test 1: a merged PR for this head branch.
  #
  # The PR also settles "is anything unsaved": its headRefOid is the commit
  # GitHub merged, so a local tip equal to it means every local commit reached
  # the remote. That is the only workable check once `gh pr merge
  # --delete-branch` has removed the remote branch — the upstream ref is gone,
  # and after a squash merge the original commits are not ancestors of the
  # default branch either. Comparing against the merged head covers both.
  merged=false
  reason=""
  if [ "$has_gh" = true ]; then
    pr_json=$(gh pr list --head "$wt_branch" --state merged --json number,headRefOid --jq '.[0] | select(.) | "\(.number) \(.headRefOid)"' 2>/dev/null || true)
    if [ -n "$pr_json" ]; then
      pr_number="${pr_json%% *}"
      pr_head="${pr_json##* }"
      if [ "$local_tip" = "$pr_head" ]; then
        merged=true
        reason="PR #${pr_number} merged"
      else
        emit "$wt_branch" "$wt_path" "skipped" "PR #${pr_number} merged at ${pr_head:0:7}, but the local branch is at ${local_tip:0:7} — commits here never reached it"
        return 0
      fi
    fi
  fi

  # Merged test 2: ancestry of the default branch. Self-sufficient on the
  # unsaved question — every commit on the branch is already in the default
  # branch, or it would not be an ancestor.
  if [ "$merged" = false ]; then
    if git merge-base --is-ancestor "$wt_branch" "$default_ref" 2>/dev/null; then
      merged=true
      reason="branch is an ancestor of ${default_ref}"
    fi
  fi

  if [ "$merged" = false ]; then
    if [ "$has_gh" = true ]; then
      emit "$wt_branch" "$wt_path" "kept" "no merged PR and not an ancestor of ${default_ref}"
    else
      emit "$wt_branch" "$wt_path" "kept" "not an ancestor of ${default_ref} (gh unavailable — PR state not checked)"
    fi
    return 0
  fi

  if [ "$dry_run" = true ]; then
    emit "$wt_branch" "$wt_path" "would-remove" "$reason"
    return 0
  fi

  # `remove` refuses a dirty worktree, `-d` refuses an unmerged branch.
  # Either refusal means the checks above and git disagree — keep the work.
  if ! git worktree remove "$wt_path" 2>/dev/null; then
    emit "$wt_branch" "$wt_path" "skipped" "git refused to remove the worktree despite ${reason}"
    return 0
  fi
  if ! git branch -d "$wt_branch" >/dev/null 2>&1; then
    emit "$wt_branch" "$wt_path" "removed" "${reason}; worktree removed, local branch kept (git refused -d)"
    return 0
  fi
  emit "$wt_branch" "$wt_path" "removed" "$reason"
}

if [ -d "$root_abs" ]; then
  # Snapshot the list before processing: process_record removes worktrees, and
  # iterating a live stream while mutating what produced it is asking for it.
  listing=$(git worktree list --porcelain)
  while IFS= read -r line; do
    case "$line" in
      "worktree "*)
        process_record
        wt_path="${line#worktree }"
        wt_branch=""
        wt_detached=false
        ;;
      "branch refs/heads/"*) wt_branch="${line#branch refs/heads/}" ;;
      "detached")            wt_detached=true ;;
    esac
  done <<< "$listing"
  process_record
fi

# Clear administrative entries for worktrees whose directory is gone (deleted
# by hand). Never touches an existing directory.
if [ "$dry_run" = false ]; then
  git worktree prune
fi

printf '%s' "$results" | jq -Rs '
  split("\u001e")
  | map(select(length > 0))
  | map(split("\u001f") | {branch: .[0], path: .[1], action: .[2], reason: .[3]})
'

#!/usr/bin/env bash
#
# list-perspectives.sh — emit every stored review perspective's name and
# description, without reading past each file's frontmatter.
#
# Usage (invoke from the repository root, using the full path):
#   skills/soloscrum-define-review-perspective/scripts/list-perspectives.sh \
#     [--names] [corpus_root]
#
# Do NOT cd into the skill directory and do NOT call as ./scripts/...
# The harness allowlist matches the literal command string; using a single
# canonical full-path form avoids per-form re-prompting.
#
# Args:
#   --names       Emit only the names, one per line. The cheapest possible
#                 scan, for when the caller just needs to know what exists.
#   corpus_root   Directory holding the perspective directories.
#                 Default: ~/.claude/review-perspectives
#
# Output (stdout, default mode):
#   JSON array of {name, description, chars, path}, sorted by name.
#   `chars` is the description length, so a caller can see at a glance which
#   descriptions approach the 2048-character limit the format sets.
#
#   Malformed entries are reported as {name, error, path} rather than dropped.
#   A perspective the selector never sees because its frontmatter is broken is
#   worse than one it sees and rejects — the author has no other signal that
#   the file is inert. `--names` omits them, since a broken entry has no name
#   to act on.
#
#   An absent or empty corpus produces `[]` and exit 0. That is the normal
#   starting state, not an error.
#
# Exit:
#   0  Scan completed; report on stdout. Malformed entries do not fail it.
#   2  Argument error (corpus_root exists but is not a directory).
#
# Why a script:
#   The selection step in soloscrum-define-code-review-process needs only the
#   frontmatter, but reading a perspective file returns the whole body — the
#   checks, the examples, the provenance — which the caller discards for every
#   perspective it does not select. Reading N files to use a fraction of each
#   is the cost this removes. As with wait-for-pr-checks.sh, being a script
#   also gives the harness allowlist one stable command string to match.
#
# Frontmatter parsing:
#   Done in-script rather than by adding a YAML dependency, and deliberately
#   scoped to the forms the perspective format permits: a plain scalar
#   (`name: foo`, optionally quoted) and a block scalar (`description: >` or
#   `|`, with or without a chomping indicator). Anything else is reported as
#   an error rather than guessed at.

set -euo pipefail

names_only=false
corpus_root="${HOME}/.claude/review-perspectives"

while [ $# -gt 0 ]; do
  case "$1" in
    --names) names_only=true; shift ;;
    -h|--help)
      echo "usage: list-perspectives.sh [--names] [corpus_root]"
      exit 0
      ;;
    -*) echo "unknown option: $1" >&2; exit 2 ;;
    *)  corpus_root="$1"; shift ;;
  esac
done

if [ -e "$corpus_root" ] && [ ! -d "$corpus_root" ]; then
  echo "corpus_root exists but is not a directory: $corpus_root" >&2
  exit 2
fi

# An absent corpus is the normal starting state — every other consumer treats
# it that way, so this one does too.
if [ ! -d "$corpus_root" ]; then
  [ "$names_only" = true ] || echo '[]'
  exit 0
fi

# Field and record separators. Git refs and file paths cannot contain control
# characters, and neither can well-formed YAML scalars, so these are
# unambiguous delimiters until jq builds the JSON.
US=$'\037'
RS=$'\036'

# Extracts `name`, `description`, and any parse error from a file's
# frontmatter, as three US-separated fields. Stops at the closing `---`; the
# body is never read.
read -r -d '' PARSE <<'AWK' || true
BEGIN { name = ""; desc = ""; err = ""; inblock = 0; blockfold = 1; done = 0 }

NR == 1 {
  if ($0 != "---") { err = "no frontmatter (first line is not ---)"; done = 1; exit }
  next
}

done { next }

/^---[[:space:]]*$/ && !inblock { done = 1; exit }

{
  # Inside a block scalar, any indented or blank line belongs to it. A line at
  # column 0 ends the block and falls through to the key matching below.
  if (inblock) {
    if ($0 ~ /^[[:space:]]/ || $0 ~ /^[[:space:]]*$/) {
      line = $0
      sub(/^[[:space:]]+/, "", line)
      if (line == "")                       desc = desc "\n"
      else if (desc == "" || desc ~ /\n$/)  desc = desc line
      else                                  desc = desc (blockfold ? " " : "\n") line
      next
    }
    inblock = 0
  }

  if ($0 ~ /^name:[[:space:]]*/) {
    v = $0; sub(/^name:[[:space:]]*/, "", v)
    gsub(/^["']|["']$/, "", v)
    name = v
    next
  }

  if ($0 ~ /^description:[[:space:]]*/) {
    v = $0; sub(/^description:[[:space:]]*/, "", v)
    if (v ~ /^[>|][-+]?[[:space:]]*$/) {
      inblock = 1
      blockfold = (substr(v, 1, 1) == ">")
      next
    }
    if (v == "") { err = "description key has no value and no block indicator"; next }
    gsub(/^["']|["']$/, "", v)
    desc = v
    next
  }
}

END {
  if (err == "") {
    if (name == "")      err = "frontmatter has no name"
    else if (desc == "") err = "frontmatter has no description"
  }
  printf "%s\037%s\037%s", name, desc, err
}
AWK

results=""
while IFS= read -r file; do
  [ -n "$file" ] || continue

  if ! parsed=$(awk "$PARSE" "$file" 2>/dev/null); then
    results="${results}${US}${US}could not read the file${US}${file}${RS}"
    continue
  fi

  results="${results}${parsed}${US}${file}${RS}"
done < <(find "$corpus_root" -mindepth 2 -maxdepth 2 -name PERSPECTIVE.md -type f 2>/dev/null | sort)

if [ "$names_only" = true ]; then
  printf '%s' "$results" | awk -v RS="$RS" -F"$US" 'NF && $1 != "" && $3 == "" { print $1 }'
  exit 0
fi

printf '%s' "$results" | jq -Rs '
  split("\u001e")
  | map(select(length > 0))
  | map(split("\u001f"))
  | map(
      if .[2] != "" then
        {name: (if .[0] == "" then null else .[0] end), error: .[2], path: .[3]}
      else
        {name: .[0], description: .[1], chars: (.[1] | length), path: .[3]}
      end
    )
'

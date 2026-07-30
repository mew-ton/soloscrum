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
#   scoped to the forms this format permits: plain scalars (bare, "double
#   quoted", or 'single quoted') and block scalars (`>` folded or `|` literal,
#   with optional chomping and explicit-indentation indicators). The parser
#   stops at the closing `---`; a body is never read.
#
#   Where it cannot be sure, it emits an error entry rather than a guess. The
#   silent-wrong-answer cases are the ones that matter here: a description the
#   selector reads as ">2" or as half its real text is worse than one it is
#   told is broken.

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

# Field and record separators for the awk -> jq handoff. The parser strips
# these bytes from every value it extracts, so a file containing one cannot
# desync the protocol.
FS_UNIT=$(printf '\037')
FS_REC=$(printf '\036')

# Extracts `name`, `description`, and any parse error from a file's
# frontmatter, as three unit-separated fields.
read -r -d '' PARSE <<'AWK' || true
function strip_seps(s) {
  gsub(SEP_UNIT, "", s)
  gsub(SEP_REC, "", s)
  return s
}

# Resolves a plain YAML scalar: strips a matching quote pair and undoes the
# escaping that pair implies. Bare scalars pass through untouched.
function scalar(v,   inner) {
  if (v ~ /^".*"$/) {
    inner = substr(v, 2, length(v) - 2)
    gsub(/\\"/, "\"", inner)
    gsub(/\\\\/, "\\", inner)
    return inner
  }
  if (v ~ /^'.*'$/) {
    inner = substr(v, 2, length(v) - 2)
    gsub(/''/, "'", inner)
    return inner
  }
  return v
}

function append_block(line) {
  if (line == "")                       desc = desc "\n"
  else if (desc == "" || desc ~ /\n$/)  desc = desc line
  else                                  desc = desc (blockfold ? " " : "\n") line
}

BEGIN {
  SEP_UNIT = sprintf("%c", 31)
  SEP_REC  = sprintf("%c", 30)
  name = ""; desc = ""; err = ""; inblock = 0; blockfold = 1
}

{
  # Normalise line endings and strip a leading BOM. A file that has passed
  # through a CRLF editor is otherwise rejected outright on line 1, and every
  # extracted value on later lines carries a trailing \r that is invisible in a
  # terminal but breaks exact matching on `name` and inflates `chars`.
  sub(/\r$/, "")
  if (NR == 1) sub(/^\xef\xbb\xbf/, "")
}

NR == 1 {
  if ($0 != "---") { err = "no frontmatter (first line is not ---)"; exit }
  next
}

{
  # A block scalar continues through indented and blank lines. Anything at
  # column 0 ends it — including a `---`, which must then be re-tested as the
  # frontmatter terminator rather than dropped.
  if (inblock) {
    if ($0 ~ /^[[:space:]]/ || $0 ~ /^[[:space:]]*$/) {
      line = $0
      sub(/^[[:space:]]+/, "", line)
      append_block(line)
      next
    }
    inblock = 0
  }

  if ($0 ~ /^---[[:space:]]*$/) exit

  if ($0 ~ /^name:[[:space:]]*/) {
    v = $0; sub(/^name:[[:space:]]*/, "", v)
    name = strip_seps(scalar(v))
    next
  }

  if ($0 ~ /^description:[[:space:]]*/) {
    v = $0; sub(/^description:[[:space:]]*/, "", v)

    # Block scalar: `>` or `|`, with optional chomping (-, +) and explicit
    # indentation (a digit) in either order. An unrecognised indicator is an
    # error, not a plain scalar — reading `>2` as the description itself is
    # exactly the silent-wrong-answer this parser must not produce.
    if (v ~ /^[>|]/) {
      if (v ~ /^[>|]([0-9][-+]?|[-+][0-9]?)?[[:space:]]*$/) {
        inblock = 1
        blockfold = (substr(v, 1, 1) == ">")
        next
      }
      err = "unrecognised block scalar indicator on description: " v
      next
    }

    if (v == "") { err = "description key has no value and no block indicator"; next }
    desc = strip_seps(scalar(v))
    next
  }
}

END {
  if (err == "") {
    if (name == "")      err = "frontmatter has no name"
    else if (desc == "") err = "frontmatter has no description"
  }
  printf "%s%c%s%c%s", name, 31, desc, 31, err
}
AWK

results=""
while IFS= read -r file; do
  [ -n "$file" ] || continue

  if ! parsed=$(awk "$PARSE" "$file" 2>/dev/null); then
    results="${results}${FS_UNIT}${FS_UNIT}could not read the file${FS_UNIT}${file}${FS_REC}"
    continue
  fi

  results="${results}${parsed}${FS_UNIT}${file}${FS_REC}"
done < <(find "$corpus_root" -mindepth 2 -maxdepth 2 -name PERSPECTIVE.md -type f 2>/dev/null | sort)

if [ "$names_only" = true ]; then
  printf '%s' "$results" | awk -v RS="$FS_REC" -F"$FS_UNIT" 'NF && $1 != "" && $3 == "" { print $1 }'
  exit 0
fi

printf '%s' "$results" | jq -Rs '
  split("\u001e")
  | map(select(length > 0))
  | map(split("\u001f"))
  | map(
      if (.[2] // "") != "" then
        {name: (if .[0] == "" then null else .[0] end), error: .[2], path: .[3]}
      else
        {name: .[0], description: .[1], chars: (.[1] | length), path: .[3]}
      end
    )
'

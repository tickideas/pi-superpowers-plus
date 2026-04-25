#!/usr/bin/env bash
#
# check-upstream.sh — list obra/superpowers commits that touch files which
# also exist in this fork (skills/, agents/, extensions/).
#
# Usage:
#   scripts/check-upstream.sh                 # since the last-sync anchor
#   scripts/check-upstream.sh 2026-04-02      # since a date
#   scripts/check-upstream.sh dff9fb3         # since a commit (exclusive)
#
# Requires the `obra` git remote pointing at https://github.com/obra/superpowers.git
# (see docs/upstream-sync.md).

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

# Last upstream commit considered during the most recent mirror.
# Update this hash after each sync. (This is an obra/main commit, not a fork commit.)
# Last update: 2026-04-02 sync (fork commit dff9fb3) — upstream HEAD was b7a8f76.
DEFAULT_ANCHOR="b7a8f76"

if ! git remote get-url obra >/dev/null 2>&1; then
  echo "error: 'obra' remote not configured." >&2
  echo "run:   git remote add obra https://github.com/obra/superpowers.git" >&2
  exit 1
fi

git fetch obra --quiet

ARG="${1:-$DEFAULT_ANCHOR}"

# Build a `git log` range/filter. If ARG looks like a date, use --since;
# otherwise treat it as a revision and use the exclusive range ARG..obra/main.
if [[ "$ARG" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
  RANGE_ARGS=(--since="$ARG" obra/main)
  HEADER="upstream commits since date $ARG"
else
  RANGE_ARGS=("$ARG..obra/main")
  HEADER="upstream commits in range $ARG..obra/main"
fi

# Files this fork actually ships (filter target).
mapfile -t FORK_FILES < <(
  find skills agents extensions -type f 2>/dev/null | sort
)

if [[ ${#FORK_FILES[@]} -eq 0 ]]; then
  echo "error: no skills/ agents/ extensions/ files found — run from repo root." >&2
  exit 1
fi

# Build a hash set for O(1) lookup.
declare -A FORK_SET=()
for f in "${FORK_FILES[@]}"; do
  FORK_SET["$f"]=1
done

echo "== $HEADER =="
echo "(showing only commits that touch files this fork ships)"
echo

found_any=0
while read -r commit; do
  [[ -z "$commit" ]] && continue

  subject="$(git log -1 --format="%h %s" "$commit")"

  # Files changed by this commit in skills/agents/extensions paths.
  mapfile -t commit_files < <(
    git show --name-only --format="" "$commit" \
      | grep -E '^(skills|agents|extensions)/' \
      | sort -u
  )

  matched=()
  for f in "${commit_files[@]}"; do
    if [[ -n "${FORK_SET[$f]:-}" ]]; then
      matched+=("$f")
    fi
  done

  if [[ ${#matched[@]} -gt 0 ]]; then
    found_any=1
    echo "RELEVANT: $subject"
    for f in "${matched[@]}"; do
      echo "  - $f"
    done
    echo
  fi
done < <(git log "${RANGE_ARGS[@]}" --format="%H" --reverse)

if [[ $found_any -eq 0 ]]; then
  echo "No upstream commits touched files this fork ships."
  echo "(Other upstream changes likely exist but are out of scope —"
  echo " see docs/upstream-sync.md for what we ignore on purpose.)"
fi

#!/bin/bash
# Loads relevant vault context at session start based on current project.
# Stdout becomes part of Claude's context.
#
# - Most recent session for the project: full content
# - Other related notes: index only (titles)

set -euo pipefail

VAULT="$HOME/vault"
INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

if [ -z "$CWD" ]; then
  exit 0
fi

PROJECT=$(basename "$CWD")

# Find most recent session file for this project
LATEST_SESSION=$(grep -rl "^project: $PROJECT" "$VAULT/sessions/" 2>/dev/null | while read -r f; do
  echo "$(stat -f %m "$f") $f"
done | sort -rn | head -1 | cut -d' ' -f2-)

# Search vault for related notes (index), filtering by score >= 0.70
RESULTS=$(qmd query -c vault "$PROJECT" -n 8 --files 2>/dev/null | awk -F, '$2 >= 0.70 { print $3 }' || true)

HAS_OUTPUT=false

# Load full content of latest session
if [ -n "$LATEST_SESSION" ] && [ -f "$LATEST_SESSION" ]; then
  echo "=== Last session for $PROJECT ==="
  cat "$LATEST_SESSION"
  echo ""
  echo "=== End last session ==="
  HAS_OUTPUT=true
fi

# Build index of other related notes
INDEX=""
COUNT=0
MAX=5

while IFS= read -r line; do
  [ -z "$line" ] && continue
  [ "$COUNT" -ge "$MAX" ] && break

  REL_PATH=$(echo "$line" | sed 's/.*qmd:\/\/vault\///')
  FILE="$VAULT/$REL_PATH"

  case "$REL_PATH" in templates/*) continue ;; esac

  # Skip the session we already loaded in full
  if [ -n "$LATEST_SESSION" ] && [ "$FILE" = "$LATEST_SESSION" ]; then
    continue
  fi

  if [ -f "$FILE" ]; then
    TITLE=$(head -20 "$FILE" | grep -E "^# " | head -1 | sed 's/^# //')
    [ -z "$TITLE" ] && TITLE="$REL_PATH"
    INDEX="$INDEX- $REL_PATH: $TITLE"$'\n'
    COUNT=$((COUNT + 1))
  fi
done <<< "$RESULTS"

if [ -n "$INDEX" ]; then
  echo "=== Other vault notes related to $PROJECT ==="
  echo "$INDEX"
  echo "Use /vault to load full content of any note."
  echo "=== End vault notes ==="
  HAS_OUTPUT=true
fi

exit 0

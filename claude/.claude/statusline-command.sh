#!/usr/bin/env bash
input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
model=$(echo "$input" | jq -r '.model.display_name // ""')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

dir=$(basename "$cwd")
parent=$(basename "$(dirname "$cwd")")

if [[ "$parent" == ".worktrees" ]]; then
  repo=$(basename "$(dirname "$(dirname "$cwd")")")
  dir_label="$repo/$dir"
else
  dir_label="$dir"
fi

branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)
dirty=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)

parts=()
[ -n "$dir_label" ] && parts+=("$dir_label")
if [ -n "$branch" ]; then
  if [ -n "$dirty" ]; then
    parts+=("git:(${branch}) x")
  else
    parts+=("git:(${branch})")
  fi
fi
[ -n "$model" ]     && parts+=("$model")
[ -n "$used" ] && parts+=("ctx:${used}%")

printf '%s' "$(IFS=' '; echo "${parts[*]}")"

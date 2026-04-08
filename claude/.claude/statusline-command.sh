#!/usr/bin/env bash
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // ""')
ctx=$(echo "$input" | jq -r '.context_window.used_percentage // 0 | floor')
usage_5h=$(echo "$input" | jq -r 'if .rate_limits.five_hour.used_percentage then (.rate_limits.five_hour.used_percentage | floor | tostring) else empty end')
usage_7d=$(echo "$input" | jq -r 'if .rate_limits.seven_day.used_percentage then (.rate_limits.seven_day.used_percentage | floor | tostring) else empty end')

# "Opus 4.6 (1M context)" -> "Opus 4.6"
short_model=$(echo "$model" | sed -E 's/ \(.*//')

output="$short_model · ctx:${ctx}%"
[ -n "$usage_5h" ] && output="$output · 5h:${usage_5h}%"
[ -n "$usage_7d" ] && output="$output · 7d:${usage_7d}%"

# Save per-pane for tmux
if [ -n "$TMUX_PANE" ]; then
  echo "$output" > "/tmp/claude-statusline-${TMUX_PANE}"
fi

# Output nothing to Claude Code (tmux reads from file)

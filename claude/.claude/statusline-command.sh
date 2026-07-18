#!/usr/bin/env bash
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // ""')
ctx=$(echo "$input" | jq -r '.context_window.used_percentage // 0 | floor')
usage_5h=$(echo "$input" | jq -r 'if .rate_limits.five_hour.used_percentage then (.rate_limits.five_hour.used_percentage | floor | tostring) else empty end')
usage_7d=$(echo "$input" | jq -r 'if .rate_limits.seven_day.used_percentage then (.rate_limits.seven_day.used_percentage | floor | tostring) else empty end')

# --- Fable weekly usage -------------------------------------------------------
# Per-model usage is NOT in the statusline stdin (that only carries the aggregate
# 5h/7d windows). It lives in the undocumented OAuth usage endpoint, under
# limits[] scoped by model: we match the limit whose scope.model.display_name is
# "Fable" and read its percent. (The flat seven_day_* keys are all null / return
# internal codenames, so limits[] is the only clean source.)
#
# Failure is ALWAYS graceful — the whole fetch runs in a backgrounded subshell and
# the display is gated on a non-empty cache, so if anything goes wrong the cache is
# overwritten empty and the "fable:" segment just vanishes. No crash, next refresh
# moves on. This covers every case worth worrying about:
#   - Fable loses its own weekly cap (moves to credits) -> no scoped limit -> gone
#   - endpoint 404s / 429s / returns non-JSON / times out -> empty         -> gone
#   - no OAuth token in the keychain                      -> empty         -> gone
# The main line (model/ctx/5h/7d) never touches this and always renders.
#
# Endpoint is undocumented and can change without notice; that too just degrades
# to no segment. Cached to a file with a 60s TTL; `touch` claims the slot up front
# so rapid refreshes don't fire duplicate requests while one is in flight. The
# fetch is detached so it never blocks the render on the network.
fable_cache="/tmp/claude-fable-usage"
mtime=$(stat -f %m "$fable_cache" 2>/dev/null || echo 0)
if [ $(( $(date +%s) - mtime )) -ge 60 ]; then
  touch "$fable_cache"
  version=$(echo "$input" | jq -r '.version // "2.1.0"')
  ( out=""
    token=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null | jq -r '.claudeAiOauth.accessToken // empty')
    if [ -n "$token" ]; then
      out=$(curl -s --max-time 5 https://api.anthropic.com/api/oauth/usage \
        -H "Authorization: Bearer $token" \
        -H "anthropic-beta: oauth-2025-04-20" \
        -H "User-Agent: claude-code/$version" \
      | jq -r '(.limits // []) | map(select((.scope.model.display_name // "") | test("fable"; "i"))) | (.[0].percent // empty) | floor' 2>/dev/null)
    fi
    # Always overwrite, even when empty, so a dead endpoint or unscoped Fable
    # clears the value instead of freezing the last reading on screen.
    printf '%s' "$out" > "$fable_cache.tmp"
    mv -f "$fable_cache.tmp" "$fable_cache" ) &
fi
fable=""
[ -s "$fable_cache" ] && fable=$(cat "$fable_cache")

# "Opus 4.6 (1M context)" -> "Opus 4.6"
short_model=$(echo "$model" | sed -E 's/ \(.*//')

output="$short_model · ctx:${ctx}%"
[ -n "$usage_5h" ] && output="$output · 5h:${usage_5h}%"
[ -n "$usage_7d" ] && output="$output · 7d:${usage_7d}%"
[ -n "$fable" ] && output="$output · fable:${fable}%"

# Save per-pane for tmux
if [ -n "$TMUX_PANE" ]; then
  echo "$output" > "/tmp/claude-statusline-${TMUX_PANE}"
fi

# Output nothing to Claude Code (tmux reads from file)

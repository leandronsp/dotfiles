#!/usr/bin/env bash
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // ""')
ctx=$(echo "$input" | jq -r '.context_window.used_percentage // 0 | floor')
usage_5h=$(echo "$input" | jq -r 'if .rate_limits.five_hour.used_percentage then (.rate_limits.five_hour.used_percentage | floor | tostring) else empty end')
usage_7d=$(echo "$input" | jq -r 'if .rate_limits.seven_day.used_percentage then (.rate_limits.seven_day.used_percentage | floor | tostring) else empty end')

# --- Usage limits: percentages + reset countdowns -----------------------------
# The statusline stdin carries only the aggregate 5h/7d percentages: no reset
# times and no per-model (Fable) breakdown. All of that lives in the undocumented
# OAuth usage endpoint (top-level five_hour/seven_day plus a limits[] array scoped
# by model). We cache, per 60s, a small JSON blob { fable%, plus the reset epochs
# for 5h / 7d / fable } and read it back to append a "~Xh"/"~Xd" countdown.
#
# Reset times are APPROXIMATE by design: the 5h window slides (only the oldest
# usage rolls off at resets_at, you don't drop to 0) and the weekly reset is
# fuzzy in practice. Hence the "~" prefix. Read it as "no earlier than", a guide.
#
# Failure is ALWAYS graceful. The fetch runs in a detached subshell and every
# field is read defensively, so if anything goes wrong the cache is overwritten
# empty and the extras simply vanish:
#   - Fable loses its own weekly cap (moves to credits) -> no scoped limit -> gone
#   - endpoint 404s / 429s / returns non-JSON / times out -> empty         -> gone
#   - no OAuth token in the keychain                      -> empty         -> gone
# The 5h/7d percentages come from stdin, so they keep rendering (just without the
# countdown); only the Fable segment depends entirely on the endpoint. The main
# line (model/ctx) never touches this.
#
# Undocumented endpoint, can change without notice (also degrades to no extras).
# `touch` claims the slot up front so rapid refreshes don't fire duplicate
# requests while one is in flight; the fetch is detached so it never blocks.
cache_file="/tmp/claude-fable-usage"
mtime=$(stat -f %m "$cache_file" 2>/dev/null || echo 0)
if [ $(( $(date +%s) - mtime )) -ge 60 ]; then
  touch "$cache_file"
  version=$(echo "$input" | jq -r '.version // "2.1.0"')
  ( out=""
    token=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null | jq -r '.claudeAiOauth.accessToken // empty')
    if [ -n "$token" ]; then
      out=$(curl -s --max-time 5 https://api.anthropic.com/api/oauth/usage \
        -H "Authorization: Bearer $token" \
        -H "anthropic-beta: oauth-2025-04-20" \
        -H "User-Agent: claude-code/$version" \
      | jq -c 'def e: if . == null then null else (sub("(\\.[0-9]+)?([+-][0-9:]+|Z)$";"Z") | fromdateiso8601) end;
               ((.limits // []) | map(select((.scope.model.display_name // "") | test("fable";"i"))) | .[0]) as $f
               | { fable: ($f.percent // null),
                   r5h: (.five_hour.resets_at | e),
                   r7d: (.seven_day.resets_at | e),
                   rfb: ($f.resets_at | e) }' 2>/dev/null)
    fi
    # Always overwrite, even when empty, so a dead endpoint or unscoped Fable
    # clears the extras instead of freezing the last reading on screen.
    printf '%s' "$out" > "$cache_file.tmp"
    mv -f "$cache_file.tmp" "$cache_file" ) &
fi

cache=""
[ -s "$cache_file" ] && cache=$(cat "$cache_file")
fable=$(printf '%s' "$cache" | jq -r '.fable // empty' 2>/dev/null)
r5h=$(printf '%s' "$cache" | jq -r '.r5h // empty' 2>/dev/null)
r7d=$(printf '%s' "$cache" | jq -r '.r7d // empty' 2>/dev/null)
rfb=$(printf '%s' "$cache" | jq -r '.rfb // empty' 2>/dev/null)

now=$(date +%s)
# epoch -> "~Xh" (<1d, rounded up) or "~Xd" (>=1d); nothing if empty or past
eta() {
  [ -z "$1" ] && return
  local s=$(( $1 - now ))
  [ "$s" -le 0 ] && { printf '~0h'; return; }
  if [ "$s" -ge 86400 ]; then printf '~%dd' "$(( s / 86400 ))"; else printf '~%dh' "$(( (s + 3599) / 3600 ))"; fi
}

# "Opus 4.6 (1M context)" -> "Opus 4.6"
short_model=$(echo "$model" | sed -E 's/ \(.*//')

output="$short_model · ctx:${ctx}%"
[ -n "$usage_5h" ] && output="$output · 5h:${usage_5h}%$(eta "$r5h")"
[ -n "$usage_7d" ] && output="$output · 7d:${usage_7d}%$(eta "$r7d")"
[ -n "$fable" ] && output="$output · fable:${fable}%$(eta "$rfb")"

# Save per-pane for tmux
if [ -n "$TMUX_PANE" ]; then
  echo "$output" > "/tmp/claude-statusline-${TMUX_PANE}"
fi

# Output nothing to Claude Code (tmux reads from file)

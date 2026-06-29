#!/usr/bin/env bash
# Records the agent's state for the tmux dashboard (agent TUI + sidebar). This is
# the robust, version-independent signal: it comes from Claude's stable hook API,
# not from scraping the UI. Written per pane to /tmp/agent-state-<pane_id>.
# Wiring (settings.json): UserPromptSubmit -> working ; Stop/Notification -> idle.
# Usage: agent-state.sh <working|idle>

[ -z "$TMUX" ] && exit 0
pane=$(tmux display-message -t "${TMUX_PANE:-}" -p '#{pane_id}' 2>/dev/null) || exit 0
[ -n "$pane" ] && printf '%s' "${1:-idle}" > "/tmp/agent-state-$pane"
exit 0

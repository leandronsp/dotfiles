#!/usr/bin/env bash
# Notify when Claude is waiting for input (Stop/Notification hook).
# macOS notification + sound + tmux window highlight.

if [ -z "$TMUX" ]; then
  osascript -e 'tell application "System Events" to display notification "Claude is waiting for input" with title "Claude Code" sound name "Funk"' 2>/dev/null &
  exit 0
fi

# Get window/pane info for Claude's pane (not the active one)
window_name=$(tmux display-message -t "$TMUX_PANE" -p '#W')
window_target=$(tmux display-message -t "$TMUX_PANE" -p '#S:#I')
pane=$(tmux display-message -t "$TMUX_PANE" -p '#P')
active=$(tmux display-message -t "$TMUX_PANE" -p '#{window_active}')

# Skip only if this tmux window is active AND Terminal is focused
if [ "$active" = "1" ]; then
  frontmost=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null)
  if [ "$frontmost" = "Terminal" ]; then
    exit 0
  fi
fi

# macOS notification (via System Events, works on macOS 26+)
osascript -e "tell application \"System Events\" to display notification \"Window: $window_name (pane $pane)\" with title \"Claude Code\" sound name \"Funk\"" 2>/dev/null &

# Highlight tmux window in status bar (reset happens on window enter via tmux hook)
tmux set-window-option -t "$window_target" window-status-style "bg=red,fg=white,bold"

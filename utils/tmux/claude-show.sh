#!/bin/bash
# Script to show/create claude pane
# Used by tmux binding C-a A

set -e

# Get session and window info
session_name=$(tmux display-message -p '#{session_name}')
window_id=$(tmux display-message -p '#{window_id}')
hidden_name="claude-hidden-$session_name-$window_id"

# Check if hidden claude window exists
if tmux list-windows -F '#{window_name}' | grep -q "^$hidden_name$"; then
  # Restore hidden claude window as pane
  tmux join-pane -h -l 35% -s "$hidden_name"
  tmux select-pane -T 'claude'
else
  # Check if claude pane already exists in current window
  claude_pane=$(tmux list-panes -F '#{pane_title} #{pane_id}' | \
    grep '^claude ' | cut -d' ' -f2)
  if [ -n "$claude_pane" ]; then
    # Focus existing claude pane
    tmux select-pane -t "$claude_pane"
  else
    # Create new claude pane
    tmux split-window -h -l 35% \
      "$HOME/.claude/local/claude --dangerously-skip-permissions"
    tmux select-pane -T 'claude'
  fi
fi
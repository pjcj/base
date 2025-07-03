#!/bin/bash
# Script to hide claude pane
# Used by tmux binding C-a B

set -e

# Remember current pane and window
current_pane=$(tmux display-message -p '#{pane_id}')
current_window=$(tmux display-message -p '#{window_id}')

# Get session and window info
session_name=$(tmux display-message -p '#{session_name}')
window_id=$(tmux display-message -p '#{window_id}')
hidden_name="claude-hidden-$session_name-$window_id"

# Find claude pane
claude_pane=$(tmux list-panes -F '#{pane_title} #{pane_id}' | \
  grep '^claude ' | cut -d' ' -f2)

if [ -n "$claude_pane" ]; then
  # Select and break the claude pane into a separate window
  tmux select-pane -t "$claude_pane"
  tmux break-pane -n "$hidden_name"

  # Return to original window and pane
  tmux select-window -t "$current_window"
  if [ "$current_pane" != "$claude_pane" ]; then
    tmux select-pane -t "$current_pane"
  fi
fi
#!/bin/bash
# Script to show/create claude pane
# Used by tmux binding C-a A

set -e

# Get current window info
current_window_name=$(tmux display-message -p '#{window_name}')
session_name=$(tmux display-message -p '#{session_name}')
current_pane_id=$(tmux display-message -p '#{pane_id}')
current_pane_command=$(tmux display-message -p '#{pane_current_command}')

# Check if we're currently in a hidden claude window
if echo "$current_window_name" | grep -q "^claude-hidden-.*"; then
  # Extract target window from hidden window name
  target_window=${current_window_name#claude-hidden-*-}
  # Join current window as pane to target window
  tmux join-pane -h -l 35% -t "$target_window"
  tmux select-pane -T 'claude'
else
  # Normal logic for non-hidden windows
  window_id=$(tmux display-message -p '#{window_id}')
  hidden_name="claude-hidden-$session_name-$window_id"

  # Check if hidden claude window exists for current window
  if tmux list-windows -F '#{window_name}' | grep -q "^$hidden_name$"; then
    # Restore hidden claude window as pane
    tmux join-pane -h -l 35% -s "$hidden_name"
    tmux select-pane -T 'claude'
  else
    # Check if claude pane already exists in current window
    claude_pane=$(tmux list-panes -F '#{pane_title} #{pane_id}' |
      grep '^claude ' | cut -d' ' -f2)
    if [ -n "$claude_pane" ]; then
      # Focus existing claude pane
      tmux select-pane -t "$claude_pane"
    else
      # If we split from a neovim pane, start ClaudeCode for IDE integration
      if [ "$current_pane_command" = "nvim" ]; then
        # Send command to the original neovim pane
        tmux send-keys -t "$current_pane_id" Escape
        tmux send-keys -t "$current_pane_id" ":ClaudeCode" Enter
      fi
      # Create new claude pane
      tmux split-window -h -l 35% \
        "$HOME/.claude/local/claude --ide --dangerously-skip-permissions"
      tmux select-pane -T 'claude'

      # If we split from a neovim pane, equalize its windows horizontally
      if [ "$current_pane_command" = "nvim" ]; then
        # Send command to the original neovim pane
        tmux send-keys -t "$current_pane_id" Escape
        tmux send-keys -t "$current_pane_id" ":horizontal wincmd =" Enter
      fi
    fi
  fi
fi

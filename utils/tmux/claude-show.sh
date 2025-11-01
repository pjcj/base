#!/bin/bash
# Script to create claude pane
# Used by tmux binding C-a A

set -e

logfile="/tmp/claude-show.log"
exec >"$logfile" 2>&1

echo "=== $(date) ==="

# Get current pane info
current_pane_id=$(tmux display-message -p '#{pane_id}')
current_pane_command=$(tmux display-message -p '#{pane_current_command}')
current_path=$(tmux display-message -p '#{pane_current_path}')

# Debug: show what we detected
echo "Current pane ID: $current_pane_id"
echo "Current pane command: [$current_pane_command]"
echo "Current path: $current_path"

# If splitting from nvim, start ClaudeCode first
if [[ $current_pane_command == "nvim" ]]; then
  echo "Condition matched: starting ClaudeCode in nvim"
  tmux send-keys -t "$current_pane_id" Escape ":ClaudeCode" Enter
  echo "ClaudeCode started"
fi

# Create new claude pane with zsh to enable autoenv
opts="--ide --permission-mode bypassPermissions"
echo "Creating new claude pane..."
tmux split-window -h -l 35% -c "$current_path" \
  "zsh -ic \"cd '$current_path' && claude $opts\""
tmux select-pane -T 'claude'
echo "Claude pane created"

# After split, equalize nvim windows if we split from nvim
if [[ $current_pane_command == "nvim" ]]; then
  echo "Waiting for nvim to settle after split..."
  sleep 0.3
  echo "Equalizing nvim windows in pane $current_pane_id"
  tmux send-keys -t "$current_pane_id" Escape ":horizontal wincmd =" Enter
  echo "Nvim windows equalized"
fi

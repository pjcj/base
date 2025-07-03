#!/bin/bash

preview_pane_name="claude-preview"

# Read the tool use data from the JSON file
if [ ! -f "/tmp/tool-use.json" ]; then
  echo "$(date): No tool-use.json found" >>/tmp/claude-preview-debug.log
  exit 0
fi

# Extract file path and line number from the JSON
file_path=$(jq -r '.tool_input.file_path // .tool_response.filePath // empty' /tmp/tool-use.json)
line_number=$(jq -r '.tool_response.structuredPatch[0].oldStart // empty' /tmp/tool-use.json)

# Debug logging
echo "$(date): Preview script called - file: $file_path, line: $line_number" >>/tmp/claude-preview-debug.log

# Exit if no file path found
if [ -z "$file_path" ] || [ "$file_path" = "null" ]; then
  echo "$(date): No valid file path found in tool-use.json" >>/tmp/claude-preview-debug.log
  exit 0
fi

# Exit if not in tmux
if [ -z "$TMUX" ]; then
  exit 0
fi

# Get current pane ID
current_pane=$(tmux display-message -p '#{pane_id}')

# Check if preview pane exists
if ! tmux list-panes -F '#{pane_title}' | grep -q "$preview_pane_name"; then
  # Create new pane above current pane (30% height)
  tmux split-window -v -b -p 30 -t "$current_pane"
  # Set the pane title for identification
  tmux select-pane -T "$preview_pane_name"
  # Get the new pane ID
  preview_pane=$(tmux display-message -p '#{pane_id}')

  # Open file in neovim (new pane) with line number if available
  if [ -n "$line_number" ] && [ "$line_number" != "null" ] && [ "$line_number" != "empty" ]; then
    tmux send-keys -t "$preview_pane" "nvim +$line_number '$file_path'" Enter
  else
    tmux send-keys -t "$preview_pane" "nvim '$file_path'" Enter
  fi
else
  # Find existing preview pane
  preview_pane=$(tmux list-panes -F '#{pane_id} #{pane_title}' | grep "$preview_pane_name" | cut -d' ' -f1)

  # Check if neovim is running in the pane
  pane_command=$(tmux display-message -t "$preview_pane" -p '#{pane_current_command}')

  if [[ $pane_command == "nvim" ]]; then
    # Neovim is running, use :edit command and jump to line
    tmux send-keys -t "$preview_pane" Escape # Ensure we're in normal mode
    if [ -n "$line_number" ] && [ "$line_number" != "null" ] && [ "$line_number" != "empty" ]; then
      tmux send-keys -t "$preview_pane" ":edit +$line_number $file_path" Enter
    else
      tmux send-keys -t "$preview_pane" ":edit $file_path" Enter
    fi
  else
    # Shell is running, start neovim with line number if available
    if [ -n "$line_number" ] && [ "$line_number" != "null" ] && [ "$line_number" != "empty" ]; then
      tmux send-keys -t "$preview_pane" "nvim +$line_number '$file_path'" Enter
    else
      tmux send-keys -t "$preview_pane" "nvim '$file_path'" Enter
    fi
  fi
fi

# Return focus to original pane
tmux select-pane -t "$current_pane"


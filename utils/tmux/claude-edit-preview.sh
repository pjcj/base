#!/bin/bash

exit  # this isn't quite there yet unfortunately

# Create unique preview pane identifier based on session and window
session_name=$(tmux display-message -p '#{session_name}')
window_id=$(tmux display-message -p '#{window_id}')
preview_pane_name="claude-preview-$session_name-$window_id"
preview_pane_file="/tmp/claude-preview-$session_name-$window_id"
lock_file="/tmp/claude-preview-lock-$session_name-$window_id"

# Prevent multiple instances from running simultaneously
if [[ -f "$lock_file" ]]; then
  echo "$(date): Another instance is already running, exiting" \
    >>/tmp/claude-preview-debug.log
  exit 0
fi
echo $$ >"$lock_file"
trap 'rm -f "$lock_file"' EXIT

# Wait for tool-use.json to be available and stable
max_attempts=5
attempt=0
while (( attempt < max_attempts )); do
  if [[ -f "/tmp/tool-use.json" ]]; then
    # Check if file has content and is not being written to
    if [[ -s "/tmp/tool-use.json" ]]; then
      # Wait a short time to ensure file is stable
      sleep 0.1
      break
    fi
  fi
  attempt=$((attempt + 1))
  sleep 0.1
done

if [[ ! -f "/tmp/tool-use.json" ]] || [[ ! -s "/tmp/tool-use.json" ]]; then
  echo "$(date): No valid tool-use.json found after $max_attempts attempts" \
    >>/tmp/claude-preview-debug.log
  exit 0
fi

# Extract file path and line number from the JSON
file_path=$(jq -r '.tool_input.file_path // .tool_response.filePath // empty' \
  /tmp/tool-use.json 2>/dev/null)
line_number=$(jq -r '.tool_response.structuredPatch[0].oldStart // empty' \
  /tmp/tool-use.json 2>/dev/null)

# Debug logging
echo "$(date): Preview script called - file: $file_path, line: $line_number" \
  >>/tmp/claude-preview-debug.log
echo "$(date): Looking for preview pane: $preview_pane_name" \
  >>/tmp/claude-preview-debug.log

# Exit if no file path found
if [[ -z "$file_path" ]] || [[ "$file_path" = "null" ]] || \
   [[ "$file_path" = "empty" ]]; then
  echo "$(date): No valid file path found (got: '$file_path')" \
    >>/tmp/claude-preview-debug.log
  exit 0
fi

# Exit if file doesn't exist
if [[ ! -f "$file_path" ]]; then
  echo "$(date): File does not exist: $file_path" \
    >>/tmp/claude-preview-debug.log
  exit 0
fi

# Exit if not in tmux
if [[ -z "$TMUX" ]]; then
  exit 0
fi

# Get current pane ID (to restore focus later)
current_pane=$(tmux display-message -p '#{pane_id}')
current_pane_title=$(tmux display-message -p '#{pane_title}')

# Determine which pane to use as the target
target_pane=""

# Case 1: If we're already in a Claude pane, use it
if [[ "$current_pane_title" = "claude" ]]; then
  target_pane="$current_pane"
  echo "$(date): Using current Claude pane as target" \
    >>/tmp/claude-preview-debug.log
else
  # Case 2: Look for any Claude pane in current window
  claude_pane=$(tmux list-panes -F '#{pane_id} #{pane_title}' | \
    grep ' claude$' | head -1 | cut -d' ' -f1)

  if [[ -n "$claude_pane" ]]; then
    target_pane="$claude_pane"
    echo "$(date): Found Claude pane $claude_pane in window" \
      >>/tmp/claude-preview-debug.log
  fi
fi

# Case 3: If no Claude relationship found, use current pane
if [[ -z "$target_pane" ]]; then
  target_pane="$current_pane"
  echo "$(date): No Claude relationship found, using current pane" \
    >>/tmp/claude-preview-debug.log
fi

# Check if preview pane exists (stored in file)
if [[ -f "$preview_pane_file" ]]; then
  preview_pane=$(cat "$preview_pane_file")
  # Verify the pane still exists
  if tmux list-panes -F '#{pane_id}' | grep -q "^$preview_pane$"; then
    echo "$(date): Found existing preview pane $preview_pane" \
      >>/tmp/claude-preview-debug.log
  else
    echo "$(date): Stored preview pane $preview_pane no longer exists" \
      >>/tmp/claude-preview-debug.log
    rm -f "$preview_pane_file"
    preview_pane=""
  fi
else
  echo "$(date): No preview pane file found" >>/tmp/claude-preview-debug.log
  preview_pane=""
fi

if [[ -z "$preview_pane" ]]; then
  echo "$(date): Creating new preview pane" >>/tmp/claude-preview-debug.log
  # Create new pane above target pane (30% height)
  tmux split-window -v -b -p 30 -t "$target_pane"
  # Get the new pane ID (the split-window creates it as the active pane)
  preview_pane=$(tmux display-message -p '#{pane_id}')
  # Store the pane ID in file for future reuse
  echo "$preview_pane" >"$preview_pane_file"

  # Open file in neovim (new pane) with line number if available
  if [[ -n "$line_number" ]] && [[ "$line_number" != "null" ]] && \
     [[ "$line_number" != "empty" ]]; then
    tmux send-keys -t "$preview_pane" "nvim +$line_number '$file_path'" Enter
    # Position the line at the top of the view (like z<CR>)
    sleep 0.2  # Wait for nvim to load
    tmux send-keys -t "$preview_pane" "z" Enter
  else
    tmux send-keys -t "$preview_pane" "nvim '$file_path'" Enter
  fi

  echo "$(date): Created preview pane $preview_pane and stored in file" \
    >>/tmp/claude-preview-debug.log
else
  echo "$(date): Using existing preview pane $preview_pane" \
    >>/tmp/claude-preview-debug.log

  # Check if neovim is running in the pane
  pane_command=$(tmux display-message -t "$preview_pane" \
    -p '#{pane_current_command}')

  if [[ $pane_command == "nvim" ]]; then
    # Neovim is running, use :edit command and jump to line
    tmux send-keys -t "$preview_pane" Escape # Ensure we're in normal mode
    if [[ -n "$line_number" ]] && [[ "$line_number" != "null" ]] && \
       [[ "$line_number" != "empty" ]]; then
      tmux send-keys -t "$preview_pane" ":edit +$line_number $file_path" Enter
      # Position the line at the top of the view (like z<CR>)
      sleep 0.1  # Brief wait for command to execute
      tmux send-keys -t "$preview_pane" "z" Enter
    else
      tmux send-keys -t "$preview_pane" ":edit $file_path" Enter
    fi
  else
    # Shell is running, start neovim with line number if available
    if [[ -n "$line_number" ]] && [[ "$line_number" != "null" ]] && \
       [[ "$line_number" != "empty" ]]; then
      tmux send-keys -t "$preview_pane" "nvim +$line_number '$file_path'" Enter
      # Position the line at the top of the view (like z<CR>)
      sleep 0.2  # Wait for nvim to load
      tmux send-keys -t "$preview_pane" "z" Enter
    else
      tmux send-keys -t "$preview_pane" "nvim '$file_path'" Enter
    fi
  fi
fi

# Return focus to original pane
tmux select-pane -t "$current_pane"

# Auto-close preview pane after 60 seconds
(sleep 60; tmux kill-pane -t "$preview_pane" 2>/dev/null || true; \
 rm -f "$preview_pane_file") &

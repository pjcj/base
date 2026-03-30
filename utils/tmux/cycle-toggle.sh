#!/bin/bash
# Toggle current pane in/out of the @cycle list
# Used by tmux binding C-a BTab

current=$(tmux display-message -p '#{@cycle}')

if [ "$current" = "1" ]; then
  tmux set-option -pu @cycle
  count=$(tmux list-panes -a -F '#{@cycle}' | grep -c '^1$' || true)
  tmux display-message "Cycle: removed (${count} tagged)"
else
  tmux set-option -p @cycle 1
  count=$(tmux list-panes -a -F '#{@cycle}' | grep -c '^1$' || true)
  tmux display-message "Cycle: added (${count} tagged)"
fi

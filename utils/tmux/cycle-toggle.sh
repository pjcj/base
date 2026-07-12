#!/usr/bin/env bash

set -eEuo pipefail
shopt -s inherit_errexit 2>/dev/null || true

# Toggle current pane in/out of the @cycle list
# Used by tmux binding C-a BTab

main() {
  local current count
  current=$(tmux display-message -p '#{@cycle}')

  if [[ $current == "1" ]]; then
    tmux set-option -pu @cycle
    count=$(tmux list-panes -a -F '#{@cycle}' | grep -c '^1$' || true)
    tmux display-message "Cycle: removed (${count} tagged)"
  else
    tmux set-option -p @cycle 1
    count=$(tmux list-panes -a -F '#{@cycle}' | grep -c '^1$' || true)
    tmux display-message "Cycle: added (${count} tagged)"
  fi
}

main "$@"

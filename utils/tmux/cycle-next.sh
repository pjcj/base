#!/usr/bin/env bash

set -eEuo pipefail
shopt -s inherit_errexit 2>/dev/null || true

# Cycle to the next @cycle-tagged pane
# Used by tmux binding C-a Tab

main() {
  local tagged
  tagged=$(tmux list-panes -a \
    -F '#{@cycle} #{pane_id} #{session_name}:#{window_index}.#{pane_index}' |
    awk '$1 == "1" { print $2, $3 }')

  if [[ -z $tagged ]]; then
    tmux display-message "Cycle: no tagged panes"
    return 0
  fi

  local count current_id
  count=$(echo "$tagged" | wc -l | tr -d ' ')
  current_id=$(tmux display-message -p '#{pane_id}')

  local -a pane_ids=() targets=()
  local pid tgt
  while IFS=' ' read -r pid tgt; do
    pane_ids+=("$pid")
    targets+=("$tgt")
  done <<<"$tagged"

  local current_pos=-1 i
  for i in "${!pane_ids[@]}"; do
    if [[ ${pane_ids[$i]} == "$current_id" ]]; then
      current_pos=$i
      break
    fi
  done

  # Next position (wrap around); if not in list, start at 0
  local next_pos
  if ((current_pos == -1)); then
    next_pos=0
  else
    next_pos=$(((current_pos + 1) % count))
  fi

  local target pos_display
  target="${targets[$next_pos]}"
  pos_display=$((next_pos + 1))

  tmux switch-client -t "$target"
  tmux display-message "Cycle: [$pos_display/$count] $target"
}

main "$@"

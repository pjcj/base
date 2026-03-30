#!/bin/bash
# Cycle to the next @cycle-tagged pane
# Used by tmux binding C-a Tab

tagged=$(tmux list-panes -a \
  -F '#{@cycle} #{pane_id} #{session_name}:#{window_index}.#{pane_index}' \
  | awk '$1 == "1" { print $2, $3 }')

if [ -z "$tagged" ]; then
  tmux display-message "Cycle: no tagged panes"
  exit 0
fi

count=$(echo "$tagged" | wc -l | tr -d ' ')
current_id=$(tmux display-message -p '#{pane_id}')

pane_ids=()
targets=()
while IFS=' ' read -r pid tgt; do
  pane_ids+=("$pid")
  targets+=("$tgt")
done <<< "$tagged"

# Find current position in cycle
current_pos=-1
for i in "${!pane_ids[@]}"; do
  if [ "${pane_ids[$i]}" = "$current_id" ]; then
    current_pos=$i
    break
  fi
done

# Next position (wrap around); if not in list, start at 0
if [ "$current_pos" -eq -1 ]; then
  next_pos=0
else
  next_pos=$(( (current_pos + 1) % count ))
fi

target="${targets[$next_pos]}"
pos_display=$(( next_pos + 1 ))

tmux switch-client -t "$target"
tmux display-message "Cycle: [$pos_display/$count] $target"

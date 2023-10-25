# Print out Memory, cpu and load using https://github.com/thewtex/tmux-mem-cpu-load

run_segment() {
  local cmd=~/.tmux/plugins/tmux-mem-cpu-load/tmux-mem-cpu-load
  if ! type "$cmd" >/dev/null 2>&1; then
    return
  fi

  local stats
  stats=$("$cmd" -q -l 0 -v --interval "$TMUX_POWERLINE_STATUS_INTERVAL")
  if [ "$stats" != "" ]; then
    echo "$stats" | perl -pe 's/  +/ /g; s|(\d+)MB|int($1/1024)|e;' \
      -e 's/[▕▏]//g;' \
      -e 's/(\d+\.\d\d)/sprintf "%.1f", $1/eg;'
  fi
  return 0
}

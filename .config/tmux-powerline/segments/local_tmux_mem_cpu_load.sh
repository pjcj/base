# Print out Memory, cpu and load using https://github.com/thewtex/tmux-mem-cpu-load

run_segment() {
  local cmd=~/.tmux/plugins/tmux-mem-cpu-load/tmux-mem-cpu-load
  if ! type "$cmd" >/dev/null 2>&1; then
    echo "CPU: N/A"
    return 0
  fi

  local stats
  # Use timeout to prevent hanging, and reduce interval to 2 second for faster startup
  stats=$(timeout 3s "$cmd" -q -l 0 -r 0 -v --interval 2 2>/dev/null)
  if [ $? -eq 0 ] && [ "$stats" != "" ]; then
    echo "$stats" | perl -pe 's/  +/ /g; s|(\d+)MB|int($1/1024)|e;' \
      -e 's/[▕▏]//g;' \
      -e 's/(\d+\.\d\d)/sprintf "%.1f", $1/eg;'
  else
    echo "CPU: ..."
  fi
  return 0
}

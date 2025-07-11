# Print out Memory, cpu and load using
# https://github.com/thewtex/tmux-mem-cpu-load

run_segment() {
  local cmd=~/.tmux/plugins/tmux-mem-cpu-load/tmux-mem-cpu-load
  local cache_file="/tmp/tmux_mem_cpu_load_cache"
  local cache_duration=5

  if ! type "$cmd" >/dev/null 2>&1; then
    echo "CPU: N/A"
    return 0
  fi

  # Check if cache exists and is still valid
  if [[ -f "$cache_file" ]]; then
    local cache_time
    cache_time=$(stat -c %Y "$cache_file" 2>/dev/null || \
                 stat -f %m "$cache_file" 2>/dev/null || echo 0)
    local cache_age=$(($(date +%s) - cache_time))
    if (( cache_age < cache_duration )); then
      # Cache is still valid, use it
      cat "$cache_file"
      return 0
    fi
  fi

  # Cache is invalid or doesn't exist, update it
  local stats
  if stats=$(timeout 3s "$cmd" -q -l 0 -r 0 -v --interval 1 2>/dev/null) &&
     [[ -n "$stats" ]]; then
    local processed_stats
    processed_stats=$(echo "$stats" | \
      perl -pe 's/  +/ /g; s|(\d+)MB|int($1/1024)|e;' \
           -e 's/[▕▏]//g;' \
           -e 's/(\d+\.\d\d)/sprintf "%.1f", $1/eg;')

    # Save to cache
    echo "$processed_stats" > "$cache_file"
    echo "$processed_stats"
  else
    # If we can't get new data but have old cache, use it
    if [[ -f "$cache_file" ]]; then
      cat "$cache_file"
    else
      echo "CPU: ..."
    fi
  fi
  return 0
}

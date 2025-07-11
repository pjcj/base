# Print out Memory, cpu and load using
# https://github.com/thewtex/tmux-mem-cpu-load

update_cache_background() {
  local cmd="$1"
  local cache_file="$2"

  # Run in background to update cache
  {
    local stats
    if stats=$(timeout 3s "$cmd" -q -l 0 -r 0 -v --interval 1 2>/dev/null) &&
      [[ -n $stats ]]; then
      local processed_stats
      processed_stats=$(echo "$stats" |
        perl -pe 's/  +/ /g; s|(\d+)MB|int($1/1024)|e;' \
          -e 's/[▕▏]//g;' \
          -e 's/(\d+\.\d\d)/sprintf "%.1f", $1/eg;')
      echo "$processed_stats" >"$cache_file"
    fi
  } &
}

run_segment() {
  local cmd=~/.tmux/plugins/tmux-mem-cpu-load/tmux-mem-cpu-load
  local cache_file="/tmp/tmux_mem_cpu_load_cache"
  local cache_duration=5
  local lock_timeout=$((cache_duration * 60 / 100)) # 60% of cache time
  local lock_file="/tmp/tmux_mem_cpu_load_lock"

  if ! type "$cmd" >/dev/null 2>&1; then
    echo "CPU: N/A"
    return 0
  fi

  # Always return immediately with cached data or loading message
  if [[ -f $cache_file ]]; then
    local cache_time
    cache_time=$(stat -c %Y "$cache_file" 2>/dev/null ||
      stat -f %m "$cache_file" 2>/dev/null || echo 0)
    local cache_age=$(($(date +%s) - cache_time))

    # Display cached data
    cat "$cache_file"

    # If cache is stale and no update is in progress, start background update
    if ((cache_age >= cache_duration)) && [[ ! -f $lock_file ]]; then
      # Create lock file to prevent multiple background updates
      touch "$lock_file"
      # Remove lock file after 60% of cache time
      (
        sleep "$lock_timeout"
        rm -f "$lock_file"
      ) &
      # Start background update
      update_cache_background "$cmd" "$cache_file"
    fi
  else
    # No cache exists, show loading message and start background update
    echo "CPU: ..."
    if [[ ! -f $lock_file ]]; then
      touch "$lock_file"
      (
        sleep "$lock_timeout"
        rm -f "$lock_file"
      ) &
      update_cache_background "$cmd" "$cache_file"
    fi
  fi

  return 0
}

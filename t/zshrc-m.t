#!/usr/bin/env bash

# Load the m function from .zshrc with bat and mdmost replaced by stubs that
# record their arguments, then check which pager each kind of call reaches.

set -eEuo pipefail
if ((BASH_VERSINFO[0] >= 4)); then
  shopt -s inherit_errexit
fi

Zshrc=$(cd "$(dirname "$0")/.." && pwd)/.zshrc
Work=$(mktemp -d)
trap 'rm -rf "$Work"' EXIT

Fails=0

if ! command -v expect >/dev/null; then
  echo "ok - skipped, expect is not installed"
  exit 0
fi

fail() {
  echo "not ok - $1" >&2
  ((Fails++)) || true
}

is() {
  local got=$1 want=$2 name=$3
  if [[ $got == "$want" ]]; then
    echo "ok - $name"
  else
    fail "$name (got '$got', want '$want')"
  fi
}

setup() {
  mkdir -p "$Work/bin"
  local tool
  for tool in bat mdmost; do
    cat >"$Work/bin/$tool" <<EOT
#!/bin/sh
echo "$tool \$*" >>"$Work/log"
EOT
    chmod +x "$Work/bin/$tool"
  done
  awk '/^m\(\)/ { p = 1 } p { print } p && /^}|}$/ { exit }' "$Zshrc" \
    >"$Work/m.zsh"
  cat >"$Work/tty.exp" <<'EOT'
set stty_init "-onlcr -echo"
spawn -noecho zsh -f -c {source ./m.zsh; m "$@"} m {*}$argv
expect eof
EOT
  touch "$Work/sample.md" "$Work/README.MD" "$Work/sample.pl"
}

# Run m with the given arguments and return what the stubs recorded.
run() {
  rm -f "$Work/log"
  (cd "$Work" && PATH="$Work/bin:$PATH" zsh -f -c 'source ./m.zsh; m "$@"' m "$@")
  cat "$Work/log" 2>/dev/null || true
}

# The same, with a terminal on standard output.
run_tty() {
  rm -f "$Work/log"
  (cd "$Work" && PATH="$Work/bin:$PATH" expect ./tty.exp "$@" >/dev/null)
  cat "$Work/log" 2>/dev/null || true
}

test_m() {
  setup
  is "$(run_tty sample.md)" "mdmost sample.md" \
    "a markdown file on a terminal goes to mdmost"
  is "$(run_tty README.MD)" "mdmost README.MD" \
    "the extension match ignores case"
  is "$(run sample.md)" "bat --tabs=2 sample.md" \
    "a markdown file off a terminal goes to bat"
  is "$(run_tty sample.pl)" "bat --tabs=2 sample.pl" \
    "another file goes to bat"
  is "$(run_tty -l perl sample.md)" "bat --tabs=2 -l perl sample.md" \
    "options send everything to bat"
  is "$(run_tty sample.md sample.pl)" "bat --tabs=2 sample.md sample.pl" \
    "several files go to bat"
  is "$(echo hi | run)" "bat --tabs=2" "a pipe goes to bat"
}

test_m

if ((Fails > 0)); then
  echo "$Fails failure(s)" >&2
  exit 1
fi

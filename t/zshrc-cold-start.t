#!/usr/bin/env bash

# Start zsh as cmux does at its first prompt, a login shell with the bare
# launchd PATH, TERM=xterm-ghostty and the terminal's own TERMINFO, then
# check that .zshrc left every key binding and terminfo lookup usable.

set -eEuo pipefail

Work=$(mktemp -d)
trap 'rm -rf "$Work"' EXIT

Zsh=$(command -v zsh)
Timeout=$(command -v timeout || true)
Terminfo_dir=
for dir in /Applications/cmux.app/Contents/Resources/terminfo \
  /Applications/Ghostty.app/Contents/Resources/terminfo; do
  if [[ -d $dir ]]; then
    Terminfo_dir=$dir
    break
  fi
done
Fails=0

fail() {
  echo "not ok - $1" >&2
  ((Fails++)) || true
}

check() {
  local name=$1
  shift
  if "$@"; then echo "ok - $name"; else fail "$name"; fi
}

is() {
  local got=$1 want=$2 name=$3
  if [[ $got == "$want" ]]; then
    echo "ok - $name"
  else
    fail "$name (got '$got', want '$want')"
  fi
}

probe() {
  cat <<'EOS'
cold_start_probe() {
  local -a all
  all=(${(f)"$(zle -la)"})
  local -A seen
  local km key widget
  for km in main viins vicmd; do
    bindkey -M $km
  done | while read -r key widget; do
    [[ $widget == \"* || -n ${seen[$widget]} ]] && continue
    seen[$widget]=1
    (( ${all[(Ie)$widget]} )) || print -r -- "widget-missing $widget"
  done
  if tput cols >/dev/null 2>&1; then
    print "terminfo ok"
  else
    print "terminfo missing"
  fi
  print -r -- "f1 $(_fzfgv 70 2>/dev/null)"
}
cold_start_probe >| "$COLD_START_OUT"
EOS
}

cold_start() {
  env -i HOME="$HOME" USER="$USER" LOGNAME="$USER" SHELL="$Zsh" \
    PATH=/usr/bin:/bin:/usr/sbin:/sbin \
    TERM=xterm-ghostty ${Terminfo_dir:+TERMINFO="$Terminfo_dir"} \
    TERM_PROGRAM=ghostty COLORTERM=truecolor LANG="${LANG:-C.UTF-8}" \
    ${SSH_AUTH_SOCK:+SSH_AUTH_SOCK="$SSH_AUTH_SOCK"} \
    COLD_START_OUT="$Work/probe" \
    ${Timeout:+"$Timeout" 120} "$Zsh" -il -c "$(probe)" \
    </dev/null >"$Work/startup.log" 2>&1
}

test_cold_start() {
  if ! cold_start; then
    fail "zsh cold start exits cleanly"
  fi
  check "cold start writes a probe" test -s "$Work/probe"
  local missing
  missing=$(sed -n 's/^widget-missing //p' "$Work/probe" | tr '\n' ' ')
  is "$missing" "" "every bound key has a widget"
  is "$(sed -n 's/^terminfo //p' "$Work/probe")" ok \
    "terminfo for TERM is found at the first prompt"
  check "F1 preview width is computed" \
    grep -q -- '--width=[0-9]' "$Work/probe"
}

test_cold_start

if ((Fails > 0)); then
  echo "--- startup log (last 20 lines) ---" >&2
  tr '\r' '\n' <"$Work/startup.log" | tail -20 >&2
  echo "$Fails failure(s)" >&2
  exit 1
fi

#!/usr/bin/env bash

# Run the yazi markdown previewer the way piper does, with no terminal on
# stdin, and check that the output is coloured and free of stray escapes.

set -eEuo pipefail
if ((BASH_VERSINFO[0] >= 4)); then
  shopt -s inherit_errexit
fi

Script=$(cd "$(dirname "$0")/.." && pwd)/utils/mdmost-preview
Work=$(mktemp -d)
trap 'rm -rf "$Work"' EXIT

Width=40
Fails=0

for tool in mdmost expect; do
  if ! command -v "$tool" >/dev/null; then
    echo "ok - skipped, $tool is not installed"
    exit 0
  fi
done

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

fixture() {
  cat >"$Work/sample.md" <<'EOS'
# Sample heading

Some *emphasis* and **strong** text with `code`.

- first
- second
EOS
}

render() {
  "$Script" "$Width" "$Work/sample.md" </dev/null >"$Work/out" 2>"$Work/err"
}

without_colour() {
  perl -pe 's/\e\[[0-9;]*m//g' "$Work/out"
}

count() {
  local pattern=$1
  perl -ne 'while (/'"$pattern"'/g) { $n++ } END { print $n + 0 }' \
    "$Work/out"
}

test_render() {
  fixture
  check "wrapper exits cleanly" render
  check "output has colour escapes" grep -q $'\e\\[[0-9;]*m' "$Work/out"
  is "$(count '\r')" 0 "no carriage returns"
  is "$(count '\e\[6n')" 0 "no cursor-position query"
  is "$(count '\e\[[0-9;?]*[^0-9;m]')" 0 "no escapes other than colour"
  local widths
  widths=$(without_colour | perl -CS -ne 'chomp; print length, "\n"' | sort -u)
  is "$widths" "$Width" "every line is $Width columns"
  check "heading text is present" grep -q "Sample heading" <(without_colour)
}

test_missing_file() {
  if "$Script" "$Width" "$Work/missing.md" </dev/null >/dev/null 2>&1; then
    fail "missing file gives a non-zero exit"
  else
    echo "ok - missing file gives a non-zero exit"
  fi
}

test_render
test_missing_file

if ((Fails > 0)); then
  echo "$Fails failure(s)" >&2
  exit 1
fi

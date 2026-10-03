#!/usr/bin/env bash

set -eEuo pipefail
if ((BASH_VERSINFO[0] >= 4)); then
  shopt -s inherit_errexit
fi

Script=$(cd "$(dirname "$0")/.." && pwd)/utils/claude-usage-snapshot
Work=$(mktemp -d)
trap 'rm -rf "$Work"' EXIT

Fake_claude="$Work/claude"
Snapshot="$Work/usage-snapshot.json"
Reset_epoch=$(jq -n '"2026-10-07T12:00:00Z" | fromdate')
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

not() { ! "$@"; }

run_forced() { run --force; }

field() { jq -r "$1" "$Snapshot"; }

mode() { stat -c %a "$1" 2>/dev/null || stat -f %Lp "$1"; }

fake_claude() {
  local reply=$1 status=${2:-0}
  cat >|"$Fake_claude" <<EOS
#!/usr/bin/env bash
cat > "$Work/stdin"
printf '%s\n' "\$@" > "$Work/args"
echo '{"type":"system","subtype":"init"}'
echo '$reply'
exit $status
EOS
  chmod +x "$Fake_claude"
}

reply() {
  jq -nc --argjson rate_limits "$1" '{
    type: "control_response",
    response: {subtype: "success", request_id: "u1",
      response: {subscription_type: "max", rate_limits_available: true,
        rate_limits: $rate_limits}}}'
}

run() {
  CLAUDE_BIN="$Fake_claude" CLAUDE_USAGE_SNAPSHOT="$Snapshot" \
    CLAUDE_USAGE_MAX_AGE=240 "$Script" "$@"
}

test_model_scoped() {
  rm -f "$Snapshot"
  fake_claude "$(reply '{"five_hour":{"utilization":0.3},
    "model_scoped":[{"display_name":"Fable","utilization":42,
      "resets_at":"2026-10-07T12:00:00.000Z"}]}')"
  run
  check "writes snapshot" test -f "$Snapshot"
  is "$(mode "$Snapshot")" 600 "snapshot is private"
  is "$(field .model_scoped[0].display_name)" Fable "names Fable"
  is "$(field .model_scoped[0].utilization)" 42 "keeps utilization"
  is "$(field .model_scoped[0].resets_at)" 2026-10-07T12:00:00.000Z \
    "keeps reset time"
  check "stamps updated_at" grep -q '"updated_at": "20' "$Snapshot"
  check "sends get_usage" grep -q '"subtype":"get_usage"' "$Work/stdin"
  is "$(wc -l <"$Work/stdin" | tr -d ' ')" 1 "sends one request"
  check "allows the usage fetch" \
    grep -q 'CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC": *""' "$Work/args"
}

test_limits_fallback() {
  rm -f "$Snapshot"
  fake_claude "$(reply '{"model_scoped":[],
    "limits":[{"kind":"weekly_all","percent":50},
      {"kind":"weekly_scoped","percent":84,"resets_at":'"$Reset_epoch"',
        "scope":{"model":{"display_name":"Fable"}}}]}')"
  run
  is "$(field .model_scoped[0].display_name)" Fable "falls back to limits"
  is "$(field .model_scoped[0].utilization)" 84 "maps percent"
  is "$(field .model_scoped[0].resets_at)" 2026-10-07T12:00:00Z \
    "converts epoch reset"
}

test_fresh_snapshot_skipped() {
  fake_claude "$(reply null)"
  run
  is "$(field .model_scoped[0].utilization)" 84 "keeps fresh snapshot"
  check "forces refresh" not run_forced 2>/dev/null
}

test_lock_held() {
  rm -f "$Snapshot" "$Work/stdin"
  mkdir "$Snapshot.lock"
  fake_claude "$(reply null)"
  run
  check "skips while locked" test ! -f "$Work/stdin"
  rmdir "$Snapshot.lock"
}

test_stale_lock() {
  rm -f "$Snapshot" "$Work/stdin"
  mkdir "$Snapshot.lock"
  touch -t 202601010000 "$Snapshot.lock"
  fake_claude "$(reply '{"model_scoped":[{"display_name":"Fable",
    "utilization":7,"resets_at":"2026-10-07T12:00:00Z"}]}')"
  run
  is "$(field .model_scoped[0].utilization)" 7 "ignores stale lock"
  check "releases lock" test ! -d "$Snapshot.lock"
}

test_null_rate_limits() {
  rm -f "$Snapshot"
  fake_claude "$(reply null)"
  check "fails on null rate limits" not run 2>/dev/null
  is "$(field '.model_scoped | length')" 0 "writes empty snapshot on failure"
  rm -f "$Work/stdin"
  run 2>/dev/null || true
  check "backs off after failure" test ! -f "$Work/stdin"
}

test_claude_exits_nonzero() {
  rm -f "$Snapshot"
  fake_claude "" 1
  check "fails when claude fails" not run 2>/dev/null
  check "writes empty snapshot when claude fails" test -f "$Snapshot"
  is "$(field '.model_scoped | length')" 0 "empty snapshot has no models"
  rm -f "$Work/stdin"
  run 2>/dev/null || true
  check "backs off after claude fails" test ! -f "$Work/stdin"
}

test_model_scoped
test_limits_fallback
test_fresh_snapshot_skipped
test_lock_held
test_stale_lock
test_null_rate_limits
test_claude_exits_nonzero

if ((Fails > 0)); then
  echo "$Fails failure(s)" >&2
  exit 1
fi

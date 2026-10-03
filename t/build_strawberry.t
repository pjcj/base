#!/usr/bin/env bash

set -eEuo pipefail
if ((BASH_VERSINFO[0] >= 4)); then
  shopt -s inherit_errexit
fi

Script=$(cd "$(dirname "$0")/.." && pwd)/utils/build_strawberry
Work=$(mktemp -d)
trap 'rm -rf "$Work"' EXIT

Sw=$Work/sw
Prefix=$Work/opt/strawberry_macos_arm64_release
Prefix_target=$Sw/deps/opt/strawberry_macos_arm64_release
Apps=$Work/apps
Deps_asset=strawberry-macos-arm64-release.tar.xz
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

env_value() { sed -n "s/^$1=//p" "$Work/cmake.env"; }

cmake_line() { sed -n "$1p" "$Work/cmake.log"; }

downloads() { grep -c '^release download' "$Work/gh.log" || true; }

fake_gh() {
  cat >|"$Work/bin/gh" <<EOS
#!/usr/bin/env bash
printf '%s\n' "\$*" >> "$Work/gh.log"
case "\$1 \$2" in
"release list") cat "$Work/latest_version" ;;
"release view") cat "$Work/deps_tag" ;;
"release download")
  pattern=\$(printf '%s\n' "\$@" | sed -n '/--pattern/{n;p;}')
  dir=\$(printf '%s\n' "\$@" | sed -n '/--dir/{n;p;}')
  output=\$(printf '%s\n' "\$@" | sed -n '/--output/{n;p;}')
  cp "$Work/fixtures/\$pattern" "\${output:-\$dir/\$pattern}"
  ;;
esac
EOS
  chmod +x "$Work/bin/gh"
}

fake_cmake() {
  cat >|"$1" <<EOS
#!/usr/bin/env bash
printf '%s\n' "\$*" >> "$Work/cmake.log"
printf 'PATH=%s\nPKG_CONFIG_PATH=%s\nLDFLAGS=%s\n' \
  "\$PATH" "\${PKG_CONFIG_PATH:-}" "\${LDFLAGS:-}" >| "$Work/cmake.env"
if [[ \$1 == -S ]]; then
  mkdir -p "\$4"
  cp "$Work/cache" "\$4/CMakeCache.txt"
fi
if [[ \$* == *"--target deploy"* ]]; then
  mkdir -p "\$2/strawberry.app/Contents/MacOS"
  touch "\$2/strawberry.app/Contents/MacOS/strawberry"
fi
EOS
  chmod +x "$1"
}

fake_pgrep() {
  printf '#!/usr/bin/env bash\nexit %s\n' "$1" >|"$Work/bin/pgrep"
  chmod +x "$Work/bin/pgrep"
}

deps_fixture() {
  local root=$Work/deps_root
  rm -rf "$root"
  mkdir -p "$root/opt/strawberry_macos_arm64_release/bin"
  fake_cmake "$root/opt/strawberry_macos_arm64_release/bin/cmake"
  tar -cJf "$Work/fixtures/$Deps_asset" -C "$root" opt
}

source_fixture() {
  local root=$Work/src_root
  rm -rf "$root"
  mkdir -p "$root/strawberry-$1"
  touch "$root/strawberry-$1/CMakeLists.txt"
  tar -cJf "$Work/fixtures/strawberry-$1.tar.xz" -C "$root" "strawberry-$1"
}

setup() {
  mkdir -p "$Work/bin" "$Work/fixtures" "$Work/opt" "$Apps"
  fake_gh
  fake_pgrep 1
  deps_fixture
  source_fixture 1.2.31
  source_fixture 1.2.30
  echo 1.2.31 >|"$Work/latest_version"
  echo 0.1.222 >|"$Work/deps_tag"
  echo 'CMAKE_PREFIX_PATH:PATH=/opt/strawberry/lib/cmake' >|"$Work/cache"
}

run() {
  PATH="$Work/bin:$PATH" STRAWBERRY_SW_DIR="$Sw" STRAWBERRY_PREFIX="$Prefix" \
    STRAWBERRY_APP_DIR="$Apps" STRAWBERRY_JOBS=3 "$Script" "$@"
}

test_missing_symlink() {
  local err
  err=$(run 2>&1 >/dev/null) && fail "fails without the prefix symlink"
  check "names the symlink command" \
    grep -q "sudo ln -s $Prefix_target $Prefix" <<<"$err"
  check "downloads nothing first" test ! -f "$Work/gh.log"
}

test_full_run() {
  ln -s "$Prefix_target" "$Prefix"
  run
  check "resolves the latest release" grep -q '^release list' "$Work/gh.log"
  check "keeps the source tarball" test -f "$Sw/src/strawberry-1.2.31.tar.xz"
  check "keeps the deps tarball with its tag" \
    test -f "$Sw/deps/strawberry-macos-arm64-release-0.1.222.tar.xz"
  is "$(cat "$Sw/deps/current")" 0.1.222 "records the deps tag"
  check "extracts the source" \
    test -f "$Sw/src/strawberry-1.2.31/CMakeLists.txt"
  check "configures the source tree" grep -q \
    -- "-S $Sw/src/strawberry-1.2.31 -B $Sw/src/strawberry-1.2.31/build" \
    "$Work/cmake.log"
  check "turns Sparkle off" grep -q -- '-DENABLE_SPARKLE=OFF' "$Work/cmake.log"
  check "bundles dependencies" grep -q -- '-DUSE_BUNDLE=ON' "$Work/cmake.log"
  check "points cmake at the prefix" \
    grep -q -- "-DCMAKE_PREFIX_PATH=$Prefix/lib/cmake" "$Work/cmake.log"
  check "builds in parallel" grep -q -- '--parallel 3' "$Work/cmake.log"
  is "$(cmake_line 3 | grep -o -- '--target [a-z]*')" "--target install" \
    "installs after building"
  is "$(cmake_line 4 | grep -o -- '--target [a-z]*')" "--target deploy" \
    "deploys last"
  check "puts the prefix first in PATH" \
    grep -q "^PATH=$Prefix/bin:" "$Work/cmake.env"
  check "hides Homebrew from the build" \
    not grep -q homebrew "$Work/cmake.env"
  is "$(env_value PKG_CONFIG_PATH)" "$Prefix/lib/pkgconfig" \
    "sets PKG_CONFIG_PATH"
  is "$(env_value LDFLAGS)" "-L$Prefix/lib -Wl,-rpath,$Prefix/lib" \
    "sets LDFLAGS"
  check "installs the bundle" \
    test -f "$Apps/strawberry.app/Contents/MacOS/strawberry"
}

test_explicit_version() {
  rm -f "$Work/gh.log"
  run 1.2.30
  check "skips the release lookup" not grep -q '^release list' "$Work/gh.log"
  check "builds the requested version" \
    test -f "$Sw/src/strawberry-1.2.30/CMakeLists.txt"
}

test_reuses_downloads() {
  rm -f "$Work/gh.log"
  touch "$Sw/deps/opt/sentinel"
  run
  is "$(downloads)" 0 "downloads nothing it already has"
  check "leaves extracted deps alone" test -f "$Sw/deps/opt/sentinel"
}

test_new_deps_release() {
  echo 0.1.230 >|"$Work/deps_tag"
  run
  is "$(cat "$Sw/deps/current")" 0.1.230 "records the new deps tag"
  check "replaces extracted deps" test ! -f "$Sw/deps/opt/sentinel"
  check "keeps the old deps tarball" \
    test -f "$Sw/deps/strawberry-macos-arm64-release-0.1.222.tar.xz"
}

test_homebrew_leak() {
  echo 'OPENSSL_ROOT_DIR:PATH=/opt/homebrew/opt/openssl' >|"$Work/cache"
  rm -f "$Work/cmake.log"
  check "fails when Homebrew leaks into the configure" not run 2>/dev/null
  is "$(wc -l <"$Work/cmake.log" | tr -d ' ')" 1 "stops before building"
  echo 'CMAKE_PREFIX_PATH:PATH=/opt/strawberry/lib/cmake' >|"$Work/cache"
}

test_no_install() {
  local out
  rm -rf "$Apps/strawberry.app"
  out=$(run --no-install 2>&1)
  check "builds without installing" test ! -d "$Apps/strawberry.app"
  check "prints the install command" grep -qF "rm -rf $Apps/strawberry.app \
&& ditto $Sw/src/strawberry-1.2.31/build/strawberry.app $Apps/strawberry.app" \
    <<<"$out"
}

test_running_app() {
  fake_pgrep 0
  check "refuses to replace a running app" not run 2>/dev/null
  check "leaves the apps folder alone" test ! -d "$Apps/strawberry.app"
  fake_pgrep 1
}

setup
test_missing_symlink
test_full_run
test_explicit_version
test_reuses_downloads
test_new_deps_release
test_homebrew_leak
test_no_install
test_running_app

if ((Fails > 0)); then
  echo "$Fails failure(s)" >&2
  exit 1
fi

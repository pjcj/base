#!/usr/bin/env bash
set -euo pipefail

if ! command -v rg >/dev/null 2>&1; then
  echo "❌ requires ripgrep (brew install ripgrep)"
  exit 1
fi

scan_dirs=(/Applications "$HOME/Applications" /System/Applications)

find "${scan_dirs[@]}" \
  -path "*/Contents/Frameworks/Electron Framework.framework/Versions/A/Electron Framework" \
  -type f -print0 2>/dev/null |
while IFS= read -r -d '' filename; do
  app="${filename%%.app/*}.app"
  appName="$(basename "$app")"

  ev="$(rg -a -m1 -o -r '$1' 'Chrome/.*Electron/([0-9]+(\.[0-9]+){1,3})' -- "$filename" 2>/dev/null || true)"
  [[ -z "$ev" ]] && ev="$(rg -a -m1 -o -r '$1' 'Electron/([0-9]+(\.[0-9]+){1,3})' -- "$filename" 2>/dev/null || true)"

  relativePath="${filename#"$app/"}"

  if rg -a -q -F "_cornerMask" -- "$filename" 2>/dev/null; then
    echo -e "❌ $appName \033[2m(Electron ${ev:-unknown}) - $relativePath\033[0m"
  else
    echo -e "✅ $appName \033[2m(Electron ${ev:-unknown}) - $relativePath\033[0m"
  fi
done

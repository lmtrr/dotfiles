#!/usr/bin/env sh

set -eu

if command -v lua >/dev/null 2>&1; then
  interpreter=lua
elif command -v luajit >/dev/null 2>&1; then
  interpreter=luajit
else
  echo "Neither lua nor luajit was found. Install one of them, then re-run this script." >&2
  exit 1
fi

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo_root"

for test_file in tests/*_test.lua; do
  "$interpreter" "$test_file"
  echo "PASS $test_file"
done

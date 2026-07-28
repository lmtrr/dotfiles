#!/usr/bin/env sh

set -eu

REPO_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
CLIENT_CHECK="$REPO_DIR/bin/tmux-client-is-wezterm"
FIXTURE_BIN="$REPO_DIR/tests/fixtures"

if ! PATH="$FIXTURE_BIN:$PATH" TMUX_CLIENT_TEST_SCENARIO=wezterm "$CLIENT_CHECK" 200; then
  echo "WezTerm client process should be detected" >&2
  exit 1
fi

if PATH="$FIXTURE_BIN:$PATH" TMUX_CLIENT_TEST_SCENARIO=other "$CLIENT_CHECK" 200; then
  echo "non-WezTerm client process should not be detected" >&2
  exit 1
fi

if "$CLIENT_CHECK" invalid; then
  echo "invalid client PID should be rejected" >&2
  exit 1
fi

echo "tmux client tests passed."

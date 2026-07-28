#!/usr/bin/env sh

set -eu

REPO_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TMUX_CONFIG="$REPO_DIR/.tmux.conf"
SERVER_NAME="dotfiles-test-$$"

cleanup() {
  tmux -L "$SERVER_NAME" kill-server >/dev/null 2>&1 || true
}

assert_equal() {
  expected=$1
  actual=$2
  message=$3

  if [ "$actual" = "$expected" ]; then
    return
  fi

  echo "$message: expected '$expected', got '$actual'" >&2
  exit 1
}

trap cleanup EXIT INT TERM

tmux -L "$SERVER_NAME" -f "$TMUX_CONFIG" new-session -d
prefix=$(tmux -L "$SERVER_NAME" show-options -gv prefix)
root_binding=$(tmux -L "$SERVER_NAME" list-keys -T root | sed -n '/ C-a /p')
prefix_binding=$(tmux -L "$SERVER_NAME" list-keys -T prefix | sed -n '/ C-a /p')

assert_equal "None" "$prefix" "global tmux prefix"
case "$prefix_binding" in
  *send-keys*C-a*) ;;
  *)
    echo "Ctrl+a should send a literal Ctrl+a from the prefix table: $prefix_binding" >&2
    exit 1
    ;;
esac

case "$root_binding" in
  *tmux-client-is-wezterm*client_pid*send-keys*C-a*switch-client*prefix*) ;;
  *)
    echo "Ctrl+a should select behavior using the active tmux client: $root_binding" >&2
    exit 1
    ;;
esac

echo "tmux config tests passed."

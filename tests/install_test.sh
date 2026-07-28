#!/usr/bin/env sh

set -eu

REPO_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
TEST_DIR=${TMPDIR:-/tmp}/dotfiles-install-test-$$
TEST_HOME="$TEST_DIR/home"
FAKE_BIN="$TEST_DIR/bin"

cleanup() {
  rm -rf "$TEST_DIR"
}

assert_symlink() {
  expected=$1
  link=$2

  if [ -L "$link" ] && [ "$(readlink "$link")" = "$expected" ]; then
    return
  fi

  echo "$link should point to $expected" >&2
  exit 1
}

trap cleanup EXIT INT TERM

mkdir -p \
  "$FAKE_BIN" \
  "$TEST_HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" \
  "$TEST_HOME/Library/Fonts"
touch "$TEST_HOME/Library/Fonts/LibertinusSerif-Regular.otf"
printf '%s\n' "existing tmux config" >"$TEST_HOME/.tmux.conf"

ln -s /usr/bin/true "$FAKE_BIN/brew"
ln -s "$REPO_DIR/tests/fixtures/date" "$FAKE_BIN/date"

printf '%s\n' "reserved backup" >"$TEST_HOME/.tmux.conf.backup.20260720000000"

HOME="$TEST_HOME" PATH="$FAKE_BIN:$PATH" sh "$REPO_DIR/install.sh" >/dev/null

assert_symlink "$REPO_DIR/.zshrc" "$TEST_HOME/.zshrc"
assert_symlink "$REPO_DIR/.tmux.conf" "$TEST_HOME/.tmux.conf"

if [ "$(cat "$TEST_HOME/.tmux.conf.backup.20260720000000")" != "reserved backup" ]; then
  echo "existing backup should be preserved" >&2
  exit 1
fi

if [ "$(cat "$TEST_HOME/.tmux.conf.backup.20260720000000.1")" != "existing tmux config" ]; then
  echo "tmux backup collision should use a numeric suffix" >&2
  exit 1
fi

assert_symlink "$REPO_DIR/bin/tmux-client-is-wezterm" "$TEST_HOME/.local/bin/tmux-client-is-wezterm"

HOME="$TEST_HOME" PATH="$FAKE_BIN:$PATH" sh "$REPO_DIR/install.sh" >/dev/null

assert_symlink "$REPO_DIR/.zshrc" "$TEST_HOME/.zshrc"
assert_symlink "$REPO_DIR/.tmux.conf" "$TEST_HOME/.tmux.conf"
assert_symlink "$REPO_DIR/bin/tmux-client-is-wezterm" "$TEST_HOME/.local/bin/tmux-client-is-wezterm"

echo "installer tests passed."

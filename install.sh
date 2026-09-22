#!/usr/bin/env sh

set -eu

if [ "$(uname -s)" != "Darwin" ]; then
  echo "install.sh only supports macOS." >&2
  exit 1
fi

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

find_brew() {
  if command -v brew >/dev/null 2>&1; then
    command -v brew
    return
  fi

  if [ -x /opt/homebrew/bin/brew ]; then
    echo /opt/homebrew/bin/brew
    return
  fi

  if [ -x /usr/local/bin/brew ]; then
    echo /usr/local/bin/brew
    return
  fi

  return 1
}

BREW_BIN=$(find_brew || true)

require_brew() {
  if [ -z "$BREW_BIN" ]; then
    echo "Homebrew was not found." >&2
    echo "Install Homebrew first, then re-run this script." >&2
    exit 1
  fi
}

require_command() {
  command_name=$1

  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "$command_name was not found." >&2
    echo "Install $command_name first, then re-run this script." >&2
    exit 1
  fi
}

install_brew_formula() {
  formula=$1
  require_brew

  if "$BREW_BIN" list --formula "$formula" >/dev/null 2>&1; then
    echo "$formula is already installed."
    return
  fi

  echo "Installing $formula with Homebrew..."
  "$BREW_BIN" install "$formula"
}

install_homebrew_tools() {
  for formula in fzf zoxide eza; do
    install_brew_formula "$formula"
  done
}

install_oh_my_zsh() {
  if [ -d "$HOME/.oh-my-zsh" ]; then
    echo "Oh My Zsh is already installed."
    return
  fi

  require_command curl

  echo "Installing Oh My Zsh..."
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
}

install_omz_custom_plugin() {
  plugin_name=$1
  repo_url=$2
  plugin_dir="$HOME/.oh-my-zsh/custom/plugins/$plugin_name"

  if [ -d "$plugin_dir" ]; then
    echo "$plugin_name is already installed."
    return
  fi

  require_command git

  mkdir -p "$HOME/.oh-my-zsh/custom/plugins"
  echo "Installing $plugin_name for Oh My Zsh..."
  git clone "$repo_url" "$plugin_dir"
}

install_symlink() {
  source=$1
  target=$2

  if [ ! -e "$source" ]; then
    echo "Missing config: $source" >&2
    exit 1
  fi

  if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
    echo "$target already points to $source."
    return
  fi

  if [ -e "$target" ] || [ -L "$target" ]; then
    backup="$target.backup.$(date +%Y%m%d%H%M%S)"
    suffix=1

    while [ -e "$backup" ] || [ -L "$backup" ]; do
      backup="$target.backup.$(date +%Y%m%d%H%M%S).$suffix"
      suffix=$((suffix + 1))
    done

    mv "$target" "$backup"
    echo "Backed up existing $target to $backup."
  fi

  mkdir -p "$(dirname -- "$target")"
  ln -s "$source" "$target"
  echo "Linked $target -> $source."
}

has_libertinus_font() {
  for dir in \
    "$HOME/Library/Fonts" \
    "/Library/Fonts" \
    "/System/Library/Fonts" \
    "/Network/Library/Fonts"
  do
    [ -d "$dir" ] || continue

    for font in "$dir"/*Libertinus* "$dir"/*libertinus*; do
      [ -f "$font" ] && return 0
    done
  done

  return 1
}

install_libertinus_font() {
  if has_libertinus_font; then
    echo "Libertinus font is already installed."
    return
  fi

  require_brew

  echo "Libertinus font is not installed. Installing font-libertinus with Homebrew..."
  "$BREW_BIN" install --cask font-libertinus
}

install_symlink "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"
install_symlink "$SCRIPT_DIR/.wezterm.lua" "$HOME/.wezterm.lua"
install_symlink "$SCRIPT_DIR/.gitconfig" "$HOME/.gitconfig"
install_symlink "$SCRIPT_DIR/nvim" "${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
install_oh_my_zsh
install_omz_custom_plugin zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git
install_homebrew_tools

install_libertinus_font

echo "Fonts are now available in Font Book."

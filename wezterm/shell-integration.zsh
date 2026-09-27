# WezTerm shell integration for the tab bar and status line in .wezterm.lua.
# It sends pane user vars after each command:
#   WEZTERM_CMD          last command line
#   WEZTERM_CMD_STATUS   "running" or the exit code
#   WEZTERM_CMD_DURATION seconds, for example "12.4"
#   WEZTERM_GIT          "branch|ahead|changed"
# Source it at the END of ~/.zshrc (after oh-my-posh), so the exit code is still correct:
#   [[ -f ~/dotfiles/wezterm/shell-integration.zsh ]] && source ~/dotfiles/wezterm/shell-integration.zsh

[[ "$TERM_PROGRAM" == "WezTerm" ]] || return 0
zmodload zsh/datetime

__wezterm_set_user_var() {
  local encoded
  encoded=$(printf '%s' "$2" | base64 | tr -d '\n')
  if [[ -n "$TMUX" ]]; then
    printf '\033Ptmux;\033\033]1337;SetUserVar=%s=%s\007\033\\' "$1" "$encoded"
  else
    printf '\033]1337;SetUserVar=%s=%s\007' "$1" "$encoded"
  fi
}

__wezterm_git_info() {
  local branch ahead changed info=""
  branch=$(git symbolic-ref --short -q HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
  if [[ -n "$branch" ]]; then
    ahead=$(git rev-list --count '@{upstream}..HEAD' 2>/dev/null)
    changed=$(git --no-optional-locks status --porcelain 2>/dev/null | wc -l | tr -d ' ')
    info="$branch|${ahead:-0}|${changed:-0}"
  fi
  [[ "$info" == "$__wezterm_last_git" ]] && return
  __wezterm_last_git=$info
  __wezterm_set_user_var WEZTERM_GIT "$info"
}

__wezterm_preexec() {
  __wezterm_cmd_start=$EPOCHREALTIME
  __wezterm_set_user_var WEZTERM_CMD "${1%%$'\n'*}"
  __wezterm_set_user_var WEZTERM_CMD_STATUS running
}

__wezterm_precmd() {
  local exit_code=$?
  if [[ -n "$__wezterm_cmd_start" ]]; then
    local duration=$(( EPOCHREALTIME - __wezterm_cmd_start ))
    # Duration first: WezTerm reads it when the status changes.
    __wezterm_set_user_var WEZTERM_CMD_DURATION "$(printf '%.1f' "$duration")"
    __wezterm_set_user_var WEZTERM_CMD_STATUS "$exit_code"
    unset __wezterm_cmd_start
  fi
  __wezterm_git_info
}

# Run first, so $? is the exit code of the command and not of another hook.
precmd_functions=(__wezterm_precmd ${precmd_functions:#__wezterm_precmd})
preexec_functions=(__wezterm_preexec ${preexec_functions:#__wezterm_preexec})

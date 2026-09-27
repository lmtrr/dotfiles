--- wezterm.lua
--- $ figlet -f small Wezterm
--- __      __      _
--- \ \    / /__ __| |_ ___ _ _ _ __
---  \ \/\/ / -_)_ /  _/ -_) '_| '  \
---   \_/\_/\___/__|\__\___|_| |_|_|_| My Wezterm config file
local wezterm = require("wezterm")
local act = wezterm.action

local zsh_path = "/bin/zsh"
local direction_keys = {
  h = "Left",
  j = "Down",
  k = "Up",
  l = "Right",
  LeftArrow = "Left",
  DownArrow = "Down",
  UpArrow = "Up",
  RightArrow = "Right",
}

local function basename(s)
  return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

local function trim(s)
  return s and s:match("^%s*(.-)%s*$") or ""
end

local function truncate_title(s, max_width)
  if max_width <= 0 or #s <= max_width then
    return s
  end

  if max_width <= 3 then
    return s:sub(1, max_width)
  end

  return s:sub(1, max_width - 3) .. "..."
end

local function cwd_to_path(cwd)
  if not cwd then
    return wezterm.home_dir
  end
  if type(cwd) == "userdata" then
    return cwd.file_path
  end
  return cwd
end

local function workspace_name_from_cwd(cwd)
  local path = cwd_to_path(cwd)
  local name = basename(path)
  return name ~= "" and name or "main"
end

local workspace_icon_names = {
  "cod_terminal",
  "dev_terminal",
  "fa_code",
  "fa_laptop",
  "fa_wrench",
  "fae_planet",
  "md_briefcase",
  "md_code_braces",
  "md_console",
  "md_cube",
  "md_database",
  "md_folder",
  "md_folder_star",
  "md_lightbulb",
  "oct_repo",
  "pl_branch",
}

local function hash_string(s)
  local hash = 0
  for i = 1, #s do
    hash = (hash * 31 + s:byte(i)) % 2147483647
  end
  return hash
end

local function workspace_icon(name)
  local icon_count = #workspace_icon_names
  local start_index = (hash_string(name or "") % icon_count) + 1

  for offset = 0, icon_count - 1 do
    local icon_name = workspace_icon_names[((start_index + offset - 1) % icon_count) + 1]
    local icon = wezterm.nerdfonts[icon_name]
    if icon and icon ~= "" then
      return icon
    end
  end

  return wezterm.nerdfonts.fae_planet or "*"
end

local function is_nvim(pane)
  local user_vars = pane:get_user_vars() or {}
  if user_vars.IS_NVIM == "true" then
    return true
  end

  local process_name = pane:get_foreground_process_name()
  return process_name and process_name:match("n?vim") ~= nil
end

local function split_nav(mode, key)
  local direction = direction_keys[key]
  return {
    key = key,
    mods = "META",
    action = wezterm.action_callback(function(window, pane)
      if is_nvim(pane) then
        window:perform_action(act.SendKey { key = key, mods = "ALT" }, pane)
        return
      end

      if mode == "resize" then
        window:perform_action(act.AdjustPaneSize { direction, 3 }, pane)
      else
        window:perform_action(act.ActivatePaneDirection(direction), pane)
      end
    end),
  }
end

local function send_if_nvim(key, mods)
  return wezterm.action_callback(function(window, pane)
    if is_nvim(pane) then
      window:perform_action(act.SendKey { key = key, mods = mods }, pane)
    end
  end)
end

local config = {}
-- Use config builder object if possible
if wezterm.config_builder then config = wezterm.config_builder() end

-- Settings
local dotfiles_dir = wezterm.home_dir .. "/dotfiles"
local theme_name = "vague" -- Change this name to switch both WezTerm and Neovim.
local theme_names = {
  "melange",
  "melange-light",
  "evergarden",
  "oxocarbon",
  "gruvbox",
  "gruvbox-light",
  "darcula",
  "vague",
  "github",
  "github-light",
  "tokyonight",
  "tokyonight-night",
  "tokyonight-storm",
  "tokyonight-moon",
  "tokyonight-day",
  "kanagawa",
  "kanagawa-dragon",
  "kanagawa-lotus",
}
local themes = {
  melange = {
    mode = "dark",
    wezterm = "Melange Dark",
    nvim = "melange",
  },
  ["melange-light"] = {
    mode = "light",
    wezterm = "Melange Light",
    nvim = "melange",
  },
  evergarden = {
    mode = "dark",
    wezterm = "Evergarden Fall Green",
    nvim = "evergarden",
  },
  oxocarbon = {
    mode = "dark",
    wezterm = "Oxocarbon Dark (Gogh)",
    nvim = "oxocarbon",
  },
  gruvbox = {
    mode = "dark",
    wezterm = "Gruvbox Dark (Gogh)",
    nvim = "gruvbox",
  },
  ["gruvbox-light"] = {
    mode = "light",
    wezterm = "GruvboxLight",
    nvim = "gruvbox",
  },
  darcula = {
    mode = "dark",
    wezterm = "Darcula",
    nvim = "darcula",
  },
  vague = {
    mode = "dark",
    wezterm = "Vague",
    nvim = "vague",
  },
  github = {
    mode = "dark",
    wezterm = "GitHub Dark Default",
    nvim = "github",
    variant = "dark_default",
  },
  ["github-light"] = {
    mode = "light",
    wezterm = "GitHub Light Default",
    nvim = "github",
    variant = "light_default",
  },
  tokyonight = {
    mode = "dark",
    wezterm = "Tokyo Night",
    nvim = "tokyonight",
    variant = "night",
  },
  ["tokyonight-night"] = {
    mode = "dark",
    wezterm = "Tokyo Night",
    nvim = "tokyonight",
    variant = "night",
  },
  ["tokyonight-storm"] = {
    mode = "dark",
    wezterm = "Tokyo Night Storm",
    nvim = "tokyonight",
    variant = "storm",
  },
  ["tokyonight-moon"] = {
    mode = "dark",
    wezterm = "Tokyo Night Moon",
    nvim = "tokyonight",
    variant = "moon",
  },
  ["tokyonight-day"] = {
    mode = "light",
    wezterm = "Tokyo Night Day",
    nvim = "tokyonight",
    variant = "day",
  },
  kanagawa = {
    mode = "dark",
    wezterm = "Kanagawa Wave",
    nvim = "kanagawa",
    variant = "wave",
  },
  ["kanagawa-dragon"] = {
    mode = "dark",
    wezterm = "Kanagawa Dragon",
    nvim = "kanagawa",
    variant = "dragon",
  },
  ["kanagawa-lotus"] = {
    mode = "light",
    wezterm = "Kanagawa Lotus",
    nvim = "kanagawa",
    variant = "lotus",
  },
}

local selected_theme = themes[theme_name]
if not selected_theme then
  error("Invalid theme_name: " .. tostring(theme_name) .. ". Expected one of: " .. table.concat(theme_names, ", "))
end
local theme_mode = selected_theme.mode
-- Tab bar colors. Semantic colors show state: ok, error, running, remote, leader.
-- pill_bg is the background of the status blocks; divider is the │ between items.
local tab_bar_palette = theme_mode == "light"
    and {
      bar_bg = "#e9e9ec",
      pill_bg = "#dcdce2",
      divider = "#a8aab4",
      inactive_bg = "#e9e9ec",
      inactive_fg = "#5f6272",
      hover_bg = "#dcdce2",
      hover_fg = "#1f2335",
      active_bg = "#ffffff",
      active_fg = "#1f2335",
      accent = "#2e7de9",
      text = "#1f2335",
      muted = "#5f6272",
      ok = "#387068",
      err = "#c64343",
      warn = "#8c6c3e",
      remote = "#b15c00",
      remote_bg = "#f6e1cc",
      leader = "#7847bd",
      git = "#7847bd",
      on_color = "#ffffff",
    }
    or {
      bar_bg = "#0f1012",
      pill_bg = "#1f2127",
      divider = "#4a4e58",
      inactive_bg = "#0f1012",
      inactive_fg = "#8b8f98",
      hover_bg = "#1f2127",
      hover_fg = "#e4e4e7",
      active_bg = "#2b2f38",
      active_fg = "#e4e4e7",
      accent = "#7aa2f7",
      text = "#e4e4e7",
      muted = "#8b8f98",
      ok = "#9ece6a",
      err = "#f7768e",
      warn = "#e0af68",
      remote = "#ff9e64",
      remote_bg = "#3a2616",
      leader = "#bb9af7",
      git = "#bb9af7",
      on_color = "#0f1012",
    }

config.default_prog = { zsh_path, "-l" }

config.color_scheme_dirs = { dotfiles_dir .. "/wezterm/colors" }
config.color_scheme = selected_theme.wezterm
config.colors = {
  tab_bar = {
    background = tab_bar_palette.bar_bg,
    active_tab = {
      bg_color = tab_bar_palette.active_bg,
      fg_color = tab_bar_palette.active_fg,
      intensity = "Bold",
    },
    inactive_tab = {
      bg_color = tab_bar_palette.inactive_bg,
      fg_color = tab_bar_palette.inactive_fg,
    },
    inactive_tab_hover = {
      bg_color = tab_bar_palette.hover_bg,
      fg_color = tab_bar_palette.hover_fg,
      italic = false,
    },
    new_tab = {
      bg_color = tab_bar_palette.bar_bg,
      fg_color = tab_bar_palette.inactive_fg,
    },
    new_tab_hover = {
      bg_color = tab_bar_palette.hover_bg,
      fg_color = tab_bar_palette.hover_fg,
      italic = false,
    },
  },
}
config.set_environment_variables = {
  THEME_NAME = theme_name,
  THEME_MODE = theme_mode,
  THEME_VARIANT = selected_theme.variant or "",
  NVIM_COLORSCHEME = selected_theme.nvim,
}

local code_ligature_features = { "calt=1", "clig=1", "liga=1", "ss11=1" }
local no_ligature_features = { "calt=0", "clig=0", "liga=0" }
config.font_dirs = { wezterm.home_dir .. "/Library/Fonts" }
config.font_size = 16
config.cell_width = 0.85
config.line_height = 1.1
config.font = wezterm.font_with_fallback({
  { family = "Anthrosevka Mono",      weight = "Regular", style = "Normal",                          harfbuzz_features = no_ligature_features },
  -- { family = "Liga SFMono Nerd Font", weight = "Regular", style = "Normal",                          harfbuzz_features = code_ligature_features },
  -- { family = "Geist Mono",            weight = "Medium",  harfbuzz_features = code_ligature_features },
  { family = "JetBrains Mono",        weight = "Regular", harfbuzz_features = code_ligature_features },
  { family = "IosevkaTerm Nerd Font", weight = "Medium" },
  { family = "Symbols Nerd Font Mono" },
  { family = "Menlo" },
})

local opacity = 0.90

-- Native fullscreen has no desktop behind the window, so a blurred image replaces the macOS blur.
local function fullscreen_background(background_color)
  return {
    {
      source = { File = dotfiles_dir .. "/assets/fletschhorn_blur.jpg" },
      width = "Cover",
      height = "Cover",
      opacity = 1.0,
    },
    {
      source = { Color = background_color },
      width = "100%",
      height = "100%",
      opacity = opacity,
    },
  }
end

local function sync_fullscreen_background(window)
  local overrides = window:get_config_overrides() or {}
  local current_color = overrides.background and overrides.background[2].source.Color
  local target_color = nil
  if window:get_dimensions().is_full_screen then
    target_color = window:effective_config().resolved_palette.background
  end
  if current_color == target_color then
    return
  end

  overrides.background = target_color and fullscreen_background(target_color) or nil
  window:set_config_overrides(overrides)
end

wezterm.on("window-resized", sync_fullscreen_background)

local is_macos = wezterm.target_triple:find("apple") ~= nil
config.window_background_opacity = opacity
config.window_close_confirmation = "AlwaysPrompt"
config.scrollback_lines = 50000
config.default_workspace = "main"
config.launch_menu = {
  { label = "Home",          cwd = wezterm.home_dir,        args = { zsh_path, "-l" } },
  { label = "Dotfiles",      cwd = dotfiles_dir,            args = { zsh_path, "-l" } },
  { label = "Neovim Config", cwd = dotfiles_dir .. "/nvim", args = { zsh_path, "-l" } },
}
config.macos_window_background_blur = 50

config.window_decorations = "RESIZE"
if is_macos then
  -- Two-display fullscreen handling is more reliable with the native macOS Space.
  config.native_macos_fullscreen_mode = true
end

-- Dim inactive panes
config.inactive_pane_hsb = {
  saturation = 0.6,
  brightness = 0.75,
}

-- Quick select: extra patterns for development output.
config.quick_select_patterns = {
  [=[[\w./@~-]+\.[A-Za-z0-9]+:\d+(?::\d+)?]=], -- file.ext:line(:col)
  [=[[\w./-]+\.py::[\w\[\]-]+]=],               -- pytest node ids
  [=[\b[A-Z][A-Z0-9]+-\d+\b]=],                 -- ticket ids, for example API-231
}

local open_patterns = {
  [=[https?://[^\s"'<>()\]]+]=],
  [=[[\w./@~-]+\.[A-Za-z0-9]+:\d+(?::\d+)?]=],
  [=[(?:~/|\.{1,2}/|/)?[\w.@-]+(?:/[\w.@-]+)+]=],
}

-- Open the picked text: a URL in the browser, a path (with :line) in nvim in a split.
local function open_selection(window, pane)
  local text = trim(window:get_selection_text_for_pane(pane))
  window:perform_action(act.ClearSelection, pane)
  if text == "" then
    return
  end
  if text:match("^https?://") then
    wezterm.open_with(text)
    return
  end
  local path, line = text:match("^(.-):(%d+)")
  path = path or text
  path = path:gsub("^~/", wezterm.home_dir .. "/")
  pane:split {
    direction = "Right",
    cwd = cwd_to_path(pane:get_current_working_dir()),
    args = { zsh_path, "-lc", 'exec nvim "$@"', "nvim", "+" .. (line or "1"), path },
  }
end

-- Keys
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
  -- Send C-a when pressing C-a twice
  { key = "a",          mods = "LEADER|CTRL", action = act.SendKey { key = "a", mods = "CTRL" } },
  { key = "c",          mods = "LEADER",      action = act.ActivateCopyMode },
  { key = "phys:Space", mods = "LEADER",      action = act.ActivateCommandPalette },
  { key = "f",          mods = "LEADER",      action = act.QuickSelect },
  {
    key = "F",
    mods = "LEADER|SHIFT",
    action = act.QuickSelectArgs {
      label = "open",
      patterns = open_patterns,
      action = wezterm.action_callback(open_selection),
    },
  },
  { key = "/",          mods = "LEADER",      action = act.Search("CurrentSelectionOrEmptyString") },
  { key = "[",          mods = "SUPER",       action = send_if_nvim("[", "ALT") },
  { key = "]",          mods = "SUPER",       action = send_if_nvim("]", "ALT") },

  -- Pane keybindings
  { key = "s",          mods = "LEADER",      action = act.SplitVertical { domain = "CurrentPaneDomain" } },
  { key = "v",          mods = "LEADER",      action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },
  { key = "h",          mods = "LEADER",      action = act.ActivatePaneDirection("Left") },
  { key = "j",          mods = "LEADER",      action = act.ActivatePaneDirection("Down") },
  { key = "k",          mods = "LEADER",      action = act.ActivatePaneDirection("Up") },
  { key = "l",          mods = "LEADER",      action = act.ActivatePaneDirection("Right") },
  { key = "q",          mods = "LEADER",      action = act.CloseCurrentPane { confirm = true } },
  { key = "z",          mods = "LEADER",      action = act.TogglePaneZoomState },
  { key = "o",          mods = "LEADER",      action = act.RotatePanes "Clockwise" },
  -- We can make separate keybindings for resizing panes
  -- But Wezterm offers custom "mode" in the name of "KeyTable"
  { key = "r",          mods = "LEADER",      action = act.ActivateKeyTable { name = "resize_pane", one_shot = false } },

  -- Tab keybindings
  { key = "t",          mods = "LEADER",      action = act.SpawnTab("CurrentPaneDomain") },
  { key = "[",          mods = "LEADER",      action = act.ActivateTabRelative(-1) },
  { key = "]",          mods = "LEADER",      action = act.ActivateTabRelative(1) },
  { key = "n",          mods = "LEADER",      action = act.ShowTabNavigator },
  {
    key = "e",
    mods = "LEADER",
    action = act.PromptInputLine {
      description = wezterm.format {
        { Attribute = { Intensity = "Bold" } },
        { Foreground = { AnsiColor = "Fuchsia" } },
        { Text = "Renaming Tab Title...:" },
      },
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end)
    }
  },
  -- Key table for moving tabs around
  { key = "m", mods = "LEADER",       action = act.ActivateKeyTable { name = "move_tab", one_shot = false } },
  -- Or shortcuts to move tab w/o move_tab table. SHIFT is for when caps lock is on
  { key = "{", mods = "LEADER|SHIFT", action = act.MoveTabRelative(-1) },
  { key = "}", mods = "LEADER|SHIFT", action = act.MoveTabRelative(1) },

  -- Lastly, workspace
  { key = "w", mods = "LEADER",       action = act.ShowLauncherArgs { flags = "FUZZY|WORKSPACES|LAUNCH_MENU_ITEMS" } },
  {
    key = "p",
    mods = "LEADER",
    action = wezterm.action_callback(function(window, pane)
      local cwd = cwd_to_path(pane:get_current_working_dir())
      window:perform_action(act.SwitchToWorkspace {
        name = workspace_name_from_cwd(cwd),
        spawn = { cwd = cwd },
      }, pane)
    end),
  },
  {
    key = "P",
    mods = "LEADER|SHIFT",
    action = act.PromptInputLine {
      description = wezterm.format({
        { Attribute = { Intensity = "Bold" } },
        { Foreground = { AnsiColor = "Teal" } },
        { Text = "Workspace name (blank uses current directory):" },
      }),
      action = wezterm.action_callback(function(window, pane, line)
        local cwd = cwd_to_path(pane:get_current_working_dir())
        local name = (line and line ~= "") and line or workspace_name_from_cwd(cwd)
        window:perform_action(act.SwitchToWorkspace {
          name = name,
          spawn = { cwd = cwd },
        }, pane)
      end),
    }
  },

  split_nav("move", "h"),
  split_nav("move", "j"),
  split_nav("move", "k"),
  split_nav("move", "l"),
  split_nav("resize", "LeftArrow"),
  split_nav("resize", "DownArrow"),
  split_nav("resize", "UpArrow"),
  split_nav("resize", "RightArrow"),
}
-- I can use the tab navigator (LDR t), but I also want to quickly navigate tabs with index
for i = 1, 9 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = "LEADER",
    action = act.ActivateTab(i - 1)
  })
end

config.key_tables = {
  resize_pane = {
    { key = "h",      action = act.AdjustPaneSize { "Left", 1 } },
    { key = "j",      action = act.AdjustPaneSize { "Down", 1 } },
    { key = "k",      action = act.AdjustPaneSize { "Up", 1 } },
    { key = "l",      action = act.AdjustPaneSize { "Right", 1 } },
    { key = "Escape", action = "PopKeyTable" },
    { key = "Enter",  action = "PopKeyTable" },
  },
  move_tab = {
    { key = "h",      action = act.MoveTabRelative(-1) },
    { key = "j",      action = act.MoveTabRelative(-1) },
    { key = "k",      action = act.MoveTabRelative(1) },
    { key = "l",      action = act.MoveTabRelative(1) },
    { key = "Escape", action = "PopKeyTable" },
    { key = "Enter",  action = "PopKeyTable" },
  }
}

-- Tab bar
-- I don't like the look of "fancy" tab bar
config.use_fancy_tab_bar = false
config.show_new_tab_button_in_tab_bar = false
config.switch_to_last_active_tab_when_closing_tab = true
config.tab_max_width = 32
config.status_update_interval = 1000
config.tab_bar_at_bottom = false

-- Shell integration (wezterm/shell-integration.zsh) sets these pane user vars:
--   WEZTERM_CMD          last command line
--   WEZTERM_CMD_STATUS   "running" or the exit code
--   WEZTERM_CMD_DURATION seconds, for example "12.4"
--   WEZTERM_GIT          "branch|ahead|changed"
local notify_after_seconds = 10
local remote_processes = { ssh = true, ["mosh-client"] = true, et = true }
-- Interactive programs "run" all the time, so they get no running dot.
local interactive_processes = {
  nvim = true, vim = true, ssh = true, ["mosh-client"] = true, lazygit = true,
  htop = true, btop = true, top = true, less = true, man = true, k9s = true,
}
local shell_processes = { zsh = true, bash = true, fish = true, sh = true }

local function nf(name, fallback)
  local ok, glyph = pcall(function() return wezterm.nerdfonts[name] end)
  if ok and glyph and glyph ~= "" then
    return glyph
  end
  return fallback or ""
end

local icons = {
  default = nf("dev_terminal", ">"),
  zoom = nf("md_arrow_expand_all", "Z"),
  split = nf("md_view_split_vertical", "|"),
  dot = nf("md_circle_medium", "*"),
  ok = nf("md_check", "ok"),
  err = nf("md_close", "x"),
  branch = nf("dev_git_branch", ""),
  clock = nf("md_clock", ""),
  folder = nf("md_folder", ""),
  keyboard = nf("md_keyboard", ""),
  resize = nf("md_arrow_expand_horizontal", ""),
  remote = nf("md_server_network", ""),
}

local process_icons = {
  nvim = nf("custom_vim"), vim = nf("custom_vim"),
  zsh = nf("dev_terminal"), bash = nf("dev_terminal"), fish = nf("dev_terminal"),
  node = nf("md_nodejs"), npm = nf("md_nodejs"), npx = nf("md_nodejs"),
  pnpm = nf("md_nodejs"), yarn = nf("md_nodejs"), bun = nf("md_nodejs"), deno = nf("md_nodejs"),
  python = nf("md_language_python"), python3 = nf("md_language_python"), pytest = nf("md_language_python"),
  cargo = nf("dev_rust"), rustc = nf("dev_rust"),
  go = nf("md_language_go"),
  java = nf("md_language_java"), gradle = nf("md_language_java"), mvn = nf("md_language_java"),
  git = nf("dev_git"), lazygit = nf("dev_git"),
  docker = nf("md_docker"),
  kubectl = nf("md_kubernetes"), k9s = nf("md_kubernetes"),
  ssh = icons.remote, ["mosh-client"] = icons.remote,
  make = nf("seti_makefile"),
  htop = nf("md_chart_areaspline"), btop = nf("md_chart_areaspline"), top = nf("md_chart_areaspline"),
}

local function icon_for(process)
  local icon = process_icons[process]
  if icon and icon ~= "" then
    return icon
  end
  return icons.default
end

local function process_of(pane_info)
  return basename((pane_info and pane_info.foreground_process_name) or "")
end

local function format_duration(seconds)
  seconds = tonumber(seconds)
  if not seconds then
    return ""
  end
  if seconds < 10 then
    return string.format("%.1fs", seconds)
  end
  if seconds < 60 then
    return string.format("%ds", math.floor(seconds))
  end
  local minutes = math.floor(seconds / 60)
  if minutes < 60 then
    return string.format("%dm%02ds", minutes, math.floor(seconds % 60))
  end
  return string.format("%dh%02dm", math.floor(minutes / 60), minutes % 60)
end

local function command_state(vars)
  vars = vars or {}
  local status = vars.WEZTERM_CMD_STATUS
  if not status or status == "" then
    return nil
  end
  return {
    running = status == "running",
    code = tonumber(status),
    duration = tonumber(vars.WEZTERM_CMD_DURATION),
    cmd = trim(vars.WEZTERM_CMD),
  }
end

local function remote_host(cmd)
  cmd = trim(cmd)
  if not cmd:match("^ssh%s") and not cmd:match("^mosh%s") then
    return ""
  end
  return cmd:match("(%S+)%s*$") or ""
end

wezterm.on("format-tab-title", function(tab, _tabs, panes, _config, hover, max_width)
  local p = tab_bar_palette
  local pane = tab.active_pane or {}
  local process = process_of(pane)
  local state = command_state(pane.user_vars)
  local is_remote = remote_processes[process] == true
  local pane_count = panes and #panes or 1
  max_width = max_width or config.tab_max_width

  local title = trim(tab.tab_title)
  if title == "" and state and state.running and state.cmd ~= "" then
    title = state.cmd
  end
  if title == "" and process ~= "" then
    title = process
  end
  if title == "" then
    title = trim(pane.title)
  end
  if title == "" then
    title = "shell"
  end

  -- Small marks after the title: zoom, pane count, command result, new output.
  local marks = {}
  if pane.is_zoomed then
    table.insert(marks, { text = icons.zoom, color = p.muted })
  end
  if pane_count > 1 then
    table.insert(marks, { text = icons.split .. " " .. pane_count, color = p.muted })
  end
  if not tab.is_active and state then
    if state.running and not interactive_processes[process] and not shell_processes[process] then
      table.insert(marks, { text = icons.dot, color = p.warn })
    elseif not state.running and state.code and state.duration and state.duration >= 5 then
      local ok = state.code == 0
      table.insert(marks, {
        text = (ok and icons.ok or icons.err) .. " " .. format_duration(state.duration),
        color = ok and p.ok or p.err,
      })
    end
  end
  if tab.has_unseen_output and #marks == 0 and not tab.is_active then
    table.insert(marks, { text = icons.dot, color = p.accent })
  end

  local index = tostring(tab.tab_index + 1)
  local marks_width = 0
  for _, mark in ipairs(marks) do
    marks_width = marks_width + wezterm.column_width(mark.text) + 1
  end
  local title_width = math.max(6, max_width - (#index + marks_width + 6))
  title = truncate_title(title, title_width)

  -- Square tab blocks: the active, hovered and remote tabs get a background.
  local bg = p.bar_bg
  local fg = p.inactive_fg
  local index_fg = p.inactive_fg
  local bold = false
  if is_remote then
    bg, fg, index_fg, bold = p.remote_bg, p.remote, p.remote, true
  elseif tab.is_active then
    bg, fg, index_fg, bold = p.active_bg, p.active_fg, p.accent, true
  elseif hover then
    bg, fg, index_fg = p.hover_bg, p.hover_fg, p.hover_fg
  end

  local cells = {
    { Background = { Color = bg } },
    { Attribute = { Intensity = bold and "Bold" or "Normal" } },
    { Foreground = { Color = index_fg } },
    { Text = " " .. index .. " " },
    { Foreground = { Color = fg } },
    { Text = icon_for(process) .. " " .. title },
  }
  for _, mark in ipairs(marks) do
    table.insert(cells, { Foreground = { Color = mark.color } })
    table.insert(cells, { Text = " " .. mark.text })
  end
  table.insert(cells, { Text = " " })
  table.insert(cells, { Attribute = { Intensity = "Normal" } })
  table.insert(cells, { Background = { Color = p.bar_bg } })
  table.insert(cells, { Text = " " })
  return cells
end)

-- A flat, square status block. items = { parts, ... }; parts = { { text, fg, bold }, ... }
-- Vertical dividers separate the items.
local function append_block(cells, bg, items)
  local p = tab_bar_palette
  table.insert(cells, { Background = { Color = bg } })
  table.insert(cells, { Text = " " })
  for i, parts in ipairs(items) do
    if i > 1 then
      table.insert(cells, { Attribute = { Intensity = "Normal" } })
      table.insert(cells, { Foreground = { Color = p.divider } })
      table.insert(cells, { Text = " │ " })
    end
    for _, part in ipairs(parts) do
      table.insert(cells, { Attribute = { Intensity = part.bold and "Bold" or "Normal" } })
      table.insert(cells, { Foreground = { Color = part.fg or p.text } })
      table.insert(cells, { Text = part.text })
    end
  end
  table.insert(cells, { Attribute = { Intensity = "Normal" } })
  table.insert(cells, { Text = " " })
end

-- Key hints for the leader key and key tables, so the next keys are on screen.
local key_hints = {
  leader = {
    { "s", "split↓" }, { "v", "split→" }, { "z", "zoom" }, { "t", "tab" }, { "p", "project" },
    { "w", "switch" }, { "f", "pick" }, { "F", "open" }, { "/", "search" }, { "r", "resize" },
    { "m", "move tab" }, { "Space", "palette" },
  },
  resize_pane = { { "h j k l", "resize pane" }, { "Esc", "done" } },
  move_tab = { { "h/j", "move left" }, { "k/l", "move right" }, { "Esc", "done" } },
}

local function hint_items(hints, key_color)
  local items = {}
  for _, hint in ipairs(hints) do
    table.insert(items, {
      { text = hint[1], fg = key_color, bold = true },
      { text = " " .. hint[2], fg = tab_bar_palette.muted },
    })
  end
  return items
end

local function sync_focus_opacity(window)
  local overrides = window:get_config_overrides() or {}
  if is_macos then
    -- Avoid focus-driven opacity changes on macOS; they line up with fullscreen
    -- issues when switching focus between displays.
    if overrides.window_background_opacity ~= nil then
      overrides.window_background_opacity = nil
      window:set_config_overrides(overrides)
    end
    return
  end
  local target_opacity = opacity
  if not window:is_focused() then
    target_opacity = opacity / 1.25
  end
  if overrides.window_background_opacity ~= target_opacity then
    overrides.window_background_opacity = target_opacity
    window:set_config_overrides(overrides)
  end
end

wezterm.on("update-status", function(window, pane)
  local p = tab_bar_palette
  sync_fullscreen_background(window)
  sync_focus_opacity(window)

  local process = basename(pane:get_foreground_process_name() or "")
  local vars = pane:get_user_vars() or {}
  local is_remote = remote_processes[process] == true

  -- Left block, flush with the left edge: workspace, or the active mode.
  local left = {}
  local key_table = window:active_key_table()
  local hints = nil
  local hint_color = p.accent
  if window:leader_is_active() then
    append_block(left, p.leader, { { { text = icons.keyboard .. " LEADER", fg = p.on_color, bold = true } } })
    hints, hint_color = key_hints.leader, p.leader
  elseif key_table then
    local label = string.upper((key_table:gsub("_pane$", ""):gsub("_", " ")))
    append_block(left, p.warn, { { { text = icons.resize .. " " .. label, fg = p.on_color, bold = true } } })
    hints, hint_color = key_hints[key_table] or { { "Esc", "done" } }, p.warn
  else
    local workspace = window:active_workspace()
    local names = wezterm.mux.get_workspace_names()
    local position = ""
    if #names > 1 then
      for i, name in ipairs(names) do
        if name == workspace then
          position = " " .. i .. "/" .. #names
        end
      end
    end
    append_block(left, p.accent, { {
      { text = workspace_icon(workspace) .. " " .. workspace, fg = p.on_color, bold = true },
      { text = position, fg = p.on_color },
    } })
  end
  table.insert(left, { Background = { Color = p.bar_bg } })
  table.insert(left, { Text = " " })
  window:set_left_status(wezterm.format(left))

  -- Right block, flush with the right edge: key hints in a mode;
  -- else remote host, git, last command and clock, with dividers.
  local items = {}
  if hints then
    items = hint_items(hints, hint_color)
  else
    if is_remote then
      local host = remote_host(vars.WEZTERM_CMD)
      table.insert(items, {
        { text = icons.remote .. " REMOTE" .. (host ~= "" and (" " .. host) or ""), fg = p.remote, bold = true },
      })
    end

    local git = vars.WEZTERM_GIT or ""
    local branch, ahead, changed = git:match("^(.-)|(%d*)|(%d*)$")
    if branch and branch ~= "" then
      local parts = {
        { text = icons.branch .. " ", fg = p.git },
        { text = branch, fg = p.text },
      }
      if tonumber(ahead) and tonumber(ahead) > 0 then
        table.insert(parts, { text = " ↑" .. ahead, fg = p.accent })
      end
      if tonumber(changed) and tonumber(changed) > 0 then
        table.insert(parts, { text = " ~" .. changed, fg = p.warn })
      end
      table.insert(items, parts)
    else
      local cwd = pane:get_current_working_dir()
      cwd = cwd and basename(cwd_to_path(cwd)) or ""
      if cwd ~= "" then
        table.insert(items, { { text = icons.folder .. " ", fg = p.ok }, { text = cwd, fg = p.text } })
      end
    end

    local state = command_state(vars)
    if state and not state.running and state.code then
      local duration = state.duration and (" " .. format_duration(state.duration)) or ""
      if state.code == 0 then
        table.insert(items, { { text = icons.ok, fg = p.ok, bold = true }, { text = duration, fg = p.text } })
      else
        table.insert(items, {
          { text = icons.err .. " exit " .. state.code, fg = p.err, bold = true },
          { text = duration, fg = p.text },
        })
      end
    end

    table.insert(items, {
      { text = icons.clock .. " ", fg = p.muted },
      { text = wezterm.strftime("%H:%M"), fg = p.text },
    })
  end
  local right = { { Background = { Color = p.bar_bg } }, { Text = " " } }
  append_block(right, p.pill_bg, items)
  window:set_right_status(wezterm.format(right))
end)

-- System notification when a long command ends in a pane you are not looking at.
wezterm.on("user-var-changed", function(window, pane, name, value)
  if name ~= "WEZTERM_CMD_STATUS" or value == "running" then
    return
  end
  local vars = pane:get_user_vars() or {}
  local duration = tonumber(vars.WEZTERM_CMD_DURATION)
  if not duration or duration < notify_after_seconds then
    return
  end
  local active = window:active_pane()
  if window:is_focused() and active and active:pane_id() == pane:pane_id() then
    return
  end
  local code = tonumber(value) or 0
  local cmd = trim(vars.WEZTERM_CMD)
  if cmd == "" then
    cmd = "Command"
  end
  local title = truncate_title(cmd, 40) .. (code == 0 and " finished" or " failed")
  local message = string.format("Exit %d after %s · %s", code, format_duration(duration), window:active_workspace())
  window:toast_notification(title, message, nil, 5000)
end)

--[[ Appearance setting for when I need to take pretty screenshots
config.enable_tab_bar = false
config.window_padding = {
  left = '0.5cell',
  right = '0.5cell',
  top = '0.5cell',
  bottom = '0cell',

}
--]]

return config

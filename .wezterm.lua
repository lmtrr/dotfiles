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
    local icon_name = workspace_icon_names[((start_index + offset - 2) % icon_count) + 1]
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
local theme_name = "github" -- Change this name to switch both WezTerm and Neovim.
local theme_names = {
  "melange",
  "melange-light",
  "evergarden",
  "oxocarbon",
  "gruvbox",
  "gruvbox-light",
  "darcula",
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
local tab_bar_palette = theme_mode == "light"
    and {
      bar_bg = "#e9dfd2",
      inactive_bg = "#d9cec2",
      inactive_fg = "#6f6259",
      hover_bg = "#cbbdaf",
      hover_fg = "#292522",
      active_bg = "#78997a",
      active_fg = "#fbf1e8",
      accent = "#b85f5f",
      alert = "#b85f5f",
      cwd = "#4f7f65",
      command = "#9a6a3f",
      clock = "#5f6f95",
      status_bg = "#d9cec2",
      status_fg = "#403a36",
    }
    or {
      bar_bg = "#171c1f",
      inactive_bg = "#232a2e",
      inactive_fg = "#96b4aa",
      hover_bg = "#313b40",
      hover_fg = "#f8f9e8",
      active_bg = "#cae0a7",
      active_fg = "#171c1f",
      accent = "#f5d098",
      alert = "#f57f82",
      cwd = "#addeb9",
      command = "#f5d098",
      clock = "#b2cfed",
      status_bg = "#232a2e",
      status_fg = "#f8f9e8",
    }

config.default_prog = { zsh_path, "-l" }

config.color_scheme_dirs = { wezterm.home_dir .. "/dotfiles/wezterm/colors" }
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
config.font_dirs = { wezterm.home_dir .. "/Library/Fonts" }
config.font_size = 16
config.cell_width = 0.85
config.font = wezterm.font_with_fallback({
  -- { family = "Monaco",                weight = "Medium", style = "Normal" },
  -- { family = "Liga SFMono Nerd Font", weight = "Medium", style = "Normal" },
  -- { family = "Geist Mono",            weight = "Medium", harfbuzz_features = code_ligature_features },
  { family = "JetBrains Mono",        weight = "Medium", harfbuzz_features = code_ligature_features },
  { family = "IosevkaTerm Nerd Font", weight = "Medium" },
  { family = "Symbols Nerd Font Mono" },
  { family = "Menlo" },
})

config.background = {
  {
    source = {
      File = wezterm.config_dir .. "assets/fletschhorn.jpg"
    },
    width = "Cover",
    height = "Cover",

    -- Opacity of only this image layer
    opacity = 0.35,

    -- Optional: darken image for readability
    hsb = {
      brightness = 0.35,
      hue = 1.0,
      saturation = 1.0,
    }
  }
}

local opacity = 0.90
local is_macos = wezterm.target_triple:find("apple") ~= nil
config.window_background_opacity = opacity
config.window_close_confirmation = "AlwaysPrompt"
config.scrollback_lines = 3000
config.default_workspace = "main"
config.launch_menu = {
  { label = "Home",          cwd = wezterm.home_dir,                     args = { zsh_path, "-l" } },
  { label = "Dotfiles",      cwd = wezterm.home_dir .. "/dotfiles",      args = { zsh_path, "-l" } },
  { label = "Neovim Config", cwd = wezterm.home_dir .. "/dotfiles/nvim", args = { zsh_path, "-l" } },
}
config.macos_window_background_blur = 50

if is_macos then
  -- Two-display fullscreen handling is more reliable with the native macOS Space.
  config.native_macos_fullscreen_mode = true
  config.window_decorations = "RESIZE"
else
  config.window_decorations = "RESIZE"
end

-- Dim inactive panes
config.inactive_pane_hsb = {
  saturation = 0.24,
  brightness = 0.5
}

-- Keys
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
  -- Send C-a when pressing C-a twice
  { key = "a",          mods = "LEADER|CTRL", action = act.SendKey { key = "a", mods = "CTRL" } },
  { key = "c",          mods = "LEADER",      action = act.ActivateCopyMode },
  { key = "phys:Space", mods = "LEADER",      action = act.ActivateCommandPalette },
  { key = "f",          mods = "LEADER",      action = act.QuickSelect },
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
config.tab_max_width = 28
config.status_update_interval = 1000
config.tab_bar_at_bottom = false
wezterm.on("format-tab-title", function(tab, _tabs, panes, _config, hover, max_width)
  local palette = tab_bar_palette
  local pane_count = panes and #panes or 1
  max_width = max_width or config.tab_max_width
  local custom_title = trim(tab.tab_title)
  local pane_title = tab.active_pane and trim(tab.active_pane.title) or ""
  local title = ""

  if custom_title ~= "" and pane_title ~= "" and custom_title ~= pane_title then
    title = custom_title .. " · " .. pane_title
  elseif custom_title ~= "" then
    title = custom_title
  elseif pane_title ~= "" then
    title = pane_title
  else
    title = "shell"
  end

  local is_zoomed = tab.active_pane and tab.active_pane.is_zoomed
  local has_unseen_output = tab.has_unseen_output
  local markers = ""
  if is_zoomed then
    markers = markers .. "Z "
  end
  if has_unseen_output then
    markers = markers .. "! "
  end

  local pane_suffix = pane_count > 1 and (" " .. pane_count .. "p") or ""
  local index = tostring(tab.tab_index + 1)
  local reserved_width = #index + #markers + #pane_suffix + 5
  local title_width = math.max(6, max_width - reserved_width)
  title = truncate_title(title, title_width)

  local bg = palette.inactive_bg
  local fg = palette.inactive_fg
  local index_fg = palette.accent
  if tab.is_active then
    bg = palette.active_bg
    fg = palette.active_fg
    index_fg = palette.active_fg
  elseif hover then
    bg = palette.hover_bg
    fg = palette.hover_fg
  end
  if has_unseen_output then
    index_fg = palette.alert
  end

  return {
    { Background = { Color = palette.bar_bg } },
    { Foreground = { Color = bg } },
    { Text = " " },
    { Background = { Color = bg } },
    { Foreground = { Color = index_fg } },
    { Attribute = { Intensity = "Bold" } },
    { Text = " " .. index .. " " },
    { Foreground = { Color = fg } },
    { Text = markers .. title .. pane_suffix .. " " },
    "ResetAttributes",
    { Background = { Color = palette.bar_bg } },
    { Text = " " },
  }
end)

local function append_status_segment(cells, icon, label, fg, icon_gap)
  if not label or label == "" then
    return
  end

  icon_gap = icon_gap or " "
  table.insert(cells, { Background = { Color = tab_bar_palette.status_bg } })
  table.insert(cells, { Foreground = { Color = fg } })
  table.insert(cells, { Attribute = { Intensity = "Bold" } })
  table.insert(cells, { Text = " " .. icon .. icon_gap })
  table.insert(cells, { Foreground = { Color = tab_bar_palette.status_fg } })
  table.insert(cells, { Text = label .. " " })
  table.insert(cells, "ResetAttributes")
  table.insert(cells, { Background = { Color = tab_bar_palette.bar_bg } })
  table.insert(cells, { Text = " " })
end

wezterm.on("update-status", function(window, pane)
  -- Workspace name
  local active_workspace = window:active_workspace()
  local stat = active_workspace
  local stat_icon = workspace_icon(active_workspace)
  local stat_color = "#C34043"
  -- It's a little silly to have workspace name all the time
  -- Utilize this to display LDR or current key table name
  local overrides = window:get_config_overrides() or {}
  if is_macos then
    -- Avoid focus-driven opacity changes on macOS; they line up with fullscreen
    -- issues when switching focus between displays.
    if overrides.window_background_opacity ~= nil then
      overrides.window_background_opacity = nil
      window:set_config_overrides(overrides)
    end
  else
    local target_opacity = opacity
    if not window:is_focused() then
      target_opacity = opacity / 1.25
    end
    if overrides.window_background_opacity ~= target_opacity then
      overrides.window_background_opacity = target_opacity
      window:set_config_overrides(overrides)
    end
  end
  if window:active_key_table() then
    stat = window:active_key_table()
    stat_color = "#7FB4CA"
  end
  if window:leader_is_active() then
    stat = "LDR"
    stat_color = "#957FB8"
  end

  -- Current working directory
  local cwd = pane:get_current_working_dir()
  if cwd then
    if type(cwd) == "userdata" then
      -- Wezterm introduced the URL object in 20240127-113634-bbcac864
      cwd = basename(cwd.file_path)
    else
      -- 20230712-072601-f4abf8fd or earlier version
      cwd = basename(cwd)
    end
  else
    cwd = ""
  end

  -- Current command
  local cmd = pane:get_foreground_process_name()
  -- CWD and CMD could be nil (e.g. viewing log using Ctrl-Alt-l)
  cmd = cmd and basename(cmd) or ""

  -- Time
  local time = wezterm.strftime("%H:%M")

  -- Left status (left of the tab line)
  local left_status = {
    { Background = { Color = tab_bar_palette.bar_bg } },
    { Text = "  " },
  }
  append_status_segment(left_status, stat_icon, stat, stat_color, "  ")
  window:set_left_status(wezterm.format(left_status))

  -- Right status
  local right_status = {
    { Background = { Color = tab_bar_palette.bar_bg } },
    { Text = " " },
  }
  -- Wezterm has built-in Nerd Font symbols:
  -- https://wezfurlong.org/wezterm/config/lua/wezterm/nerdfonts.html
  append_status_segment(right_status, wezterm.nerdfonts.md_folder, cwd, tab_bar_palette.cwd)
  append_status_segment(right_status, wezterm.nerdfonts.fa_code, cmd, tab_bar_palette.command)
  append_status_segment(right_status, wezterm.nerdfonts.md_clock, time, tab_bar_palette.clock)
  window:set_right_status(wezterm.format(right_status))
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

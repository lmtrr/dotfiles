local repo_root = arg[0]:match("^(.*)/tests/[^/]+$") or "."
if repo_root == "." then
  local pwd = assert(io.popen("pwd"))
  repo_root = assert(pwd:read("*l"))
  pwd:close()
end

-- The config builds its paths from wezterm.home_dir .. "/dotfiles", so the fake
-- home directory is the parent of the repository.
local home_dir = assert(repo_root:match("^(.*)/[^/]+$"), "repo_root has no parent directory")

local function action_stub()
  return setmetatable({}, {
    __index = function()
      return function() return {} end
    end,
  })
end

local event_handlers = {}

package.preload["wezterm"] = function()
  return {
    home_dir = home_dir,
    config_dir = home_dir,
    target_triple = "aarch64-apple-darwin",
    action = action_stub(),
    action_callback = function(fn) return fn end,
    format = function(_) return "" end,
    nerdfonts = setmetatable({}, { __index = function() return "x" end }),
    on = function(event, handler) event_handlers[event] = handler end,
    strftime = function() return "" end,
    font_with_fallback = function(fonts) return fonts end,
    config_builder = nil,
  }
end

local config = dofile(repo_root .. "/.wezterm.lua")

local checkout_hint = "repo must be checked out at " .. home_dir .. "/dotfiles, got " .. repo_root

assert(config.background == nil, "background image must only be applied in fullscreen")

local palette_background = "#141415"

local function fake_window(is_full_screen)
  local window = { overrides = {}, override_calls = 0, is_full_screen = is_full_screen }
  function window:get_dimensions() return { is_full_screen = self.is_full_screen } end
  function window:effective_config() return { resolved_palette = { background = palette_background } } end
  function window:get_config_overrides() return self.overrides end
  function window:set_config_overrides(overrides)
    self.overrides = overrides
    self.override_calls = self.override_calls + 1
  end
  return window
end

local on_resized = assert(event_handlers["window-resized"], "window-resized handler is missing")

local windowed = fake_window(false)
on_resized(windowed)
assert(windowed.overrides.background == nil)
assert(windowed.override_calls == 0)

local fullscreen = fake_window(true)
on_resized(fullscreen)
local image_layer = fullscreen.overrides.background[1]
local background_path = repo_root .. "/assets/fletschhorn_blur.jpg"
assert(image_layer.source.File == background_path, checkout_hint)
local background_file = assert(io.open(background_path, "r"), "background image is missing")
background_file:close()
assert(image_layer.opacity == nil or image_layer.opacity == 1.0, "image layer must be fully opaque")
local color_layer = fullscreen.overrides.background[2]
assert(color_layer.source.Color == palette_background, "color layer must use the theme background")
assert(color_layer.opacity == config.window_background_opacity, "color layer must match windowed opacity")

on_resized(fullscreen)
assert(fullscreen.override_calls == 1, "overrides must not be reapplied when state is unchanged")

palette_background = "#F2ECBC"
on_resized(fullscreen)
assert(fullscreen.overrides.background[2].source.Color == palette_background, "color layer must follow a theme change")
assert(fullscreen.override_calls == 2)

fullscreen.is_full_screen = false
on_resized(fullscreen)
assert(fullscreen.overrides.background == nil)
assert(fullscreen.override_calls == 3)

assert(config.color_scheme_dirs[1] == repo_root .. "/wezterm/colors", checkout_hint)

local function launch_menu_cwd(label)
  for _, entry in ipairs(config.launch_menu) do
    if entry.label == label then
      return entry.cwd
    end
  end
  return nil
end

assert(launch_menu_cwd("Dotfiles") == repo_root, checkout_hint)
assert(launch_menu_cwd("Neovim Config") == repo_root .. "/nvim", checkout_hint)

assert(config.window_decorations == "RESIZE")

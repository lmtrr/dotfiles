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

package.preload["wezterm"] = function()
  return {
    home_dir = home_dir,
    config_dir = home_dir,
    target_triple = "aarch64-apple-darwin",
    action = action_stub(),
    action_callback = function(fn) return fn end,
    format = function(_) return "" end,
    nerdfonts = setmetatable({}, { __index = function() return "x" end }),
    on = function() end,
    strftime = function() return "" end,
    font_with_fallback = function(fonts) return fonts end,
    config_builder = nil,
  }
end

local config = dofile(repo_root .. "/.wezterm.lua")

local checkout_hint = "repo must be checked out at " .. home_dir .. "/dotfiles, got " .. repo_root

local background_path = repo_root .. "/assets/fletschhorn.jpg"
assert(config.background[1].source.File == background_path, checkout_hint)
local background_file = assert(io.open(background_path, "r"), "background image is missing")
background_file:close()

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

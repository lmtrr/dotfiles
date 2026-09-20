local repo_root = arg[0]:match("^(.*)/tests/[^/]+$") or "."
local wezterm_path = repo_root .. "/.wezterm.lua"
local theme_path = repo_root .. "/nvim/lua/config/theme.lua"
local plugin_path = repo_root .. "/nvim/lua/plugins/github.lua"

local function read_file(path)
  local file = assert(io.open(path, "r"))
  local content = assert(file:read("*a"))
  assert(file:close())
  return content
end

local function split_lines(content)
  local lines = {}
  for line in (content .. "\n"):gmatch("(.-)\n") do
    table.insert(lines, line)
  end
  return lines
end

local function deepcopy(value)
  if type(value) ~= "table" then
    return value
  end

  local copy = {}
  for key, item in pairs(value) do
    copy[deepcopy(key)] = deepcopy(item)
  end
  return copy
end

local function load_theme(wezterm_config)
  _G.vim = {
    env = { HOME = repo_root },
    fn = {
      filereadable = function(path)
        return path == wezterm_path and 1 or 0
      end,
      fnamemodify = function()
        return repo_root
      end,
      readfile = function(path)
        assert(path == wezterm_path)
        return split_lines(wezterm_config)
      end,
      stdpath = function()
        return repo_root .. "/nvim"
      end,
    },
    uv = {
      fs_realpath = function(path)
        return path
      end,
    },
    deepcopy = deepcopy,
  }

  return dofile(theme_path)
end

local wezterm_config = read_file(wezterm_path)
local dark_config = wezterm_config:gsub(
  'local theme_name = "[%w%-]+"',
  'local theme_name = "github"',
  1
)
assert(dark_config:find('local theme_name = "github"', 1, true))

local dark_theme = load_theme(dark_config):get()
assert(dark_theme.name == "github")
assert(dark_theme.mode == "dark")
assert(dark_theme.colorscheme == "github")
assert(dark_theme.variant == "dark_default")

local light_config = dark_config:gsub(
  'local theme_name = "github"',
  'local theme_name = "github-light"',
  1
)
local light_theme = load_theme(light_config):get()
assert(light_theme.name == "github-light")
assert(light_theme.mode == "light")
assert(light_theme.colorscheme == "github")
assert(light_theme.variant == "light_default")

local selected_theme = dark_theme
local setup_options
local colorscheme

package.loaded["config.theme"] = {
  get = function()
    return selected_theme
  end,
  is_colorscheme = function(name)
    return name == "github"
  end,
  is_transparent = function()
    return selected_theme.mode == "dark"
  end,
}
package.loaded["github-theme"] = {
  setup = function(options)
    setup_options = options
  end,
}
_G.vim = {
  o = {},
  cmd = {
    colorscheme = function(name)
      colorscheme = name
    end,
  },
}

local plugin = dofile(plugin_path)
assert(plugin[1] == "projekt0n/github-nvim-theme")
assert(plugin.enabled)

plugin.config()
assert(vim.o.background == "dark")
assert(setup_options.options.transparent)
assert(setup_options.options.terminal_colors)
assert(colorscheme == "github_dark_default")

selected_theme = light_theme
plugin.config()
assert(vim.o.background == "light")
assert(not setup_options.options.transparent)
assert(colorscheme == "github_light_default")

selected_theme = { mode = "dark", variant = "unknown" }
plugin.config()
assert(colorscheme == "github_dark_default")

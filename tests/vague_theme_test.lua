local repo_root = arg[0]:match("^(.*)/tests/[^/]+$") or "."
local wezterm_path = repo_root .. "/.wezterm.lua"
local theme_path = repo_root .. "/nvim/lua/config/theme.lua"
local plugin_path = repo_root .. "/nvim/lua/plugins/vague.lua"

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
local vague_config = wezterm_config:gsub(
  'local theme_name = "[%w%-]+"',
  'local theme_name = "vague"',
  1
)
assert(vague_config:find('local theme_name = "vague"', 1, true))

local vague_theme = load_theme(vague_config):get()
assert(vague_theme.name == "vague")
assert(vague_theme.mode == "dark")
assert(vague_theme.colorscheme == "vague")
assert(vague_theme.variant == nil)

-- The theme table above falls back to nvim/lua/config/theme.lua, so assert the WezTerm
-- registration separately instead of relying on the resolved theme.
local vague_block = assert(wezterm_config:match("\n  vague = {(.-)\n  },"))
assert(vague_block:find('mode = "dark"', 1, true))
assert(vague_block:find('wezterm = "Vague"', 1, true))
assert(vague_block:find('nvim = "vague"', 1, true))
assert(wezterm_config:match('local theme_names = {(.-)\n}'):find('"vague"', 1, true))
assert(read_file(repo_root .. "/wezterm/colors/vague.toml"):find('name = "Vague"', 1, true))

local is_transparent = true
local setup_options
local colorscheme

package.loaded["config.theme"] = {
  get = function()
    return vague_theme
  end,
  is_colorscheme = function(name)
    return name == "vague"
  end,
  is_transparent = function()
    return is_transparent
  end,
}
package.loaded["vague"] = {
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
assert(plugin[1] == "vague-theme/vague.nvim")
assert(plugin.enabled)
assert(plugin.lazy == false)

plugin.config()
assert(vim.o.background == "dark")
assert(setup_options.transparent)
assert(colorscheme == "vague")

is_transparent = false
plugin.config()
assert(vim.o.background == "dark")
assert(not setup_options.transparent)
assert(colorscheme == "vague")

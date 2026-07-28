local M = {}

local default_theme = "melange"

local themes = {
  melange = {
    mode = "dark",
    colorscheme = "melange",
  },
  ["melange-light"] = {
    mode = "light",
    colorscheme = "melange",
  },
  evergarden = {
    mode = "dark",
    colorscheme = "evergarden",
    variant = "fall",
    accent = "green",
  },
  oxocarbon = {
    mode = "dark",
    colorscheme = "oxocarbon",
  },
  gruvbox = {
    mode = "dark",
    colorscheme = "gruvbox",
  },
  ["gruvbox-light"] = {
    mode = "light",
    colorscheme = "gruvbox",
  },
  darcula = {
    mode = "dark",
    colorscheme = "darcula",
  },
  github = {
    mode = "dark",
    colorscheme = "github",
    variant = "dark_default",
  },
  ["github-light"] = {
    mode = "light",
    colorscheme = "github",
    variant = "light_default",
  },
  tokyonight = {
    mode = "dark",
    colorscheme = "tokyonight",
    variant = "night",
  },
  ["tokyonight-night"] = {
    mode = "dark",
    colorscheme = "tokyonight",
    variant = "night",
  },
  ["tokyonight-storm"] = {
    mode = "dark",
    colorscheme = "tokyonight",
    variant = "storm",
  },
  ["tokyonight-moon"] = {
    mode = "dark",
    colorscheme = "tokyonight",
    variant = "moon",
  },
  ["tokyonight-day"] = {
    mode = "light",
    colorscheme = "tokyonight",
    variant = "day",
  },
  kanagawa = {
    mode = "dark",
    colorscheme = "kanagawa",
    variant = "wave",
  },
  ["kanagawa-dragon"] = {
    mode = "dark",
    colorscheme = "kanagawa",
    variant = "dragon",
  },
  ["kanagawa-lotus"] = {
    mode = "light",
    colorscheme = "kanagawa",
    variant = "lotus",
  },
}

local selected_theme = nil

local function normalize_string(value)
  if type(value) ~= "string" then
    return nil
  end

  local normalized = value:gsub("^%s+", ""):gsub("%s+$", "")
  if normalized == "" then
    return nil
  end

  return normalized
end

local function normalize_mode(mode)
  if mode == "light" then
    return "light"
  end
  if mode == "dark" then
    return "dark"
  end
  return nil
end

local function normalize_theme_name(name)
  return normalize_string(name)
end

local function escape_pattern(value)
  return (value:gsub("([^%w])", "%%%1"))
end

local function read_quoted_field(content, field)
  local escaped_field = escape_pattern(field)

  return content:match("%f[%w_]" .. escaped_field .. "%f[^%w_]%s*=%s*['\"]([^'\"]+)['\"]")
end

local function find_matching_table(content, open_pos)
  local depth = 0
  local quote = nil
  local escaped = false
  local i = open_pos

  while i <= #content do
    local char = content:sub(i, i)

    if quote then
      if escaped then
        escaped = false
      elseif char == "\\" then
        escaped = true
      elseif char == quote then
        quote = nil
      end
    elseif content:sub(i, i + 1) == "--" then
      local next_line = content:find("\n", i + 2, true)
      if not next_line then
        break
      end
      i = next_line
    elseif char == "'" or char == '"' then
      quote = char
    elseif char == "{" then
      depth = depth + 1
    elseif char == "}" then
      depth = depth - 1
      if depth == 0 then
        return content:sub(open_pos + 1, i - 1)
      end
    end

    i = i + 1
  end

  return nil
end

local function read_theme_block(content, name)
  local escaped_name = escape_pattern(name)
  local patterns = {
    "%f[%w_]" .. escaped_name .. "%f[^%w_]%s*=%s*{",
    "%[%s*['\"]" .. escaped_name .. "['\"]%s*%]%s*=%s*{",
  }

  for _, pattern in ipairs(patterns) do
    local _, open_pos = content:find(pattern)
    if open_pos then
      return find_matching_table(content, open_pos)
    end
  end

  return nil
end

local function read_theme_from_wezterm_content(content)
  local name = normalize_theme_name(
    content:match("local%s+theme_name%s*=%s*['\"]([%w%-%_]+)['\"]")
      or content:match("config%.theme_name%s*=%s*['\"]([%w%-%_]+)['\"]")
  )

  if not name then
    return nil
  end

  local theme = { name = name }
  local block = read_theme_block(content, name)
  if block then
    theme.mode = normalize_mode(read_quoted_field(block, "mode"))
    theme.colorscheme = normalize_string(read_quoted_field(block, "nvim"))
    theme.variant = normalize_string(read_quoted_field(block, "variant"))
  end

  return theme
end

local function read_theme_from_wezterm_config()
  local uv = vim.uv or vim.loop
  local config_dir = uv.fs_realpath(vim.fn.stdpath("config")) or vim.fn.stdpath("config")
  local candidates = {
    vim.fn.fnamemodify(config_dir, ":h") .. "/.wezterm.lua",
    vim.env.HOME .. "/dotfiles/.wezterm.lua",
    vim.env.HOME .. "/.wezterm.lua",
  }

  for _, path in ipairs(candidates) do
    if vim.fn.filereadable(path) == 1 then
      local content = table.concat(vim.fn.readfile(path), "\n")
      local theme = read_theme_from_wezterm_content(content)
      if theme then
        return theme
      end
    end
  end

  return nil
end

local function theme_from_name(name)
  name = normalize_theme_name(name)
  if not name then
    return nil
  end

  local theme = vim.deepcopy(themes[name] or {})
  theme.name = name
  theme.colorscheme = theme.colorscheme or name
  return theme
end

local function apply_theme_overrides(theme, overrides)
  for key, value in pairs(overrides or {}) do
    if value ~= nil then
      theme[key] = value
    end
  end

  return theme
end

local function resolve_theme()
  local wezterm_theme = read_theme_from_wezterm_config()
  local theme = theme_from_name(wezterm_theme and wezterm_theme.name)
    or theme_from_name(vim.env.THEME_NAME)
    or theme_from_name(default_theme)

  apply_theme_overrides(theme, wezterm_theme)

  if not (wezterm_theme and wezterm_theme.mode) then
    theme.mode = normalize_mode(vim.env.THEME_MODE) or theme.mode
  end

  if not (wezterm_theme and wezterm_theme.colorscheme) then
    theme.colorscheme = normalize_string(vim.env.NVIM_COLORSCHEME) or theme.colorscheme
  end

  if not (wezterm_theme and wezterm_theme.variant) then
    theme.variant = normalize_string(vim.env.THEME_VARIANT) or theme.variant
  end

  return theme
end

function M.get()
  if not selected_theme then
    selected_theme = resolve_theme()
  end

  return selected_theme
end

function M.name()
  return M.get().name
end

function M.mode()
  return M.get().mode
end

function M.colorscheme()
  return M.get().colorscheme
end

function M.is(name)
  return M.name() == name
end

function M.is_colorscheme(colorscheme)
  return M.colorscheme() == colorscheme
end

function M.is_transparent()
  local theme = M.get()

  if theme.transparent ~= nil then
    return theme.transparent
  end

  return theme.mode ~= "light"
end

return M

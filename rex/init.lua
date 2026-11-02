-- Rex key bindings that follow ~/dotfiles/.wezterm.lua.
-- Reload after a change: rex config reload

local LEADER = "ctrl+a"
local TERMINAL = "com.superlogical.terminal"
local SHELL_FLAVOR = "com.superlogical.terminal.shell"
local DEFAULT_SESSION = "main"
local MODE_RESIZE_STEP = 2
local QUICK_RESIZE_STEP = 5

local function leader(key, action, args)
  rex.bind(LEADER .. ">" .. key, action, args)
end

local function is_nvim(block_id)
  local info = rex.block.call(TERMINAL, "process", { block_id = block_id })
  local fg = info and info.foreground
  if not fg then
    return false
  end
  local name = fg.argv0 or fg.name or ""
  return name:match("n?vim") ~= nil
end

local function url_to_path(url)
  local path = (url or ""):gsub("^file://[^/]*", "")
  return (path:gsub("%%(%x%x)", function(hex)
    return string.char(tonumber(hex, 16))
  end))
end

local function basename(path)
  return path:match("([^/]+)/?$") or ""
end

local function find_session(label)
  local list = rex.call("session.list") or {}
  for _, s in ipairs(list.sessions or {}) do
    if s.label == label then
      return s.session_id
    end
  end
  return nil
end

local function create_session(label, cwd)
  local created, err = rex.call("session.create", {
    label = label,
    initial_windows = {
      { layout = rex.layout.block { flavor = SHELL_FLAVOR, options = { cwd = cwd } } },
    },
  })
  if err ~= nil then
    error(err, 0)
  end
  return created.session_id
end

-- Same as split_nav in .wezterm.lua: Neovim gets the key, else Rex moves or resizes the pane.
rex.action {
  name = "split_nav",
  title = "Pane Navigation (Neovim Aware)",
  args = { key = "string", mode = "string", direction = "string" },
  run = function(ctx, args)
    if is_nvim(ctx.block_id) then
      rex.client.queue("pane.send_key", { key = args.key })
      return
    end
    if args.mode == "resize" then
      rex.client.queue("pane.resize", { direction = args.direction, amount = QUICK_RESIZE_STEP })
      return
    end
    rex.client.queue("pane.focus", { direction = args.direction })
  end,
}

-- Same as send_if_nvim in .wezterm.lua: outside Neovim the key does nothing.
rex.action {
  name = "send_if_nvim",
  title = "Send Key to Neovim Only",
  args = { key = "string" },
  run = function(ctx, args)
    if is_nvim(ctx.block_id) then
      rex.client.queue("pane.send_key", { key = args.key })
    end
  end,
}

-- Same as LEADER p in .wezterm.lua: a Rex session is a WezTerm workspace.
rex.action {
  name = "project_session",
  title = "Go to Project Session",
  run = function(ctx, _args)
    local info = rex.block.call(TERMINAL, "pwd", { block_id = ctx.block_id }) or {}
    local cwd = url_to_path(info.pwd)
    local name = basename(cwd)
    if name == "" then
      name = DEFAULT_SESSION
    end
    local session_id = find_session(name) or create_session(name, cwd)
    rex.client.queue("session.select", { session_id = session_id })
  end,
}

-- Leader keys
leader("ctrl+a", "pane.send_key", { key = "ctrl+a" })
leader("space", "client.palette.toggle")
leader("/", "client.find.open")

-- Panes
leader("s", "pane.split.down")
leader("v", "pane.split.right")
leader("h", "pane.focus.left")
leader("j", "pane.focus.down")
leader("k", "pane.focus.up")
leader("l", "pane.focus.right")
leader("q", "pane.close")
leader("z", "pane.zoom")
leader("r", "client.mode.enter", { name = "resize_pane" })

-- Tabs
leader("t", "client.tab.new")
leader("[", "client.tab.previous")
leader("]", "client.tab.next")
leader("e", "client.tab.rename")
leader("m", "client.mode.enter", { name = "move_tab" })
leader("shift+[", "client.tab.move.backward")
leader("shift+]", "client.tab.move.forward")
for i = 1, 9 do
  leader(tostring(i), "client.tab.goto", { index = i })
end

-- Workspaces (Rex sessions)
leader("w", "session.switch")
leader("p", "project_session")

-- WezTerm META is Alt. In Rex, "meta" means Cmd, so these use "alt".
local nav_keys = { h = "left", j = "down", k = "up", l = "right" }
for key, direction in pairs(nav_keys) do
  rex.bind("alt+" .. key, "split_nav", { key = "alt+" .. key, mode = "move", direction = direction })
end
for _, direction in ipairs({ "left", "down", "up", "right" }) do
  rex.bind("alt+" .. direction, "split_nav", { key = "alt+" .. direction, mode = "resize", direction = direction })
end

rex.bind("cmd+[", "send_if_nvim", { key = "alt+[" })
rex.bind("cmd+]", "send_if_nvim", { key = "alt+]" })

-- Key modes (WezTerm key tables)
for key, direction in pairs(nav_keys) do
  rex.bind("resize_pane/" .. key, "pane.resize", { direction = direction, amount = MODE_RESIZE_STEP })
end
rex.bind("resize_pane/enter", "client.mode.exit")

rex.bind("move_tab/h", "client.tab.move.backward")
rex.bind("move_tab/j", "client.tab.move.backward")
rex.bind("move_tab/k", "client.tab.move.forward")
rex.bind("move_tab/l", "client.tab.move.forward")
rex.bind("move_tab/enter", "client.mode.exit")

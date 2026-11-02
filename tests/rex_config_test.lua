local repo_root = arg[0]:match("^(.*)/tests/[^/]+$") or "."

local NVIM_BLOCK = "block:nvim"
local SHELL_BLOCK = "block:shell"

local bindings = {}
local actions = {}
local queued = {}
local sessions = {}
local created = {}
local pwd_by_block = {}

local function argv0_for(block_id)
  return block_id == NVIM_BLOCK and "nvim" or "zsh"
end

rex = {
  bind = function(key, action, args)
    bindings[key] = { action = action, args = args }
  end,
  action = function(def)
    actions[def.name] = def
  end,
  layout = {
    block = function(spec) return spec end,
  },
  block = {
    call = function(_creator, method, args)
      if method == "process" then
        return { foreground = { argv0 = argv0_for(args.block_id) } }
      end
      return { pwd = pwd_by_block[args.block_id] }
    end,
  },
  call = function(method, args)
    if method == "session.list" then
      return { sessions = sessions }
    end
    table.insert(created, args)
    return { session_id = "session:new" }
  end,
  client = {
    queue = function(name, args)
      table.insert(queued, { name = name, args = args })
    end,
  },
}

dofile(repo_root .. "/rex/init.lua")

local function run(name, block_id, args)
  queued = {}
  actions[name].run({ block_id = block_id }, args or {})
  return queued
end

-- Leader bindings follow the WezTerm leader table.
assert(bindings["ctrl+a>s"].action == "pane.split.down", "LEADER s must split down")
assert(bindings["ctrl+a>v"].action == "pane.split.right", "LEADER v must split right")
assert(bindings["ctrl+a>3"].args.index == 3, "LEADER 3 must go to tab 3")
assert(bindings["ctrl+a>ctrl+a"].args.key == "ctrl+a", "LEADER LEADER must send ctrl+a")
assert(bindings["ctrl+a>r"].args.name == "resize_pane", "LEADER r must enter resize mode")

-- WezTerm META is Alt, and Rex "meta" is Cmd, so pane keys must use alt.
assert(bindings["alt+h"].action == "split_nav", "alt+h must use split_nav")
assert(bindings["meta+h"] == nil, "meta+h must not be bound")

-- split_nav gives the key to Neovim, else moves or resizes the pane.
local nav = run("split_nav", NVIM_BLOCK, { key = "alt+h", mode = "move", direction = "left" })
assert(#nav == 1 and nav[1].name == "pane.send_key" and nav[1].args.key == "alt+h", "nvim must get alt+h")

nav = run("split_nav", SHELL_BLOCK, { key = "alt+h", mode = "move", direction = "left" })
assert(#nav == 1 and nav[1].name == "pane.focus" and nav[1].args.direction == "left", "shell must focus left")

nav = run("split_nav", SHELL_BLOCK, { key = "alt+left", mode = "resize", direction = "left" })
assert(#nav == 1 and nav[1].name == "pane.resize" and nav[1].args.direction == "left", "shell must resize left")

-- send_if_nvim sends the key only to Neovim.
local sent = run("send_if_nvim", NVIM_BLOCK, { key = "alt+[" })
assert(#sent == 1 and sent[1].args.key == "alt+[", "nvim must get alt+[")
assert(#run("send_if_nvim", SHELL_BLOCK, { key = "alt+[" }) == 0, "shell must get nothing")

-- project_session reuses a session named after the folder, else creates one there.
pwd_by_block[SHELL_BLOCK] = "file://mac.local/Users/me/my%20project"
sessions = { { session_id = "session:old", label = "my project" } }
local selected = run("project_session", SHELL_BLOCK)
assert(selected[1].args.session_id == "session:old", "existing session must be reused")
assert(#created == 0, "no session must be created when one exists")

sessions = {}
selected = run("project_session", SHELL_BLOCK)
assert(selected[1].args.session_id == "session:new", "new session must be selected")
assert(created[1].label == "my project", "new session must use the folder name")
assert(created[1].initial_windows[1].layout.options.cwd == "/Users/me/my project", "new session must start in the folder")

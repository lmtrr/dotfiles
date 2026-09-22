local repo_root = arg[0]:match("^(.*)/tests/[^/]+$") or "."

-- The module reads vim.g and vim.fn while it loads.
_G.vim = { g = { have_nerd_font = false }, fn = {} }

local tabline = dofile(repo_root .. "/nvim/lua/ui/tabline.lua")

local limit = 24

assert(tabline.truncate_name("short.lua", limit) == "short.lua")

local long_name = string.rep("a", 30)
assert(tabline.truncate_name(long_name, limit) == string.rep("a", limit - 3) .. "...")
assert(#tabline.truncate_name(long_name, limit) <= limit)

local exact_name = string.rep("b", limit)
assert(tabline.truncate_name(exact_name, limit) == exact_name)

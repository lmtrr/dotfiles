return {
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      on_attach = function(bufnr)
        local gitsigns = require("gitsigns")
        local map = function(keys, func, desc)
          vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "Git: " .. desc })
        end

        map("]h", function() gitsigns.nav_hunk("next") end, "Next hunk")
        map("[h", function() gitsigns.nav_hunk("prev") end, "Previous hunk")
        map("<leader>gb", function()
          gitsigns.blame_line({ full = true })
        end, "[G]it [B]lame line")
        map("<leader>gB", gitsigns.toggle_current_line_blame, "Toggle [G]it current line [B]lame")
        map("<leader>gp", gitsigns.preview_hunk, "[G]it [P]review hunk")
        map("<leader>gd", gitsigns.diffthis, "[G]it [D]iff current buffer")
      end,
    },
  },
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewClose",
      "DiffviewFileHistory",
      "DiffviewFocusFiles",
      "DiffviewOpen",
      "DiffviewRefresh",
      "DiffviewToggleFiles",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      { "<leader>go", "<cmd>DiffviewOpen<CR>", desc = "[G]it [O]pen diff view" },
      { "<leader>gq", "<cmd>DiffviewClose<CR>", desc = "[G]it close diff view" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", desc = "[G]it file [H]istory" },
      { "<leader>gH", "<cmd>DiffviewFileHistory<CR>", desc = "[G]it repo [H]istory" },
    },
  },
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "sindrets/diffview.nvim",
    },
    keys = {
      { "<leader>gg", "<cmd>Neogit<CR>", desc = "[G]it status" },
      { "<leader>gl", "<cmd>Neogit log<CR>", desc = "[G]it [L]og graph" },
    },
    opts = {
      graph_style = "unicode",
      integrations = {
        diffview = true,
        telescope = true,
      },
    },
  },
}

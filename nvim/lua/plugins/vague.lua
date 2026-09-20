local theme = require("config.theme")

return {
  "vague-theme/vague.nvim",
  enabled = theme.is_colorscheme("vague"),
  lazy = false,
  priority = 1000,
  config = function()
    -- Vague ships a single dark palette, so the background never follows the theme mode.
    vim.o.background = "dark"

    require("vague").setup({
      transparent = theme.is_transparent(),
    })

    vim.cmd.colorscheme("vague")
  end,
}

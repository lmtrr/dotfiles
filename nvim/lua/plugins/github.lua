local theme = require("config.theme")

local variants = {
  dark_default = true,
  light_default = true,
}

local function fallback_variant(mode)
  return mode == "light" and "light_default" or "dark_default"
end

return {
  "projekt0n/github-nvim-theme",
  name = "github-theme",
  enabled = theme.is_colorscheme("github"),
  lazy = false,
  priority = 1000,
  config = function()
    local selected_theme = theme.get()
    local variant = selected_theme.variant or fallback_variant(selected_theme.mode)

    if not variants[variant] then
      variant = fallback_variant(selected_theme.mode)
    end

    vim.o.background = selected_theme.mode

    require("github-theme").setup({
      options = {
        transparent = theme.is_transparent(),
        terminal_colors = true,
      },
    })

    vim.cmd.colorscheme("github_" .. variant)
  end,
}

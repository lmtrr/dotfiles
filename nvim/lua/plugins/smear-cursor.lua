return {
  "sphamba/smear-cursor.nvim",
  event = "VeryLazy",
  cmd = "SmearCursorToggle",
  cond = not vim.g.neovide, --> Neovide animates the cursor itself
  opts = {
    smear_insert_mode = true,              --> smooth caret: animate the insert-mode cursor
    vertical_bar_cursor_insert_mode = true,
  },
}

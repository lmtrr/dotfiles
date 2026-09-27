local function format_opts(bufnr, opts)
  bufnr = bufnr or 0
  local target_bufnr = bufnr == 0 and vim.api.nvim_get_current_buf() or bufnr

  if vim.bo[target_bufnr].filetype == "markdown" then
    local prettier = require("conform").get_formatter_info("prettier", target_bufnr)
    if not prettier.available then
      return nil
    end
  end

  return vim.tbl_extend("force", {
    bufnr = target_bufnr,
    timeout_ms = 500,
    lsp_format = "fallback",
  }, opts or {})
end

return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>F",
      function()
        local opts = format_opts(0, { async = true })
        if opts then
          require("conform").format(opts)
        end
      end,
      desc = "[F]ormat buffer",
    },
    {
      "<leader>cf",
      function()
        local opts = format_opts(0, { async = true })
        if opts then
          require("conform").format(opts)
        end
      end,
      desc = "[C]ode [F]ormat",
    },
  },
  opts = {
    notify_on_error = true,
    format_on_save = function(bufnr)
      return format_opts(bufnr)
    end,
    formatters_by_ft = {
      c = { "clang_format" },
      cpp = { "clang_format" },
      go = { "gofumpt", "goimports", "gofmt" },
      lua = { "stylua" },
      markdown = { "prettier" },
      python = { "ruff_organize_imports", "ruff_format" },
      rust = { "rustfmt" },
      sh = { "shfmt" },
      tex = { "latexindent" },
      toml = { "taplo" },
      yaml = { "prettier" },
    },
  },
}

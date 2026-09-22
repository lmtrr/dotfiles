return {
  "nvim-java/nvim-java",
  ft = "java",
  dependencies = {
    "neovim/nvim-lspconfig",
    "mason-org/mason.nvim",
    "mfussenegger/nvim-dap",
  },
  config = function()
    require("java").setup()
    vim.lsp.config("jdtls", {
      capabilities = require("cmp_nvim_lsp").default_capabilities(),
      settings = {
        java = {
          eclipse = {
            downloadSources = true,
          },
          maven = {
            downloadSources = true,
          },
          implementationsCodeLens = {
            enabled = true,
          },
          referencesCodeLens = {
            enabled = true,
          },
        },
      },
    })
    vim.lsp.enable("jdtls")
  end,
}

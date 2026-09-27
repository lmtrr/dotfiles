return {
  "nvim-java/nvim-java",
  ft = "java",
  dependencies = {
    "neovim/nvim-lspconfig",
    "mason-org/mason.nvim",
    "mfussenegger/nvim-dap",
  },
  config = function()
    local jdk = require("config.jdk")
    local jdks = jdk.find_sdkman_jdks()
    local jdtls_home = jdk.find_jdtls_home(jdks)
    if not jdtls_home then
      vim.notify("jdtls needs a JDK 21 to 25 from SDKMAN. Install one with `sdk install java`.", vim.log.levels.WARN)
      return
    end

    -- nvim-java calls spring_boot.setup() without java_cmd, so the Spring Boot LS
    -- would use $JAVA_HOME, which can be an old JDK. setup() keeps the values of this table.
    require("spring_boot.config").java_cmd = jdtls_home .. "/bin/java"

    require("java").setup({
      jdk = { auto_install = false },
    })
    vim.lsp.config("jdtls", {
      capabilities = require("cmp_nvim_lsp").default_capabilities(),
      cmd_env = {
        JAVA_HOME = jdtls_home,
        PATH = jdtls_home .. "/bin:" .. vim.env.PATH,
      },
      settings = {
        java = {
          -- jdtls also picks the Gradle daemon JDK from these runtimes
          configuration = {
            runtimes = jdk.to_runtimes(jdks),
          },
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

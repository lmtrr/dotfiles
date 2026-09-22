local M = { "neovim/nvim-lspconfig", }

M.dependencies = {
  { "mason-org/mason.nvim", opts = {}, },      --> LSP server manager
  { "mason-org/mason-lspconfig.nvim" },
  { "j-hui/fidget.nvim",       opts = {}, },     --> LSP status indicator
  {
    "cenk1cenk2/schema-companion.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },
  {
    "folke/lazydev.nvim",                        --> Neovim dev environment
    ft = "lua",
    opts = {
      library = {
        { path = "luvit-meta/library", words = { "vim%.uv" }, },
      },
    },
  },
  { 'Bilal2453/luvit-meta', lazy = true }, --> vim.uv support
}

M.config = function()
  -- Makes autocmd for LSP functionalities
  local theovim_lsp_config_group = vim.api.nvim_create_augroup("TheovimLspConfig", { clear = true, })

  vim.api.nvim_create_autocmd("LspAttach", {
    group = theovim_lsp_config_group,
    callback = function(event)
      local map = function(keys, func, desc)
        vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
      end

      -- Sets the default values for LSP functions with Telescope counterparts
      local status, builtin = pcall(require, "telescope.builtin")
      local telescope_opt = { jump_type = "tab" } --> spawns selection in a new tab
      local telescope_or = function(picker, fallback, opts)
        if status and builtin[picker] then
          return function() builtin[picker](opts or {}) end
        end
        return fallback
      end
      -- Sets the navigation keymaps
      map("gd", telescope_or("lsp_definitions", vim.lsp.buf.definition, telescope_opt),
        "[G]oto [D]efinition")
      map("gr", telescope_or("lsp_references", vim.lsp.buf.references), "[G]oto [R]eferences")
      map("gI", telescope_or("lsp_implementations", vim.lsp.buf.implementation), "[G]oto [I]mplementation")
      map("<leader>D",
        telescope_or("lsp_type_definitions", vim.lsp.buf.type_definition, telescope_opt),
        "Type [D]efinition")
      -- Sets the symbol keymaps
      map("<leader>ds", telescope_or("lsp_document_symbols", vim.lsp.buf.document_symbol), "[D]ocument [S]ymbols")
      map("<leader>ws", telescope_or("lsp_dynamic_workspace_symbols", vim.lsp.buf.workspace_symbol),
        "[W]orkspace [S]ymbols")

      -- Sets the functiosn with no Telescope counterparts
      map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
      map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
      map("gD", vim.lsp.buf.declaration, "[G]o [D]eclaration")
      map("K", function() vim.lsp.buf.hover({ border = "rounded", title = "Hover" }) end, "Hover")
      vim.keymap.set("i", "<C-k>", function() vim.lsp.buf.signature_help({ border = "rounded", title = "Signature Help" }) end,
        { buffer = event.buf, desc = "LSP: Signature help" })

      -- Creates an autocmd to highlight the symbol under the cursor
      local client = vim.lsp.get_client_by_id(event.data.client_id)
      if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
        local theovim_lsp_hl_group = vim.api.nvim_create_augroup("TheovimLspHl", { clear = false, })
        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
          buffer = event.buf,
          group = theovim_lsp_hl_group,
          callback = vim.lsp.buf.document_highlight,
        })

        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
          buffer = event.buf,
          group = theovim_lsp_hl_group,
          callback = vim.lsp.buf.clear_references,
        })

        local theovim_lsp_detach_group = vim.api.nvim_create_augroup("TheovimLspHlDetach", { clear = true, })
        vim.api.nvim_create_autocmd("LspDetach", {
          group = theovim_lsp_detach_group,
          callback = function(event2)
            vim.lsp.buf.clear_references()
            vim.api.nvim_clear_autocmds({ group = "TheovimLspHl", buffer = event2.buf })
          end
        })
      end

      -- Enable inlay hints by default and create a keybinding to toggle them,
      -- as hints can displace some of the code
      if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
        vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
        map("<leader>th", function()
          vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }), { bufnr = event.buf })
        end, "[T]oggle Inlay [H]ints")
      end
    end,
  })

  -- Gets nvim-cmp capabilities
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

  local schema_companion = require("schema-companion")
  local kubernetes_schema_matcher = function()
    return schema_companion.sources.matchers.kubernetes.setup({ version = "master" })
  end

  local function rust_analyzer_root_dir(bufnr, on_dir)
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local cargo_crate_dir = vim.fs.root(fname, { "Cargo.toml" })

    if not cargo_crate_dir then
      on_dir(vim.fs.root(fname, { "rust-project.json", ".git" }))
      return
    end

    if vim.fn.executable("cargo") == 0 then
      on_dir(cargo_crate_dir)
      return
    end

    local cmd = {
      "cargo",
      "metadata",
      "--no-deps",
      "--format-version",
      "1",
      "--manifest-path",
      cargo_crate_dir .. "/Cargo.toml",
    }

    vim.system(cmd, { text = true }, function(output)
      local cargo_workspace_root
      if output.code == 0 and output.stdout then
        local ok, result = pcall(vim.json.decode, output.stdout)
        if ok and type(result) == "table" and result["workspace_root"] then
          cargo_workspace_root = vim.fs.normalize(result["workspace_root"])
        end
      end

      on_dir(cargo_workspace_root or cargo_crate_dir)
    end)
  end

  -- Defines a list of servers and server-specific config
  local servers = {
    bashls = {},
    clangd = {
      cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--completion-style=detailed",
        "--header-insertion=iwyu",
      },
      filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
      root_markers = {
        ".clangd",
        ".clang-tidy",
        "compile_commands.json",
        "compile_flags.txt",
      },
    },
    metals = {
      root_markers = { "build.sbt", "build.sc", "build.mill", "pom.xml", ".git" },
    },
    pyright = {
      settings = {
        python = {
          analysis = {
            autoImportCompletions = true,
            autoSearchPaths = true,
            diagnosticMode = "openFilesOnly",
            useLibraryCodeForTypes = true,
          },
        },
      },
    },
    rust_analyzer = {
      root_dir = rust_analyzer_root_dir,
      settings = {
        ["rust-analyzer"] = {
          cargo = {
            allFeatures = true,
          },
          procMacro = {
            enable = true,
          },
        },
      },
    },
    texlab = {},
    taplo = {},
    -- html = { filetypes = { "html", "twig", "hbs"} },
    gopls = {
      filetypes = { "go", "gomod", "gowork", "gotmpl" },
      root_markers = { "go.work", "go.mod", ".git" },
      settings = {
        gopls = {
          -- Enable auto imports
          gofumpt = true,
          usePlaceholders = true,
          completeUnimported = true,
          staticcheck = true,
          matcher = "fuzzy",

          -- Enable documentation features
          hints = {
            assignVariableTypes = true,
            compositeLiteralFields = true,
            compositeLiteralTypes = true,
            constantValues = true,
            functionTypeParameters = true,
            parameterNames = true,
            rangeVariableTypes = true,
          },

          analyses = {
            unusedparams = true,
            shadow = true,
            nilness = true,
            unusedwrite = true,
            useany = true,
          },

          -- Enable codelens for better documentation
          codelenses = {
            generate = true,
            gc_details = true,
            test = true,
            tidy = true,
            upgradeDeprecatedLints = true,
          },
        },
      },
    },
    lua_ls = {
      settings = {
        Lua = {
          telemetry = { enable = false },
        },
      },
    },
    helm_ls = schema_companion.setup_client(
      schema_companion.adapters.helmls.setup({
        sources = {
          kubernetes_schema_matcher(),
        },
      }),
      {
        settings = {
          ["helm-ls"] = {
            yamlls = {
              path = "yaml-language-server",
              config = {
                completion = true,
                hover = true,
                schemas = {
                  kubernetes = "templates/**",
                },
              },
            },
          },
        },
      }
    ),
    yamlls = schema_companion.setup_client(
      schema_companion.adapters.yamlls.setup({
        sources = {
          kubernetes_schema_matcher(),
          schema_companion.sources.lsp.setup(),
          schema_companion.sources.none.setup(),
        },
      }),
      {
        settings = {
          yaml = {
            completion = true,
            format = { enable = true },
            hover = true,
            schemaStore = { enable = true },
            validate = true,
          },
        },
      }
    ),
  }

  -- Ensure Mason-backed servers are installed.
  -- Some servers in `servers` (for example `metals`) are not provided by Mason
  -- and must still be set up explicitly below.
  local mason_servers = {
    "bashls",
    "clangd",
    "gopls",
    "helm_ls",
    "lua_ls",
    "pyright",
    "rust_analyzer",
    "taplo",
    "texlab",
    "yamlls",
  }

  require("mason-lspconfig").setup({
    ensure_installed = mason_servers,
    -- This config registers custom `vim.lsp.config()` entries below, and also
    -- enables non-Mason servers such as `metals`; keep enablement explicit.
    automatic_enable = false,
  })

  local function ensure_mason_tools(tools)
    local ok_platform, platform = pcall(require, "mason-core.platform")
    if ok_platform and platform.is_headless then
      return
    end

    local ok_registry, registry = pcall(require, "mason-registry")
    if not ok_registry then
      return
    end

    registry.refresh(vim.schedule_wrap(function(success)
      if success == false then
        return
      end

      local function call_package_method(pkg, method)
        if type(pkg[method]) ~= "function" then
          return false
        end

        local ok, result = pcall(pkg[method], pkg)
        return ok and result
      end

      for _, package_name in ipairs(tools) do
        local ok_package, pkg = pcall(registry.get_package, package_name)
        if ok_package
            and not call_package_method(pkg, "is_installed")
            and not call_package_method(pkg, "is_installing")
            and type(pkg.install) == "function" then
          pcall(pkg.install, pkg)
        end
      end
    end))
  end

  ensure_mason_tools({
    "prettier",
  })

  for server_name, server in pairs(servers) do
    server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
    vim.lsp.config(server_name, server)
    vim.lsp.enable(server_name)
  end
end

return M

return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "jay-babu/mason-nvim-dap.nvim",
    "leoluz/nvim-dap-go",
    "mfussenegger/nvim-dap-python",
    "nvim-neotest/nvim-nio",
    "rcarriga/nvim-dap-ui",
    "theHamsta/nvim-dap-virtual-text",
    "mason-org/mason.nvim",
  },
  keys = {
    {
      "<leader>db",
      function()
        require("dap").toggle_breakpoint()
      end,
      desc = "[D]ebug [B]reakpoint",
    },
    {
      "<leader>dB",
      function()
        require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
      end,
      desc = "[D]ebug conditional [B]reakpoint",
    },
    {
      "<leader>dc",
      function()
        require("dap").continue()
      end,
      desc = "[D]ebug [C]ontinue",
    },
    {
      "<leader>di",
      function()
        require("dap").step_into()
      end,
      desc = "[D]ebug step [I]nto",
    },
    {
      "<leader>do",
      function()
        require("dap").step_over()
      end,
      desc = "[D]ebug step [O]ver",
    },
    {
      "<leader>dO",
      function()
        require("dap").step_out()
      end,
      desc = "[D]ebug step [O]ut",
    },
    {
      "<leader>dr",
      function()
        require("dap").repl.open()
      end,
      desc = "[D]ebug [R]EPL",
    },
    {
      "<leader>dt",
      function()
        require("dap").terminate()
      end,
      desc = "[D]ebug [T]erminate",
    },
    {
      "<leader>du",
      function()
        require("dapui").toggle()
      end,
      desc = "[D]ebug [U]I",
    },
    {
      "<leader>dl",
      function()
        require("dap").run_last()
      end,
      desc = "[D]ebug [L]ast",
    },
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    require("nvim-dap-virtual-text").setup({})
    dapui.setup({
      floating = {
        border = "rounded",
      },
    })

    require("mason-nvim-dap").setup({
      automatic_installation = true,
      ensure_installed = {
        "codelldb",
        "delve",
        "python",
      },
      handlers = {},
    })

    local debugpy_python = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
    if vim.fn.executable(debugpy_python) == 1 then
      require("dap-python").setup(debugpy_python)
    end

    require("dap-go").setup()

    local codelldb_configs = {
      {
        name = "Launch file",
        type = "codelldb",
        request = "launch",
        program = function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
      },
      {
        name = "Attach to process",
        type = "codelldb",
        request = "attach",
        pid = require("dap.utils").pick_process,
        cwd = "${workspaceFolder}",
      },
    }

    dap.configurations.c = codelldb_configs
    dap.configurations.cpp = codelldb_configs

    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "go",
      callback = function(args)
        vim.keymap.set("n", "<leader>dn", function()
          require("dap-go").debug_test()
        end, { buffer = args.buf, desc = "[D]ebug [N]earest Go test" })
        vim.keymap.set("n", "<leader>dN", function()
          require("dap-go").debug_last_test()
        end, { buffer = args.buf, desc = "[D]ebug last Go test" })
      end,
    })
  end,
}

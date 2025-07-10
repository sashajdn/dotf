--- Diagnostics configuration
return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    --- Mason setup
    local servers = {
      "clangd",
      "cssls",
      "gopls",
      "graphql",
      "html",
      "lua_ls",
      "marksman",
      "pyright",
      "ruff",
      "rust_analyzer",
      "ts_ls",
      "dockerls",
      "markdown_oxide",
      "jsonls",
      "yamlls",
    }

    local tools = {
      "prettier", -- prettier formatter
      "stylua", -- lua formatter
      "eslint_d", -- js linter
    }

    local mason = require("mason")
    local mason_lspconfig = require("mason-lspconfig")

    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    mason_lspconfig.setup({
      ensure_installed = servers,
    })

    local mason_tool_installer = require("mason-tool-installer")
    mason_tool_installer.setup({
      ensure_installed = tools,
    })
    ---

    --- Diagnostics configuration
    local diagnostic_config = {
      signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " },
      update_in_insert = true,
      severity_sort = true,
      float = {
        focusable = false,
        style = "minimal",
        border = "single",
        source = "always",
        header = "",
        prefix = "",
        suffix = "",
      },
    }
    vim.diagnostic.config(diagnostic_config)

    --- Capabilities configuration
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.foldingRange = {
      dynamicRegistration = true,
      lineFoldingOnly = true,
    }
    capabilities.textDocument.semanticTokens.multilineTokenSupport = true
    capabilities.textDocument.completion.completionItem.snippetSupport = true

    vim.lsp.config("*", {
      capabilities = capabilities,
    })

    --- Key configuration
    local keymap = vim.keymap
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        local opts = { buffer = ev.buf, silent = true }

        opts.desc = "Show LSP references"
        keymap.set("n", "<leader>gr", "<cmd>Telescope lsp_references<CR>", opts)

        opts.desc = "Show documentation for what is under cursor"
        keymap.set("n", "<leader>gh", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

        opts.desc = "Go to declaration"
        keymap.set("n", "<leader>gD", vim.lsp.buf.declaration, opts) -- go to declaration

        opts.desc = "Show LSP definitions"
        keymap.set("n", "<leader>gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

        opts.desc = "Show LSP implementations"
        keymap.set("n", "<leader>gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

        opts.desc = "Show LSP type definitions"
        keymap.set("n", "<leaderr>gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

        opts.desc = "Show LSP code actions"
        keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

        opts.desc = "Smart rename"
        keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

        opts.desc = "Show buffer diagnostics"
        keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

        opts.desc = "Show line diagnostics"
        keymap.set("n", "<leader>dl", vim.diagnostic.open_float, opts) -- show diagnostics for line

        opts.desc = "Go to previous diagnostic"
        keymap.set("n", "<leader>dp", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

        opts.desc = "Go to next diagnostic"
        keymap.set("n", "<leader>dn", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

        opts.desc = "Restart LSP"
        keymap.set("n", "<leader>rs", ":LscRestart<CR>", opts) -- mapping to restart lsp if necessary
      end,
    })

    --- Server setups ---

    --- Lua
    vim.lsp.config.lua_lsp = {
      cmd = { "lua-language-server" },
      filetypes = { "lua" },
      root_markers = { ".luarc.json", ".git", vim.uv.cwd() },
      settings = {
        Lua = {
          telemetry = {
            enable = false,
          },
          -- make the language server recognize "vim" global
          diagnostics = {
            globals = { "vim" },
          },
          completion = {
            callSnippet = "Replace",
          },
        },
      },
    }
    vim.lsp.enable("lua_lsp")

    --- Python
    vim.lsp.config.pyright = {
      settings = {
        python = {
          pyright = {
            disableOrganizeImports = true,
          },
          analysis = {
            ignore = { "*" },
          },
          pythonPath = "/Users/sasha/Library/Caches/pypoetry/virtualenvs/analysis-QFYxe2qh-py3.13/bin/python",
          venvPath = "/Users/sasha/Library/Caches/pypoetry/virtualenvs/",
          venv = "analysis-QFYxe2qh-py3.13",
        },
      },
    }
    vim.lsp.enable("pyright")
    vim.lsp.enable("ruff")

    --- Go
    local go_root = vim.fs.dirname(vim.fs.find({ "go.work", "go.mod", ".git" }, { upward = true })[1])
    vim.lsp.config.gopls = {
      cmd = { "gopls", "serve" },
      filetypes = { "go", "gomod", "gowork", "gotmpl" },
      root_dir = go_root,
      settings = {
        gopls = {
          completeUnimported = true,
          usePlaceholders = false,
          analyses = {
            unusedparams = true,
          },
          ["ui.inlayhint.hints"] = {
            compositeLiteralFields = true,
            constantValues = true,
            parameterNames = true,
            rangeVariableTypes = true,
          },
          staticcheck = true,
          buildFlags = { "-tags=integration" },
        },
      },
    }
    vim.lsp.enable("gopls")

    --- Rust
    vim.lsp.config.rust_analyzer = {
      filetypes = { "rust" },
      cmd = { "rust-analyzer" },
      workspace_required = true,
      root_dir = function(buf, cb)
        local root = vim.fs.root(buf, { "Cargo.toml", "rust-project.json" })
        local out = vim.system({ "cargo", "metadata", "--no-deps", "--format-version", "1" }, { cwd = root }):wait()
        if out.code ~= 0 then
          return cb(root)
        end

        local ok, result = pcall(vim.json.decode, out.stdout)
        if ok and result.workspace_root then
          return cb(result.workspace_root)
        end

        return cb(root)
      end,
      settings = {
        autoformat = false,
        ["rust-analyzer"] = {
          check = {
            command = "clippy",
          },
          inlayHints = {
            enable = true,
            typeHints = true,
            parameterHints = true,
            chainingHints = true,
            closureReturnTypeHints = true,
          },
          procMacro = {
            enable = true,
          },
          checkOnSave = {
            command = "check", -- cargo check
          },
          cargo = {
            extraEnv = { CARGO_PROFILE_RUST_ANALYZER_INHERITS = "dev" },
            extraArgs = { "--profile", "rust-analyzer" },
            loadOutDirsFromCheck = true,
            allFeatures = true,
          },
          imports = {
            granularity = {
              group = "crate",
            },
            prefix = "self",
          },
          diagnostics = {
            refreshSupport = false,
          },
          lens = {
            enable = true,
          },
          hoverActions = {
            enable = true,
            border = "rounded",
          },
          completion = {
            autoimport = {
              enable = true,
            },
            postfix = {
              enable = false,
            },
          },
        },
      },
    }
    vim.lsp.enable("rust_analyzer")

    --- Bash
    vim.lsp.config.bashls = {
      cmd = { "bash-language-server", "start" },
      filetypes = { "bash", "sh", "zsh" },
      root_markers = { ".git", vim.uv.cwd() },
      settings = {
        bashIde = {
          globPattern = vim.env.GLOB_PATTERN or "*@(.sh|.inc|.bash|.command)",
        },
      },
    }
    vim.lsp.enable("bashls")

    -- Start, Stop, Restart, Log commands
    vim.api.nvim_create_user_command("LspStart", function()
      vim.cmd.e()
    end, { desc = "Starts LSP clients in the current buffer" })

    vim.api.nvim_create_user_command("LspStop", function(opts)
      for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
        if opts.args == "" or opts.args == client.name then
          client:stop(true)
          vim.notify(client.name .. ": stopped")
        end
      end
    end, {
      desc = "Stop all LSP clients or a specific client attached to the current buffer.",
      nargs = "?",
      complete = function(_, _, _)
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        local client_names = {}
        for _, client in ipairs(clients) do
          table.insert(client_names, client.name)
        end
        return client_names
      end,
    })

    vim.api.nvim_create_user_command("LspRestart", function()
      local detach_clients = {}
      for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
        client:stop(true)
        if vim.tbl_count(client.attached_buffers) > 0 then
          detach_clients[client.name] = { client, vim.lsp.get_buffers_by_client_id(client.id) }
        end
      end
      local timer = vim.uv.new_timer()
      if not timer then
        return vim.notify("Servers are stopped but havent been restarted")
      end
      timer:start(
        100,
        50,
        vim.schedule_wrap(function()
          for name, client in pairs(detach_clients) do
            local client_id = vim.lsp.start(client[1].config, { attach = false })
            if client_id then
              for _, buf in ipairs(client[2]) do
                vim.lsp.buf_attach_client(buf, client_id)
              end
              vim.notify(name .. ": restarted")
            end
            detach_clients[name] = nil
          end
          if next(detach_clients) == nil and not timer:is_closing() then
            timer:close()
          end
        end)
      )
    end, {
      desc = "Restart all the language client(s) attached to the current buffer",
    })

    vim.api.nvim_create_user_command("LspLog", function()
      vim.cmd.vsplit(vim.lsp.log.get_filename())
    end, {
      desc = "Get all the lsp logs",
    })

    vim.api.nvim_create_user_command("LspInfo", function()
      vim.cmd("silent checkhealth vim.lsp")
    end, {
      desc = "Get all the information about all lsp attached",
    })
  end,
}

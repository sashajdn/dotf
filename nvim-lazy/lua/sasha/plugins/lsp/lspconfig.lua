return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/neodev.nvim", opts = {} },
  },
  config = function()
    local lspconfig = require("lspconfig")

    local mason_lspconfig = require("mason-lspconfig")

    local cmp_nvim_lsp = require("cmp_nvim_lsp")

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

    local capabilities = cmp_nvim_lsp.default_capabilities()
    local util = require("lspconfig/util")

    -- Change the Diagnostic symbols in the sign column (gutter)
    -- (not in youtube nvim video)
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    mason_lspconfig.setup_handlers({
      -- default handler for installed servers
      function(server_name)
        lspconfig[server_name].setup({
          capabilities = capabilities,
        })
      end,
      ["lua_ls"] = function()
        -- configure lua server (with special settings)
        lspconfig["lua_ls"].setup({
          capabilities = capabilities,
          settings = {
            Lua = {
              -- make the language server recognize "vim" global
              diagnostics = {
                globals = { "vim" },
              },
              completion = {
                callSnippet = "Replace",
              },
            },
          },
        })
      end,
      ["gopls"] = function()
        lspconfig.gopls.setup({
          cmd = { "gopls", "serve" },
          filetypes = { "go", "gomod", "gowork", "gotmpl" },
          root_dir = util.root_pattern("go.work", "go.mod", ".git"),
          capabilities = capabilities,
          settings = {
            gopls = {
              completeUnimported = true,
              usePlaceholders = false,
              analyses = {
                unusedparams = true,
              },
              staticcheck = true,
              buildFlags = { "-tags=integration" },
            },
          },
        })
      end,
      ["clangd"] = function()
        lspconfig.clangd.setup({})
      end,
      ["pyright"] = function()
        lspconfig.pyright.setup({
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
        })
      end,
      ["ruff"] = function()
        lspconfig.ruff.setup({})
      end,
      ["rust_analyzer"] = function()
        lspconfig.rust_analyzer.setup({
          capabilities = capabilities,
          settings = {
            ["rust-analyzer"] = {
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
        })
      end,
    })
  end,
}

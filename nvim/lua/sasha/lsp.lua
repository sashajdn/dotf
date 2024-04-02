-- Check installation of lspconfig.
local lsp_status_ok, lspconfig = pcall(require, "lspconfig")
if not lsp_status_ok then
    return
end

-- Check installation of lspkind.
local lspkind_status_ok, lspkind = pcall(require, "lspkind")
if not lspkind_status_ok then
    print("missing lspkind")
    return
end

local util = require("lspconfig/util")

local Remap = require("sasha.keymap")
local nnoremap = Remap.nnoremap
local inoremap = Remap.inoremap


local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local function config(_config)
    return vim.tbl_deep_extend("force", {
        capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities()),
        on_attach = function()
            -- LSP keymappings.
            nnoremap("<leader>gh", function() vim.lsp.buf.hover() end)
            nnoremap("<leader>gd", function() vim.lsp.buf.definition() end)
            nnoremap("<leader>gw", function() vim.lsp.buf.workspace_symbol() end)
            nnoremap("<leader>gt", function() vim.lsp.buf.type_definition() end)
            nnoremap("<leader>gr", function() vim.lsp.buf.references() end)
            nnoremap("<leader>gi", function() vim.lsp.buf.implementation() end)
            nnoremap("<leader>rn", function() vim.lsp.buf.rename() end)

            -- Diagnostic keymappings.
            nnoremap("<leader>df", function() vim.diagnostic.open_float() end)
            nnoremap("<leader>dn", function() vim.diagnostic.goto_next() end)
            nnoremap("<leader>dp", function() vim.diagnostic.goto_prev() end)
        end,
    }, _config or {})
end

-- Typescript.
lspconfig.tsserver.setup(config({
    filetypes = { "typescript", "typescriptreact", "typescript.tsx" },
    cmd = { "typescript-language-server", "--stdio" }
}))

-- Python.
lspconfig.pyright.setup(config())

-- Golang.
lspconfig.gopls.setup(config({
    cmd = { "gopls", "serve" },
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    root_dir = util.root_pattern("go.work","go.mod", ".git"),
    settings = {
        gopls = {
            completeUnimported = true,
            usePlaceholders = true,
            analyses = {
                unusedparams = true,
            },
            staticcheck = true,
        },
    },
}))

-- Golang linter.
-- lspconfig.golangci_lint_ls.setup(config())

-- Rust.
lspconfig.rust_analyzer.setup(config())

-- Solidity.
lspconfig.solang.setup(config())

-- cplusplus.
lspconfig.clangd.setup(config())

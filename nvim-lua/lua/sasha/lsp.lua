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

local Remap = require("sasha.keymap")
local nnoremap = Remap.nnoremap
local inoremap = Remap.inoremap

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local function config(_config)
    return vim.tbl_deep_extend("force", {
        capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities()),
        on_attach = function()
            -- LSP keymappings.
            nnoremap("<leader>gd", function() vim.lsp.buf.definition() end)
            inoremap("<leader>gh", function() vim.lsp.buf.signature_help() end)
            nnoremap("<leader>gr", function() vim.lsp.buf.references() end)
            nnoremap("<leader>rn", function() vim.lsp.buf.rename() end)

            -- Diagnostic keymappings.
            nnoremap("<leader>gf", function() vim.diagnostic.open_float() end)
            nnoremap("<leader>gn", function() vim.diagnostic.goto_next() end)
            nnoremap("<leader>gN", function() vim.diagnostic.goto_prev() end)
        end,
    }, _config or {})
end

-- Typescript.
lspconfig.tsserver.setup(config())

-- Golang.
lspconfig.gopls.setup(config({
    cmd = { "gopls", "serve" },
    settings = {
        gopls = {
            analyses = {
                unusedparams = true,
            },
            staticcheck = true,
        }
    }
}))

-- Rust.
lspconfig.rust_analyzer.setup(config({
    cmd = { "rustup", "run", "nightly", "rust-analyzer" },
}))

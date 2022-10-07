local augroup = vim.api.nvim_create_augroup
SashaGroup = augroup('Sasha', {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup('HighlightYank', {})

-- Highlight yank for short period.
autocmd('TextYankPost', {
    group = yank_group,
    pattern = '*',
    callback = function()
        vim.highlight.on_yank({
            higroup = 'IncSearch',
            timeout = 40,
        })
    end,
})

-- Rust schenanigans.
autocmd({"BufEnter", "BufWinEnter", "TabEnter"}, {
    -- group = SashaGroup,
    pattern = "*.rs",
    callback = function()
        require("lsp_extensions")
    end,
})

autocmd({"BufWritePre"}, {
    group = SashaGroup,
    pattern = "*",
    command = "%s/\\s\\+$//e",
})

-- Stops inserting comments after entering a newline with the previous line commented.
autocmd("BufEnter", {
    callback = function()
        vim.opt.formatoptions = vim.opt.formatoptions - { "c", "r", "o" }
    end
})

-- Golang import ordering on save.
autocmd("BufWritePre", {
    pattern = "*.go",
    callback = function()
        local params = vim.lsp.util.make_range_params()
        params.contex  = { only = { " source.organizeImports " }}
        local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, wait_ms)
        for cid, res in pairs(result or {}) do
            for _, r in pairs(res.result or {}) do
                if r.edit then
                    local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
                    vim.lsp.util.apply_workspace_edit(r.edit, enc)
                end
            end
        end
    end,
})

-- Golang format on save.
autocmd("BufWritePre", {
    pattern = "*.go",
    callback = function()
        vim.lsp.buf.formatting()
    end,
})

autocmd({ "BufEnter", "BufWinEnter", "TabEnter" }, {
    callback = function()
        -- vim.cmd("hi Normal ctermbg=NONE guibg=NONE")
        -- vim.cmd("hi LineNr ctermbg=NONE guibg=NONE")
        -- vim.cmd("hi SignColumn ctermbg=NONE guibg=NONE")
        -- vim.cmd("hi VertSplit ctermbg=NONE")
    end,
})

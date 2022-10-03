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
    group = SashaGroup,
    pattern = "*.rs",
    callback = function()
        require("lsp_extensions").inlay_hints{}
    end
})

autocmd({"BufWritePre"}, {
    group = SashaGroup,
    pattern = "*",
    command = "%s/\\s\\+$//e",
})

-- Stops inserting comments after entering a newline with the previous line commented.
autocmd("BufEnter", {
    callback = function()
        vim.opt.formatoptions= vim.opt.formatoptions - { "c", "r", "o" }
    end
})

function Transparency()
    vim.g.oxocarbon_lua_keep_terminal = true
    vim.g.oxocarbon_lua_transparent = true
    vim.g.oxocarbon_lua_alternative_telescope = true

    vim.opt.background = "dark"

    vim.cmd("colorscheme oxocarbon-lua")

    local hl = function(what, opts)
        vim.api.nvim_set_hl(0, what, opts)
    end

    hl("SignColumn", {
        bg = "none",
    })

    hl("CursorLineNR", {
        bg = "none"
    })

    hl("Normal", {
        bg = "none"
    })

    hl("NormalNC", {
        bg = "none"
    })

    hl("VertSplit", {
        bg = "none",
        fg = "#262626"
    })

    hl("LineNr", {
        fg = "#78a9ff"
    })

    hl("netrwDir", {
        fg = "#78a9ff"
    })
end

Transparency()

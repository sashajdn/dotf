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
        bg = "None"
    })

    -- hl("Normal", {
    --   bg = "none"
    -- })

    hl("LineNr", {
        fg = "#5eacd3"
    })

    hl("netrwDir", {
        fg = "#5eacd3"
    })

end

Transparency()

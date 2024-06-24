return {
  "sashajdn/oxocarbon.nvim",
  priority = 1000,
  config = function()
    vim.g.oxocarbon_lua_keep_terminal = true
    vim.g.oxocarbon_lua_transparent = true
    vim.g.oxocarbon_lua_alternative_telescope = true

    vim.cmd("colorscheme oxocarbon-lua")

    local hl = function(what, opts)
      vim.api.nvim_set_hl(0, what, opts)
    end

    hl("SignColumn", {
      bg = "none",
    })

    hl("CursorLineNR", {
      bg = "none",
    })

    hl("Normal", {
      bg = "none",
    })

    hl("NormalFloat", {
      bg = "none",
    })

    hl("NormalNC", {
      bg = "none",
    })

    hl("VertSplit", {
      bg = "none",
      fg = "#262626",
    })

    hl("LineNr", {
      bg = "none",
      fg = "#78a9ff",
    })

    hl("StatusLine", {
      bg = "none",
    })

    hl("StatusLine", {
      bg = "none",
    })

    hl("StatusLineNC", {
      bg = "none",
    })

    hl("NvimTreeNormal", {
      bg = "none",
    })

    hl("NvimTreeNormalNC", {
      bg = "none",
    })

    hl("NvimTreeVertSplit", {
      bg = "none",
    })
  end,
}

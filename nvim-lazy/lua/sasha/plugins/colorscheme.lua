return {
  "sashajdn/oxocarbon.nvim",
  branch = "feat/add-noice-highlight-groups",
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

    -- Markdown
    hl("@markup.heading.1", {
      fg = "#ff7eb6",
    })
    hl("@markup.heading.2", {
      fg = "#3ddbd9",
    })
    hl("@markup.heading.3", {
      fg = "#f7b188",
    })
    hl("@markup.heading.4", {
      fg = "#be95ff",
    })
    hl("@markup.heading.5", {
      fg = "#82cfff",
    })
    hl("@markup.heading.6", {
      fg = "#ee5396",
    })

    -- Avante
    hl("AvanteConflictCurrent", {
      fg = "#ff7eb6",
      bg = "#393939",
      bold = true,
    })

    hl("AvanteConflictIncoming", {
      fg = "#3ddbd9",
      bg = "#393939",
      italic = true,
    })

    hl("AvanteConflictCurrentLabel", {
      fg = "#ee5396",
      bg = "#393939",
      bold = true,
    })

    hl("AvanteConflictIncomingLabel", {
      fg = "#3ddbd9",
      bg = "#393939",
      italic = true,
    })

    -- Selection
    hl("StarWordHighlight", {
      bg = "#e66c1f",
      fg = "#ffffff",
      bold = true,
    })
  end,
}

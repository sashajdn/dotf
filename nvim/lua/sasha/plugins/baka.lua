return {
  "sashajdn/baka",
  event = "VeryLazy",
  config = function()
    require("baka").setup()

    -- Override Baka float chrome with oxocarbon accents so popups stand out
    -- against the transparent background. Re-applied on colorscheme change.
    local function paint()
      vim.api.nvim_set_hl(0, "BakaBorder", { fg = "#78a9ff" })           -- blue
      vim.api.nvim_set_hl(0, "BakaTitle",  { fg = "#82cfff", bold = true }) -- cyan
    end
    paint()
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("BakaUserHighlights", { clear = true }),
      callback = paint,
    })
  end,
}

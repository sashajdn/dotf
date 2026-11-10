return {
  dir = vim.fn.expand("~/repos/painter.nvim"),
  lazy = false,
  config = function()
    require("painter").setup()
  end,
}

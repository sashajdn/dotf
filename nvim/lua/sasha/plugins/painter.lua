return {
  "sashajdn/painter.nvim",
  url = "git@github.com:sashajdn/painter.nvim.git",
  branch = "master",
  lazy = false,
  config = function()
    require("painter").setup()
  end,
}

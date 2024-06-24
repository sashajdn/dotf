return {
  "akinsho/bufferline.nvim",
  after = "oxocarbon-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  version = "*",
  opts = {
    options = {
      mode = "tabs",
      separator_style = "slant",
    },
  },
  config = function()
    require("bufferline").setup({
      highlights = {
        fill = {
          bg = "none",
        },
        background = {
          bg = "none",
        },
        tab = {
          bg = "none",
        },
      },
    })
  end,
}

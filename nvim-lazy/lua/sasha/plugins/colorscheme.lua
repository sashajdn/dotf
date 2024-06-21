return {
  "sashajdn/espeon",
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      flavour = "mocha",
      term_colors = true,
      transparent_background = true,
      integrations = {
        dashboard = true,
        harpoon = true,
        mason = true,
        nvimtree = true,
        which_key = true,
      },
    })
    vim.cmd("colorscheme catppuccin")
  end,
}

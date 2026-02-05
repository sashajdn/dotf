return {
  {
    "albxllm/moltstream",
    build = "make build",
    config = function()
      require("moltstream").setup({
        keymap = {
          send = "<leader>ms", -- send raw
          send_code = "<leader>mc", -- send with git context (for code)
          open = "<leader>mo", -- open
          history = "<leader>mu", -- user history
        },
      })
    end,
    keys = {
      { "<leader>mo", desc = "Moltstream: Open" },
      { "<leader>ms", mode = "v", desc = "Moltstream: Send" },
      { "<leader>mc", mode = "v", desc = "Moltstream: Send code" },
    },
  },
}

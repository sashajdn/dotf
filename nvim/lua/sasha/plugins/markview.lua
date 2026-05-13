return {
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      preview = {
        enable = false,
        enable_hybrid_mode = true,
        filetypes = { "markdown" },
        icon_provider = "devicons",
      },
    },
    keys = {
      {
        "<leader>mR",
        function()
          local bufnr = vim.api.nvim_get_current_buf()
          local actions = require("markview.actions")
          local state = require("markview.state")

          if not state.buf_attached(bufnr) then
            actions.attach(bufnr, { enable = false, hybrid_mode = true })
          end

          local buf_state = state.get_buffer_state(bufnr, false)
          if buf_state and buf_state.enable then
            actions.disable(bufnr)
            pcall(function()
              require("diagram").clear()
            end)
            pcall(vim.cmd, "RenderMarkdown buf_enable")
          else
            pcall(vim.cmd, "RenderMarkdown buf_disable")
            actions.enable(bufnr)
            pcall(function()
              require("diagram").render()
            end)
          end
        end,
        desc = "Toggle Markview render",
      },
    },
  },
}

local has_mermaid_cli = vim.fn.executable("mmdc") == 1

return {
  {
    "3rd/image.nvim",
    build = false,
    ft = { "markdown" },
    opts = {
      backend = "kitty",
      processor = "magick_cli",
      integrations = {
        markdown = {
          enabled = false,
        },
      },
      max_width_window_percentage = 85,
      max_height_window_percentage = 60,
      tmux_show_only_in_active_window = true,
      window_overlap_clear_enabled = true,
    },
  },
  {
    "3rd/diagram.nvim",
    ft = { "markdown" },
    dependencies = {
      "3rd/image.nvim",
    },
    opts = function()
      return {
        integrations = {
          require("diagram.integrations.markdown"),
        },
        events = {
          render_buffer = has_mermaid_cli and { "BufWinEnter", "InsertLeave" } or {},
          clear_buffer = { "BufLeave" },
        },
        renderer_options = {
          mermaid = {
            background = "transparent",
            theme = "dark",
            scale = 2,
          },
        },
      }
    end,
    keys = {
      {
        "<leader>md",
        function()
          require("diagram").render()
        end,
        ft = { "markdown" },
        desc = "Render Markdown diagrams",
      },
    },
  },
}

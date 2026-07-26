return {
  "MeanderingProgrammer/render-markdown.nvim",
  lazy = false,
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    enabled = false,
    file_types = { "markdown" },
    render_modes = { "n", "c" },
    heading = {
      enabled = false,
    },
    code = {
      width = "block",
      left_margin = 0,
      left_pad = 1,
      right_pad = 1,
      min_width = 72,
      border = "none",
      language = false,
      language_name = false,
      language_icon = false,
      language_info = false,
      highlight = "RenderMarkdownCode",
      highlight_info = "RenderMarkdownCodeInfo",
      highlight_border = "RenderMarkdownCodeBorder",
      highlight_fallback = "RenderMarkdownCodeFallback",
      highlight_inline = "RenderMarkdownCodeInline",
    },
    pipe_table = {
      enabled = false,
    },
    quote = {
      enabled = false,
    },
    dash = {
      enabled = false,
    },
    bullet = {
      enabled = false,
    },
    checkbox = {
      enabled = false,
    },
    callout = {
      note = { raw = "[!NOTE]", rendered = "NOTE", highlight = "RenderMarkdownInfo" },
      tip = { raw = "[!TIP]", rendered = "TIP", highlight = "RenderMarkdownSuccess" },
      important = { raw = "[!IMPORTANT]", rendered = "IMPORTANT", highlight = "RenderMarkdownHint" },
      warning = { raw = "[!WARNING]", rendered = "WARNING", highlight = "RenderMarkdownWarn" },
      caution = { raw = "[!CAUTION]", rendered = "CAUTION", highlight = "RenderMarkdownError" },
    },
    link = {
      enabled = false,
    },
    inline_highlight = {
      enabled = false,
    },
    latex = {
      enabled = false,
    },
    padding = {
      highlight = "MarkdownRenderNormal",
    },
    win_options = {
      conceallevel = {
        default = vim.o.conceallevel,
        rendered = 3,
      },
      concealcursor = {
        default = vim.o.concealcursor,
        rendered = "",
      },
    },
  },
  config = function(_, opts)
    require("render-markdown").setup(opts)
    require("sasha.markdown_render").setup_highlights()
  end,
}

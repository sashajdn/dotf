return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPre", "BufNewFile" },
  build = ":TSUpdate",
  dependencies = {
    "windwp/nvim-ts-autotag",
  },
  config = function()
    local treesitter = require("nvim-treesitter.configs")

    treesitter.setup({
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },

      indent = {
        enable = true,
        disable = {
          "markdown",
          "lua",
        },
      },

      autotag = {
        enable = true,
      },

      ensure_installed = {
        "json",
        "javascript",
        "typescript",
        "tsx",
        "yaml",
        "html",
        "css",
        "markdown",
        "markdown_inline",
        "graphql",
        "bash",
        "lua",
        "vim",
        "dockerfile",
        "gitignore",
        "vimdoc",
        "c",
        "rust",
        "go",
        "gomod",
        "gosum",
        "python",
        "make",
        "cpp",
        "cuda",
        "gitcommit",
        "proto",
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<leader>vi",
          node_incremental = "<leader>vn",
          scope_incremental = false,
          node_decremental = "<leader>vp",
        },
      },
    })
  end,
}

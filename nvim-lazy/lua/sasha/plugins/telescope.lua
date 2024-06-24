return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")

    local builtin = require("telescope.builtin")

    local function search_dotfiles()
      builtin.git_files({
        prompt_title = "< DotF 💻 >",
        cwd = "$HOME/dotf",
        hidden = true,
      })
    end

    local function search_wiki()
      builtin.git_files({
        prompt_title = "< Wiki 📚>",
        cwd = "$WIKI",
        hidden = true,
      })
    end

    telescope.setup({
      defaults = {
        file_sorter = require("telescope.sorters").get_fzy_sorter,
        file_previewer = require("telescope.previewers").vim_buffer_cat.new,
        grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
        qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,

        path_display = { "smart" },
        prompt_prefix = "λ ",
        mappings = {
          i = {
            ["<C-x>"] = false,
            ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,

            ["<Down>"] = actions.move_selection_next,
            ["<Up>"] = actions.move_selection_previous,

            ["<C-u>"] = actions.preview_scrolling_up,
            ["<C-d>"] = actions.preview_scrolling_down,
          },
        },
      },
    })

    telescope.load_extension("fzf")

    local keymap = vim.keymap

    keymap.set("n", "<leader>ff", "<cmd>Telescope git_files<cr>", { desc = "Fuzzy find files in cwd" })
    keymap.set("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "Fuzzy find recent files" })
    keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "Fuzzy find string in cwd" })
    keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>", { desc = "Fuzzy find string under cursor in cwd" })
    keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find TODOs" })
    keymap.set("n", "<leader>fd", search_dotfiles, { desc = "Search dotf" })
    keymap.set("n", "<leader>fw", search_wiki, { desc = "Search Wiki" })
  end,
}

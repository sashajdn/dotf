if true then
  return {}
else
  return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()

      local keymap = vim.keymap

      keymap.set("n", "<leader>ba", function()
        harpoon:list():add()
      end, { desc = "Harpoon add to list" })

      keymap.set("n", "<leader>bq", function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, { desc = "Harpoon toggle quick menu" })

      keymap.set("n", "<leader>bn", function()
        harpoon:list():next()
      end, { desc = "Harpoon go to next buffer" })

      keymap.set("n", "<leader>bp", function()
        harpoon:list():prev()
      end, { desc = "Harpoon go to prev buffer" })
    end,
  }
end

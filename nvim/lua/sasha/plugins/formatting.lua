return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local conform = require("conform")

    conform.setup({
      formatters_by_ft = {
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        lua = { "stylua" },
      },
      format_on_save = function(bufnr)
        local ft = vim.bo[bufnr].filetype
        if ft == "helm" then
          return
        end
        return {
          lsp_fallback = true,
          async = false,
          timeout_ms = 1000,
        }
      end,
    })

    local keymap = vim.keymap

    keymap.set({ "n", "v" }, "<leader>cf", function()
      conform.format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 1000,
      })
    end, { desc = "Format file or range in (visual mode)" })
  end,
}

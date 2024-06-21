local augroup = vim.api.nvim_create_augroup
SashaCoreGroup = augroup("SashaCore", {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup("HighlightYank", {})

-- Highlight yank for short period.
autocmd("TextYankPost", {
  group = yank_group,
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({
      higroup = "IncSearch",
      timeout = 40,
    })
  end,
})

-- Remove trailing whitespace on save.
autocmd({ "BufWritePre" }, {
  group = SashaGroup,
  pattern = "*",
  command = "%s/\\s\\+$//e",
})

-- Stops inserting comments after entering a newline with the previous line commented.
autocmd("BufEnter", {
  callback = function()
    vim.opt.formatoptions = vim.opt.formatoptions - { "c", "r", "o" }
  end,
})

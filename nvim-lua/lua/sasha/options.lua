vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"

vim.opt.nu = true
vim.opt.relativenumber = true -- sets relativenumber, relative line number, with the current being the true line number

vim.opt.errorbells = false

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true
vim.opt.wrap = false

vim.opt.cursorline = true -- adds highlighted cursorline

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true -- adds persistent undofile
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir" -- sets the directory of where to put undo files

vim.opt.hlsearch = false -- search highlight is *not* persisted
vim.opt.incsearch = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.cmdheight = 1 -- gives more space for displaying messages.

vim.opt.updatetime = 50 -- default is 4000ms

vim.opt.shortmess:append("c")

vim.opt.colorcolumn = "120"

vim.g.mapleader = " "

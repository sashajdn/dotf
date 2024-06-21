vim.cmd("let g:netrw_liststyle = 3")

local opt = vim.opt

opt.errorbells = false

opt.nu = true
opt.relativenumber = true
opt.number = true

-- tabs & indentation
opt.tabstop = 2
-- opt.softtabstop = 4
opt.shiftwidth = 2
opt.expandtab = true -- expand tabs to spaces
opt.autoindent = true -- copy indent from current line when creating a new one
opt.smartindent = true
opt.wrap = false

-- undos
opt.undofile = true

-- search settings
opt.hlsearch = false -- search highlight is *not* persisted
opt.incsearch = true
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if mixed case in search, assumes case sensitive wanted

-- commands
opt.cmdheight = 1

-- cursor
opt.cursorline = true

-- theme
opt.termguicolors = true
opt.background = "dark"

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

-- clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- split windows
opt.splitright = true
opt.splitbelow = true

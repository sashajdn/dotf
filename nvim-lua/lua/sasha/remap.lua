local Remap = require("sasha.keymap")
local nnoremap = Remap.nnoremap
local vnoremap = Remap.vnoremap
local inoremap = Remap.inoremap
local xnoremap = Remap.xnoremap

-- Keymappings
-- TODO: move to after directory

-- Filetree
nnoremap("<leader>t", "<cmd>Lex 30<CR>") -- open filetree in left hand buffer.

-- Push pasted over words (etc) so unnamed register, to keep current in clipboard.
vnoremap("<leader>p",  "\"_dp")

-- Splits
nnoremap("<leader>V", "<cmd>split<CR>") -- open horizontal split.
nnoremap("<leader>v", "<cmd>vsplit<CR>") -- open vertical split.

nnoremap("<leader>h", "<cmd>wincmd h<CR>") -- move to the window on the left.
nnoremap("<leader>j", "<cmd>wincmd j<CR>") -- move to the window below.
nnoremap("<leader>k", "<cmd>wincmd k<CR>") -- move to the window above.
nnoremap("<leader>l", "<cmd>wincmd l<CR>") -- move to the window to the right.

-- Windows
nnoremap("<leader>o", "<cmd>wincmd o<CR>") -- quit all windows except the current window.

-- Selection
vnoremap("<", "<gv") -- keep block section integrity when increasing indent
vnoremap(">", ">gv") -- keep block section integrity when decreasing indent.

vnoremap("J", ":m '>+1<CR>gv=gv") -- move block downwards whilst keeping ident.
vnoremap("K", ":m '<-2<CR>gv=gv") -- move block upwards whilst keeping ident.

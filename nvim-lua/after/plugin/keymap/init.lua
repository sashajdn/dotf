local Remap = require("sasha.keymap")
local nnoremap = Remap.nnoremap
local vnoremap = Remap.vnoremap
local inoremap = Remap.inoremap
local xnoremap = Remap.xnoremap
local nmap = Remap.nmap

-- Quicklist.
nnoremap("<leader>qn", "<cmd>cnext<CR>zz") -- go next item on quicklist & re-center.
nnoremap("<leader>qp", "<cmd>cprev<CR>zz") -- go previous item on quicklist & re-center.

-- Navigation.
nnoremap("n", "nzzzv")
nnoremap("N", "Nzzzv")
nnoremap("<C-d>", "<C-d>zz") -- Center cursor after moving half a page down.
nnoremap("<C-u>", "<C-u>zz") -- Center cursor after moving half a page up.

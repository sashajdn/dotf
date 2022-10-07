local Remap = require("sasha.keymap")
local nnoremap = Remap.nnoremap
local vnoremap = Remap.vnoremap
local inoremap = Remap.inoremap
local xnoremap = Remap.xnoremap
local nmap = Remap.nmap

-- Quicklist.
nnoremap("<leader>qn", "<cmd>cnext<CR>")
nnoremap("<leader>qp", "<cmd>cprev<CR>")

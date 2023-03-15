local ok, chatgpt = pcall(require, "chatgpt")
if not ok then
    return
end

local Remap = require("sasha.keymap")
local nnoremap = Remap.nnoremap

nnoremap("<leader>cg", "<cmd>ChatGPT<CR>")

nnoremap("<leader>ca", "<cmd>ChatGPTActAs<CR>")

nnoremap("<leader>cc", "<cmd>ChatGPTCompleteCode<CR>")

nnoremap("<leader>ce", "<cmd>ChatGPTEditWithInstructions<CR>")

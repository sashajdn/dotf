local ok, chatgpt = pcall(require, "chatgpt")
if not ok then
    print("CHATGPT, NOT OK")
    return
end

local Remap = require("sasha.keymap")
local nnoremap = Remap.nnoremap
local inoremap = Remap.inoremap

chatgpt.setup({
    welcome_message = "Hello, Sasha 👾",
    question_sign = "❓",
    answer_sign = "🤖",
    keymaps = {
        close = { "<ESC>" },
        submit = "<C-s>",
    },
})

return chatgpt

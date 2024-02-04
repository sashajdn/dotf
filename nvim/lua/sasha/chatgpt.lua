local ok, chatgpt = pcall(require, "chatgpt")
if not ok then
    print("CHATGPT, NOT OK")
    return
end

local Remap = require("sasha.keymap")
local nnoremap = Remap.nnoremap
local inoremap = Remap.inoremap

-- https://www.reddit.com/r/ASCII_Archive/comments/iga1d4/your_robot_friend/
WELCOME_MESSAGE = [[
               _.agjWMb         dMWkpe._
              'H8888888b,     ,d8888888H'
               V88888888Wad8beW88888888V
              ,;88888888888888888888888:.
    ,ae.,   _aM8888888888888888888888888Me_   ,.ae.
  ,d88888b,d8888888888888888888888888888888b.d88888b.
 d888888888888888888888888888888888888888888888888888b
'V888888888888888888888888888888888888888888888888888V'
  "V88888888888888888888888888888888888888888888888V"
    88888888WMP^YMW88888888888888888WMP^YMW88888888
    88888WP'  _,_ "VW888888W8888888V" _,_  'VW88888
    888888"  dM8Mb '888888' '888888' d888b  "888888
    88888H  :H888H: H88888   88888H :H888H:  H88888
    888888b "^YWWP /888888   888888\ YWWP^" d888888
    88888888be._.ad8888888._.8888888be._.ad88888888
    WW8888888888888888888888888888888888888888888WW
     '''"""^^YW8888888W888888888W8888888WY^^"""'''
    MWbozxae  8888888/  ._____.  \8888888  aexzodWM
    88888888  8MMHHWW;  8888888  :WWHHMM8  88888888
    'Y888888b.__       /8888888\       __.d888888Y'
     "V888888888MHWkjgd888888888bkpajWHM88888888V"
       '^Y88888888888888888888888888888888888P^'
          '"^VY8888888888888888888888888YV^"'
               '""^^^VY888888888VY^^^""'


        "If you don't ask the right questions,
                you don't get the right answers."
                                              ~ Robert Half
]]

chatgpt.setup({
    welcome_message = WELCOME_MESSAGE,
    question_sign = "❓",
    answer_sign = "🤖",
    session_window = {
        border = {
            highlight = "ChatGPTChatSessionBorder",
        },
        win_options = {
            winhighlight = "Normal:ChatGPTChatSessionNormal,FloatBorder:ChatGPTChatSessionBorder",
        },
    },
    chat_window = {
        border = {
            highlight = "ChatGPTChatWindowBorder",
            text = {
                top = " 🤖 ChatGPT ",
            },
        },
        win_options = {
            winhighlight = "Normal:ChatGPTChatWindowNormal,FloatBorder:ChatGPTChatWindowBorder",
        },
    },
    chat_input = {
        prompt = " > ",
        border = {
            highlight = "ChatGPTChatInputBorder",
        },
        win_options = {
            winhighlight = "Normal:ChatGPTChatInputNormal,FloatBorder:ChatGPTChatInputBorder",
        },
    },
    keymaps = {
        close = { "<C-c>" },
        submit = "<C-s>",
        new_session = "<C-m>",
    },
})

return chatgpt

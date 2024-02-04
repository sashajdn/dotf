local ok, mark = pcall(require, "harpoon.mark")
if not ok then
    return
end

local ok, ui = pcall(require, "harpoon.ui")
if not ok then
    return
end

local Remap = require("sasha.keymap")
local nnoremap = Remap.nnoremap

nnoremap("<leader>sa", function()
    mark.add_file()
end)

nnoremap("<leader>su", function()
    ui.toggle_quick_menu()
end)

nnoremap("<leader>sn", function()
    ui.nav_next()
end)

nnoremap("<leader>sp", function()
    ui.nav_prev()
end)

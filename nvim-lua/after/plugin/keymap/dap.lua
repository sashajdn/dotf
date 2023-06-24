local ok, dap = pcall(require, "dap")
if not ok then
    print("Failed to load `dap`")
    return
end

local ok, dapgo = pcall(require, "dap-go")
if not ok then
    print("Failed to load `dap-go`")
    return
end



local Remap = require("sasha.keymap")
local nnoremap = Remap.nnoremap
local inoremap = Remap.inoremap

-- Set keymappings.
nnoremap("<leader>db", function() dap.toggle_breakpoint() end)
nnoremap("<leader>dl", function() dapgo.debug_last() end)
nnoremap("<leader>dt", function() dapgo.debug_test() end)
nnoremap("<leader>dc", function() dap.continue() end)
nnoremap("<leader>do", function() dap.step_over() end)
nnoremap("<leader>dsi", function() dap.step_into() end)
nnoremap("<leader>dso", function() dap.step_out() end)
nnoremap("<leader>du", function()
    local widgets = require("dap.ui.widgets")
    local sidebar = widgets.sidebar(widgets.scopes)
    sidebar.open()
end)

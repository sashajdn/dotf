local ok, builtin = pcall(require, "telescope.builtin")
if not ok then
    return
end

local Remap = require("sasha.keymap")
local nnoremap = Remap.nnoremap

-- Default.
nnoremap("<leader>ft", "<cmd>Telescope")

-- Telescope file fuzzy finding.
-- <leader>f
nnoremap("<leader>ff", function()
    builtin.git_files()
end)

nnoremap("<leader>fg", function()
    builtin.live_grep()
end)

nnoremap("<leader>fb", function()
    builtin.buffers()
end)

nnoremap("<leader>fh", function()
    builtin.help_tags()
end)
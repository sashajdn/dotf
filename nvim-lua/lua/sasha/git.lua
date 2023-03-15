local ok, gitsigns = pcall(require, "gitsigns")
if not ok then
    return
end

local Remap = require("sasha.keymap")
local nnoremap = Remap.nnoremap

gitsigns.setup({
    on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        -- Actions.
        nnoremap("<leader>gb", function() gs.blame_line{full=true} end)
    end
})

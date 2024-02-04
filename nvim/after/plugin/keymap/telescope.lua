local ok, builtin = pcall(require, "telescope.builtin")
if not ok then
    return
end

local Remap = require("sasha.keymap")
local nnoremap = Remap.nnoremap

local function search_dotfiles()
    builtin.git_files({
        prompt_title = "< DotF 💻 >",
        cwd = "$HOME/dotf",
        hidden = true,
    })
end

local function search_wiki()
    builtin.git_files({
        prompt_title = "< Wiki 📚 >",
        cwd = "$WIKI",
        hidden = true,
    })
end
-- Default.
nnoremap("<leader>ft", "<cmd>Telescope<CR>")

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

nnoremap("<leader>fd", function()
    search_dotfiles()
end)

nnoremap("<leader>fw", function()
    search_wiki()
end)

nnoremap("<leader>e", "<cmd>Telescope emoji<CR>")

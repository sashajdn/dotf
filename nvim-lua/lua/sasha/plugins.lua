vim.cmd [[packadd packer.nvim]]

-- Use a protected call to validate that packer is indeed installed.
local status_ok, packer = pcall(require, 'packer')
if not status_ok then
    return
end

-- Set to use a pop window as opposed to a buffer.
packer.init {
    display = {
        open_fn = function()
            return require("packer.util").float { border = "rounded" }
        end,
    },
}

return require('packer').startup(function()
    -- Neovim package manager.
	use 'wbthomason/packer.nvim'

    -- Defaults & Boilerplate.
    use 'nvim-lua/popup.nvim'
    use 'nvim-lua/plenary.nvim'

    -- LSP.
    use("neovim/nvim-lspconfig") -- LSP configuration.
    use("onsails/lspkind-nvim") -- Pictograms.
    use("nvim-lua/lsp_extensions.nvim") -- LSP Lua extensions.
    use("glepnir/lspsaga.nvim") -- Further LSP extensions.

    -- Completion.
    use("hrsh7th/nvim-cmp") -- The completion plugin.
    use("hrsh7th/cmp-nvim-lsp") -- LSP completions .
    use("hrsh7th/cmp-buffer") -- Buffer completions.
    use("hrsh7th/cmp-path") -- Path completions.
    use("hrsh7th/cmp-cmdline") -- Commandline completions.
    use("hrsh7th/cmp-nvim-lua") -- Commandline completions.
    -- use("tzachar/cmp-tabnine", { run = "./install.sh" }) -- Tabnine completion.

    -- Snippets.
    use('L3MON4D3/LuaSnip') -- Snippet engine.
    use('saadparwaiz1/cmp_luasnip') -- Snippet completions.
    use('rafamadriz/friendly-snippets') -- Snippet collection.

    -- Treesitter.
    use("nvim-treesitter/nvim-treesitter", {
        run = ":TSUpdate"
    })

    -- Themes.
	use 'B4mbus/oxocarbon-lua.nvim'

	-- Colorizer.
	use 'norcalli/nvim-colorizer.lua'

    -- Golden ratio.
    use 'roman/golden-ratio'

    -- Undo.
    use("mbbill/undotree")
end)

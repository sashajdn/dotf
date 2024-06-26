vim.cmd [[packadd packer.nvim]]

-- Use a protected call to validate that packer is indeed installed.
local status_ok, packer = pcall(require, 'packer')
if not status_ok then
    return
end

local function is_copilot_enabled()
    return os.getenv("DOTF_COPILOT_ENABLED") == "1"
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

    -- Devicons.
    use({
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true }
    })

    -- LSP.
    use("neovim/nvim-lspconfig") -- LSP configuration.
    use("onsails/lspkind.nvim") -- Pictograms.
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
    use("nvim-treesitter/playground")

    -- Telescope.
    use("nvim-telescope/telescope.nvim")
    use("xiyaowong/telescope-emoji.nvim")

    -- Themes.
    use('sashajdn/oxocarbon.nvim')
    -- use('liuchengxu/space-vim-theme')

	-- Colorizer.
    use('norcalli/nvim-colorizer.lua')

    -- Golden ratio.
    use('roman/golden-ratio')

    -- Undo.
    use("mbbill/undotree")

    -- Git.
    use ("ThePrimeagen/git-worktree.nvim")
    use ("lewis6991/gitsigns.nvim")

    -- Harpoon.
    use ("ThePrimeagen/harpoon")

    -- ChatGPT.
    use("MunifTanjim/nui.nvim")
    use ("jackMort/ChatGPT.nvim")

    -- Noice.
    use("folke/noice.nvim")

    -- DAP.
    use('folke/neodev.nvim')
    use("mfussenegger/nvim-dap")
    use("jay-babu/mason-nvim-dap.nvim", {
        event = "VeryLazy",
        dependencies = {
            "williamboman/mason.nvim",
            "mfussenegger/nvim-dap",
        },
        opts = {
            handlers = {},
        },
    })
    use("leoluz/nvim-dap-go", {
        ft = "go",
        dependencies = "mfussenegger/nvim-dap",
    })
    use("nvim-telescope/telescope-dap.nvim")
    use("rcarriga/nvim-dap-ui", {
        event = "VeryLazy",
        dependencies = "mfussenegger/nvim-dap",
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")
            dapui.setup()
            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end
        end
    })

    -- Go.
    use("olexsmir/gopher.nvim", {
        ft = "go",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
    })

    -- Rust.
    use('simrat39/rust-tools.nvim', {
        ft = "rust",
        dependencies = {
            'neovim/nvim-lspconfig',
        },
    })

    -- Plugin manager.
    use("williamboman/mason.nvim", {
        opts = {
            ensure_installed = {
                "clangd",
                "clang-format",
                "codelldb",
                "rust-analyzer",
                "gopls",
                "nodejs",
            }
        }
    })

    -- Copilot
    if is_copilot_enabled() then
        use {
          "zbirenbaum/copilot.lua",
          cmd = "Copilot",
          event = "VimEnter",
          config = function()
              require("copilot").setup({
                  suggestion = { enabled = true },
                  panel = { enabled = true }
              })
          end
        }

        use {
            "zbirenbaum/copilot-cmp",
            after = { "copilot.lua" },
            config = function ()
                require("copilot_cmp").setup()
            end
        }
    end
end)

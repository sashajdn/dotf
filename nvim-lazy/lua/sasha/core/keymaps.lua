vim.g.mapleader = " "

local keymap = vim.keymap

-- Highlights.
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- Increment / decrement numbers.
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" })
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" })

-- Navigation.
keymap.set("n", "n", "nzzzv") -- keep centered going to next.
keymap.set("n", "N", "Nzzzv") -- keep centered going to previous.
keymap.set("n", "<C-u>", "<C-u>zz") -- keep centered moving half a page down.
keymap.set("n", "<C-d>", "<C-d>zz") -- keep centered moving half a page up.
keymap.set("n", "<C-o>", "<C-o>zz")
keymap.set("n", "<C-i>", "<C-i>zz")

-- Window management.
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" })
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" })
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" })
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" })
keymap.set("n", "<leader>h", "<cmd>wincmd h<CR>", { desc = "Move to the window on the left" })
keymap.set("n", "<leader>j", "<cmd>wincmd j<CR>", { desc = "Move to the window above" })
keymap.set("n", "<leader>k", "<cmd>wincmd k<CR>", { desc = "Move to the window below" })
keymap.set("n", "<leader>l", "<cmd>wincmd l<CR>", { desc = "Move to the window on the right" })

-- Tab management.
keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" })
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" })
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })

-- Tmux.
keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>", { desc = "Tmux Sessionizer" })

-- Visual mode.
keymap.set("v", "<", "<gv") -- keep block selection when indenting
keymap.set("v", ">", ">gv") -- keep block selecting when indenting
keymap.set("v", "K", ":m '<-2<CR>gv=gv") -- keep indentation when moving up.
keymap.set("v", "J", ":m '>+1<CR>gv=g") -- keep indentation when moving down.

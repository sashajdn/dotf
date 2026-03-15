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

-- Quickfix navigation.
keymap.set("n", "]q", "<cmd>cnext<CR>zz", { desc = "Next quickfix item" })
keymap.set("n", "[q", "<cmd>cprev<CR>zz", { desc = "Previous quickfix item" })
keymap.set("n", "]Q", "<cmd>clast<CR>zz", { desc = "Last quickfix item" })
keymap.set("n", "[Q", "<cmd>cfirst<CR>zz", { desc = "First quickfix item" })

-- Claude Code.
local function get_claude_pane()
  local session = vim.fn.system("tmux display-message -p '#{session_name}'"):gsub("%s+", "")
  local pane_file = "/tmp/tmux-claude-" .. session
  local ok, lines = pcall(vim.fn.readfile, pane_file)
  if ok and #lines > 0 then
    return lines[1]
  end
  return nil
end

local function open_claude_pane()
  local file = vim.fn.expand("%:p")
  vim.cmd("silent !tmux-claude-toggle " .. vim.fn.shellescape(file))
end

local function send_to_claude(text, ensure_open)
  if not get_claude_pane() then
    if not ensure_open then return end
    open_claude_pane()
    -- Delay paste to let Claude boot.
    vim.defer_fn(function()
      send_to_claude(text, false)
    end, 2000)
    return
  end
  local tmpfile = "/tmp/tmux-claude-send"
  local f = io.open(tmpfile, "w")
  f:write(text)
  f:close()
  vim.fn.system("tmux load-buffer " .. tmpfile)
  vim.fn.system("tmux paste-buffer -t " .. get_claude_pane())
end

keymap.set("n", "<leader>cc", open_claude_pane, { desc = "Toggle Claude Code" })

keymap.set("v", "<leader>cs", function()
  local start_line = vim.fn.line("v")
  local end_line = vim.fn.line(".")
  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local file = vim.fn.expand("%:p")
  local ft = vim.bo.filetype
  local msg = string.format("`%s:%d-%d`:\n```%s\n%s\n```\n", file, start_line, end_line, ft, table.concat(lines, "\n"))
  send_to_claude(msg, true)
end, { desc = "Send selection to Claude" })

local claude_context_timer = vim.uv.new_timer()
local claude_last_file = nil

vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("ClaudeBufferContext", {}),
  callback = function()
    local file = vim.fn.expand("%:p")
    if file == "" or file == claude_last_file then return end
    if not vim.bo.buflisted or vim.bo.buftype ~= "" then return end
    if not get_claude_pane() then return end

    claude_context_timer:stop()
    claude_context_timer:start(10000, 0, vim.schedule_wrap(function()
      claude_last_file = file

      local bufs = {}
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted and vim.bo[buf].buftype == "" then
          local name = vim.api.nvim_buf_get_name(buf)
          if name ~= "" then
            table.insert(bufs, name)
          end
        end
      end

      local session = vim.fn.system("tmux display-message -p '#{session_name}'"):gsub("%s+", "")
      local ctx_file = "/tmp/claude-nvim-context-" .. session
      local ctx = io.open(ctx_file, "w")
      ctx:write(string.format("current_buffer: %s\nopen_buffers:\n%s\n", file, table.concat(bufs, "\n")))
      ctx:close()
    end))
  end,
})

-- Tmux.
keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>", { desc = "Tmux Sessionizer" })
keymap.set("n", "<C-t>", "<cmd>silent !bash tmux-lhs-terminal<CR>", { desc = "Tmux Toggle LHS Terminal" })

-- Visual mode.
keymap.set("v", "<", "<gv") -- keep block selection when indenting
keymap.set("v", ">", ">gv") -- keep block selecting when indenting
keymap.set("v", "K", ":m '<-2<CR>gv=gv") -- keep indentation when moving up.
keymap.set("v", "J", ":m '>+1<CR>gv=gv") -- keep indentation when moving down.

-- Highlights.
local last_match_id = nil

function ToggleWordHighlight()
  if last_match_id then
    vim.fn.matchdelete(last_match_id)
    last_match_id = nil
  else
    local word = vim.fn.expand("<cword>")
    if word == "" then
      return
    end
    -- Use very nomagic mode (\V) so the word is taken literally.
    local pattern = "\\V" .. vim.fn.escape(word, "\\")
    -- Priority of 10 (adjust if needed); using "Search" highlight group.
    last_match_id = vim.fn.matchadd("StarWordHighlight", pattern, 10)
  end
end

keymap.set("n", "*", "<cmd>lua ToggleWordHighlight()<CR>", { desc = "Toggle word highlight" })

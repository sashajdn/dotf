local keymap = vim.keymap

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

-- Toggle.
keymap.set("n", "<leader>cc", open_claude_pane, { desc = "Toggle Claude Code" })

-- Send selection.
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

-- Auto buffer context (debounced, written to file for passive consumption).
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

local augroup = vim.api.nvim_create_augroup
local SashaCoreGroup = augroup("SashaCore", {})

local autocmd = vim.api.nvim_create_autocmd
local yank_group = augroup("HighlightYank", {})

-- Highlight yank for short period.
autocmd("TextYankPost", {
  group = yank_group,
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({
      higroup = "IncSearch",
      timeout = 40,
    })
  end,
})

-- Remove trailing whitespace on save.
autocmd({ "BufWritePre" }, {
  group = SashaCoreGroup,
  pattern = "*",
  command = "%s/\\s\\+$//e",
})

-- Stops inserting comments after entering a newline with the previous line commented.
autocmd("BufEnter", {
  callback = function()
    vim.opt.formatoptions = vim.opt.formatoptions - { "c", "r", "o" }
  end,
})

autocmd({ "LspAttach" }, {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    client.server_capabilities.semanticTokensProvider = nil
  end,
})

--- ### Go ### ---
local GoGroup = augroup("GoGroup", {})

autocmd("BufWritePre", {
  group = GoGroup,
  pattern = "*.go",
  callback = function()
    -- Organize imports on save.
    local params = vim.lsp.util.make_range_params()
    params.contex = { only = { "source.organizeImports" } }
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 300)
    for cid, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
          vim.lsp.util.apply_workspace_edit(r.edit, enc)
        end
      end
    end

    -- Golang format on save.
    vim.lsp.buf.format()
  end,
})

-- ### Python ### ---
local PythonGroup = augroup("PythonGroup", {})

--- Format on save.
autocmd("BufWritePre", {
  group = PythonGroup,
  pattern = "*.py",
  callback = function()
    vim.lsp.buf.format()
  end,
})

autocmd("FileType", {
  group = PythonGroup,
  pattern = "python",
  callback = function()
    -- vim.bo.tabstop = 2
    -- vim.bo.softtabstop = 2
    -- vim.bo.shiftwidth = 2
    -- vim.bo.expandtab = true
  end,
})

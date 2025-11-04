-- Bridge Neovim 0.10's stricter LSP position encoding requirements.
local util = vim.lsp and vim.lsp.util or nil

if not util or not util.make_position_params then
  return
end

local native_make_position_params = util.make_position_params

local function resolve_offset_encoding(bufnr, offset_encoding)
  if offset_encoding then
    return offset_encoding
  end

  bufnr = bufnr or vim.api.nvim_get_current_buf()

  for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    local encoding = client.offset_encoding
      or (client.config and client.config.offset_encoding)
      or (client.capabilities and client.capabilities.offsetEncoding and client.capabilities.offsetEncoding[1])

    if encoding then
      return encoding
    end
  end

  return "utf-16"
end

util.make_position_params = function(bufnr, offset_encoding, position)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  offset_encoding = resolve_offset_encoding(bufnr, offset_encoding)

  return native_make_position_params(bufnr, offset_encoding, position)
end

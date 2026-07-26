local M = {}

local function normalize_path(path)
  if path == nil or path == "" then
    return path
  end

  if vim.startswith(path, "file://") then
    path = vim.uri_to_fname(path)
  end

  return vim.fs.normalize(path)
end

local function is_absolute(path)
  return path:sub(1, 1) == "/" or path:match("^%a:[/\\]") ~= nil
end

local function absolute_path(path)
  path = normalize_path(path)
  if path == nil or path == "" then
    return path
  end

  if is_absolute(path) then
    return path
  end

  return normalize_path(vim.fn.fnamemodify(path, ":p"))
end

local function terminal_path_components(path, max_components)
  local parts = vim.split(path, "/", { plain = true, trimempty = true })
  if #parts <= max_components then
    return path
  end

  return table.concat(vim.list_slice(parts, #parts - max_components + 1, #parts), "/")
end

local function compact_reference_path(_, path)
  local absolute = absolute_path(path)
  if absolute == nil or absolute == "" then
    return path
  end

  local root = vim.fs.root(absolute, ".git")
  if root ~= nil then
    root = normalize_path(root)
    local prefix = root .. "/"
    if vim.startswith(absolute, prefix) then
      return terminal_path_components(absolute:sub(#prefix + 1), 3)
    end
  end

  return terminal_path_components(vim.fn.fnamemodify(absolute, ":~:."), 3)
end

function M.references()
  require("telescope.builtin").lsp_references({
    path_display = compact_reference_path,
    show_line = false,
    trim_text = true,
  })
end

return M

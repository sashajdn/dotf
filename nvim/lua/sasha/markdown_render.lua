local M = {}

local state = {}

local palette = {
  bg = "#161616",
  bg_alt = "#1c1c1c",
  surface = "#262626",
  surface_2 = "#393939",
  fg = "#f2f4f8",
  muted = "#c3ccdc",
  gutter = "#525252",
  cyan = "#82cfff",
  teal = "#3ddbd9",
}

local window_options = {
  "breakindent",
  "colorcolumn",
  "concealcursor",
  "conceallevel",
  "cursorline",
  "linebreak",
  "number",
  "relativenumber",
  "signcolumn",
  "showbreak",
  "wrap",
  "winhighlight",
}

local function hl(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

function M.setup_highlights()
  hl("MarkdownRenderNormal", { bg = palette.bg, fg = palette.fg })
  hl("MarkdownRenderNormalNC", { bg = palette.bg, fg = palette.muted })
  hl("MarkdownRenderSignColumn", { bg = palette.bg, fg = palette.gutter })
  hl("MarkdownRenderEndOfBuffer", { bg = palette.bg, fg = palette.bg })
  hl("MarkdownRenderLineNr", { bg = palette.bg, fg = palette.gutter })
  hl("MarkdownRenderCursorLine", { bg = palette.bg_alt })
  hl("MarkdownRenderCursorLineNr", { bg = palette.bg_alt, fg = palette.cyan, bold = true })
  hl("MarkdownRenderColorColumn", { bg = palette.bg })
  hl("MarkdownRenderFoldColumn", { bg = palette.bg, fg = palette.gutter })

  hl("RenderMarkdownH1", { fg = palette.fg, bold = true })
  hl("RenderMarkdownH2", { fg = palette.fg, bold = true })
  hl("RenderMarkdownH3", { fg = palette.fg, bold = true })
  hl("RenderMarkdownH4", { fg = palette.fg, bold = true })
  hl("RenderMarkdownH5", { fg = palette.fg, bold = true })
  hl("RenderMarkdownH6", { fg = palette.fg, bold = true })
  hl("RenderMarkdownH1Bg", { bg = palette.bg, fg = palette.fg, bold = true })
  hl("RenderMarkdownH2Bg", { bg = palette.bg, fg = palette.fg, bold = true })
  hl("RenderMarkdownH3Bg", { bg = palette.bg, fg = palette.fg, bold = true })
  hl("RenderMarkdownH4Bg", { bg = palette.bg, fg = palette.fg, bold = true })
  hl("RenderMarkdownH5Bg", { bg = palette.bg, fg = palette.fg, bold = true })
  hl("RenderMarkdownH6Bg", { bg = palette.bg, fg = palette.fg, bold = true })

  hl("RenderMarkdownCode", { bg = palette.surface, fg = palette.fg })
  hl("RenderMarkdownCodeInfo", { bg = palette.surface, fg = palette.teal, italic = true })
  hl("RenderMarkdownCodeBorder", { bg = palette.surface, fg = palette.surface_2 })
  hl("RenderMarkdownCodeFallback", { bg = palette.surface, fg = palette.cyan })
  hl("RenderMarkdownCodeInline", { bg = palette.surface, fg = palette.cyan })
  hl("RenderMarkdownDash", { fg = palette.gutter })
  hl("RenderMarkdownBullet", { fg = palette.muted })
  hl("RenderMarkdownQuote", { fg = palette.muted })
  hl("RenderMarkdownQuote1", { fg = palette.muted })
  hl("RenderMarkdownQuote2", { fg = palette.muted })
  hl("RenderMarkdownQuote3", { fg = palette.muted })
  hl("RenderMarkdownTableHead", { bg = palette.bg, fg = palette.fg, bold = true })
  hl("RenderMarkdownTableRow", { bg = palette.bg, fg = palette.muted })
  hl("RenderMarkdownUnchecked", { fg = palette.gutter })
  hl("RenderMarkdownChecked", { fg = palette.teal })
  hl("RenderMarkdownTodo", { fg = palette.muted })
  hl("RenderMarkdownLink", { fg = palette.muted, underline = true })
  hl("RenderMarkdownWikiLink", { fg = palette.muted, underline = true })
  hl("RenderMarkdownInlineHighlight", { bg = palette.surface_2, fg = palette.fg })
  hl("RenderMarkdownMath", { fg = palette.muted })
  hl("RenderMarkdownInfo", { fg = palette.muted })
  hl("RenderMarkdownSuccess", { fg = palette.teal })
  hl("RenderMarkdownHint", { fg = palette.muted })
  hl("RenderMarkdownWarn", { fg = palette.muted })
  hl("RenderMarkdownError", { fg = palette.muted })
end

local function merge_winhighlight(existing, overrides)
  local merged = {}
  local order = {}

  for item in string.gmatch(existing or "", "([^,]+)") do
    local from, to = item:match("^%s*([^:]+):([^:]+)%s*$")
    if from and to then
      merged[from] = to
      table.insert(order, from)
    end
  end

  for from, to in pairs(overrides) do
    if merged[from] == nil then
      table.insert(order, from)
    end
    merged[from] = to
  end

  local parts = {}
  for _, from in ipairs(order) do
    table.insert(parts, ("%s:%s"):format(from, merged[from]))
  end

  return table.concat(parts, ",")
end

local function save_window(win)
  if state[win] then
    return
  end

  state[win] = {}
  for _, option in ipairs(window_options) do
    state[win][option] = vim.wo[win][option]
  end
end

local function apply_window(win)
  save_window(win)

  vim.wo[win].wrap = true
  vim.wo[win].linebreak = true
  vim.wo[win].breakindent = true
  vim.wo[win].showbreak = "  "
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].cursorline = false
  vim.wo[win].colorcolumn = ""
  vim.wo[win].signcolumn = "no"
  vim.wo[win].conceallevel = 3
  vim.wo[win].concealcursor = ""
  vim.wo[win].winhighlight = merge_winhighlight(vim.wo[win].winhighlight, {
    Normal = "MarkdownRenderNormal",
    NormalNC = "MarkdownRenderNormalNC",
    SignColumn = "MarkdownRenderSignColumn",
    EndOfBuffer = "MarkdownRenderEndOfBuffer",
    LineNr = "MarkdownRenderLineNr",
    CursorLine = "MarkdownRenderCursorLine",
    CursorLineNr = "MarkdownRenderCursorLineNr",
    FoldColumn = "MarkdownRenderFoldColumn",
    ColorColumn = "MarkdownRenderColorColumn",
  })
end

local function restore_window(win)
  local saved = state[win]
  if not saved or not vim.api.nvim_win_is_valid(win) then
    state[win] = nil
    return
  end

  for option, value in pairs(saved) do
    vim.wo[win][option] = value
  end
  state[win] = nil
end

local function is_markdown(buf)
  local ft = vim.bo[buf].filetype
  return ft == "markdown" or ft == "quarto" or ft == "rmd"
end

function M.enable()
  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()

  if not is_markdown(buf) then
    vim.notify("Markdown render is only available in Markdown buffers", vim.log.levels.WARN)
    return
  end

  M.setup_highlights()
  apply_window(win)

  local render = require("render-markdown")
  render.buf_enable()
  render.render({ buf = buf, win = win, event = "SashaMarkdownRender" })

  vim.b[buf].sasha_markdown_render_enabled = true
end

function M.disable()
  local buf = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()

  pcall(function()
    require("render-markdown").buf_disable()
  end)

  restore_window(win)
  vim.b[buf].sasha_markdown_render_enabled = false
end

function M.toggle()
  local buf = vim.api.nvim_get_current_buf()
  if vim.b[buf].sasha_markdown_render_enabled then
    M.disable()
  else
    M.enable()
  end
end

function M.restore_all()
  for win in pairs(state) do
    restore_window(win)
  end
end

return M

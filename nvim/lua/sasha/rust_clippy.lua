-- On-demand `cargo clippy` for the current buffer's target.
--
-- Detects whether the file is a bin/main/lib/integration-test/example/bench
-- and runs `cargo clippy` with the narrowest target flags that still include
-- inline tests. Results are streamed into the quickfix list so jumps work
-- with :cnext / :cprev / :copen.

local M = {}

local function find_manifest(start)
  local matches = vim.fs.find({ "Cargo.toml" }, { path = start, upward = true, limit = 1 })
  return matches[1]
end

local function detect_target_args(rel)
  local m

  m = rel:match("^examples/(.+)%.rs$")
  if m then return { "--example", m } end

  m = rel:match("^benches/(.+)%.rs$")
  if m then return { "--bench", m } end

  m = rel:match("^tests/(.+)%.rs$")
  if m then return { "--test", m } end

  m = rel:match("^src/bin/(.+)%.rs$")
  if m then return { "--bin", m, "--tests" } end

  if rel == "src/main.rs" then
    return { "--bins", "--tests" }
  end

  if rel:match("^src/") then
    return { "--lib", "--tests" }
  end

  return { "--all-targets" }
end

local function parse_short(line, pkg_root)
  local path, lnum, col, rest = line:match("^([^:]+):(%d+):(%d+):%s*(.*)$")
  if not path then
    return nil
  end

  local abs = path
  if not vim.startswith(abs, "/") then
    abs = pkg_root .. "/" .. path
  end

  local ty = "E"
  local lower = rest:lower()
  if lower:match("^warning") then
    ty = "W"
  elseif lower:match("^note") or lower:match("^help") then
    ty = "I"
  end

  return {
    filename = abs,
    lnum = tonumber(lnum),
    col = tonumber(col),
    text = rest,
    type = ty,
  }
end

local function build_items(text, pkg_root)
  local items = {}
  for line in text:gmatch("[^\r\n]+") do
    local item = parse_short(line, pkg_root)
    if item then
      table.insert(items, item)
    end
  end
  return items
end

function M.run()
  if vim.bo.filetype ~= "rust" then
    vim.notify("rust clippy: not a rust buffer", vim.log.levels.WARN)
    return
  end

  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("rust clippy: buffer has no name", vim.log.levels.WARN)
    return
  end

  local manifest = find_manifest(file)
  if not manifest then
    vim.notify("rust clippy: no Cargo.toml found", vim.log.levels.WARN)
    return
  end

  local pkg_root = vim.fs.dirname(manifest)
  local rel = file:sub(#pkg_root + 2)
  local target_args = detect_target_args(rel)

  local cmd = {
    "cargo",
    "clippy",
    "--manifest-path",
    manifest,
    "--message-format=short",
    "--color=never",
    "--no-deps",
    "-q",
  }
  vim.list_extend(cmd, target_args)

  local title = "cargo clippy " .. table.concat(target_args, " ")
  vim.fn.setqflist({}, " ", { title = title, items = {} })
  vim.notify(title, vim.log.levels.INFO)

  vim.system(cmd, { text = true, cwd = pkg_root }, function(obj)
    vim.schedule(function()
      local out = (obj.stdout or "") .. "\n" .. (obj.stderr or "")
      local items = build_items(out, pkg_root)

      vim.fn.setqflist({}, " ", { title = title, items = items })

      local errors, warnings = 0, 0
      for _, it in ipairs(items) do
        if it.type == "E" then
          errors = errors + 1
        elseif it.type == "W" then
          warnings = warnings + 1
        end
      end

      if #items > 0 then
        vim.cmd("botright copen")
        vim.cmd("wincmd p")
        vim.notify(
          string.format("rust clippy: %d errors, %d warnings", errors, warnings),
          errors > 0 and vim.log.levels.ERROR or vim.log.levels.WARN
        )
      else
        vim.cmd("cclose")
        if obj.code ~= 0 then
          vim.notify("rust clippy: failed (exit " .. obj.code .. "), no parseable diagnostics", vim.log.levels.ERROR)
        else
          vim.notify("rust clippy: clean", vim.log.levels.INFO)
        end
      end
    end)
  end)
end

return M

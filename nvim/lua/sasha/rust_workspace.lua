local M = {}

local cache_dir = vim.fn.stdpath("cache") .. "/ra-linked-projects"
local script_path = vim.fn.stdpath("config") .. "/scripts/ra_prune_workspace.py"
local linked_cache = {}

local function rustc_host()
  local output = vim.fn.systemlist({ "rustc", "-vV" })
  if vim.v.shell_error ~= 0 then
    return nil
  end
  for _, line in ipairs(output) do
    local host = line:match("^host:%s*(.+)$")
    if host then
      return vim.trim(host)
    end
  end
  return nil
end

local function find_manifest(root_dir)
  local matches = vim.fs.find({ "Cargo.toml" }, { path = root_dir, upward = true, limit = 1 })
  if #matches > 0 then
    return matches[1]
  end
  return nil
end

local function generate_linked_project(manifest_path)
  if vim.fn.filereadable(script_path) == 0 then
    vim.notify("rust-analyzer linked project script missing: " .. script_path, vim.log.levels.WARN)
    return nil
  end

  local cmd = { "python3", script_path, "--manifest-path", manifest_path, "--out-dir", cache_dir }
  local host_target = rustc_host()
  if host_target then
    table.insert(cmd, "--filter-platform")
    table.insert(cmd, host_target)
  end
  table.insert(cmd, "--skip-sysroot-src")
  local output = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    vim.notify("rust-analyzer linked project generation failed: " .. vim.trim(output), vim.log.levels.WARN)
    return nil
  end

  local linked = vim.trim(output)
  if linked == "" then
    return nil
  end
  return linked
end

function M.on_new_config(new_config, root_dir)
  local manifest_path = find_manifest(root_dir)
  if not manifest_path then
    return
  end

  local linked = linked_cache[manifest_path]
  if not linked then
    linked = generate_linked_project(manifest_path)
    if not linked then
      return
    end
    linked_cache[manifest_path] = linked
  end

  new_config.settings = new_config.settings or {}
  new_config.settings["rust-analyzer"] = new_config.settings["rust-analyzer"] or {}
  new_config.settings["rust-analyzer"].cargo = new_config.settings["rust-analyzer"].cargo or {}
  if new_config.settings["rust-analyzer"].cargo.target == nil then
    new_config.settings["rust-analyzer"].cargo.target = rustc_host()
  end
  new_config.settings["rust-analyzer"].linkedProjects = { linked }
end

return M

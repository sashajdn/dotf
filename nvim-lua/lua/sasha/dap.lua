local ok, dap = pcall(require, "dap")
if not ok then
    print("Failed to load `dap`")
    return
end

local ok, dap_go = pcall(require, "dap-go")
if not ok then
    print("Failed to load `dap-go`")
    return
end


local function config(_config)
    return vim.tbl_deep_extend("force", {
        on_attach = function()
        end
    }, _config or {})
end

dap_go.setup(config())

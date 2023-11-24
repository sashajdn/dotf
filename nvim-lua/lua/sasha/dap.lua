local dap_ok, dap = pcall(require, "dap")
if not dap_ok then
    return
end

local dap_go = require("dap-go")

-- Set signs.
vim.fn.sign_define('DapBreakpoint', {text='✋', texthl='', linehl='', numhl=''})
vim.fn.sign_define('DapStopped', {text='✅', texthl='', linehl='', numhl=''})
vim.fn.sign_define('DapBreakpointRejected', {text='🙅', texthl='', linehl='', numhl=''})

-- Go.
dap_go.setup({
  dap_configurations = {
    {
      -- Must be "go" or it will be ignored by the plugin.
      type = "go",
      name = "Attach remote",
      mode = "remote",
      request = "attach",
    },
  },
  delve = {
    -- The path to the executable dlv which will be used for debugging
    -- by default, this is the "dlv" executable on your PATH.
    path = "dlv",
    -- Time to wait for delve to initialize the debug session.
    -- default to 20 seconds
    initialize_timeout_sec = 20,
    -- a string that defines the port to start delve debugger.
    -- default to string "${port}" which instructs nvim-dap
    -- to start the process in a random available port
    port = "${port}",
    -- additional args to pass to dlv
    args = {}
  },
})

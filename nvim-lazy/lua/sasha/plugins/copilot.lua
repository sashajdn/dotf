local function is_copilot_enabled()
  return os.getenv("DOTF_COPILOT_ENABLED") == "1"
end

if not is_copilot_enabled() then
  return {}
end

return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = { enabled = true },
        panel = { enabled = true },
      })
    end,
  },
  {
    "zbirenbaum/copilot-cmp",
    config = function()
      require("copilot_cmp").setup()
    end,
  },
}

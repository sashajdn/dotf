local status_ok, treesitter_config = pcall(require, "nvim-treesitter.configs")
if not status_ok then
    return
end

treesitter_config.setup{
    ensure_installed = "all",
    ignore_install = { "phpdoc" }, -- This is marked as experimental & is failing.
    sync_install = false,
    auto_install = true,
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
    },
}

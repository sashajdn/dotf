local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",  -- latest stable branch
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("sasha.plugins", {
  checker = {
    enabled = true,
    notify = false,
  },

  change_detection = {
    notify = false,
  },
})

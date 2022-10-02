vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function()
	use 'wbthomason/packer.nvim'
	use 'B4mbus/oxocarbon-lua.nvim'
end)

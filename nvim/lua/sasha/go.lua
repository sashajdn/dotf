local ok, gopher = pcall(require, "gopher")
if not ok then
	return
end

gopher.setup({
	commands = {
		go = "go",
		gomodifytags = "gomodifytags",
		gotests = "~/go/bin/gotests",
		impl = "impl",
		iferr = "iferr",
	},
})

local cmp_status_ok, cmp = pcall(require, "cmp")
if not cmp_status_ok then
    print("No cmp...")
    return
end

local snip_status_ok, snip = pcall(require, "luasnip")
if not snip_status_ok then
    print("No snip...")
    return
end

require("luasnip/loaders/from_vscode").lazy_load()

cmp.setup({
    snippet = {
        expand = function(args)
            snip.lsp_expand(args.body)
        end,
    },

    sources = {
        -- { name = "cmp_tabnine" }, TODO
        { name = "luasnip" },
        { name = "buffer" },
        { name = "path" },
    },

    mapping = {
        ["<CR>"] = cmp.mapping.confirm { select = true },
    }
})

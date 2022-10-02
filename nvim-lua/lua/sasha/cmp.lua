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
    -- Setup.
    snippet = {
        expand = function(args)
            snip.lsp_expand(args.body)
        end,
    },

    -- Sources of which to pull from, sorted by priority.
    sources = {
        -- { name = "cmp_tabnine" }, TODO
        { name = "luasnip" },
        { name = "buffer" },
        { name = "path" },
    },

    -- Keymappings.
    mapping = {
        ["<CR>"] = cmp.mapping.confirm { select = true },
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip() then
                luasnip.expand()
            else fallback()
            end
        end, {
            "i",
            "s",
        }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, {
            "i",
            "s",
        }),
    },

    -- Confirm options.
    confirm_opts = {
        behavior = cmp.ConfirmBehavior.Replace,
        select = false,
    },

    -- Documentation window.
    window = {
        documentation = {
          border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
        },
    },
})

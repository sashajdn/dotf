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

local lspkind = require("lspkind")

local source_mapping = {
    nvim_lsp = "[LSP]",
    buffer = "[BUF]",
    nvim_lua = "[LUA]",
    path = "[PATH]",
    copilot = "[COP]"
}

cmp.setup({
    -- TODO: is this correct?
    -- This is to remove the random slection on pre select.
    preselect = cmp.PreselectMode.None,
    completion = { completeopt = "noselect" },

    -- Setup.
    snippet = {
        expand = function(args)
            snip.lsp_expand(args.body)
        end,
    },

    -- Sources of which to pull from, sorted by priority.
    sources = {
        -- { name = "cmp_tabnine" }, TODO
        { name = "nvim_lsp"},
        { name = "luasnip" },
        { name = "buffer" },
        { name = "path" },
        { name = "copilot" },
    },

    -- Keymappings.
    mapping = {
        ["<CR>"] = cmp.mapping.confirm { select = true },

        -- Move down in the selection.
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
        ["<Down>"] = cmp.mapping(function(fallback)
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

        -- Move up in the selection.
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
        ["<Up>"] = cmp.mapping(function(fallback)
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

    formatting = {
        format = function(entry, vim_item)
            -- vim_item.kind = lspkind.presets.default[vim_item.kind]
            local menu = source_mapping[entry.source.name]
            vim_item.menu = menu
            return vim_item
        end,
    },
})

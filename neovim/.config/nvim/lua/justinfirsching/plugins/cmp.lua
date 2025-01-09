return {
    'hrsh7th/nvim-cmp',             -- Autocompletion
    dependencies = {
        'hrsh7th/cmp-nvim-lsp',     -- LSP Autocompletion
        'hrsh7th/cmp-buffer',       -- Buffer Autocompletion
        'saadparwaiz1/cmp_luasnip', -- Snippet Autocompletion
        'zbirenbaum/copilot-cmp',   -- Copilot Completions
    },
    config = function()
        local cmp = require('cmp')
        cmp.setup({
            snippet = {
                expand = function(args)
                    require('luasnip').lsp_expand(args.body)
                end,
            },
            mapping = {
                ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
                ['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
                ['<C-d>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                ['<CR>'] = cmp.mapping.confirm({ select = false }),
                ['<Tab>'] = cmp.mapping.confirm({ select = true }),
            },
            completion = {
                completeopt = 'menu,menuone,noselect,noinsert,preview',
            },
            sources = {
                { name = 'nvim_lsp' },
                { name = 'luasnip' },
                { name = 'buffer' },
                { name = 'copilot' },
            },
        })
    end
}

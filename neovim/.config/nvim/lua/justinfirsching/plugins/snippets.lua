return {
    'L3MON4D3/LuaSnip', -- Snippets
    version = "v2.*",
    build = "make install_jsregexp",
    dependencies = {
        'rafamadriz/friendly-snippets', -- Snippet Collection
    },
    config = function()
        require("luasnip.loaders.from_vscode").lazy_load()
    end
}

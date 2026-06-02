return {
    "seblj/roslyn.nvim",
    dependencies = {
        "mason-org/mason-lspconfig.nvim",
    },
    ft = "cs",
    init = function()
        vim.lsp.config("roslyn", {
            handlers = {
                ["razor/provideDynamicFileInfo"] = function()
                    return vim.NIL
                end,
            },
        })
    end,
    opts = {
        lock_target = true,
    },
}

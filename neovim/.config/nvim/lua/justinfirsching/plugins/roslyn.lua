return {
    "seblyng/roslyn.nvim",
    dependencies = {
        "mason-org/mason.nvim",
    },
    init = function()
        vim.lsp.config("roslyn", {
            handlers = {
                ["razor/provideDynamicFileInfo"] = function()
                    return vim.NIL
                end,
            },
        })
    end,
}

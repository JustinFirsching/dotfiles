local function patch_open_floating_preview()
    if vim.g.justinfirsching_lsp_float_ui_patched then
        return
    end

    local open_floating_preview = vim.lsp.util.open_floating_preview

    vim.lsp.util.open_floating_preview = function(contents, syntax, opts, ...)
        local bufnr, winid = open_floating_preview(contents, syntax, opts, ...)

        if winid then
            vim.wo[winid].statusline = ""
            vim.wo[winid].winbar = ""

            if vim.bo[bufnr].filetype == "markdown" then
                vim.wo[winid].concealcursor = "n"
            end
        end

        return bufnr, winid
    end

    vim.g.justinfirsching_lsp_float_ui_patched = true
end

return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        patch_open_floating_preview()
        vim.lsp.enable({
            "bashls",
            "basedpyright",
            "bicep",
            "biome",
            "gopls",
            "lua_ls",
        })
    end,
}

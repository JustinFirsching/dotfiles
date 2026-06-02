local M = {}

M.diagnostic_float = {
    border = "rounded",
    source = "if_many",
    header = "",
    prefix = "",
}

M.hover = {
    border = "rounded",
    max_width = 100,
    max_height = 30,
}

M.signature_help = {
    border = "rounded",
    max_width = 100,
    max_height = 20,
}

function M.with_handler_opts(handler, handler_opts)
    return function(err, result, ctx, config)
        local merged_config = vim.tbl_deep_extend("force", handler_opts, config or {})
        return handler(err, result, ctx, merged_config)
    end
end

function M.patch_open_floating_preview()
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

return M

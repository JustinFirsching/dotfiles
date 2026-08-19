local M = {}

M.diagnostic_float = {
    border = "rounded",
    source = "if_many",
    header = "",
    prefix = "",
}

M.hover = {
    border = "rounded",
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

return M

local has_conform, conform = pcall(require, 'conform')
if not has_conform then
    return nil
end

conform.setup({
    formatters_by_ft = {
        css = { "prettier" },
        html = { "prettier" },
        javascript = { "prettier" },
        json = { "prettier" },
        jsx = { "prettier" },
        markdown = { "prettier" },
        python = { "isort", "black" },
        typescript = { "prettier" },
        yaml = { "prettier" },
    },
    default_format_opts = {
        lsp_format = true,
    }
})

vim.keymap.set("n", "<leader>f", conform.format, { noremap = true, silent = true })

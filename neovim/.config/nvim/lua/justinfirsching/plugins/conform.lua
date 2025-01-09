return {
    'stevearc/conform.nvim', -- Formatters
    config = function()
        local conform = require('conform')
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

        -- Format File
        vim.keymap.set("n", "<leader>f", require('conform').format, { noremap = true, silent = true })
    end
}

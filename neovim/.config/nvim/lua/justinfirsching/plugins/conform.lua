return {
    'stevearc/conform.nvim', -- Formatters
    config = function()
        local conform = require('conform')
        conform.setup({
            formatters_by_ft = {
                css = { "prettierd" },
                html = { "prettierd" },
                javascript = { "prettierd" },
                json = { "prettierd" },
                jsx = { "prettierd" },
                markdown = { "prettierd" },
                python = { "isort", "black" },
                typescript = { "prettierd" },
                yaml = { "prettierd" },
            },
            default_format_opts = {
                lsp_format = true,
            }
        })

        -- Format File
        vim.keymap.set("n", "<leader>f", require('conform').format, { noremap = true, silent = true })
    end
}

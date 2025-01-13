return {
    'mfussenegger/nvim-lint', -- Linters
    config = function()
        local lint = require('lint')
        lint.linters_by_ft = {
            go = { 'golangcilint', },
            json = { 'jsonlint', },
            yaml = { 'yamllint', },
            markdown = { 'markdownlint', },
        }

        -- Run linter when changing windows
        vim.api.nvim_create_autocmd({ 'BufEnter', 'InsertLeave', 'TextChanged', 'BufWritePost' }, {
            callback = function()
                if vim.bo.buftype ~= "nofile" then
                    lint.try_lint()
                end
            end,
        })
    end
}

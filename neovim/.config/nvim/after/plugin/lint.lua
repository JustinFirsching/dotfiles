vim.api.nvim_create_autocmd({ 'BufEnter', 'InsertLeave', 'TextChanged', 'BufWritePost' }, {
    callback = function()
        require('lint').try_lint()
    end,
})

require('lint').linters_by_ft = {
    go = { 'golangcilint', },
    json = { 'jsonlint', },
    yaml = { 'yamllint', },
    markdown = { 'markdownlint', },
}

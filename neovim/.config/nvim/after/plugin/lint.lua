local has_lint, lint = pcall(require, 'lint')
if not has_lint then
    return
end

vim.api.nvim_create_autocmd({ 'BufEnter', 'InsertLeave', 'TextChanged', 'BufWritePost' }, {
    callback = function()
        lint.try_lint()
    end,
})

lint.linters_by_ft = {
    go = { 'golangcilint', },
    json = { 'jsonlint', },
    yaml = { 'yamllint', },
    markdown = { 'markdownlint', },
}

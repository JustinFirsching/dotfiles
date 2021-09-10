-- Clear trailing whitespace on save
vim.cmd('autocmd BufWritePre * %s/\\s\\+$//e')

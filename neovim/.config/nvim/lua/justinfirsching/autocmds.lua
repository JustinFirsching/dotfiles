-- Clear trailing whitespace on save
vim.cmd('autocmd BufWritePre * %s/\\s\\+$//e')

-- Load updates to Xresources
vim.cmd('autocmd BufWritePost .Xresources silent !xrdb <afile>')

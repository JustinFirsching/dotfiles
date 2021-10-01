vim.cmd('autocmd BufWritePost packer.lua source <afile> | PackerCompile')
vim.cmd('autocmd BufWritePost .Xresources silent !xrdb <afile>')

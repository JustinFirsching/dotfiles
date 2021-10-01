-- Just to hide LSP errors...
local vim = vim

vim.opt.autoindent = true
vim.opt.clipboard = 'unnamedplus'
vim.opt.colorcolumn = '80'
vim.opt.expandtab = true
vim.opt.hidden = true
vim.opt.incsearch = true
vim.opt.errorbells = false
vim.opt.swapfile = false
vim.opt.wrap = false
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 3
vim.opt.shiftwidth = 4
vim.opt.showmatch = true
vim.opt.signcolumn = 'yes'
vim.opt.tabstop = 4
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true
vim.opt.updatetime = 50
vim.opt.laststatus = 2
vim.opt.showmode = false
vim.opt.hlsearch = false

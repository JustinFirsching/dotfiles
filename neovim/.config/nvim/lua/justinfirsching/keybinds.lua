vim.g.mapleader = " "

-- Exit Insert Mode
vim.keymap.set('i', '<C-c>', '<Esc>')

-- Toggle search highlighting
vim.keymap.set('n', '<leader>hl', function()
    vim.opt.hlsearch = not(vim.opt.hlsearch:get())
end)

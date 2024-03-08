vim.g.mapleader = " "

-- Exit Insert Mode
vim.keymap.set('i', '<C-c>', '<Esc>')

-- Toggle search highlighting
vim.keymap.set('n', '<leader>hl', function()
    vim.opt.hlsearch = not(vim.opt.hlsearch:get())
end)

-- Remap 'p' and 'P' in Visual Mode to not lose the pasted text
vim.api.nvim_set_keymap('x', 'p', [[pgvy`>]], { noremap = true, silent = true })
vim.api.nvim_set_keymap('x', 'P', [[Pgvy`>]], { noremap = true, silent = true })

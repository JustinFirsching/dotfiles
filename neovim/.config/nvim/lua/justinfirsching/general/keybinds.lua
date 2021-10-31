local bind = function(mode, key, f)
    vim.api.nvim_set_keymap(mode, key, f, { noremap = true, silent = true })
end

local bind_buf = function(mode, key, f)
    vim.api.nvim_buf_set_keymap(0, mode, key, f, {noremap = true, silent = true})
end

-- Set the leader key
vim.g.mapleader = " "

-- Exit Insert Mode
bind_buf('i', '<C-c>', '<Esc>')
bind('i', '<C-c>', '<Esc>')

-- Undo Menu
bind('n', '<leader>u', '<cmd>UndotreeShow<CR>')

-- File Finder
bind('n', '<leader>rf', '<cmd>Telescope find_files<CR>')
-- Buffer Reader
bind('n', '<leader>rb', '<cmd>Telescope buffers<CR>')
-- Old File Reader
bind('n', '<leader>ro', '<cmd>Telescope oldfiles<CR>')

-- Project Search
bind('n', '<leader>ps', '<cmd>Telescope live_grep<CR>')

return bind

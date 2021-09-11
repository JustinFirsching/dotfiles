local bind = function(key, f)
    vim.api.nvim_set_keymap('n', key, f, { noremap = true, silent = true })
end

-- Set the leader key
vim.g.mapleader = " "

-- Undo Menu
bind('<leader>u', '<cmd>UndotreeShow<CR>')
-- File Finder
bind('<leader>rf', '<cmd>Telescope find_files hidden=true<CR>')
-- Buffer Reader
bind('<leader>rb', '<cmd>Telescope buffers<CR>')
-- Old File Reader
bind('<leader>ro', '<cmd>Telescope oldfiles<CR>')
-- Project Search
bind('<leader>ps', '<cmd>lua require("telescope.builtin").grep_string({ search = vim.fn.input("Grep Input> ") })<CR>')

return bind

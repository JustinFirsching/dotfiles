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
-- Code Navigation
bind('<leader>vd', '<cmd>lua vim.lsp.buf.definition()<CR>')
bind('<leader>vi', '<cmd>lua vim.lsp.buf.implementation()<CR>')
bind('<leader>vsh', '<cmd>lua vim.lsp.buf.signature_help()<CR>')
bind('<leader>vrr', '<cmd>lua vim.lsp.buf.references()<CR>')
bind('<leader>vrn', '<cmd>lua vim.lsp.buf.rename()<CR>')
bind('<leader>vh', '<cmd>lua vim.lsp.buf.hover()<CR>')
bind('<leader>vca', '<cmd>lua vim.lsp.buf.code_action()<CR>')
bind('<leader>vsd', '<cmd>lua vim.lsp.util.show_line_diagnostics()<CR>')
bind('<leader>vn', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>')

return bind

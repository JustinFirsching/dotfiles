vim.g.mapleader = " "

-- Exit Insert Mode
vim.keymap.set('i', '<C-c>', '<Esc>')

local map = function(modes, lhs, rhs)
    vim.keymap.set(modes, lhs, rhs, { noremap = true, silent = true })
end

-- Toggle search highlighting
vim.keymap.set('n', '<leader>hl', function()
    vim.opt.hlsearch = not (vim.opt.hlsearch:get())
end)


-- Remap 'p' and 'P' in Visual Mode to not lose the pasted text
map('x', 'p', [[pgvy`>]])
map('x', 'P', [[Pgvy`>]])

-- Always move the the new buffer after a split
local split_and_move = function(split_cmd)
    vim.cmd(split_cmd)
    vim.cmd("wincmd w")
end
map({ 'v', 'n', 'o' }, '<C-W>s', function() split_and_move("split") end)
map({ 'v', 'n', 'o' }, '<C-W>v', function() split_and_move("vsplit") end)

-- Shortcut for :vnew
map({ 'v', 'n', 'o' }, '<C-W>V', function()
    -- Split the window vertically with a new buffer
    vim.cmd("vnew")
    -- This is just to make the buffer open to the right
    vim.cmd("wincmd x")
    vim.cmd("wincmd w")
end)

-- Move between diagnostics
map("n", "]d", vim.diagnostic.goto_next)
map("n", "[d", vim.diagnostic.goto_prev)

-- LSP
local split_to_definition = function(split_cmd)
    vim.cmd(split_cmd)
    vim.cmd("wincmd w")
    vim.lsp.buf.definition()
end
map("n", "<leader>ca", vim.lsp.buf.code_action)
map("n", "<leader>gD", vim.lsp.buf.declaration)
map("n", "<leader>gds", function() split_to_definition("split") end)
map("n", "<leader>gdv", function() split_to_definition("vsplit") end)
map("n", "K", vim.lsp.buf.hover)
map("n", "<leader>rn", vim.lsp.buf.rename)
map("n", "<leader>sd", vim.diagnostic.open_float)
map("n", "<leader>sh", vim.lsp.buf.signature_help)
map({ "n", "i" }, "<M-k>", vim.lsp.buf.signature_help)

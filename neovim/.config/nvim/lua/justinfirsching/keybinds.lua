vim.g.mapleader = " "

-- Exit Insert Mode
vim.keymap.set('i', '<C-c>', '<Esc>')

-- Toggle search highlighting
vim.keymap.set('n', '<leader>hl', function()
    vim.opt.hlsearch = not (vim.opt.hlsearch:get())
end)

-- Remap 'p' and 'P' in Visual Mode to not lose the pasted text
vim.keymap.set('x', 'p', [[pgvy`>]], { noremap = true, silent = true })
vim.keymap.set('x', 'P', [[Pgvy`>]], { noremap = true, silent = true })

-- Always move the the new buffer after a split
local split_and_move = function(split_cmd)
    vim.cmd(split_cmd)
    vim.cmd("wincmd w")
end
vim.keymap.set({'v', 'n', 'o'}, '<C-W>s', function() split_and_move("split") end, { noremap = true, silent = true })
vim.keymap.set({'v', 'n', 'o'}, '<C-W>v', function() split_and_move("vsplit") end, { noremap = true, silent = true })

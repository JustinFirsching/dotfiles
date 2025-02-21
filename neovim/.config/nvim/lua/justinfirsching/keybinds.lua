vim.g.mapleader = " "

-- Exit Insert Mode
vim.keymap.set('i', '<C-c>', '<Esc>')

local map_opts = { noremap = true, silent = true }

-- Toggle search highlighting
vim.keymap.set('n', '<leader>hl', function()
    vim.opt.hlsearch = not (vim.opt.hlsearch:get())
end)


-- Remap 'p' and 'P' in Visual Mode to not lose the pasted text
vim.keymap.set('x', 'p', [[pgvy`>]], map_opts)
vim.keymap.set('x', 'P', [[Pgvy`>]], map_opts)

-- Always move the the new buffer after a split
local split_and_move = function(split_cmd)
    vim.cmd(split_cmd)
    vim.cmd("wincmd w")
end
vim.keymap.set({ 'v', 'n', 'o' }, '<C-W>s', function() split_and_move("split") end, map_opts)
vim.keymap.set({ 'v', 'n', 'o' }, '<C-W>v', function() split_and_move("vsplit") end, map_opts)

-- Shortcut for :vnew
vim.keymap.set({ 'v', 'n', 'o' }, '<C-W>V', function()
    -- Split the window vertically with a new buffer
    vim.cmd("vnew")
    -- This is just to make the buffer open to the right
    vim.cmd("wincmd x")
    vim.cmd("wincmd w")
end, map_opts)

-- Move between diagnostics
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, map_opts)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, map_opts)

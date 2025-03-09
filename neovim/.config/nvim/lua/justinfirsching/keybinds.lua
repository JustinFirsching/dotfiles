local map_key = require("justinfirsching.utils").map_key

local split_and_move = function(split_cmd, callback)
    vim.cmd(split_cmd)
    vim.cmd("wincmd w")
    if callback ~= nil then
        callback()
    end
end

vim.g.mapleader = " "

-- Exit Insert Mode
map_key('i', '<C-c>', '<Esc>')

-- Toggle search highlighting
map_key('n', '<leader>hl', function()
    vim.opt.hlsearch = not (vim.opt.hlsearch:get())
end)

-- Remap 'p' and 'P' in Visual Mode to not lose the pasted text
map_key('x', 'p', [[pgvy`>]])
map_key('x', 'P', [[Pgvy`>]])

-- Always move the the new buffer after a split
map_key({ 'v', 'n', 'o' }, '<C-W>s', function() split_and_move("split") end)
map_key({ 'v', 'n', 'o' }, '<C-W>v', function() split_and_move("vsplit") end)

-- Shortcut for :vnew
map_key({ 'v', 'n', 'o' }, '<C-W>V', function()
    -- Split the window vertically with a new buffer
    vim.cmd("vnew")
    -- This is just to make the buffer open to the right
    vim.cmd("wincmd x")
    vim.cmd("wincmd w")
end)

-- Move between diagnostics
map_key("n", "]d", vim.diagnostic.goto_next)
map_key("n", "[d", vim.diagnostic.goto_prev)

-- LSP
map_key("n", "<leader>ca", vim.lsp.buf.code_action)
map_key("n", "<leader>gD", vim.lsp.buf.declaration)
map_key("n", "<leader>gds", function() split_and_move("split", vim.lsp.buf.definition) end)
map_key("n", "<leader>gdv", function() split_and_move("vsplit", vim.lsp.buf.definition) end)
map_key("n", "K", vim.lsp.buf.hover)
map_key("n", "<leader>rn", vim.lsp.buf.rename)
map_key("n", "<leader>sd", vim.diagnostic.open_float)
map_key("n", "<leader>sh", vim.lsp.buf.signature_help)
map_key({ "n", "i" }, "<M-k>", vim.lsp.buf.signature_help)

-- Open URLs in the browser
map_key("n", "gf", function()
    local url = vim.fn.expand("<cfile>")
    if url:match("^http") then
        vim.system({ "xdg-open", url }, { detach = true })
    else
        vim.cmd("edit " .. url)
    end
end)

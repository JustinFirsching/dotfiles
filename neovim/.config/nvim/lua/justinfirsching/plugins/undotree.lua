return {
    'mbbill/undotree', -- Undo History
    config = function()
        -- View Undotree
        vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)
    end
}

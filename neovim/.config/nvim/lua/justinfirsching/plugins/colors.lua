return {
    'ellisonleao/gruvbox.nvim',
    lazy = false,
    priority = 1000,
    config = function()
        require('gruvbox').setup({
            contrast = 'hard',
            transparent_mode = true,
            italic = {
                strings = false,
                emphasis = false,
                comments = false,
                operators = false,
                folds = false,
            },
        })

        vim.cmd.colorscheme('gruvbox')
    end,
}

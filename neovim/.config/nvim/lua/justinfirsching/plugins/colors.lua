return {
    'ellisonleao/gruvbox.nvim',
    lazy = false,
    priority = 1000,
    config = function()
        require('gruvbox').setup({
            contrast = 'hard',
            transparent_mode = false,
            italic = {
                strings = false,
                emphasis = false,
                comments = false,
                operators = false,
                folds = false,
            },
        })

        vim.cmd.colorscheme('gruvbox')

        local highlight_groups = {
            Normal = { bg = 'none', ctermbg = 'none' },
            NormalFloat = { bg = 'none', ctermbg = 'none' },
        }

        for group, styles in pairs(highlight_groups) do
            vim.api.nvim_set_hl(0, group, styles)
        end
    end,
}

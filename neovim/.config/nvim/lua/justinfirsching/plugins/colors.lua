return {
    'morhetz/gruvbox',
    lazy = false,
    priority = 1000,
    config = function()
        vim.g.gruvbox_contrast_dark = "hard"
        vim.g.gruvbox_transparent_bg = true
        vim.cmd.colorscheme("gruvbox")

        vim.opt.background = "dark"

        local hl_opts = { bg = "none", ctermbg = "none" }
        vim.api.nvim_set_hl(0, "Normal", hl_opts)
        vim.api.nvim_set_hl(0, "NormalFloat", hl_opts)
    end
}

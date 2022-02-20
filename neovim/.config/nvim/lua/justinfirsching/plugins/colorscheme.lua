vim.cmd([[
    colorscheme gruvbox
    set termguicolors
    set background=dark
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    let g:gruvbox_contrast_dark = 'hard'
    highlight Normal guibg=NONE ctermbg=NONE
]])


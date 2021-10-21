if exists('+termguicolors')
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif

set background=dark
colorscheme gruvbox
let g:gruvbox_contrast_dark='hard'
highlight Normal guibg=NONE ctermbg=NONE

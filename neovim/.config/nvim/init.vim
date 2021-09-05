" Preferences
let mapleader=" "
filetype on
filetype plugin on
filetype plugin indent on
set autoindent
set clipboard+=unnamedplus
set colorcolumn=80
set completeopt=menuone,noinsert,noselect
set expandtab
set hidden
set incsearch
set noerrorbells
set noswapfile
set nowrap
set number
set relativenumber
set scrolloff=3
set shiftwidth=4
set showmatch
set signcolumn=yes
set tabstop=4
set undodir=~/.vim/undodir
set undofile
set updatetime=50
" End Preferences

" Plugins
call plug#begin('~/.vim/plugged')
Plug 'itchyny/lightline.vim' " Aesthetic bar
Plug 'morhetz/gruvbox', {'as': 'gruvbox'} " Aesthetic theme
Plug 'neovim/nvim-lspconfig' " Autocomplete Language Servers
Plug 'anott03/nvim-lspinstall' " Language Server Installer
Plug 'nvim-lua/completion-nvim' " Autocomplete
Plug 'udalov/kotlin-vim' " Kotlin support
Plug 'sheerun/vim-polyglot' " Language syntax
Plug 'tpope/vim-fugitive' " Git Integration
Plug 'mhinz/vim-signify' " Git Indicate Line Changes
Plug 'mbbill/undotree' " Undo History
Plug 'nvim-lua/popup.nvim' " Telescope Dependency
Plug 'nvim-lua/plenary.nvim' " Telescope Dependency
Plug 'nvim-telescope/telescope.nvim' " File Finder + Code Navigator
call plug#end()
" End Plugins

" Autocomplete Language Servers
let g:completion_matching_strategy_list = ['exact', 'substring', 'fuzzy']
" Python
lua require'lspconfig'.pylsp.setup{ on_attach=require'completion'.on_attach }
" Clang (C/C++)
lua require'lspconfig'.clangd.setup{ on_attach=require'completion'.on_attach }
" Java
lua require'lspconfig'.jdtls.setup{ on_attach=require'completion'.on_attach }
" Typescript
lua require'lspconfig'.tsserver.setup{ on_attach=require'completion'.on_attach }
" For more language servers
" https://github.com/neovim/nvim-lspconfig#configurations
" End Autocomplete Language Servers

" Custom Mappings
" " Control-C to Escape
inoremap <C-c> <esc>
" " Undo Menu
nnoremap <leader>u :UndotreeShow<CR>
" " File Finder
nnoremap <leader>rf <cmd>Telescope find_files hidden=true<cr>
" " Buffer Reader
nnoremap <leader>rb <cmd>Telescope buffers<cr>
" " Old File Reader
nnoremap <leader>ro <cmd>Telescope oldfiles<cr>
" " Project Search
nnoremap <leader>ps :lua require('telescope.builtin').grep_string({ search = vim.fn.input("Grep Input> ") })<CR>
" " Code Navigation
nnoremap <leader>vd :lua vim.lsp.buf.definition()<CR>
nnoremap <leader>vi :lua vim.lsp.buf.implementation()<CR>
nnoremap <leader>vsh :lua vim.lsp.buf.signature_help()<CR>
nnoremap <leader>vrr :lua vim.lsp.buf.references()<CR>
nnoremap <leader>vrn :lua vim.lsp.buf.rename()<CR>
nnoremap <leader>vh :lua vim.lsp.buf.hover()<CR>
nnoremap <leader>vca :lua vim.lsp.buf.code_action()<CR>
nnoremap <leader>vsd :lua vim.lsp.util.show_line_diagnostics()<CR>
nnoremap <leader>vn :lua vim.lsp.diagnostic.goto_next()<CR>
" End Custom Mappings

" LightLine Settings
set laststatus=2
set noshowmode
" End LightLine Settings

" Theme
colorscheme gruvbox
set t_Co=256
let g:gruvbox_contrast_dark='hard'
set background=dark
hi Normal guibg=NONE ctermbg=NONE
" End Theme

" Commands because I suck
command! W write
command! Wq write | quit
command! WQ write | quit
command! Q quit
" End Commands because I suck

" Clear trailing whitespace on save
autocmd BufWritePre * %s/\s\+$//e

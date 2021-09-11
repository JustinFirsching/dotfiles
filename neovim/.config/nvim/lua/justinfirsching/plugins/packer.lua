-- Make sure packer is installed
local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
  vim.cmd 'packadd packer.nvim'
end

return require('packer').startup(function()
  use 'wbthomason/packer.nvim' -- Package Manager
  -- LSP
  use {
      'kabouzeid/nvim-lspinstall',
      run = function()
          require('justinfirsching.plugins.lspinstall').install_servers()
      end,
      requires = {
          {
              'neovim/nvim-lspconfig',
              config = function() require('justinfirsching.plugins.lsp') end,
          },
      },
  }
  use 'itchyny/lightline.vim' -- Aesthetic bar
  use {'morhetz/gruvbox', as = 'gruvbox'} -- Aesthetic theme
  use 'neovim/nvim-lspconfig' -- Autocomplete Language Servers
  use 'nvim-lua/completion-nvim' -- Autocomplete
  use 'sheerun/vim-polyglot' -- Language syntax
  use 'tpope/vim-fugitive' -- Git Integration
  use 'mhinz/vim-signify' -- Git Indicate Line Changes
  use 'mbbill/undotree' -- Undo History
  use 'nvim-lua/popup.nvim' -- Telescope Dependency
  use 'nvim-lua/plenary.nvim' -- Telescope Dependency
  use 'nvim-telescope/telescope.nvim' -- File Finder + Code Navigator
end)

-- Make sure packer is installed
local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
  vim.cmd 'packadd packer.nvim'
end

return require('packer').startup(function()
  use 'wbthomason/packer.nvim' -- Package Manager
  use 'itchyny/lightline.vim' -- Aesthetic bar
  use {'morhetz/gruvbox', as = 'gruvbox'} -- Aesthetic theme
  use 'neovim/nvim-lspconfig' -- Language Servers
  -- LSP install
  use {
    'williamboman/nvim-lsp-installer',
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
  -- Java LSP
  use 'mfussenegger/nvim-jdtls'
  -- Snippets
  use {
      'L3MON4D3/LuaSnip',
      requires = {
          { 'rafamadriz/friendly-snippets' }
      },
  }
  -- Autocompletion plugins
  use {
    'hrsh7th/nvim-cmp',
    config = function() require('justinfirsching.plugins.cmp') end,
    requires = {
      'hrsh7th/cmp-nvim-lsp', -- LSP source for nvim-cmp
      'hrsh7th/cmp-buffer', -- Buffer source for nvim-cmp
      'saadparwaiz1/cmp_luasnip' -- Snippet source for nvim-cmp
    },
  }
  use 'sheerun/vim-polyglot' -- Syntax Highlighting
  use 'tpope/vim-fugitive' -- Git Integration
  use 'mhinz/vim-signify' -- Git Indicate Line Changes
  use 'mbbill/undotree' -- Undo History
  -- File Finder + Code Navigation
  use {
    'nvim-telescope/telescope.nvim',
    requires = {
      { 'nvim-lua/plenary.nvim' },
      {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate',
        config = function() require('justinfirsching.plugins.treesitter') end,
      }
    }
  }

end)

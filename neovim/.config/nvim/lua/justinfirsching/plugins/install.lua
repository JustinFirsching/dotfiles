-- Make sure packer is installed
local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim' -- Package Manager
  use 'itchyny/lightline.vim' -- Aesthetic bar
  use {'morhetz/gruvbox', as = 'gruvbox'} -- Aesthetic theme
  -- LSP install
  use {
    'williamboman/nvim-lsp-installer',
    requires = {
      'neovim/nvim-lspconfig', -- Language Servers
    },
    config = function()
      require('justinfirsching.plugins.lsp')
    end,
    run = function()
      require('justinfirsching.plugins.lsp').install_missing()
    end
  }
  -- Java LSP
  use 'mfussenegger/nvim-jdtls'
  -- Completion plugins
  use {
    'hrsh7th/nvim-cmp',
    config = function()
      require("justinfirsching.plugins.autocomplete")
    end,
    requires = {
      'hrsh7th/cmp-nvim-lsp', -- LSP source for nvim-cmp
      'hrsh7th/cmp-buffer', -- Buffer source for nvim-cmp
      'saadparwaiz1/cmp_luasnip', -- Snippet source for nvim-cmp
      'kdheepak/cmp-latex-symbols', -- Latex source for nvim-cpm
    },
  }
  -- Snippet Engine
  use {
    'L3MON4D3/LuaSnip',
    requires = {
      -- Snippet Collection
      'rafamadriz/friendly-snippets',
    }
  }
  use 'tpope/vim-fugitive' -- Git Integration
  use 'mhinz/vim-signify' -- Git Indicate Line Changes
  use 'mbbill/undotree' -- Undo History
  -- File Finder + Code Navigation
  use {
    'nvim-telescope/telescope.nvim',
    config = function()
      require('justinfirsching.plugins.telescope')
    end,
    requires = {
      'nvim-lua/plenary.nvim',
      'BurntSushi/ripgrep',
      'nvim-telescope/telescope-fzf-native.nvim',
    }
  }
  -- Syntax
  use {
    'nvim-treesitter/nvim-treesitter',
    config = function()
      require('justinfirsching.plugins.treesitter')
    end,
    run = ':TSUpdate',
  }

end)

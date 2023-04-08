local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Map leader (must be done right after loading lazy.nvim)
vim.g.mapleader = " "
vim.g.maplocalleader = ","

require('lazy').setup({
  {
    "nvim-lua/plenary.nvim",
  },

  {
    "L3MON4D3/LuaSnip",
  },

  {
    "kylechui/nvim-surround",
    config = function()
      require("nvim-surround").setup({})
    end,
  },

  {
    "windwp/nvim-autopairs",
    config = function()
      require "plugins.nvim-autopairs"
    end
  },

  {
    "kyazdani42/nvim-web-devicons",
    config = function()
      require "plugins.nvim-web-devicons"
    end,
  },

  {
    "folke/tokyonight.nvim",
    config = function()
      require "plugins.tokyonight"
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require "plugins.nvim-treesitter"
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-textobjects",
  },

  {
    "kyazdani42/nvim-tree.lua",
    config = function()
      require "plugins.nvim-tree"
    end,
  },

  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require "plugins.gitsigns"
    end,
  },

  {
    "onsails/lspkind-nvim",
    config = function()
      require "plugins.lspkind"
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-path", "hrsh7th/cmp-buffer", "saadparwaiz1/cmp_luasnip" },
    config = function()
      require "plugins.cmp"
    end,
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "plugins.lspconfig"
    end,
  },

  {
    "jose-elias-alvarez/null-ls.nvim",
    config = function()
      require "plugins.null-ls"
    end,
  },

  {
    "williamboman/mason.nvim",
    dependencies = {
      {
        "williamboman/mason-lspconfig.nvim",
        config = function()
          require "plugins.mason-lspconfig"
        end,
      },
    },
    config = function()
      require "plugins.mason"
    end,
  },

  {
    "folke/trouble.nvim",
    config = function()
      require "plugins.trouble"
    end,
  },

  {
    "TimUntersberger/neogit",
    config = function()
      require "plugins.neogit"
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require "plugins.lualine"
    end,
  },

  {
    "numToStr/Comment.nvim",
    config = function()
      require "plugins.comment"
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    config = function()
      require "plugins.telescope"
    end,
  },

  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
  },

  {
    "nvim-telescope/telescope-ui-select.nvim",
  },

  {
    "folke/which-key.nvim",
    config = function()
      require "plugins.which-key"
    end,
  },

  {
    "goolord/alpha-nvim",
    config = function()
      require "plugins.alpha"
    end,
  },
})

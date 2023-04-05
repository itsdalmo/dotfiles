local is_bootstrap = false
local install_path = vim.fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  is_bootstrap = true

  -- Clone
  vim.fn.system { "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path }

  -- Add
  vim.cmd [[packadd packer.nvim]]
end

local packer = require "packer"

-- Use popup window for Packer
packer.init {
  display = {
    open_fn = function()
      return require("packer.util").float {
        border = "rounded",
      }
    end,
  },
}

packer.startup(function(use)
  use { "wbthomason/packer.nvim" }

  use {
    "nvim-lua/plenary.nvim",
  }

  use {
    "L3MON4D3/LuaSnip",
  }

  use {
    "kylechui/nvim-surround",
    config = function()
      require("nvim-surround").setup({})
    end,
  }

  use {
    "windwp/nvim-autopairs",
    config = function()
      require "plugins.nvim-autopairs"
    end
  }

  use {
    "kyazdani42/nvim-web-devicons",
    config = function()
      require "plugins.nvim-web-devicons"
    end,
  }

  use {
    "folke/tokyonight.nvim",
    config = function()
      require "plugins.tokyonight"
    end,
  }

  use {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    config = function()
      require "plugins.nvim-treesitter"
    end,
  }

  use {
    "nvim-treesitter/nvim-treesitter-textobjects",
  }

  use {
    "kyazdani42/nvim-tree.lua",
    config = function()
      require "plugins.nvim-tree"
    end,
  }

  use {
    "lewis6991/gitsigns.nvim",
    config = function()
      require "plugins.gitsigns"
    end,
  }

  use {
    "onsails/lspkind-nvim",
    config = function()
      require "plugins.lspkind"
    end,
  }

  use {
    "hrsh7th/nvim-cmp",
    requires = { "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-path", "hrsh7th/cmp-buffer", "saadparwaiz1/cmp_luasnip" },
    config = function()
      require "plugins.cmp"
    end,
  }

  use {
    "neovim/nvim-lspconfig",
    config = function()
      require "plugins.lspconfig"
    end,
  }

  use {
    "jose-elias-alvarez/null-ls.nvim",
    config = function()
      require "plugins.null-ls"
    end,
  }

  use {
    "williamboman/mason.nvim",
    config = function()
      require "plugins.mason"
    end,
  }

  use {
    "williamboman/mason-lspconfig.nvim",
    after = "mason.nvim",
    config = function()
      require "plugins.mason-lspconfig"
    end,
  }

  use {
    "folke/trouble.nvim",
    config = function()
      require "plugins.trouble"
    end,
  }

  use {
    "TimUntersberger/neogit",
    config = function()
      require "plugins.neogit"
    end,
  }

  use {
    "nvim-lualine/lualine.nvim",
    config = function()
      require "plugins.lualine"
    end,
  }

  use {
    "numToStr/Comment.nvim",
    config = function()
      require "plugins.comment"
    end,
  }

  use {
    "nvim-telescope/telescope.nvim",
    config = function()
      require "plugins.telescope"
    end,
  }

  use {
    "nvim-telescope/telescope-fzf-native.nvim",
    run = "make",
  }

  use {
    "nvim-telescope/telescope-ui-select.nvim",
  }

  use {
    "folke/which-key.nvim",
    config = function()
      require "plugins.which-key"
    end,
  }

  use {
    "goolord/alpha-nvim",
    config = function()
      require "plugins.alpha"
    end,
  }

  if is_bootstrap then
    require("packer").sync()
  end
end)

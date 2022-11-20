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
    commit = "4b7e520",
  }

  use {
    "L3MON4D3/LuaSnip",
    commit = "2373292",
  }

  use {
    "kylechui/nvim-surround",
    commit = "9338071",
    config = function()
      require("nvim-surround").setup({})
    end,
  }

  use {
    "windwp/nvim-autopairs",
    commit = "6b6e35f",
    config = function()
      require "plugins.nvim-autopairs"
    end
  }

  use {
    "kyazdani42/nvim-web-devicons",
    commit = "3b1b794",
    config = function()
      require "plugins.nvim-web-devicons"
    end,
  }

  use {
    "folke/tokyonight.nvim",
    commit = "62b4e89",
    config = function()
      require "plugins.tokyonight"
    end,
  }

  use {
    "nvim-treesitter/nvim-treesitter",
    commit = "596fd67",
    run = ":TSUpdate",
    config = function()
      require "plugins.nvim-treesitter"
    end,
  }

  use {
    "kyazdani42/nvim-tree.lua",
    commit = "cc18122",
    config = function()
      require "plugins.nvim-tree"
    end,
  }

  use {
    "lewis6991/gitsigns.nvim",
    commit = "9ff7dfb",
    config = function()
      require "plugins.gitsigns"
    end,
  }

  use {
    "onsails/lspkind-nvim",
    commit = "c68b3a0",
    config = function()
      require "plugins.lspkind"
    end,
  }

  use {
    "hrsh7th/nvim-cmp",
    commit = "8a9e8a8",
    requires = { "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-path", "hrsh7th/cmp-buffer", "saadparwaiz1/cmp_luasnip" },
    config = function()
      require "plugins.cmp"
    end,
  }

  use {
    "neovim/nvim-lspconfig",
    commit = "04b672b",
    config = function()
      require "plugins.lspconfig"
    end,
  }

  use {
    "jose-elias-alvarez/null-ls.nvim",
    commit = "07d4ed4",
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
    commit = "a1e2219",
    after = "mason.nvim",
    config = function()
      require "plugins.mason-lspconfig"
    end,
  }

  use {
    "folke/trouble.nvim",
    commit = "897542f",
    config = function()
      require "plugins.trouble"
    end,
  }

  use {
    "TimUntersberger/neogit",
    commit = "c1a2a1a",
    config = function()
      require "plugins.neogit"
    end,
  }

  use {
    "nvim-lualine/lualine.nvim",
    commit = "3325d5d",
    config = function()
      require "plugins.lualine"
    end,
  }

  use {
    "numToStr/Comment.nvim",
    commit = "5f01c1a",
    config = function()
      require "plugins.comment"
    end,
  }

  use {
    "nvim-telescope/telescope.nvim",
    commit = "7a4ffef",
    config = function()
      require "plugins.telescope"
    end,
  }

  use {
    "nvim-telescope/telescope-fzf-native.nvim",
    commit = "65c0ee3",
    run = "make",
  }

  use {
    "nvim-telescope/telescope-ui-select.nvim",
    commit = "62ea5e5",
  }

  use {
    "folke/which-key.nvim",
    commit = "61553ae",
    config = function()
      require "plugins.which-key"
    end,
  }

  use {
    "goolord/alpha-nvim",
    commit = "a858e4e",
    config = function()
      require "plugins.alpha"
    end,
  }

  if is_bootstrap then
    require("packer").sync()
  end
end)

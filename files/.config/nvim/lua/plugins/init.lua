return {
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    config = function()
      require("mini.ai").setup()
    end,
  },

  {
    "echasnovski/mini.bufremove",
    event = "VeryLazy",
    config = function()
      require("mini.bufremove").setup()
    end,
  },

  {
    "echasnovski/mini.extra",
    event = "VeryLazy",
    config = function()
      require("mini.extra").setup()
    end,
  },

  {
    "echasnovski/mini.pairs",
    event = "VeryLazy",
    config = function()
      require("mini.pairs").setup()
    end,
  },

  {
    "echasnovski/mini.surround",
    event = "VeryLazy",
    config = function()
      require("mini.surround").setup()
    end,
  },

  {
    "echasnovski/mini.visits",
    event = "VeryLazy",
    config = function()
      require("mini.visits").setup()
    end,
  },

  {
    "echasnovski/mini.pick",
    event = "VeryLazy",
    config = function()
      require("plugins.config.mini-pick")
    end,
  },

  {
    "echasnovski/mini-git",
    main = "mini.git",
    event = "VeryLazy",
    config = function()
      require("plugins.config.mini-git")
    end,
  },

  {
    "echasnovski/mini.diff",
    event = "VeryLazy",
    config = function()
      require("plugins.config.mini-diff")
    end,
  },

  {
    "echasnovski/mini.files",
    event = "VeryLazy",
    config = function()
      require("plugins.config.mini-files")
    end,
  },

  {
    "echasnovski/mini.hipatterns",
    event = "VeryLazy",
    config = function()
      require("plugins.config.mini-hipatterns")
    end,
  },

  {
    "echasnovski/mini.clue",
    event = "VimEnter",
    config = function()
      require("plugins.config.mini-clue")
    end,
  },

  {
    "echasnovski/mini.starter",
    event = "VimEnter",
    config = function()
      require("plugins.config.mini-starter")
    end,
  },

  {
    "echasnovski/mini.notify",
    event = "VeryLazy",
    config = function()
      require("plugins.config.mini-notify")
    end,
  },

  {
    "echasnovski/mini.statusline",
    event = "VeryLazy",
    config = function()
      require("plugins.config.mini-statusline")
    end,
  },

  {
    "echasnovski/mini.icons",
    lazy = false,
    config = function()
      require("mini.icons").setup()
    end,
  },

  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("plugins.config.tokyonight")
    end,
  },

  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    config = function()
      require("persistence").setup()
    end,
  },

  {
    "folke/ts-comments.nvim",
    event = "VeryLazy",
    config = function()
      require("ts-comments").setup()
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    version = false,
    build = ":TSUpdate",
    config = function()
      require("plugins.config.nvim-treesitter")
    end,
  },

  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("plugins.config.lspconfig")
    end,
  },

  {
    "SmiteshP/nvim-navic",
    config = function()
      require("plugins.config.nvim-navic")
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    version = false,
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-buffer",
    },
    config = function()
      require("plugins.config.cmp")
    end,
  },

  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("plugins.config.conform")
    end,
  },

  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("plugins.config.lint")
    end,
  },

  {
    "windwp/nvim-ts-autotag",
    event = "VeryLazy",
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },

  {
    "zk-org/zk-nvim",
    event = "VeryLazy",
    config = function()
      require("plugins.config.zk")
    end,
  },

  -- library used by most plugins
  { "nvim-lua/plenary.nvim", lazy = true },
}

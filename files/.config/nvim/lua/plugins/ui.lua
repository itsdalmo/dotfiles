return {
  -- best colorscheme <3
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = { style = "night" },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd([[colorscheme tokyonight]])
    end,
  },

  -- keybindings
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      plugins = { spelling = true },
      key_labels = {
        ["<space>"] = "SPC",
        ["<cr>"] = "RET",
        ["<tab>"] = "TAB",
      },
      defaults = {
        mode = { "n", "v" },
        ["]"] = { name = "+next" },
        ["["] = { name = "+prev" },
        ["<leader>b"] = { name = "+buffer" },
        ["<leader>e"] = { name = "+error/diagnostic" },
        ["<leader>f"] = { name = "+file/find" },
        ["<leader>g"] = { name = "+git" },
        ["<leader>gh"] = { name = "+hunk" },
        ["<leader>h"] = { name = "+harpoon" },
        ["<leader>l"] = { name = "+lsp" },
        ["<leader>q"] = { name = "+quit/session" },
        ["<leader>s"] = { name = "+search" },
        ["<leader>t"] = { name = "+toggle" },
        ["<leader>w"] = { name = "+window" },
        ["<localleader>g"] = { name = "+goto" },
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.register(opts.defaults)
    end,
  },

  -- dashboard/splash screen when opening nvim
  {
    "echasnovski/mini.starter",
    event = "VimEnter",
    config = function()
      local starter = require("mini.starter")

      starter.setup({
        items = {
          {
            name = "New file",
            action = "enew | startinsert",
            section = "Actions",
          },
          {
            name = "Find file",
            action = "Telescope find_files hidden=true",
            section = "Actions",
          },
          {
            name = "Recent files",
            action = 'lua require("telescope.builtin").oldfiles({ only_cwd = true })',
            section = "Actions",
          },
          {
            name = "Session restore",
            action = 'lua require("persistence").load()',
            section = "Actions",
          },
          {
            name = "Lazy",
            action = "Lazy",
            section = "Actions",
          },
          {
            name = "Quit",
            action = "qa",
            section = "Actions",
          },
        },
        footer = "",
      })
    end,
  },

  -- notifications
  {
    "echasnovski/mini.notify",
    event = "VeryLazy",
    config = function()
      local notify = require("mini.notify")
      notify.setup()
      vim.notify = notify.make_notify()
    end,
  },

  -- statusline
  {
    "echasnovski/mini.statusline",
    event = "VeryLazy",
    config = function()
      local statusline = require("mini.statusline")
      statusline.section_filename = function()
        return "%f%m%r"
      end
      statusline.section_location = function()
        return "%l:%v"
      end
      local inactive = function()
        return "%#MiniStatuslineInactive#%f%m%r%="
      end
      return statusline.setup({
        content = { inactive = inactive },
        use_icons = true,
        set_vim_settings = true,
      })
    end,
  },
}

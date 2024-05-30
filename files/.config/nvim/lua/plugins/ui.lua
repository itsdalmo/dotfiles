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
    "echasnovski/mini.clue",
    event = "VimEnter",
    config = function()
      local miniclue = require("mini.clue")
      miniclue.setup({
        triggers = {
          -- Leader triggers
          { mode = "n", keys = "<Leader>" },
          { mode = "x", keys = "<Leader>" },

          -- Local leader triggers
          { mode = "n", keys = "<Localleader>" },
          { mode = "x", keys = "<Localleader>" },

          -- Built-in completion
          { mode = "i", keys = "<C-x>" },

          -- Brackets
          { mode = "n", keys = "]" },
          { mode = "n", keys = "[" },

          -- `g` key
          { mode = "n", keys = "g" },
          { mode = "x", keys = "g" },

          -- Marks
          { mode = "n", keys = "'" },
          { mode = "n", keys = "`" },
          { mode = "x", keys = "'" },
          { mode = "x", keys = "`" },

          -- Registers
          { mode = "n", keys = '"' },
          { mode = "x", keys = '"' },
          { mode = "i", keys = "<C-r>" },
          { mode = "c", keys = "<C-r>" },

          -- Window commands
          { mode = "n", keys = "<C-w>" },

          -- `z` key
          { mode = "n", keys = "z" },
          { mode = "x", keys = "z" },
        },

        clues = {
          -- Enhance this by adding descriptions for <Leader> mapping groups
          miniclue.gen_clues.builtin_completion(),
          miniclue.gen_clues.g(),
          miniclue.gen_clues.marks(),
          miniclue.gen_clues.registers(),
          miniclue.gen_clues.windows(),
          miniclue.gen_clues.z(),

          -- Custom clues
          { mode = "n", keys = "<Leader>b", desc = "+Buffers" },
          { mode = "n", keys = "<Leader>d", desc = "+Diagnostic" },
          { mode = "n", keys = "<Leader>f", desc = "+Files" },
          { mode = "n", keys = "<Leader>g", desc = "+Git" },
          { mode = "n", keys = "<Leader>gh", desc = "+Hunks" },
          { mode = "n", keys = "<Leader>l", desc = "+LSP" },
          { mode = "n", keys = "<Leader>q", desc = "+Quit/Session" },
          { mode = "n", keys = "<Leader>s", desc = "+Search" },
          { mode = "n", keys = "<Leader>t", desc = "+Toggle" },
          { mode = "n", keys = "<Leader>w", desc = "+Window" },
          { mode = "n", keys = "<Localleader>g", desc = "+Goto" },
        },
      })
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
            action = [[Pick files tool="rg"]],
            section = "Actions",
          },
          {
            name = "Recent files",
            action = [[Pick visit_paths]],
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

return {
  -- automatically close brackets etc.
  {
    "windwp/nvim-autopairs",
    event = "VeryLazy",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    opts = { check_ts = true },
    config = function(_, opts)
      local found, cmp = pcall(require, "cmp")
      if found then
        cmp.event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done())
      end
      require("nvim-autopairs").setup(opts)
    end,
  },

  -- easily comment out lines/blocks
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    config = true,
  },

  -- act on surrounding pairs
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function(_, opts)
      require("nvim-surround").setup(opts)
    end,
  },

  -- todo comments
  {
    "folke/todo-comments.nvim",
    cmd = { "TodoTrouble", "TodoTelescope" },
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      search = {
        command = "rg",
        args = {
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--hidden",
          "--glob=!.git/",
        },
      },
    },
    -- stylua: ignore
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
      { "<leader>st", "<cmd>TodoTelescope<cr>", desc = "Todo" },
      { "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme" },
    },
    config = true,
  },

  -- better diagnostics list and others
  {
    "folke/trouble.nvim",
    cmd = { "TroubleToggle", "Trouble" },
    opts = {
      use_diagnostic_signs = true,
    },
    keys = {
      { "<leader>dd", "<cmd>TroubleToggle<cr>", desc = "Show diagnostics" },
      { "<leader>dl", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "List diagnostics" },
      { "<leader>dL", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "List workspace diagnostics" },
    },
  },

  -- magit for neovim
  {
    "NeogitOrg/neogit",
    cmd = { "Neogit" },
    keys = {
      { "<leader>gs", "<cmd>Neogit<cr>", desc = "Status" },
    },
    opts = {
      integrations = {
        diffview = false,
      },
    },
    config = function(_, opts)
      require("neogit").setup(opts)
    end,
  },
  -- git signs
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        -- stylua: ignore start
        map("n", "]h", gs.next_hunk, "Next Hunk")
        map("n", "[h", gs.prev_hunk, "Prev Hunk")
        map({ "n", "v" }, "<leader>ghs", "<cmd>Gitsigns stage_hunk<cr>", "Stage Hunk")
        map({ "n", "v" }, "<leader>ghr", "<cmd>Gitsigns reset_hunk<cr>", "Reset Hunk")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>ghd", gs.preview_hunk, "Diff Hunk")
        map("n", "<leader>ghb", function() gs.blame_line() end, "Blame Line")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<cr>", "GitSigns Select Hunk")
        map("n", "<leader>tb", "<cmd>Gitsigns toggle_current_line_blame<cr>", "Toggle line blame")
      end,
    },
  },

  -- file tree/explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    keys = {
      {
        "<leader>fl",
        function()
          require("neo-tree.command").execute({ toggle = true, reveal = true })
        end,
        desc = "Locate active file (in neo-tree)",
      },
      {
        "<leader>ft",
        function()
          require("neo-tree.command").execute({ toggle = true })
        end,
        desc = "File Tree",
      },
    },
    deactivate = function()
      vim.cmd([[Neotree close]])
    end,
    init = function()
      vim.g.neo_tree_remove_legacy_commands = 1
      if vim.fn.argc() == 1 then
        local stat = vim.loop.fs_stat(vim.fn.argv(0))
        if stat and stat.type == "directory" then
          require("neo-tree")
        end
      end
    end,
    opts = {
      window = {
        position = "left",
        width = 40,
        mapping_options = {
          noremap = true,
          nowait = true,
        },
        mappings = {
          ["<space>"] = "none",
          ["<tab>"] = { "toggle_node", nowait = false },
          ["<c-x>"] = "open_split",
          ["<c-v>"] = "open_vsplit",
        },
      },
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = true,
        use_libuv_file_watcher = true,
        filtered_items = {
          visible = true,
          hide_dotfiles = true,
          hide_gitignored = true,
          hide_hidden = true,
        },
      },
      default_component_configs = {
        indent = {
          with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
          expander_collapsed = "",
          expander_expanded = "",
          expander_highlight = "NeoTreeExpander",
        },
      },
    },
    config = function(_, opts)
      require("neo-tree").setup(opts)
    end,
  },
}

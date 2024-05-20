return {
  -- buffer removal
  { "echasnovski/mini.bufremove", event = "VeryLazy", config = true },

  -- textobjects
  { "echasnovski/mini.ai", event = "VeryLazy", config = true },

  -- automatically close brackets etc.
  { "echasnovski/mini.pairs", event = "VeryLazy", config = true },

  -- act on surrounding pairs
  { "echasnovski/mini.surround", event = "VeryLazy", config = true },

  -- extras (pickers and textobjects)
  { "echasnovski/mini.extra", event = "VeryLazy", config = true },

  -- file navigation
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "VeryLazy",
    config = function()
      local harpoon = require("harpoon")
      harpoon.setup()

      vim.keymap.set("n", "<leader>ha", function()
        harpoon:list():add()
      end, { desc = "Add to harpoon" })
      vim.keymap.set("n", "<leader>hl", function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, { desc = "Open harpoon list" })

      vim.keymap.set("n", "<C-1>", function()
        harpoon:list():select(1)
      end)
      vim.keymap.set("n", "<C-2>", function()
        harpoon:list():select(2)
      end)
      vim.keymap.set("n", "<C-3>", function()
        harpoon:list():select(3)
      end)
      vim.keymap.set("n", "<C-4>", function()
        harpoon:list():select(4)
      end)
      vim.keymap.set("n", "<C-5>", function()
        harpoon:list():select(5)
      end)
    end,
  },

  -- treesitter context aware commentstring
  {
    "folke/ts-comments.nvim",
    event = "VeryLazy",
    opts = {},
  },

  -- todo comments
  {
    "folke/todo-comments.nvim",
    cmd = { "TodoTrouble" },
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
    },
    config = true,
  },

  -- better diagnostics list and others
  {
    "folke/trouble.nvim",
    cmd = { "TroubleToggle", "Trouble" },
    opts = {
      auto_preview = false,
      use_diagnostic_signs = true,
    },
    keys = {
      { "<leader>dd", "<cmd>TroubleToggle<cr>", desc = "Show diagnostics" },
      { "<leader>dl", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "List diagnostics" },
      { "<leader>dL", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "List workspace diagnostics" },
    },
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
        local gs = require("gitsigns")

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
        map("n", "<leader>tb", function() require("utils").toggle_blame() end, "Line blame")
      end,
    },
  },

  -- file tree/explorer
  {
    "echasnovski/mini.files",
    event = "VeryLazy",
    config = function()
      local files = require("mini.files")
      files.setup({
        mappings = {
          go_in = "L",
          go_in_plus = "l",
        },
        windows = {
          preview = true,
          width_focus = 30,
          width_preview = 30,
        },
        options = {
          use_as_default_explorer = true,
        },
      })

      local map_split = function(buf_id, lhs, direction)
        local rhs = function()
          local new_target_window
          vim.api.nvim_win_call(files.get_target_window(), function()
            vim.cmd("belowright " .. direction .. " split")
            new_target_window = vim.api.nvim_get_current_win()
          end)

          files.set_target_window(new_target_window)
          files.go_in({ close_on_file = true })
        end

        local desc = "Split " .. direction
        vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
      end

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesBufferCreate",
        callback = function(args)
          local buf_id = args.data.buf_id
          map_split(buf_id, "<c-s>", "horizontal")
          map_split(buf_id, "<c-v>", "vertical")
        end,
      })

      vim.keymap.set("n", "<leader>ft", function()
        files.open(vim.uv.cwd(), true)
      end, { desc = "File Tree (cwd)" })
      vim.keymap.set("n", "<leader>fl", function()
        files.open(vim.api.nvim_buf_get_name(0), true)
      end, { desc = "Locate active file (in mini.files)" })
    end,
  },

  -- pick (telescope alternative)
  {
    "echasnovski/mini.pick",
    event = "VeryLazy",
    config = function()
      local pick = require("mini.pick")
      pick.setup()
      vim.ui.select = pick.ui_select

      pick.registry.buffers = function(local_opts)
        local delete_buffer = function()
          local current = pick.get_picker_matches().current
          require("mini.bufremove").delete(current.bufnr)

          local items = {}
          for _, item in ipairs(pick.get_picker_items()) do
            if current.bufnr ~= item.bufnr then
              table.insert(items, item)
            end
          end
          pick.set_picker_items(items)
        end
        pick.builtin.buffers(local_opts, { mappings = { delete = { char = "<C-d>", func = delete_buffer } } })
      end

      vim.keymap.set("n", "<leader><space>", [[<cmd>Pick commands<cr>]], { desc = "Commands" })
      vim.keymap.set("n", "<leader>:", [[<cmd>Pick history<cr>]], { desc = "Command history" })
      vim.keymap.set("n", "<leader>bb", [[<cmd>Pick buffers<cr>]], { desc = "Show all buffers" })
      vim.keymap.set("n", "<leader>ff", [[<cmd>Pick files tool="rg"<cr>]], { desc = "Find files" })
      vim.keymap.set("n", "<leader>fr", [[<cmd>Pick oldfiles<cr>]], { desc = "Recent files" })
      vim.keymap.set("n", "<leader>gl", [[<cmd>Pick git_commits path="%"<cr>]], { desc = "Show log (buffer)" })
      vim.keymap.set("n", "<leader>gL", [[<cmd>Pick git_commits<cr>]], { desc = "Show log (repository)" })
      vim.keymap.set("n", "<leader>ss", [[<cmd>Pick grep_live tool="rg"<cr>]], { desc = "Grep" })
      vim.keymap.set("n", "<leader>sb", [[<cmd>Pick buf_lines scope="current"<cr>]], { desc = "Buffer" })
      vim.keymap.set("n", "<leader>sh", [[<cmd>Pick help<cr>]], { desc = "Buffer" })
      vim.keymap.set("n", "<leader>sr", [[<cmd>Pick resume<cr>]], { desc = "Resume" })
      vim.keymap.set("n", "<leader>sd", [[<cmd>Pick diagnostic scope="current"<cr>]], { desc = "Diagnostics (buffer)" })
      vim.keymap.set("n", "<leader>sD", [[<cmd>Pick diagnostic<cr>]], { desc = "Diagnostics (workspace)" })
      vim.keymap.set("n", "<leader>sj", [[<cmd>Pick lsp scope="document_symbol"<cr>]], { desc = "Goto symbol" })
      vim.keymap.set(
        "n",
        "<leader>sJ",
        [[<cmd>Pick lsp scope="workspace_symbol"<cr>]],
        { desc = "Goto symbol (workspace)" }
      )
    end,
  },
}

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
  { "echasnovski/mini.visits", event = "VeryLazy", config = true },

  -- treesitter context aware commentstring
  { "folke/ts-comments.nvim", event = "VeryLazy", config = true },

  -- highlight patterns
  {
    "echasnovski/mini.hipatterns",
    event = "VeryLazy",
    config = function()
      local hi_words = require("mini.extra").gen_highlighter.words
      require("mini.hipatterns").setup({
        highlighters = {
          TODO = hi_words({ "TODO", "Todo", "todo" }, "MiniHipatternsTodo"),
          NOTE = hi_words({ "NOTE", "Note", "note" }, "MiniHipatternsNote"),
          HACK = hi_words({ "HACK", "Hack", "hack" }, "MiniHipatternsHack"),
          FIXME = hi_words({ "FIXME", "Fixme", "fixme" }, "MiniHipatternsFixme"),
        },
      })
    end,
  },

  -- git
  {
    "echasnovski/mini-git",
    main = "mini.git",
    event = "VeryLazy",
    config = function()
      local git = require("mini.git")
      git.setup()

      -- Only include branch name in the git summary
      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniGitUpdated",
        callback = function(data)
          local summary = vim.b[data.buf].minigit_summary
          vim.b[data.buf].minigit_summary_string = summary.head_name or ""
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniGitCommandSplit",
        callback = function(data)
          if data.data.git_subcommand ~= "blame" then
            return
          end

          -- Align blame output with source
          local win_src = data.data.win_source
          vim.wo.wrap = false
          vim.fn.winrestview({ topline = vim.fn.line("w0", win_src) })
          vim.api.nvim_win_set_cursor(0, { vim.fn.line(".", win_src), 0 })

          -- Bind both windows so that they scroll together
          vim.wo[win_src].scrollbind, vim.wo.scrollbind = true, true
        end,
      })

      vim.keymap.set("n", "<leader>gb", [[<cmd>vert Git blame -- %<cr>]], { desc = "Blame" })
      vim.keymap.set("n", "<leader>gs", function()
        git.show_at_cursor()
      end, { desc = "Show at cursor" })
    end,
  },

  -- git diff
  {
    "echasnovski/mini.diff",
    event = "VeryLazy",
    config = function()
      local diff = require("mini.diff")
      diff.setup({
        view = {
          style = "sign",
          signs = {
            add = "▎",
            change = "▎",
            delete = "",
          },
        },
        options = {
          wrap_goto = true,
        },
      })
      vim.keymap.set("n", "<leader>gd", function()
        require("utils").toggle_diff()
      end, { desc = "Toggle diff overlay" })
    end,
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
      vim.keymap.set("n", "<leader>fr", [[<cmd>Pick visit_paths<cr>]], { desc = "Recent files" })
      vim.keymap.set("n", "<leader>gl", [[<cmd>Pick git_commits path="%"<cr>]], { desc = "Show log (buffer)" })
      vim.keymap.set("n", "<leader>gL", [[<cmd>Pick git_commits<cr>]], { desc = "Show log (repository)" })
      vim.keymap.set("n", "<leader>ss", [[<cmd>Pick grep_live tool="rg"<cr>]], { desc = "Grep" })
      vim.keymap.set("n", "<leader>sb", [[<cmd>Pick buf_lines scope="current"<cr>]], { desc = "Buffer" })
      vim.keymap.set("n", "<leader>sh", [[<cmd>Pick help<cr>]], { desc = "Buffer" })
      vim.keymap.set("n", "<leader>sr", [[<cmd>Pick resume<cr>]], { desc = "Resume" })
      vim.keymap.set(
        "n",
        "<leader>st",
        [[<cmd>Pick hipatterns highlighters=TODO,NOTE,HACK,FIXME<cr>]],
        { desc = "Todo/note/hack/fixme" }
      )
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

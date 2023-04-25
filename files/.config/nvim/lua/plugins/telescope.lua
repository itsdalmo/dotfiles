return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  version = false,
  dependencies = {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    config = function()
      require("telescope").load_extension("fzf")
    end,
  },
  keys = {
    -- buffers
    { "<leader>bb", "<cmd>Telescope buffers<cr>", desc = "Show all buffers" },
    -- files
    { "<leader>ff", "<cmd>Telescope find_files hidden=true<cr>", desc = "Find Files" },
    { "<leader>fr", "<cmd>Telescope oldfiles only_cwd=true<cr>", desc = "Recent Files" },
    -- git
    { "<leader>gl", "<cmd>Telescope git_bcommits<cr>", desc = "Show log (file)" },
    { "<leader>gL", "<cmd>Telescope git_commits<cr>", desc = "Show log (repository)" },
    -- search
    { "<leader>ss", "<cmd>Telescope live_grep<cr>", desc = "Grep (root dir)" },
    { "<leader>sr", "<cmd>Telescope resume<cr>", desc = "Resume" },
    { "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer" },
    { "<leader>sd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
    {
      "<leader>sj",
      ':lua require("telescope.builtin").lsp_document_symbols()<CR>',
      desc = "Goto Symbol",
    },
    {
      "<leader>sJ",
      ':lua require("telescope.builtin").lsp_workspace_symbols()<CR>',
      desc = "Goto Symbol (Workspace)",
    },
    -- other
    { "<leader><space>", "<cmd>Telescope commands<cr>", desc = "Commands" },
    { "<leader>:", "<cmd>Telescope command_history<cr>", desc = "Command History" },
    { "<leader>sa", "<cmd>Telescope autocommands<cr>", desc = "Auto Commands" },
    { "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Help Pages" },
    { "<leader>sH", "<cmd>Telescope highlights<cr>", desc = "Search Highlight Groups" },
    { "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Key Maps" },
    { "<leader>sm", "<cmd>Telescope marks<cr>", desc = "Jump to Mark" },
    { "<leader>sM", "<cmd>Telescope man_pages<cr>", desc = "Man Pages" },
    { "<leader>so", "<cmd>Telescope vim_options<cr>", desc = "Options" },
  },
  opts = function(_, _)
    local actions = require("telescope.actions")

    local opts = {
      defaults = {
        prompt_prefix = " ",
        selection_caret = " ",
        mappings = {
          n = {
            ["q"] = actions.close,
            ["<C-j>"] = actions.preview_scrolling_down,
            ["<C-k>"] = actions.preview_scrolling_up,
            ["<C-d>"] = actions.delete_buffer,
          },
          i = {
            ["<C-j>"] = actions.preview_scrolling_down,
            ["<C-k>"] = actions.preview_scrolling_up,
            ["<C-d>"] = actions.delete_buffer,
          },
        },
        vimgrep_arguments = {
          "rg",
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
      pickers = {
        find_files = {
          find_command = { "fd", "--type", "f", "--strip-cwd-prefix" },
        },
      },
    }
    return opts
  end,
  config = function(_, opts)
    require("telescope").setup(opts)
  end,
}

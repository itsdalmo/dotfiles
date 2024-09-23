local opts = {
  highlight = {
    enable = true,
    disable = {},
  },
  indent = {
    enable = true,
    disable = {},
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<C-space>",
      node_incremental = "<C-space>",
      scope_incremental = false,
      node_decremental = "<bs>",
    },
  },
}

require("nvim-treesitter.configs").setup(opts)
vim.treesitter.language.register("html", "gohtml")
vim.treesitter.language.register("river", "alloy")

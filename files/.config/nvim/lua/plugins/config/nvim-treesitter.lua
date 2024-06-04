local opts = {
  highlight = {
    enable = true,
    disable = {},
  },
  indent = {
    enable = true,
    disable = {},
  },
  ensure_installed = {
    "bash",
    "c",
    "dockerfile",
    "fish",
    "gitignore",
    "go",
    "gomod",
    "gosum",
    "gowork",
    "hcl",
    "html",
    "html",
    "javascript",
    "json",
    "lua",
    "luadoc",
    "luap",
    "markdown",
    "markdown_inline",
    "nix",
    "proto",
    "python",
    "query",
    "regex",
    "sql",
    "terraform",
    "toml",
    "tsx",
    "typescript",
    "vim",
    "vimdoc",
    "yaml",
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
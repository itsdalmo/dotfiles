local present, treesitter = pcall(require, "nvim-treesitter.configs")

if not present then
  return
end

local options = {
  highlight = {
    enable = true,
    disable = {},
  },
  indent = {
    enable = true,
    disable = {},
  },
  ensure_installed = {
    "lua",
    "go",
    "gomod",
    "hcl",
    "python",
    "dockerfile",
    "bash",
    "fish",
    "markdown",
    "gitignore",
    "json",
    "yaml",
    "toml",
    "proto",
    "javascript",
    "typescript",
    "html",
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["af"] = { query = "@function.outer", desc = "Select outer function" },
        ["if"] = { query = "@function.inner", desc = "Select inner function" },
        ["ac"] = { query = "@class.outer", desc = "Select outer class" },
        ["ic"] = { query = "@class.inner", desc = "Select inner class" },
        ["aa"] = { query = "@parameter.inner", desc = "Select outer paramter" },
        ["ia"] = { query = "@parameter.outer", desc = "Select inner parameter" },
      },
    },
    move = {
      enable = true,
      set_jumps = true,
      goto_next_start = {
        ["]f"] = { query = "@function.outer", desc = "Goto next function" },
        ["]c"] = { query = "@class.outer", desc = "Goto next class" },
        ["]a"] = { query = "@parameter.inner", desc = "Goto next parameter" },
      },
      goto_previous_start = {
        ["[f"] = { query = "@function.outer", desc = "Goto previous function" },
        ["[c"] = { query = "@class.outer", desc = "Goto previous class" },
        ["[a"] = { query = "@parameter.inner", desc = "Goto previous parameter" },
      },
    },
  },
}

treesitter.setup(options)

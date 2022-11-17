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
    enable = false,
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
}

treesitter.setup(options)

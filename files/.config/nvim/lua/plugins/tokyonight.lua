local present, tokyonight = pcall(require, "tokyonight")

if not present then
  return
end

local options = {
  style = "night"
}

tokyonight.setup(options)
vim.cmd [[colorscheme tokyonight]]

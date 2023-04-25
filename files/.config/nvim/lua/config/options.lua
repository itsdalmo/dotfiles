-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Options
local options = {
  belloff = "all",
  showmode = false,
  termguicolors = true,
  background = "dark",
  encoding = "utf-8",
  laststatus = 2,
  cmdheight = 0,
  clipboard = "unnamed",
  autoindent = true,
  smartindent = true,
  number = true,
  relativenumber = true,
  signcolumn = "yes",
  numberwidth = 4,
  showmatch = true,
  history = 10000,
  tabstop = 4,
  shiftwidth = 2,
  softtabstop = 2,
  expandtab = true,
  scrolloff = 5,
  sidescrolloff = 5,
  mouse = "n",
  ignorecase = true,
  smartcase = true,
  hlsearch = true,
  backup = false,
  writebackup = false,
  swapfile = false,
  showtabline = 0,
  splitright = true,
  splitbelow = true,
  wrap = false,
  completeopt = "menu,menuone,noselect",
  fillchars = {
    vert = "│",
  },
}

for k, v in pairs(options) do
  vim.opt[k] = v
end

-- disable nvim intro
vim.opt.shortmess:append("c")

-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Options
local options = {
  autoindent = true,
  autowrite = true,
  background = "dark",
  backup = false,
  belloff = "all",
  clipboard = "unnamedplus",
  cmdheight = 1,
  completeopt = "menu,menuone,noselect",
  conceallevel = 3,
  cursorline = true,
  encoding = "utf-8",
  expandtab = true,
  fillchars = { vert = "│" },
  formatoptions = "jcroqlnt",
  history = 10000,
  hlsearch = true,
  ignorecase = true,
  inccommand = "nosplit",
  laststatus = 0,
  mouse = "n",
  number = true,
  numberwidth = 4,
  relativenumber = true,
  ruler = false,
  scrolloff = 5,
  sessionoptions = { "buffers", "curdir", "tabpages", "winsize" },
  shiftround = true,
  shiftwidth = 2,
  showmatch = true,
  showmode = false,
  showtabline = 0,
  sidescrolloff = 5,
  signcolumn = "yes",
  smartcase = true,
  smartindent = true,
  softtabstop = 2,
  splitbelow = true,
  splitright = true,
  swapfile = false,
  tabstop = 2,
  termguicolors = true,
  undofile = true,
  wrap = false,
  writebackup = false,
}

for k, v in pairs(options) do
  vim.opt[k] = v
end

-- disable nvim intro
vim.opt.shortmess:append("c")

-- add filetypes
vim.filetype.add({
  extension = {
    gohtml = "gohtml",
    gotmpl = "gotmpl",
    tfstate = "json",
  },
})

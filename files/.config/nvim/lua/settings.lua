-- General settings
local settings = {
  mapleader = " ",
  maplocalleader = ",",
}

for k, v in pairs(settings) do
  vim.g[k] = v
end

-- Options
local options = {
  belloff = "all",
  showmode = false,
  termguicolors = true,
  background = "dark",
  encoding = "utf-8",
  laststatus = 2,
  cmdheight = 1,
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
}

for k, v in pairs(options) do
  vim.opt[k] = v
end

-- disable builtins plugins
local disabled = {
  "netrw",
  "netrwPlugin",
  "netrwSettings",
  "netrwFileHandlers",
  "gzip",
  "zip",
  "zipPlugin",
  "tar",
  "tarPlugin",
  "getscript",
  "getscriptPlugin",
  "vimball",
  "vimballPlugin",
  "2html_plugin",
  "logipat",
  "rrhelper",
  "spellfile_plugin",
  "matchit",
}

for _, plugin in pairs(disabled) do
  vim.g["loaded_" .. plugin] = 1
end

-- disable nvim intro
vim.opt.shortmess:append "c"

-- strip trailing whitespace on write
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = { "*" },
  command = [[%s/\s\+$//e]],
})

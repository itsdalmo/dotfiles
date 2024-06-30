local navic = require("nvim-navic")
navic.setup({
  separator = " ",
  highlight = true,
  depth_limit = 5,
  -- lazy_update_context = true,
})

vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"

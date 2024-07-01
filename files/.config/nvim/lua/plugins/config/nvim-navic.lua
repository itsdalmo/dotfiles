local navic = require("nvim-navic")
navic.setup({
  separator = " ",
  highlight = true,
  depth_limit = 5,
})

vim.keymap.set("n", "<leader>tw", function()
  require("utils").toggle_winbar()
end, { desc = "Toggle winbar" })

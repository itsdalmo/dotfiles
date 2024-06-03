local diff = require("mini.diff")
diff.setup({
  view = {
    style = "sign",
    signs = {
      add = "▎",
      change = "▎",
      delete = "",
    },
  },
  options = {
    wrap_goto = true,
  },
})
vim.keymap.set("n", "<leader>gd", function()
  require("utils").toggle_diff()
end, { desc = "Toggle diff overlay" })

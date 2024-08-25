local diff = require("mini.diff")
diff.setup({
  options = {
    wrap_goto = true,
  },
})
vim.keymap.set("n", "<leader>gd", function()
  require("utils").toggle_diff()
end, { desc = "Toggle diff overlay" })

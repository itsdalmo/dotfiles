require("zk").setup({
  picker = "minipick",
  lsp = {
    config = {
      cmd = { "zk", "lsp" },
      name = "zk",
    },
    auto_attach = {
      enabled = true,
      filetypes = { "markdown" },
    },
  },
})

vim.keymap.set("n", "<leader>nn", [[<cmd>ZkNew { title = vim.fn.input("Title: ") }<cr>]], { desc = "New note" })
vim.keymap.set("n", "<leader>nf", [[<cmd>ZkNotes { sort = { 'modified' } }<cr>]], { desc = "Find note" })
vim.keymap.set("n", "<leader>nd", [[<cmd>ZkNew { dir = "daily" }<cr>]], { desc = "Open daily note" })
vim.keymap.set(
  "n",
  "<leader>nt",
  [[<cmd>ZkNew { dir = "daily", date = "tomorrow" }<cr>]],
  { desc = "Open tomorrows daily note" }
)
vim.keymap.set(
  "n",
  "<leader>nm",
  [[<cmd>ZkNew { dir = "meetings", vim.fn.input("Title: ") }<cr>]],
  { desc = "New meeting note" }
)

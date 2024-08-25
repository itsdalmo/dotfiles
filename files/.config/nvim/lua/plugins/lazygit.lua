-- NOTE: lazygit does not have a setup function
-- require("lazygit").setup()

vim.keymap.set("n", "<leader>gg", [[<cmd>LazyGit<cr>]], { desc = "Lazygit" })

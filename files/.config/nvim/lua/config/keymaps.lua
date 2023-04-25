-- Note: Most keymaps are specified in plugins/which-key.
local function map(mode, shortcut, command, opts)
  opts = opts or {}
  opts = vim.tbl_deep_extend("keep", opts, { noremap = true, silent = true })
  vim.api.nvim_set_keymap(mode, shortcut, command, opts)
end

-- Keep search matches in the middle of the window.
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Indent visual selected code without unselecting and going back to normal mode
map("v", ">", ">gv")
map("v", "<", "<gv")

-- Jump between splits
map("n", "<C-k>", ":wincmd k<CR>")
map("n", "<C-j>", ":wincmd j<CR>")
map("n", "<C-h>", ":wincmd h<CR>")
map("n", "<C-l>", ":wincmd l<CR>")

map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })
map("n", "<leader>sc", "<cmd>noh<CR>", { desc = "Clear search" })

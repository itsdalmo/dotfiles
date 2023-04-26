local function map(mode, shortcut, command, opts)
  opts = opts or {}
  opts = vim.tbl_deep_extend("keep", opts, { noremap = true })
  vim.keymap.set(mode, shortcut, command, opts)
end

-- Keep search matches in the middle of the window.
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Indent visual selected code without unselecting and going back to normal mode
map("v", ">", ">gv")
map("v", "<", "<gv")

-- Jump between splits
map("n", "<C-k>", "<cmd>wincmd k<cr>")
map("n", "<C-j>", "<cmd>wincmd j<cr>")
map("n", "<C-h>", "<cmd>wincmd h<cr>")
map("n", "<C-l>", "<cmd>wincmd l<cr>")

-- Lazygit
map("n", "<leader>gg", function()
  require("util.lsp").float_term({ "lazygit" }, { esc_esc = false })
end, { desc = "Lazygit" })

-- LSP
map("n", "li", "<cmd>LspInfo<cr>", { desc = "Info" })
map("n", "lr", "<cmd>LspRestart<cr>", { desc = "Restart" })

-- Files
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New file" })

-- Buffers
map("n", "]b", "<cmd>bprev<cr>", { desc = "Next buffer" })
map("n", "[b", "<cmd>bnext<cr>", { desc = "Previous buffer" })
map("n", "<leader>bd", "<cmd>bd<cr>", { desc = "Close active buffer" })

-- Tabs
map("n", "]<tab>", "<cmd>tabnext<cr>", { desc = "Next tab" })
map("n", "[<tab>", "<cmd>tabprevious<cr>", { desc = "Previous tab" })

-- Search
map("n", "<leader>sc", "<cmd>noh<CR>", { desc = "Clear search" })

-- Quit
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

-- TODO: Window management
-- TODO: Toggles (diagnostics, autoformat etc)

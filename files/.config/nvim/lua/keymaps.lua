local utils = require("utils")

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

-- Buffers
map("n", "]b", "<cmd>bprev<cr>", { desc = "Next buffer" })
map("n", "[b", "<cmd>bnext<cr>", { desc = "Previous buffer" })
map("n", "<leader>bd", ":lua MiniBufremove.delete()<cr>", { desc = "Close active buffer" })

-- Files
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New file" })

-- LSP
map("n", "<leader>li", "<cmd>LspInfo<cr>", { desc = "Info" })
map("n", "<leader>lr", "<cmd>LspRestart<cr>", { desc = "Restart" })

-- Diagnostics
map("n", "<localleader>d", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "]d", utils.diagnostic_goto(true), { desc = "Next Diagnostic" })
map("n", "[d", utils.diagnostic_goto(false), { desc = "Prev Diagnostic" })
map("n", "]w", utils.diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
map("n", "[w", utils.diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })
map("n", "]e", utils.diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
map("n", "[e", utils.diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
map("n", "]t", "gt", { desc = "Next tab" })
map("n", "[t", "gT", { desc = "Prev tab" })

-- Quit
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

-- Search
map("n", "<leader>sc", "<cmd>noh<CR>", { desc = "Clear search" })

-- Tabs
map("n", "]<tab>", "<cmd>tabnext<cr>", { desc = "Next tab" })
map("n", "[<tab>", "<cmd>tabprevious<cr>", { desc = "Previous tab" })

-- Toggles
map("n", "<leader>tf", require("utils").toggle_autoformat, { desc = "Autoformat" })
map("n", "<leader>tc", require("utils").toggle_conceal, { desc = "Conceal" })
map("n", "<leader>td", require("utils").toggle_diagnostics, { desc = "Diagnostics" })
map("n", "<leader>tw", require("utils").toggle_wrap, { desc = "Wrap (soft)" })
map("n", "<leader>tD", require("utils").toggle_diffthis, { desc = "Diffthis" })

-- Window
map("n", "<leader>wv", "<cmd>vsplit<cr>", { desc = "Split vertical" })
map("n", "<leader>ws", "<cmd>split<cr>", { desc = "Split horizontal" })
map("n", "<leader>w<left>", "<C-w><", { desc = "Resize left" })
map("n", "<leader>w<right>", "<C-w>>", { desc = "Resize right" })
map("n", "<leader>w<up>", "<C-w>+", { desc = "Resize up" })
map("n", "<leader>w<down>", "<C-w>-", { desc = "Resize down" })

-- Note: Most keymaps are specified in plugins/which-key.
local function map(mode, shortcut, command)
  vim.api.nvim_set_keymap(mode, shortcut, command, {
    noremap = true,
    silent = true,
  })
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

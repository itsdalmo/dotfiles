-- Note: Most keymaps are specified in plugins/which-key.
local function map(mode, shortcut, command)
    vim.api.nvim_set_keymap(mode, shortcut, command, {
        noremap = true,
        silent = true
    })
end

-- Keep search matches in the middle of the window.
map('n', 'n', 'nzzzv')
map('n', 'N', 'Nzzzv')

-- indent visual selected code without unselecting and going back to normal mode
map('v', '>', '>gv')
map('v', '<', '<gv')

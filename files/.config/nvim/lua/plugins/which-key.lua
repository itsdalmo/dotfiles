local wk = require("which-key")

local major = {
    name = '+major',

    ['<tab>'] = {'<C-o>', 'Go back'}
}

local leader = {
    ['<leader>'] = {':lua require("telescope.builtin").commands()<CR>', 'Commands'},
    ['<tab>'] = {':e #<cr>lua', 'Last buffer'},

    b = {
        name = "+buffers",
        b = {':lua require("telescope.builtin").buffers()<CR>', 'Show all buffers'},
        d = {':bd<CR>', 'Close active buffer'}
    },
    f = {
        name = "+files",
        f = {':lua require("telescope.builtin").find_files({ hidden = true })<CR>', 'Find file'},
        r = {':lua require("telescope.builtin").oldfiles()<CR>', 'Recent files'},
        t = {':lua require("nvim-tree").toggle(false)<CR>', 'File tree'},
        l = {':lua require("nvim-tree").find_file(true)<CR>', 'Show active file in tree'},
        n = {':enew<cr>', 'New file'}
    },
    g = {
        c = {"<Cmd>Telescope git_branches<CR>", "branches"},
        l = {"<Cmd>Telescope git_commits<CR>", "commits"},
        s = {"<Cmd>Telescope git_status<CR>", "status"}
    },
    s = {
        name = "+search",
        s = {':lua require("telescope.builtin").live_grep()<CR>', 'Search in files'},
        c = {':noh<CR>', 'Clear search'}
    },
    q = {
        name = "+quit",
        q = {':qa<CR>', 'Quit'}
    }
}

wk.register(major, {
    prefix = "<localleader>"
})

wk.register(leader, {
    prefix = '<leader>'
})

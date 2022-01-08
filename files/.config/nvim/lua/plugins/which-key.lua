local wk = require("which-key")

local major = {
    name = '+major',

    ['<tab>'] = {'<C-o>', 'Go back'},
    ["."] = {':lua vim.lsp.buf.code_action()<CR>', 'Quick fix'},
    [" "] = {':lua vim.lsp.buf.code_action()<CR>', 'Code action'},

    r = {'<cmd>lua vim.lsp.buf.rename()<CR>', 'Rename'},
    g = {
        name = '+goto',
        r = {':lua require("telescope.builtin").lsp_references()<CR>', 'Go to references'},
        d = {':lua require("telescope.builtin").lsp_definitions()<CR>', 'Go to definition'},
        i = {':lua require("telescope.builtin").lsp_implementations()<CR>', 'Go to implementation'},
        t = {':lua require("telescope.builtin").lsp_type_definitions()<CR>', 'Go to type definition'},
        j = {':lua require("telescope.builtin").lsp_document_symbols()<CR>', 'Jump to symbol'},
        J = {':lua require("telescope.builtin").lsp_workspace_symbols()<CR>', 'Jump to symbol in workspace'}
    }
}

local leader = {
    ['<leader>'] = {':lua require("telescope.builtin").commands()<CR>', 'Commands'},
    ['<tab>'] = {':e #<cr>lua', 'Last buffer'},

    m = major, -- Identical to the major (localleader) bindings.

    b = {
        name = "+buffers",
        b = {':lua require("telescope.builtin").buffers()<CR>', 'Show all buffers'},
        d = {':bd<CR>', 'Close active buffer'}
    },
    f = {
        name = "+files",
        f = {':lua require("telescope.builtin").find_files({ hidden = true })<CR>', 'Find file'},
        r = {':lua require("telescope.builtin").oldfiles()<CR>', 'Open Recent file'},
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
        j = {':lua require("telescope.builtin").lsp_document_symbols()<CR>', 'Jump to symbol'},
        J = {':lua require("telescope.builtin").lsp_workspace_symbols()<CR>', 'Jump to symbol in workspace'}
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

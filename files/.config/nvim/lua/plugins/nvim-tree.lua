local g = vim.g

g.nvim_tree_git_hl = 1
g.nvim_tree_highlight_opened_files = 1
g.nvim_tree_respect_buf_cwd = 1
g.nvim_tree_width_allow_resize = 1
g.nvim_tree_show_icons = {
    git = 1,
    folders = 1,
    files = 1
}

g.nvim_tree_icons = {
    default = "‣ "
}

local tree = require('nvim-tree')

local options = {
    open_on_setup = true,
    update_cwd = true,
    actions = {
        open_file = {
            resize_window = false,
            quit_on_open = false,
            window_picker = {
                enable = false
            }
        }
    },
    system_open = {
        cmd = nil,
        args = {}
    },
    filters = {
        dotfiles = true,
        custom = {'.git', 'node_modules', '.cache', '.bin'}
    },
    view = {
        width = 32
    },
    renderer = {
        indent_markers = {
            enable = true
        }
    }
}

tree.setup(options)

local g = vim.g

g.nvim_tree_width_allow_resize = 1

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
        },
        icons = {
            show = {  
                git = true,
                folder = true,
                file = true,
            },
            glyphs = {
              default = "‣ "
            }
        },
        highlight_git = true,
        highlight_opened_files = 'icon',
    },
    respect_buf_cwd = true,
}

tree.setup(options)

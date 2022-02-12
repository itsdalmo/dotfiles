local telescope = require('telescope')
local actions = require('telescope.actions')

local options = {
    defaults = {
        mappings = {
            n = {
                ["q"] = actions.close,
                ["<C-j>"] = actions.preview_scrolling_down,
                ["<C-k>"] = actions.preview_scrolling_up
            },
            i = {
                ["<C-j>"] = actions.preview_scrolling_down,
                ["<C-k>"] = actions.preview_scrolling_up
            }
        }
    },
    pickers = {
        find_files = {
            find_command = {"fd", "--type", "f", "--strip-cwd-prefix"}
        }
    }
}

telescope.setup(options)

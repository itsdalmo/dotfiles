local telescope = require('telescope')

local options = {
    defaults = {
        mappings = {
            n = {
                ["q"] = require('telescope.actions').close
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

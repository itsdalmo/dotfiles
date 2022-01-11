local telescope = require('telescope')

local options = {
    defaults = {
        mappings = {
            n = {
                ["q"] = require('telescope.actions').close
            }
        }
    }
}

telescope.setup(options)

local treesitter = require('nvim-treesitter.configs')

local options = {
    highlight = {
        enable = true,
        disable = {}
    },
    indent = {
        enable = false,
        disable = {}
    },
    ensure_installed = {"lua", "go", "fish", "json", "yaml", "toml"}
}

treesitter.setup(options)

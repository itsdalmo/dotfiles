local lualine = require('lualine')

local symbols = {
    error = ' ',
    warn = ' ',
    info = ' ',
    hint = ' '
}

local options = {
    options = {
        icons_enabled = true,
        theme = 'onedark',
        component_separators = {
            left = '',
            right = ''
        },
        section_separators = {
            left = '',
            right = ''
        },
        disabled_filetypes = {}
    },
    sections = {
        lualine_a = {'mode'},
        lualine_b = {'branch', 'diff', 'diagnostics'},
        lualine_c = {'filename'},
        lualine_x = {'encoding', 'filetype', {
            'diagnostics',
            sources = {'nvim_diagnostic'},
            symbols = symbols
        }},
        lualine_y = {'progress'},
        lualine_z = {'location'}
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {'filename'},
        lualine_x = {'location'},
        lualine_y = {},
        lualine_z = {}
    },
    tabline = {}
}

lualine.setup(options)

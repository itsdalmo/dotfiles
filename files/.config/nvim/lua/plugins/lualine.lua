local lualine = require('lualine')

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
        disabled_filetypes = {"NvimTree"}
    },
    sections = {
        lualine_a = {'mode'},
        lualine_b = {'branch', 'diff', 'diagnostics'},
        lualine_c = {{
            'filename',
            file_status = true,
            path = 1
        }},
        lualine_x = {'encoding', 'filetype'},
        lualine_y = {'progress'},
        lualine_z = {'location'}
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {{
            'filename',
            file_status = true,
            path = 1
        }},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {'location'}
    },
    tabline = {}
}

lualine.setup(options)

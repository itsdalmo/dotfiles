local onedark = require('onedark')

onedark.setup {
    colors = {
        fg = '#BBBBBB',
        bg = '#282C34',
        bg1 = '#31353f',
        purple = '#d55fde',
        green = '#89ca78',
        orange = '#d29a66',
        blue = '#61afef',
        yellow = '#e5c07b',
        cyan = '#2bbac5',
        red = '#ef596f',
        grey = '#80848e'
    },
    highlights = {
        NvimTreeNormal = {
            fg = "$fg",
            bg = "$bg"
        },
        NvimTreeVertSplit = {
            fg = '$bg1',
            bg = '$bg'
        },
        NvimTreeEndOfBuffer = {
            fg = '$bg',
            bg = '$bg'
        },
        NvimTreeSpecialFile = {
            fg = "$yellow",
            fmt = "none"
        }
    }
}

onedark.load()

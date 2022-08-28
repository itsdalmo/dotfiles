local present, gitsigns = pcall(require, "gitsigns")

if not present then
    return
end

local config = {
    signcolumn = true,
    signs = {
        add = {
            hl = "GitSignsAdd",
            text = "▎",
            numhl = "GitSignsAddNr",
            linehl = "GitSignsAddLn"
        },
        change = {
            hl = "GitSignsChange",
            text = "▎",
            numhl = "GitSignsChangeNr",
            linehl = "GitSignsChangeLn"
        },
        delete = {
            hl = "GitSignsDelete",
            text = "▎",
            numhl = "GitSignsDeleteNr",
            linehl = "GitSignsDeleteLn"
        }
    }
}

gitsigns.setup(config)

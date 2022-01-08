local lspconfig = require('lspconfig')
local protocol = require('vim.lsp.protocol')

local symbols = {
    Error = ' ',
    Warn = ' ',
    Info = ' ',
    Hint = ' '
}

for type, icon in pairs(symbols) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, {
        text = icon,
        texthl = hl,
        numhl = hl
    })
end

local on_attach = function(client, bufnr)
    local function buf_set_keymap(...)
        vim.api.nvim_buf_set_keymap(bufnr, ...)
    end
    local function buf_set_option(...)
        vim.api.nvim_buf_set_option(bufnr, ...)
    end

    -- Enable completion triggered by <c-x><c-o>
    buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

end

local servers = {'gopls'}

for _, server in ipairs(servers) do
    lspconfig[server].setup {
        on_attach = on_attach,
        flags = {
            debounce_text_changes = 150
        }
    }
end

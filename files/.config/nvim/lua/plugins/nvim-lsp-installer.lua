local installer = require('nvim-lsp-installer')

installer.on_server_ready(function(server)
    local opts = {}
    server:setup(opts)
end)

local present, lspconfig = pcall(require, "lspconfig")

if not present then
  return
end

local protocol = require "vim.lsp.protocol"

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...)
    vim.api.nvim_buf_set_keymap(bufnr, ...)
  end

  local function buf_set_option(...)
    vim.api.nvim_buf_set_option(bufnr, ...)
  end

  -- Enable completion triggered by <c-x><c-o>
  buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
end

-- Set up completion using nvim_cmp with LSP source
local capabilities = require('cmp_nvim_lsp').default_capabilities()

lspconfig.sumneko_lua.setup {
  on_attach = on_attach,
  settings = {
    Lua = {
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = { "vim" },
      },

      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
    },
  },
}

lspconfig.gopls.setup {
  on_attach = on_attach,
  settings = {
    gopls = {
      ["gofumpt"] = true,
      ["local"] = "github.com/pexip,gitlab.com/pexip"
    }
  }
}

lspconfig.pyright.setup {
  on_attach = on_attach,
}

lspconfig.jsonls.setup {
  on_attach = on_attach,
}

lspconfig.yamlls.setup {
  on_attach = on_attach,
}

lspconfig.dockerls.setup {
  on_attach = on_attach,
}

lspconfig.terraformls.setup {
  on_attach = on_attach,
}

lspconfig.denols.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

lspconfig.html.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
  underline = true,
  update_in_insert = false,
  virtual_text = {
    spacing = 4,
    prefix = "●",
  },
  severity_sort = true,
})

-- Diagnostic symbols in the sign column (gutter)
local signs = {
  Error = " ",
  Warn = " ",
  Hint = " ",
  Info = " ",
}
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, {
    text = icon,
    texthl = hl,
    numhl = "",
  })
end

vim.diagnostic.config {
  virtual_text = {
    prefix = "●",
  },
  update_in_insert = true,
  float = {
    source = "always",
  },
}
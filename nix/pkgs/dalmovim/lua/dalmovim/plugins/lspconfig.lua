vim.diagnostic.config({
  underline = false,
  severity_sort = true,
  update_in_insert = false,
  signs = {
    severity = {
      min = "WARN",
    },
  },
  virtual_text = {
    spacing = 4,
    prefix = "●",
    severity = {
      min = "ERROR",
    },
  },
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("custom-lsp-attach", { clear = true }),
  callback = function(event)
    local buffer = event.buf
    local client = vim.lsp.get_client_by_id(event.data.client_id)

    if client.server_capabilities.documentSymbolProvider then
      require("nvim-navic").attach(client, buffer)
    end
  end,
})

local servers = {
  ansiblels = {},
  dockerls = {},
  eslint = {
    settings = {
      workingDirectory = { mode = "auto" },
    },
  },
  gopls = {
    filetypes = { "go", "gomod", "gowork", "gotmpl", "gohtml" },
    settings = {
      gopls = {
        templateExtensions = { "gotmpl", "gohtml" },
      },
    },
  },
  html = {
    filetypes = { "html", "gohtml" },
  },
  cssls = {},
  jsonls = {},
  jsonnet_ls = {},
  nil_ls = {},
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = { globals = { "vim", "jit" } },
        workspace = { checkThirdParty = false },
        completion = { callSnippet = "Replace" },
      },
    },
  },
  terraformls = {},
  tflint = {},
  ts_ls = {
    settings = {
      typescript = {
        format = {
          indentSize = vim.o.shiftwidth,
          convertTabsToSpaces = vim.o.expandtab,
          tabSize = vim.o.tabstop,
        },
      },
      javascript = {
        format = {
          indentSize = vim.o.shiftwidth,
          convertTabsToSpaces = vim.o.expandtab,
          tabSize = vim.o.tabstop,
        },
      },
      completions = { completeFunctionCalls = true },
    },
  },
  yamlls = {
    settings = {
      yaml = { keyOrdering = false },
    },
  },
}

local lspconfig = require("lspconfig")
for server, config in pairs(servers) do
  config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
  require("lspconfig")[server].setup(config)
end

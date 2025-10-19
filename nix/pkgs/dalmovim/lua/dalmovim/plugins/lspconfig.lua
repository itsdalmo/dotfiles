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

local servers = {
  dockerls = {},
  eslint = {
    settings = {
      workingDirectory = { mode = "auto" },
    },
  },
  gopls = {
    filetypes = { "go", "gomod", "gowork", "gotmpl", "gohtml", "tmpl" },
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
  nil_ls = {
    settings = {
      nix = {
        flake = {
          autoArchive = false,
        },
      },
    },
  },
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

for server, config in pairs(servers) do
  vim.lsp.config(server, config)
  vim.lsp.enable(server)
end

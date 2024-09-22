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

    local function map(mode, shortcut, command, desc)
      local opts = { desc = desc, noremap = true, buffer = buffer }
      vim.keymap.set(mode, shortcut, command, opts)
    end

    map("n", "<localleader>k", vim.lsp.buf.hover, "Hover")
    map("n", "<localleader>gr", [[<cmd>Pick lsp scope="references"<cr>]], "References")
    map("n", "<localleader>gD", [[<cmd>Pick lsp scope="declaration"<cr>]], "Goto Declaration")
    map("n", "<localleader>gi", [[<cmd>Pick lsp scope="implementation"<cr>]], "Goto Implementation")
    map("n", "<localleader>gt", [[<cmd>Pick lsp scope="type_definition"<cr>]], "Goto Type Definition")

    if client.server_capabilities.codeActionProvider then
      map({ "n", "v" }, "<localleader>.", vim.lsp.buf.code_action, "Code Action")
    end

    if client.server_capabilities.renameProvider then
      map("n", "<localleader>r", vim.lsp.buf.rename, "Rename")
    end

    if client.server_capabilities.signatureHelpProvider then
      map("n", "<localleader>s", vim.lsp.buf.signature_help, "Signature Help")
    end

    if client.server_capabilities.definitionProvider then
      map("n", "<localleader>gd", [[<cmd>Pick lsp scope="definition"<cr>]], "Goto Definition")
    end

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

local capabilities = vim.tbl_deep_extend(
  "force",
  {},
  vim.lsp.protocol.make_client_capabilities(),
  require("cmp_nvim_lsp").default_capabilities()
)

for server, config in pairs(servers) do
  local cfg = vim.tbl_deep_extend("force", {
    capabilities = vim.deepcopy(capabilities),
  }, config or {})
  require("lspconfig")[server].setup(cfg)
end

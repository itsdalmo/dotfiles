local servers = {
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
  tsserver = {
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

local icons = {
  Error = " ",
  Warn = " ",
  Hint = " ",
  Info = " ",
}

-- diagnostics
vim.diagnostic.config({
  diagnostics = {
    underline = true,
    update_in_insert = false,
    virtual_text = {
      spacing = 4,
      source = "if_many",
      prefix = "●",
    },
    severity_sort = true,
    signs = {
      text = {
        [vim.diagnostic.severity.INFO] = icons.Info,
        [vim.diagnostic.severity.HINT] = icons.Hint,
        [vim.diagnostic.severity.WARN] = icons.Warn,
        [vim.diagnostic.severity.ERROR] = icons.Error,
      },
    },
  },
  format = {
    formatting_options = nil,
    timeout_ms = nil,
  },
})

-- keybinds
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("custom-lsp-attach", { clear = true }),
  callback = function(event)
    local buffer = event.buf
    local client = vim.lsp.get_client_by_id(event.data.client_id)

    local function map(mode, shortcut, command, desc)
      local opts = { desc = desc, noremap = true, buffer = buffer }
      vim.keymap.set(mode, shortcut, command, opts)
    end

    -- mini.completion
    vim.bo[buffer].omnifunc = "v:lua.MiniCompletion.completefunc_lsp"

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
  end,
})

local capabilities = vim.tbl_deep_extend("force", {}, vim.lsp.protocol.make_client_capabilities())
for server, config in pairs(servers) do
  local cfg = vim.tbl_deep_extend("force", {
    capabilities = vim.deepcopy(capabilities),
  }, config or {})
  require("lspconfig")[server].setup(cfg)
end
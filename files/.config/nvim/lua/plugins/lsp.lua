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

return {
  -- NOTE: Server configuration are defined in config/lsp.lua
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
  },
  config = function()
    local icons = require("config.icons")
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
            [vim.diagnostic.severity.INFO] = icons.diagnostics.Info,
            [vim.diagnostic.severity.HINT] = icons.diagnostics.Hint,
            [vim.diagnostic.severity.WARN] = icons.diagnostics.Warn,
            [vim.diagnostic.severity.ERROR] = icons.diagnostics.Error,
          },
        },
      },
      format = {
        formatting_options = nil,
        timeout_ms = nil,
      },
    })

    -- signs --TODO: These need to be set irrespective of the LSP now?
    for name, icon in pairs(require("config.icons").diagnostics) do
      name = "DiagnosticSign" .. name
      vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
    end

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

        map("n", "<localleader>k", vim.lsp.buf.hover, "Hover")
        map("n", "<localleader>gr", "<cmd>Trouble lsp_references<cr>", "References")
        map("n", "<localleader>gD", vim.lsp.buf.declaration, "Goto Declaration")
        map("n", "<localleader>gi", "<cmd>Trouble lsp_implementations<cr>", "Goto Implementation")
        map("n", "<localleader>gt", "<cmd>Trouble lsp_type_definitions<cr>", "Goto Type Definition")

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
          map("n", "<localleader>gd", "<cmd>Trouble lsp_definitions<cr>", "Goto Definition")
        end
      end,
    })

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
  end,
}

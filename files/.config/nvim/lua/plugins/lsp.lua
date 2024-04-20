return {
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    event = "VeryLazy",
    build = ":MasonUpdate", -- :MasonUpdate updates registry contents
    config = function(_, opts)
      require("mason").setup(opts)
    end,
  },

  -- NOTE: Installed servers are defined in config/lsp.lua
  {
    "williamboman/mason-lspconfig.nvim",
    event = "VeryLazy",
    dependencies = { "williamboman/mason.nvim" },
    opts = function()
      local opts = {
        ensure_installed = {},
        automatic_installation = false,
      }

      return opts
    end,
  },

  -- NOTE: Server configuration are defined in config/lsp.lua
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    opts = {
      diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "●",
        },
        severity_sort = true,
      },
      format = {
        formatting_options = nil,
        timeout_ms = nil,
      },
    },
    config = function(_, opts)
      local servers = require("config.lsp").servers
      local utils = require("utils")

      -- diagnostics
      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

      -- signs
      for name, icon in pairs(require("config.icons").diagnostics) do
        name = "DiagnosticSign" .. name
        vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
      end

      -- keybinds
      utils.lsp_attach_autocmd(function(client, bufnr)
        local function map(mode, shortcut, command, desc)
          opts = { desc = desc, noremap = true, buffer = bufnr }
          vim.keymap.set(mode, shortcut, command, opts)
        end

        map("n", "<localleader>k", vim.lsp.buf.hover, "Hover")
        map("n", "<localleader>d", vim.diagnostic.open_float, "Line Diagnostics")
        map("n", "<localleader>gr", "<cmd>Trouble lsp_references<cr>", "References")
        map("n", "<localleader>gD", vim.lsp.buf.declaration, "Goto Declaration")
        map("n", "<localleader>gi", "<cmd>Trouble lsp_implementations<cr>", "Goto Implementation")
        map("n", "<localleader>gt", "<cmd>Trouble lsp_type_definitions<cr>", "Goto Type Definition")

        map("n", "]d", utils.diagnostic_goto(true), "Next Diagnostic")
        map("n", "[d", utils.diagnostic_goto(false), "Prev Diagnostic")
        map("n", "]w", utils.diagnostic_goto(true, "WARN"), "Next Warning")
        map("n", "[w", utils.diagnostic_goto(false, "WARN"), "Prev Warning")
        map("n", "]e", utils.diagnostic_goto(true, "ERROR"), "Next Error")
        map("n", "[e", utils.diagnostic_goto(false, "ERROR"), "Prev Error")

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

        local forced_format = function()
          utils.format({ force = true })
        end

        if client.server_capabilities.documentFormattingProvider then
          map("n", "<localleader>=", forced_format, "Format Document")

          -- Enable automatic formatting
          if client.supports_method("textDocument/formatting") then
            vim.api.nvim_create_autocmd("BufWritePre", {
              group = vim.api.nvim_create_augroup("LspFormat." .. bufnr, {}),
              buffer = bufnr,
              callback = utils.format,
            })
          end
        end

        if client.server_capabilities.documentRangeFormattingProvider then
          map("v", "<localleader>=", forced_format, "Format Range")
        end
      end)

      -- server setup (must be installed with mason-lspconfig)
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
  },

  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")

      lint.linters_by_ft = {
        fish = { "fish" },
        proto = { "buf_lint" },
        sh = { "shellcheck" },

        -- TODO: Move to lsp?
        go = { "golangcilint" },
      }

      local group = vim.api.nvim_create_augroup("lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = group,
        callback = function()
          require("lint").try_lint()
        end,
      })
    end,
  },

  -- NOTE: null-ls executables are installed by Homebrew.
  {
    "jose-elias-alvarez/null-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = function()
      local nls = require("null-ls")
      return {
        root_dir = require("null-ls.utils").root_pattern(".null-ls-root", ".neoconf.json", ".git"),
        sources = {
          nls.builtins.formatting.buf,
          nls.builtins.formatting.fish_indent,
          nls.builtins.formatting.prettier.with({
            -- Single quote is a string literal and is a better default
            extra_args = { "--single-quote" },
          }),
          nls.builtins.formatting.shfmt,
          nls.builtins.formatting.stylua,
          nls.builtins.formatting.terraform_fmt.with({
            -- Using terraformls to format actual terraform files
            filetypes = { "hcl" },
          }),
        },
      }
    end,
  },
}

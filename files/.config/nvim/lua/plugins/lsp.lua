return {
  -- NOTE: Server configuration are defined in config/lsp.lua
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
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

      -- signs --TODO: These need to be set irrespective of the LSP now?
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
      end)

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
        bzl = { "buildifier" },
        fish = { "fish" },
        go = { "golangcilint" }, -- TODO: Move to lsp?
        proto = { "buf_lint" },
        sh = { "shellcheck" },
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

  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    keys = {
      {
        "<localleader>=",
        function()
          require("utils").format({ force = true })
        end,
      },
    },
    opts = {
      format = {
        timeout_ms = 3000,
        async = false,
        quiet = false,
        lsp_fallback = true,
      },
      formatters = {
        injected = {
          options = {
            ignore_errors = true,
            lang_to_ext = {
              bash = "sh",
            },
            lang_to_formatters = {
              bash = { "shfmt" },
            },
          },
        },
      },
      formatters_by_ft = {
        bzl = { "buildifier" },
        fish = { "fish_indent" },
        hcl = { "terraform_fmt" },
        lua = { "stylua" },
        go = { "gofumpt" },
        markdown = { "prettier", "injected" },
        proto = { "buf" },
        sh = { "shfmt" },
        yaml = { "prettier" },
      },
    },
  },
}

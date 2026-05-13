local conform = require("conform")

conform.setup({
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

    -- Alloy formatter (for river configuration language)
    alloy = { command = "alloy", args = { "fmt", "-" } },

    prettier = {
      args = { "--stdin-filepath", "$FILENAME", "--print-width", "120", "--prose-wrap", "never" },
    },
  },
  formatters_by_ft = {
    alloy = { "alloy" },
    bash = { "shfmt" },
    bzl = { "buildifier" },
    fish = { "fish_indent" },
    go = { "gofumpt" },
    hcl = { "terraform_fmt" },
    json = { "prettier" },
    jsonc = { "prettier" },
    jsonnet = { "jsonnetfmt" },
    libsonnet = { "jsonnetfmt" },
    lua = { "stylua" },
    markdown = { "prettier", "injected" },
    nix = { "nixfmt" },
    proto = { "buf" },
    sh = { "shfmt" },
    sql = { "sql_formatter" },
    yaml = { "prettier" },
  },
})

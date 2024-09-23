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
  },
  formatters_by_ft = {
    alloy = { "alloy" },
    bash = { "shfmt" },
    bzl = { "buildifier" },
    fish = { "fish_indent" },
    go = { "gofumpt" },
    hcl = { "terraform_fmt" },
    jsonnet = { "jsonnetfmt" },
    libsonnet = { "jsonnetfmt" },
    lua = { "stylua" },
    markdown = { "prettier", "injected" },
    nix = { "nixpkgs_fmt" },
    proto = { "buf" },
    sh = { "shfmt" },
    sql = { "sql_formatter" },
    yaml = { "prettier" },
  },
})

vim.keymap.set("n", "<localleader>=", function()
  require("utils").format({ force = true })
end)

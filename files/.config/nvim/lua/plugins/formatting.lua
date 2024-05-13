return {
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
      nix = { "nixpkgs_fmt" },
      proto = { "buf" },
      sh = { "shfmt" },
      sql = { "sql_formatter" },
      yaml = { "prettier" },
    },
  },
}

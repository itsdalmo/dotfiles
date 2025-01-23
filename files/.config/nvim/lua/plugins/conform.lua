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

    -- Deno formatter (replaces prettier)
    deno = {
      command = "deno",
      args = function(_, ctx)
        local ext = vim.bo[ctx.buf].filetype
        local wrap = "always"
        if ext == "markdown" then
          ext = "md"

          -- Don't wrap prose since it messes up rendering in e.g. Obsidian
          wrap = "never"
        end
        return { "fmt", "-", "--unstable-yaml", "--line-width", "120", "--prose-wrap", wrap, "--ext", ext }
      end,
    },
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
    markdown = { "deno", "injected" },
    nix = { "nixpkgs_fmt" },
    proto = { "buf" },
    sh = { "shfmt" },
    sql = { "sql_formatter" },
    yaml = { "deno" },
  },
})

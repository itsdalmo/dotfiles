require("zk").setup({
  picker = "minipick",
  lsp = {
    config = {
      cmd = { "zk", "lsp" },
      name = "zk",
    },
    auto_attach = {
      enabled = true,
      filetypes = { "markdown" },
    },
  },
})

local present, nls = pcall(require, "null-ls")

if not present then
  return
end

local options = {
  sources = {
    nls.builtins.diagnostics.golangci_lint,
    nls.builtins.diagnostics.shellcheck,
    nls.builtins.diagnostics.jsonlint,
    nls.builtins.code_actions.gitsigns,
    nls.builtins.formatting.buf,
    nls.builtins.formatting.packer,
    nls.builtins.diagnostics.buf,
    nls.builtins.diagnostics.fish,
  },
}

nls.setup(options)

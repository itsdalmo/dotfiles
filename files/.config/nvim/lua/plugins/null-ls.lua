local present, nls = pcall(require, "null-ls")

if not present then
  return
end

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

local lsp_formatting = function(bufnr)
  vim.lsp.buf.format({
    filter = function(client)
      return client.name == "null-ls"
    end,
    bufnr = bufnr,
  })
end

local on_attach = function(client, bufnr)
  if client.supports_method("textDocument/formatting") then
    vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = augroup,
      buffer = bufnr,
      callback = function()
        lsp_formatting(bufnr)
      end,
    })
  end
end


local options = {
  sources = {
    nls.builtins.diagnostics.golangci_lint,
    nls.builtins.diagnostics.shellcheck,
    nls.builtins.diagnostics.jsonlint,
    nls.builtins.formatting.buf,
    nls.builtins.formatting.packer,
    nls.builtins.diagnostics.buf,
    nls.builtins.diagnostics.fish,
    nls.builtins.diagnostics.terraform_validate,
  },
  on_attach = on_attach,
}

nls.setup(options)

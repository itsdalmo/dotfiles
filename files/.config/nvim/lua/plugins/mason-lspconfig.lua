local present, lspconfig = pcall(require, "mason-lspconfig")

if not present then
  return
end

local options = {
  automatic_installation = true,
  ensure_installed = {
    "lua_ls",
    "gopls",
    "pyright",
    "jsonls",
    "yamlls",
    "dockerls",
    "terraformls",
    "tflint",
    "denols",
    "html",
  },
}

lspconfig.setup(options)

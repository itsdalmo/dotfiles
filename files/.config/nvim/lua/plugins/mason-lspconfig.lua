local present, lspconfig = pcall(require, "mason-lspconfig")

if not present then
  return
end

local options = {
  automatic_installation = true,
  ensure_installed = {
    "sumneko_lua",
    "gopls",
    "pyright",
    "jsonls",
    "yamlls",
    "dockerls",
    "terraformls",
    "denols",
    "html",
  },
}

lspconfig.setup(options)

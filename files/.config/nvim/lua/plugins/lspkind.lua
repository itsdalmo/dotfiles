local present, lspkind = pcall(require, "lspkind")

if not present then
  return
end

local options = {
  mode = "symbol",
  preset = "codicons",
}

lspkind.init(options)

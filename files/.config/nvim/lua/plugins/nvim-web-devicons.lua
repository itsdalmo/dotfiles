local present, devicons = pcall(require, "nvim-web-devicons")

if not present then
  return
end

local options = {}

devicons.setup(options)

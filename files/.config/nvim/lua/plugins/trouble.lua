local present, trouble = pcall(require, "trouble")

if not present then
  return
end

local options = {}

trouble.setup(options)

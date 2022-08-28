local present, trouble = pcall(require, "trouble")

if not present then
  return
end

-- HACK: https://github.com/folke/trouble.nvim/issues/153
local util = require("trouble.util")
local _jump_to_item = util.jump_to_item
util.jump_to_item = function(win, ...)
  return _jump_to_item(win or 0, ...)
end

local options = {}

trouble.setup(options)

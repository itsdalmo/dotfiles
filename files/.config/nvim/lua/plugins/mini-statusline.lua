---@diagnostic disable: undefined-global
local statusline = require("mini.statusline")

statusline.section_diff = function()
  return ""
end

statusline.section_filename = function()
  if vim.bo.buftype == "terminal" then
    return "%t"
  else
    return "%f%m%r"
  end
end

statusline.section_fileinfo = function()
  local filetype = vim.bo.filetype
  if filetype == "" then
    return ""
  end
  return MiniIcons.get("filetype", filetype) .. " " .. filetype
end

statusline.section_location = function()
  return "%l:%v"
end

return statusline.setup({
  use_icons = true,
  set_vim_settings = true,
})

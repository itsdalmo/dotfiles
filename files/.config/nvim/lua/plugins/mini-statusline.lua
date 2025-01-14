---@diagnostic disable: undefined-global
require("mini.statusline").setup({
  use_icons = true,
  set_vim_settings = true,
})

MiniStatusline.section_diff = function()
  return ""
end

MiniStatusline.section_filename = function()
  if vim.bo.buftype == "terminal" then
    return "%t"
  else
    return "%f%m%r"
  end
end

MiniStatusline.section_fileinfo = function()
  local filetype = vim.bo.filetype
  if filetype == "" then
    return ""
  end
  return MiniIcons.get("filetype", filetype) .. " " .. filetype
end

MiniStatusline.section_location = function()
  return "%l:%v"
end

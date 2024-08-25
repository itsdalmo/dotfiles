local statusline = require("mini.statusline")
statusline.section_filename = function()
  return "%f%m%r"
end
statusline.section_location = function()
  return "%l:%v"
end
local inactive = function()
  return "%#MiniStatuslineInactive#%f%m%r%="
end
return statusline.setup({
  content = { inactive = inactive },
  use_icons = true,
  set_vim_settings = true,
})

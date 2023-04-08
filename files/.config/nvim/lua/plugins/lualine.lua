local present, lualine = pcall(require, "lualine")

if not present then
  return
end

local tree_extension = {
  filetypes = { "NvimTree" },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch" },
    lualine_z = { "location" },
  },
}

local options = {
  options = {
    globalstatus = true,
    icons_enabled = true,
    theme = "tokyonight",
    component_separators = '|',
    section_separators = '',
  },
  sections = {
    lualine_a = { "mode", },
    lualine_b = { "branch" },
    lualine_c = {
      { "filename", file_status = false, path = 1 },
    },
    lualine_x = { "diagnostics" },
    lualine_y = { "filetype" },
    lualine_z = { "location" },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {
      { "filename", file_status = false, path = 1 },
    },
    lualine_x = {},
    lualine_y = {},
    lualine_z = { "location" },
  },
  tabline = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = { "tabs" }
  },
  extensions = { tree_extension },
}

lualine.setup(options)

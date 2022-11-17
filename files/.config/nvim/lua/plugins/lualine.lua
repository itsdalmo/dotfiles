local present, lualine = pcall(require, "lualine")

if not present then
  return
end

local tree_extension = {
  filetypes = { "NvimTree" },
  sections = {
    lualine_a = { "mode" },
    lualine_z = { "location" },
  },
}

local options = {
  options = {
    icons_enabled = true,
    theme = "tokyonight",
    component_separators = {
      left = "",
      right = "",
    },
    section_separators = {
      left = "",
      right = "",
    },
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch" },
    lualine_c = { {
      "filename",
      file_status = false,
      path = 0,
    } },
    lualine_x = { "diagnostics" },
    lualine_y = { "filetype" },
    lualine_z = { "location" },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { {
      "filename",
      file_status = false,
      path = 1,
    } },
    lualine_x = {},
    lualine_y = {},
    lualine_z = { "location" },
  },
  tabline = {},
  extensions = { tree_extension },
}

lualine.setup(options)

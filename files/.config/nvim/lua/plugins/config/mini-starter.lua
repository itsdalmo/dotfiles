local starter = require("mini.starter")

starter.setup({
  items = {
    {
      name = "New file",
      action = "enew | startinsert",
      section = "Actions",
    },
    {
      name = "Find file",
      action = [[Pick files tool="rg"]],
      section = "Actions",
    },
    {
      name = "Recent files",
      action = [[Pick oldfiles current_dir=true]],
      section = "Actions",
    },
    {
      name = "Session restore",
      action = 'lua require("persistence").load()',
      section = "Actions",
    },
    {
      name = "Lazy",
      action = "Lazy",
      section = "Actions",
    },
    {
      name = "Quit",
      action = "qa",
      section = "Actions",
    },
  },
  footer = "",
})

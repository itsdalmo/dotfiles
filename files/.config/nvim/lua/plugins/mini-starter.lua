require("mini.starter").setup({
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
      action = [[Pick visit_paths recency_weight=1]],
      section = "Actions",
    },
    {
      name = "Session restore",
      action = [[lua require("persistence").load()]],
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

-- source: https://github.com/echasnovski/mini.deps/blob/main/scripts/init-deps-example.lua
local path_package = vim.fn.stdpath("data") .. "/site/"
require("mini.deps").setup({ path = { package = path_package } })

local now, later = MiniDeps.now, MiniDeps.later

now(function()
  require("commands")
  require("options")
  require("keymaps")
end)

-- Theme
now(function()
  require("plugins.tokyonight")
end)

-- Mini
now(function()
  require("plugins.mini-notify")
end)

now(function()
  require("plugins.mini-starter")
end)

now(function()
  require("plugins.mini-statusline")
end)

now(function()
  require("mini.icons").setup()
  MiniIcons.mock_nvim_web_devicons()
end)

later(function()
  require("mini.extra").setup()
end)

later(function()
  require("mini.ai").setup()
end)

later(function()
  require("plugins.mini-bracketed")
end)

later(function()
  require("mini.bufremove").setup()
end)

later(function()
  require("plugins.mini-clue")
end)

later(function()
  require("plugins.mini-diff")
end)

later(function()
  require("plugins.mini-files")
end)

later(function()
  require("plugins.mini-git")
end)

later(function()
  require("plugins.mini-hipatterns")
end)

later(function()
  require("mini.misc").setup()
  MiniMisc.setup_auto_root()
end)

later(function()
  require("mini.pairs").setup()
end)

later(function()
  require("plugins.mini-pick")
end)

later(function()
  require("mini.surround").setup()
end)

later(function()
  require("mini.trailspace").setup()
end)

later(function()
  require("plugins.mini-visits")
end)

-- Other
later(function()
  require("persistence").setup()
end)

later(function()
  require("plugins.nvim-treesitter")
end)

later(function()
  require("ts-comments").setup()
end)

later(function()
  require("plugins.lspconfig")
end)

later(function()
  require("plugins.nvim-navic")
end)

later(function()
  require("plugins.blink")
end)

later(function()
  require("plugins.conform")
end)

later(function()
  require("plugins.lint")
end)

later(function()
  require("nvim-ts-autotag").setup()
end)

later(function()
  require("plugins.zk")
end)

later(function()
  require("plugins.lazygit")
end)

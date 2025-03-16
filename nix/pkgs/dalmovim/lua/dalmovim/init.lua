-- source: https://github.com/echasnovski/mini.deps/blob/main/scripts/init-deps-example.lua
local path_package = vim.fn.stdpath("data") .. "/site/"
require("mini.deps").setup({ path = { package = path_package } })

---@diagnostic disable: undefined-global
local now, later = MiniDeps.now, MiniDeps.later

now(function()
  require("dalmovim.commands")
  require("dalmovim.options")
  require("dalmovim.keymaps")
end)

-- Theme
now(function()
  require("tokyonight").setup({ style = "night" })
  vim.cmd([[colorscheme tokyonight]])
end)

-- Mini
now(function()
  require("mini.notify").setup()
  vim.notify = MiniNotify.make_notify()
end)

now(function()
  require("dalmovim.plugins.mini-starter")
end)

now(function()
  require("dalmovim.plugins.mini-statusline")
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
  require("dalmovim.plugins.mini-bracketed")
end)

later(function()
  require("mini.bufremove").setup()
end)

later(function()
  require("dalmovim.plugins.mini-clue")
end)

later(function()
  require("mini.diff").setup({ options = { wrap_goto = true } })
end)

later(function()
  require("dalmovim.plugins.mini-files")
end)

later(function()
  require("dalmovim.plugins.mini-git")
end)

later(function()
  require("dalmovim.plugins.mini-hipatterns")
end)

later(function()
  require("mini.misc").setup()
  MiniMisc.setup_auto_root()
end)

later(function()
  require("mini.operators").setup()
end)

later(function()
  require("mini.pairs").setup()
end)

later(function()
  require("dalmovim.plugins.mini-pick")
end)

later(function()
  require("mini.surround").setup()
end)

later(function()
  require("mini.trailspace").setup()
end)

later(function()
  require("dalmovim.plugins.mini-visits")
end)

-- Other
later(function()
  require("persistence").setup()
end)

later(function()
  require("dalmovim.plugins.nvim-treesitter")
end)

later(function()
  require("ts-comments").setup()
end)

later(function()
  require("dalmovim.plugins.lspconfig")
end)

later(function()
  require("dalmovim.plugins.nvim-navic")
end)

later(function()
  require("dalmovim.plugins.blink")
end)

later(function()
  require("dalmovim.plugins.conform")
end)

later(function()
  require("dalmovim.plugins.lint")
end)

later(function()
  require("nvim-ts-autotag").setup()
end)

later(function()
  require("dalmovim.plugins.zk")
end)

later(function()
  require("snacks").setup({
    lazygit = { enabled = true },
  })
end)

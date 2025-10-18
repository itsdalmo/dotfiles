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
  MiniIcons.tweak_lsp_kind()
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
  -- Don't show 'Text' suggestions
  local process_items_opts = { kind_priority = { Text = -1, Snippet = 99 } }
  local process_items = function(items, base)
    return MiniCompletion.default_process_items(items, base, process_items_opts)
  end
  require("mini.completion").setup({
    lsp_completion = { source_func = "omnifunc", auto_setup = false, process_items = process_items },
  })

  -- Set up LSP part of completion
  local on_attach = function(event)
    local buffer = event.buf
    local client = vim.lsp.get_client_by_id(event.data.client_id)

    if client.server_capabilities.documentSymbolProvider then
      require("nvim-navic").attach(client, buffer)
    end
    vim.bo[buffer].omnifunc = "v:lua.MiniCompletion.completefunc_lsp"
  end

  vim.api.nvim_create_autocmd("LspAttach", { callback = on_attach })
  vim.lsp.config("*", { capabilities = MiniCompletion.get_lsp_capabilities() })
end)

later(function()
  require("mini.keymap").setup()
  local map_multistep = require("mini.keymap").map_multistep

  local tab_steps = {
    "minisnippets_next",
    "minisnippets_expand",
    "pmenu_next",
    "jump_after_tsnode",
    "jump_after_close",
  }
  local shifttab_steps = {
    "minisnippets_prev",
    "pmenu_prev",
    "jump_before_tsnode",
    "jump_before_open",
  }

  map_multistep("i", "<Tab>", tab_steps)
  map_multistep("i", "<S-Tab>", shifttab_steps)
  map_multistep("i", "<CR>", { "pmenu_accept", "minipairs_cr" })
  map_multistep("i", "<BS>", { "minipairs_bs" })
end)

later(function()
  require("mini.snippets").setup()
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

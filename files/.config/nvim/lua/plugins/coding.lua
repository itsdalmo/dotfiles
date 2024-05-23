return {
  -- auto completion
  {
    "echasnovski/mini.completion",
    event = "VeryLazy",
    config = function()
      require("mini.completion").setup({
        lsp_completion = {
          source_func = "omnifunc",
          auto_setup = false,
        },
        set_vim_settings = true,
        fallback_action = "<c-x><c-f>", -- Path completion
      })
    end,
  },

  -- auto close html tags etc
  {
    "windwp/nvim-ts-autotag",
    event = "VeryLazy",
    opts = {},
  },
}

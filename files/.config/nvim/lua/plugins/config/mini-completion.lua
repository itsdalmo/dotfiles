local completion = require("mini.completion")
completion.setup({
  lsp_completion = {
    source_func = "omnifunc",
    auto_setup = false,
  },
  set_vim_settings = true,
  fallback_action = "<c-x><c-f>", -- Path completion
})

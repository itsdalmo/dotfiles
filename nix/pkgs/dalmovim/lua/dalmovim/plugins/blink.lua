local blink = require("blink.cmp")

blink.setup({
  keymap = {
    ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
    ["<C-e>"] = { "hide", "fallback" },
    ["<CR>"] = { "accept", "fallback" },

    ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
    ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },

    ["<Up>"] = { "select_prev", "fallback" },
    ["<Down>"] = { "select_next", "fallback" },

    ["<C-k>"] = { "scroll_documentation_up", "fallback" },
    ["<C-j>"] = { "scroll_documentation_down", "fallback" },
  },

  appearance = {
    use_nvim_cmp_as_default = false,
    nerd_font_variant = "mono",
  },

  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },

  completion = {
    accept = {
      auto_brackets = {
        enabled = true,
      },
    },
    menu = {
      auto_show = function(ctx)
        return ctx.mode ~= "cmdline"
      end,
    },
    documentation = {
      auto_show = true,
    },
  },
})

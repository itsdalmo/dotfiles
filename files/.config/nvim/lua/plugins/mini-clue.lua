local clue = require("mini.clue")
clue.setup({
  triggers = {
    -- Leader triggers
    { mode = "n", keys = "<Leader>" },
    { mode = "x", keys = "<Leader>" },

    -- Local leader triggers
    { mode = "n", keys = "<Localleader>" },
    { mode = "x", keys = "<Localleader>" },

    -- Built-in completion
    { mode = "i", keys = "<C-x>" },

    -- Brackets
    { mode = "n", keys = "]" },
    { mode = "n", keys = "[" },

    -- `g` key
    { mode = "n", keys = "g" },
    { mode = "x", keys = "g" },

    -- Marks
    { mode = "n", keys = "'" },
    { mode = "n", keys = "`" },
    { mode = "x", keys = "'" },
    { mode = "x", keys = "`" },

    -- Registers
    { mode = "n", keys = '"' },
    { mode = "x", keys = '"' },
    { mode = "i", keys = "<C-r>" },
    { mode = "c", keys = "<C-r>" },

    -- Window commands
    { mode = "n", keys = "<C-w>" },

    -- `z` key
    { mode = "n", keys = "z" },
    { mode = "x", keys = "z" },
  },

  clues = {
    -- Enhance this by adding descriptions for <Leader> mapping groups
    clue.gen_clues.builtin_completion(),
    clue.gen_clues.g(),
    clue.gen_clues.marks(),
    clue.gen_clues.registers(),
    clue.gen_clues.windows(),
    clue.gen_clues.z(),

    -- Custom clues
    { mode = "n", keys = "<Leader>b", desc = "+Buffers" },
    { mode = "n", keys = "<Leader>d", desc = "+Diagnostic" },
    { mode = "n", keys = "<Leader>f", desc = "+Files" },
    { mode = "n", keys = "<Leader>g", desc = "+Git" },
    { mode = "n", keys = "<Leader>l", desc = "+LSP" },
    { mode = "n", keys = "<Leader>n", desc = "+Notes" },
    { mode = "n", keys = "<Leader>q", desc = "+Quit/Session" },
    { mode = "n", keys = "<Leader>s", desc = "+Search" },
    { mode = "n", keys = "<Leader>t", desc = "+Toggle" },
    { mode = "n", keys = "<Leader>v", desc = "+Visits" },
    { mode = "n", keys = "<Leader>w", desc = "+Window" },
    { mode = "n", keys = "<Localleader>g", desc = "+Goto" },
  },
})

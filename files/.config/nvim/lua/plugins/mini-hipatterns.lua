local hi_words = require("mini.extra").gen_highlighter.words
require("mini.hipatterns").setup({
  highlighters = {
    TODO = hi_words({ "TODO", "Todo", "todo" }, "MiniHipatternsTodo"),
    NOTE = hi_words({ "NOTE", "Note", "note" }, "MiniHipatternsNote"),
    HACK = hi_words({ "HACK", "Hack", "hack" }, "MiniHipatternsHack"),
    FIXME = hi_words({ "FIXME", "Fixme", "fixme" }, "MiniHipatternsFixme"),
  },
})

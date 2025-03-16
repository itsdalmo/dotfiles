local words = MiniExtra.gen_highlighter.words
require("mini.hipatterns").setup({
  highlighters = {
    TODO = words({ "TODO" }, "MiniHipatternsTodo"),
    NOTE = words({ "NOTE" }, "MiniHipatternsNote"),
    HACK = words({ "HACK" }, "MiniHipatternsHack"),
    FIXME = words({ "FIXME" }, "MiniHipatternsFixme"),
  },
})

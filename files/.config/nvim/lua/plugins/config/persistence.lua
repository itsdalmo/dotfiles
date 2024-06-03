local persistence = require("persistence")
persistence.setup({
  options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals" },
})

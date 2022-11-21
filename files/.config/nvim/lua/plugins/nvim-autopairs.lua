local present, autopairs = pcall(require, "nvim-autopairs")

if not present then
  return
end

local cmp_autopairs = require('nvim-autopairs.completion.cmp')
local cmp = require("cmp")
cmp.event:on(
  "confirm_done",
  cmp_autopairs.on_confirm_done()
)

local options = {
  check_ts = true,
}
autopairs.setup(options)

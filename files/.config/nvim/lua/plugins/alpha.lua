local present, alpha = pcall(require, "alpha")

if not present then
  return
end

local dashboard = require "alpha.themes.dashboard"

-- setup footer
local function footer()
  local datetime = os.date "%Y/%m/%d %H:%M:%S"
  return datetime
end

-- menu
dashboard.section.buttons.val = {
  dashboard.button("n", " New file", ":ene <BAR> startinsert<CR>"),
  dashboard.button("f", " Find file", ':lua require("telescope.builtin").find_files({ hidden = true })<CR>'),
  dashboard.button("r", "  Recent files", ':lua require("telescope.builtin").oldfiles()<CR>'),
  dashboard.button("s", " Settings", ":e $MYVIMRC<CR>"),
  dashboard.button("u", " Update plugins", ":PackerUpdate<CR>"),
  dashboard.button("q", " Quit", ":qa<CR>"),
}

dashboard.section.footer.val = footer()

alpha.setup(dashboard.opts)

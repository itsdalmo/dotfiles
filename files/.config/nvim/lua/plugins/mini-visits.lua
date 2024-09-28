local extra = require("mini.extra")
local visits = require("mini.visits")
visits.setup({
  list = {
    filter = visits.gen_filter.this_session(),
  },
})

vim.keymap.set("n", "<leader>fr", function()
  extra.pickers.visit_paths({ filter = require("mini.visits").gen_filter.this_session() })
end, { desc = "Recent files" })

vim.keymap.set("n", "<leader>va", function()
  visits.add_label("core")
end, { desc = "Add to visits" })

vim.keymap.set("n", "<leader>vd", function()
  visits.remove_label({ filter = "core" })
end, { desc = "Remove from visits" })

vim.keymap.set("n", "<leader>vv", function()
  extra.pickers.visit_paths({ filter = "core" })
end, { desc = "Select visits" })

-- https://github.com/echasnovski/mini.nvim/blob/848c5e8f428faf843051768e0d56104cd02aea1f/doc/mini-visits.txt#L304-L316
local map_iterate_core = function(lhs, direction, desc)
  local opts = { filter = "core", sort = sort_latest, wrap = true }
  local rhs = function()
    visits.iterate_paths(direction, vim.fn.getcwd(), opts)
  end
  vim.keymap.set("n", lhs, rhs, { desc = desc })
end

map_iterate_core("[{", "last", "Core label (earliest)")
map_iterate_core("[[", "forward", "Core label (earlier)")
map_iterate_core("]]", "backward", "Core label (later)")
map_iterate_core("]}", "first", "Core label (latest)")

local visits = require("mini.visits")
visits.setup({
  list = {
    filter = visits.gen_filter.this_session(),
  },
})

-- https://github.com/echasnovski/mini.nvim/blob/fcf982a66df4c9e7ebb31a6a01c604caee2cd488/doc/mini-visits.txt#L304-L317
local sort_latest = MiniVisits.gen_sort.default({ recency_weight = 1 })
local map_iterate_core = function(lhs, direction, desc)
  local opts = { filter = "core", sort = sort_latest, wrap = false }
  local rhs = function()
    MiniVisits.iterate_paths(direction, vim.fn.getcwd(), opts)
  end
  vim.keymap.set("n", lhs, rhs, { desc = desc })
end

map_iterate_core("[[", "forward", "Core label (earlier)")
map_iterate_core("]]", "backward", "Core label (later)")

-- Add c-1 ... 9 shortcuts for the paths with the core label
map_shortcut = function(lhs, index, desc)
  local rhs = function()
    MiniVisits.iterate_paths("first", nil, { filter = "core", sort = sort_latest, n_times = index, wrap = false })
  end
  vim.keymap.set("n", lhs, rhs, { desc = desc })
end

map_shortcut("<c-1>", 1, "Goto visit 1")
map_shortcut("<c-2>", 2, "Goto visit 2")
map_shortcut("<c-3>", 3, "Goto visit 3")
map_shortcut("<c-4>", 4, "Goto visit 4")
map_shortcut("<c-5>", 5, "Goto visit 5")
map_shortcut("<c-6>", 6, "Goto visit 6")
map_shortcut("<c-7>", 7, "Goto visit 7")
map_shortcut("<c-8>", 8, "Goto visit 8")
map_shortcut("<c-9>", 9, "Goto visit 9")

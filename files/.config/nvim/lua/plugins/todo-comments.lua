require("todo-comments").setup({ highlight = { keyword = "bg" } })

local todosearch = require("todo-comments.search")
local todoconfig = require("todo-comments.config")
local pick = require("mini.pick")

pick.registry.todo_comments = function(local_opts)
  local callback = function(comments)
    local items = {}
    for _, c in ipairs(comments) do
      local icon = todoconfig.options.keywords[c.tag].icon or " "
      local text = string.format("%s %s", icon, c.text)
      table.insert(items, {
        text = text,
        path = c.filename,
        lnum = c.lnum,
        col = c.col,
      })
    end
    pick.set_picker_items(items)
  end
  local source = {
    name = "TODO/NOTE/HACK/FIXME Comments",
    items = todosearch.search(callback, { cwd = local_opts.cwd or "" }),
  }
  return pick.start({ source = source })
end

vim.keymap.set("n", "<leader>st", [[<cmd>Pick todo_comments<cr>]], { desc = "Todo/note/hack/fixme (cwd)" })
vim.keymap.set("n", "<leader>sT", [[<cmd>Pick todo_comments cwd="%:h"<cr>]], { desc = "Todo/note/hack/fixme" })

local pick = require("mini.pick")
pick.setup()
vim.ui.select = pick.ui_select

pick.registry.buffers = function(local_opts)
  local delete_buffer = function()
    local current = pick.get_picker_matches().current
    require("mini.bufremove").delete(current.bufnr)

    local items = {}
    for _, item in ipairs(pick.get_picker_items()) do
      if current.bufnr ~= item.bufnr then
        table.insert(items, item)
      end
    end
    pick.set_picker_items(items)
  end
  pick.builtin.buffers(local_opts, { mappings = { delete = { char = "<C-d>", func = delete_buffer } } })
end

-- https://github.com/echasnovski/mini.nvim/issues/830
pick.registry.files = function()
  local command = { "fd", "--type=file", "--color=never", "--follow", "--hidden" }
  local show_with_icons = function(buf_id, items, query)
    return pick.default_show(buf_id, items, query, { show_icons = true })
  end
  local source = { name = "Files (fd)", show = show_with_icons }
  return pick.builtin.cli({ command = command }, { source = source })
end

vim.keymap.set("n", "<leader><space>", [[<cmd>Pick commands<cr>]], { desc = "Commands" })
vim.keymap.set("n", "<leader>:", [[<cmd>Pick history<cr>]], { desc = "Command history" })
vim.keymap.set("n", "<leader>bb", [[<cmd>Pick buffers<cr>]], { desc = "Show all buffers" })
vim.keymap.set("n", "<leader>ff", [[<cmd>Pick files tool="rg"<cr>]], { desc = "Find files" })
vim.keymap.set("n", "<leader>fr", [[<cmd>Pick visit_paths recency_weight=1<cr>]], { desc = "Recent files" })
vim.keymap.set("n", "<leader>gl", [[<cmd>Pick git_commits path="%"<cr>]], { desc = "Show log (buffer)" })
vim.keymap.set("n", "<leader>gL", [[<cmd>Pick git_commits<cr>]], { desc = "Show log (repository)" })
vim.keymap.set("n", "<leader>ss", [[<cmd>Pick grep_live tool="rg"<cr>]], { desc = "Grep" })
vim.keymap.set("n", "<leader>sb", [[<cmd>Pick buf_lines scope="current"<cr>]], { desc = "Buffer" })
vim.keymap.set("n", "<leader>sh", [[<cmd>Pick help<cr>]], { desc = "Buffer" })
vim.keymap.set("n", "<leader>sr", [[<cmd>Pick resume<cr>]], { desc = "Resume" })
vim.keymap.set(
  "n",
  "<leader>st",
  [[<cmd>Pick hipatterns highlighters=TODO,NOTE,HACK,FIXME<cr>]],
  { desc = "Todo/note/hack/fixme" }
)
vim.keymap.set("n", "<leader>sd", [[<cmd>Pick diagnostic scope="current"<cr>]], { desc = "Diagnostics (buffer)" })
vim.keymap.set("n", "<leader>sD", [[<cmd>Pick diagnostic<cr>]], { desc = "Diagnostics (workspace)" })
vim.keymap.set("n", "<leader>sj", [[<cmd>Pick lsp scope="document_symbol"<cr>]], { desc = "Goto symbol" })
vim.keymap.set("n", "<leader>sJ", [[<cmd>Pick lsp scope="workspace_symbol"<cr>]], { desc = "Goto symbol (workspace)" })

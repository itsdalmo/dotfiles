local pick = require("mini.pick")
pick.setup({
  mappings = {
    scroll_left = "<C-h>",
    scroll_down = "<C-j>",
    scroll_up = "<C-k>",
    scroll_right = "<C-l>",
  },
})
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

-- Support specifying the current directory:
-- https://github.com/echasnovski/mini.nvim/blob/0f93724569ebf27b6b3bc7130d8044a9020a8cc5/doc/mini-pick.txt#L1135-L1140
pick.registry.grep_live = function(local_opts)
  local opts = { source = { cwd = local_opts.cwd } }
  local_opts.cwd = nil
  return pick.builtin.grep_live(local_opts, opts)
end

-- Custom picker to show hidden files using fd as the picker tool:
-- https://github.com/echasnovski/mini.nvim/issues/830
pick.registry.files = function(local_opts)
  local command = { "fd", "--type=file", "--color=never", "--follow", "--hidden" }
  local show_with_icons = function(buf_id, items, query)
    return pick.default_show(buf_id, items, query, { show_icons = true })
  end
  local source = { name = "Files (fd)", show = show_with_icons, cwd = local_opts.cwd }

  return pick.builtin.cli({ command = command }, { source = source })
end

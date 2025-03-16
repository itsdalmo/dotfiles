---@diagnostic disable: undefined-global
require("mini.pick").setup({
  mappings = {
    scroll_left = "<C-h>",
    scroll_down = "<C-j>",
    scroll_up = "<C-k>",
    scroll_right = "<C-l>",
  },
})
vim.ui.select = MiniPick.ui_select

MiniPick.registry.buffers = function(local_opts)
  local delete_buffer = function()
    local current = MiniPick.get_picker_matches().current
    MiniBufremove.delete(current.bufnr)

    local items = {}
    for _, item in ipairs(MiniPick.get_picker_items()) do
      if current.bufnr ~= item.bufnr then
        table.insert(items, item)
      end
    end
    MiniPick.set_picker_items(items)
  end
  MiniPick.builtin.buffers(local_opts, { mappings = { delete = { char = "<C-d>", func = delete_buffer } } })
end

-- Support specifying the current directory:
-- https://github.com/echasnovski/mini.nvim/blob/0f93724569ebf27b6b3bc7130d8044a9020a8cc5/doc/mini-pick.txt#L1135-L1140
MiniPick.registry.grep_live = function(local_opts)
  local opts = { source = { cwd = local_opts.cwd } }
  local_opts.cwd = nil
  return MiniPick.builtin.grep_live(local_opts, opts)
end

-- Custom picker to show hidden files using fd as the picker tool:
-- https://github.com/echasnovski/mini.nvim/issues/830
MiniPick.registry.files = function(local_opts)
  local command = { "fd", "--type=file", "--color=never", "--follow", "--hidden" }
  local show_with_icons = function(buf_id, items, query)
    return MiniPick.default_show(buf_id, items, query, { show_icons = true })
  end
  local source = { name = "Files (fd)", show = show_with_icons, cwd = local_opts.cwd }

  return MiniPick.builtin.cli({ command = command }, { source = source })
end

-- Custom picker for comments
MiniPick.registry.comments = function(local_opts)
  local search = function(cb, opts)
    local ok, Job = pcall(require, "plenary.job")
    if not ok then
      error("search requires https://github.com/nvim-lua/plenary.nvim")
      return
    end

    Job:new({
      command = "rg",
      args = {
        "--vimgrep",
        "--only-matching",
        "--color=never",
        "(TODO|NOTE|HACK|FIXME).*$",
        opts.cwd,
      },
      on_exit = vim.schedule_wrap(function(j, code)
        if code == 2 then
          error("rg" .. " failed with code " .. code .. "\n" .. table.concat(j:stderr_result(), "\n"))
        end
        cb(j:result())
      end),
    }):start()
  end

  local callback = function(lines)
    local items = {}
    for _, line in pairs(lines) do
      local file, row, col, text = line:match("^(.+):(%d+):(%d+):(.*)$")
      if file then
        table.insert(items, {
          text = text,
          path = file,
          lnum = tonumber(row),
          col = tonumber(col),
        })
      end
    end
    MiniPick.set_picker_items(items)
  end

  local source = {
    name = "TODO/NOTE/HACK/FIXME",
    items = search(callback, { cwd = local_opts.cwd or vim.fn.getcwd() }),
  }
  return MiniPick.start({ source = source })
end

-- Register a custom 'visit_paths' picker with a <C-d> mapping
MiniPick.registry.visit_paths = function(local_opts)
  local remove_label = function()
    local current = MiniPick.get_picker_matches().current
    MiniVisits.remove_label("core", current)

    local items = {}
    for _, item in ipairs(MiniPick.get_picker_items()) do
      if current ~= item then
        table.insert(items, item)
      end
    end
    MiniPick.set_picker_items(items)
  end

  -- Invoke the original visit_paths picker with the custom <C-d> mapping
  MiniExtra.pickers.visit_paths(local_opts, {
    mappings = {
      -- Define a new action named 'delete' bound to <C-d>
      delete = {
        char = "<C-d>",
        func = remove_label,
      },
    },
  })
end

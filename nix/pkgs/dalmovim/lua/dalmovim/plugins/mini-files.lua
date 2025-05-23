local files = require("mini.files")
files.setup({
  mappings = {
    go_in = "L",
    go_in_plus = "l",
  },
  windows = {
    preview = true,
    width_focus = 30,
    width_preview = 30,
  },
  options = {
    use_as_default_explorer = true,
  },
})

local map_split = function(buf_id, lhs, direction)
  local rhs = function()
    local new_target_window
    vim.api.nvim_win_call(files.get_explorer_state().target_window, function()
      vim.cmd("belowright " .. direction .. " split")
      new_target_window = vim.api.nvim_get_current_win()
    end)

    files.set_target_window(new_target_window)
    files.go_in({ close_on_file = true })
  end

  local desc = "Split " .. direction
  vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
end

local yank_path = function()
  local path = (files.get_fs_entry() or {}).path
  if path == nil then
    return vim.notify("Cursor is not on valid entry")
  end
  vim.fn.setreg(vim.v.register, vim.fn.fnamemodify(path, ":.")) -- Relative path
end

vim.api.nvim_create_autocmd("User", {
  pattern = "MiniFilesBufferCreate",
  callback = function(args)
    local buf_id = args.data.buf_id
    map_split(buf_id, "<c-s>", "horizontal")
    map_split(buf_id, "<c-v>", "vertical")
    vim.keymap.set("n", "gy", yank_path, { buffer = buf_id, desc = "Yank path" })
  end,
})

require("mini.git").setup()

-- Only include branch name in the git summary
vim.api.nvim_create_autocmd("User", {
  pattern = "MiniGitUpdated",
  callback = function(data)
    local summary = vim.b[data.buf].minigit_summary
    vim.b[data.buf].minigit_summary_string = summary.head_name or ""
  end,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "MiniGitCommandSplit",
  callback = function(data)
    if data.data.git_subcommand ~= "blame" then
      return
    end

    -- Align blame output with source
    local win_src = data.data.win_source
    vim.wo.wrap = false
    vim.fn.winrestview({ topline = vim.fn.line("w0", win_src) })
    vim.api.nvim_win_set_cursor(0, { vim.fn.line(".", win_src), 0 })

    -- Bind both windows so that they scroll together
    vim.wo[win_src].scrollbind, vim.wo.scrollbind = true, true
  end,
})

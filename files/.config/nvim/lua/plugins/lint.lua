local lint = require("lint")

lint.linters_by_ft = {
  bzl = { "buildifier" },
  fish = { "fish" },
  go = { "golangcilint" },
  proto = { "buf_lint" },
  sh = { "shellcheck" },
}

local group = vim.api.nvim_create_augroup("lint", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
  group = group,
  callback = function()
    lint.try_lint()
  end,
})

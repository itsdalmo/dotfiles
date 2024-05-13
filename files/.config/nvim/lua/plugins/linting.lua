return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      bzl = { "buildifier" },
      fish = { "fish" },
      go = { "golangcilint" }, -- TODO: Move to lsp?
      proto = { "buf_lint" },
      sh = { "shellcheck" },
    }

    local group = vim.api.nvim_create_augroup("lint", { clear = true })
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = group,
      callback = function()
        require("lint").try_lint()
      end,
    })
  end,
}

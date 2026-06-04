vim.treesitter.language.register("html", "gohtml")
vim.treesitter.language.register("river", "alloy")

vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    if pcall(vim.treesitter.start) then
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

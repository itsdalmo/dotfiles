local M = {}

local conceallevel = 3
function M.toggle_conceal()
  local current = vim.opt_local["conceallevel"]:get()
  if current == 0 then
    vim.opt_local["conceallevel"] = conceallevel
    vim.notify("conceal enabled")
  else
    conceallevel = current
    vim.opt_local["conceallevel"] = 0
    vim.notify("conceal disabled")
  end
end

local autoformat = true
function M.toggle_autoformat()
  autoformat = not autoformat
  if autoformat then
    vim.b.autoformat = nil
    vim.notify("autoformat enabled")
  else
    vim.b.autoformat = false
    vim.notify("autoformat disabled")
  end
end

local diagnostics = true
function M.toggle_diagnostics()
  diagnostics = not diagnostics
  if diagnostics then
    vim.diagnostic.enable()
    vim.notify("diagnostics enabled")
  else
    vim.notify("diagnostics disabled")
    vim.diagnostic.disable()
  end
end

local diff = false
function M.toggle_diff()
  require("mini.diff").toggle_overlay()
  diff = not diff
  if diff then
    vim.notify("git diff enabled")
  else
    vim.notify("git diff disabled")
  end
end

function M.format(opts)
  local buf = vim.api.nvim_get_current_buf()
  if vim.b.autoformat == false and not (opts and opts.force) then
    return
  end
  require("conform").format({ bufnr = buf, lsp_fallback = true })
end

function M.diagnostic_goto(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    go({ severity = severity })
  end
end

function M.float_term(cmd, opts)
  opts = vim.tbl_deep_extend("force", {
    size = { width = 0.9, height = 0.9 },
  }, opts or {})
  local float = require("lazy.util").float_term(cmd, opts)
  if opts.esc_esc == false then
    vim.keymap.set("t", "<esc>", "<esc>", { buffer = float.buf, nowait = true })
  end
end

M.icons = {
  diagnostics = {
    Error = " ",
    Warn = " ",
    Hint = " ",
    Info = " ",
  },
  git = {
    added = " ",
    modified = " ",
    removed = " ",
  },
  kinds = {
    Array = " ",
    Boolean = " ",
    Class = " ",
    Color = " ",
    Constant = " ",
    Constructor = " ",
    Copilot = " ",
    Enum = " ",
    EnumMember = " ",
    Event = " ",
    Field = " ",
    File = " ",
    Folder = " ",
    Function = " ",
    Interface = " ",
    Key = " ",
    Keyword = " ",
    Method = " ",
    Module = " ",
    Namespace = " ",
    Null = " ",
    Number = " ",
    Object = " ",
    Operator = " ",
    Package = " ",
    Property = " ",
    Reference = " ",
    Snippet = " ",
    String = " ",
    Struct = " ",
    Text = " ",
    TypeParameter = " ",
    Unit = " ",
    Value = " ",
    Variable = " ",
  },
}

return M

local M = {}

local conceallevel = 3
function M.toggle_conceal()
  local current = vim.opt_local["conceallevel"]:get()
  if current == 0 then
    vim.opt_local["conceallevel"] = conceallevel
  else
    conceallevel = current
    vim.opt_local["conceallevel"] = 0
  end
end

local autoformat = true
function M.toggle_autoformat()
  autoformat = not autoformat
  if autoformat then
    vim.b.autoformat = nil
  else
    vim.b.autoformat = false
  end
end

local diagnostics = true
function M.toggle_diagnostics()
  diagnostics = not diagnostics
  if diagnostics then
    vim.diagnostic.enable()
  else
    vim.diagnostic.disable()
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

return M

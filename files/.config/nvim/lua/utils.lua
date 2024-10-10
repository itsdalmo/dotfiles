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

function M.toggle_wrap()
  local wrap = not vim.opt.wrap:get()
  if wrap then
    vim.opt.wrap = true
    vim.notify("soft wrap enabled")
  else
    vim.opt.wrap = false
    vim.notify("soft wrap disabled")
  end
end

local diagnostics = true
function M.toggle_diagnostics()
  diagnostics = not diagnostics
  if diagnostics then
    vim.diagnostic.enable()
    vim.notify("diagnostics enabled")
  else
    vim.diagnostic.disable()
    vim.notify("diagnostics disabled")
  end
end

local diffthis = false
function M.toggle_diffthis()
  diffthis = not diffthis
  if diffthis then
    vim.cmd("windo diffthis")
  else
    vim.cmd("windo diffoff")
  end
end

function M.toggle_diff()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.b[bufnr].diff_enabled = not (vim.b[bufnr].diff_enabled or false)

  require("mini.diff").toggle_overlay()

  if vim.b[bufnr].diff_enabled then
    vim.notify("git diff enabled")
  else
    vim.notify("git diff disabled")
  end
end

function M.toggle_winbar()
  local bufnr = vim.api.nvim_get_current_buf()
  local winbar = not (vim.b[bufnr].winbar_enabled or false)
  vim.b[bufnr].winbar_enabled = winbar

  if winbar then
    vim.wo.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
    vim.b.navic_lazy_update_context = false
    vim.notify("winbar enabled")
  else
    vim.wo.winbar = ""
    vim.b.navic_lazy_update_context = true
    vim.notify("winbar disabled")
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

return M

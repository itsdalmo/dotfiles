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

function M.toggle_autoformat()
  local bufnr = vim.api.nvim_get_current_buf()
  local autoformat = not (vim.b[bufnr].autoformat ~= false)
  vim.b[bufnr].autoformat = autoformat
  if autoformat then
    vim.notify("autoformat enabled")
  else
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

  MiniDiff.toggle_overlay()
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

local zoom = false
function M.toggle_zoom()
  zoom = not zoom
  if zoom then
    vim.api.nvim_input("<C-w>_<C-w>|")
  else
    vim.api.nvim_input("<C-w>=")
  end
end

function M.format(opts)
  local buf = vim.api.nvim_get_current_buf()
  if vim.b[buf].autoformat == false and not (opts and opts.force) then
    return
  end
  require("conform").format({ bufnr = buf, lsp_fallback = true })
end

function M.open_github()
  local cmd = { "gh", "browse", vim.fn.expand("%:.") }
  local git = (MiniGit.get_buf_data() or {})

  if git.head_name ~= nil then
    table.insert(cmd, "--branch")
    table.insert(cmd, git.head_name)
  end

  local output = vim.fn.system(cmd)
  local exit_code = vim.v.shell_error

  if exit_code ~= 0 then
    vim.notify("Failed to open on github: " .. output, vim.log.levels.ERROR)
  end
end

return M

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
  local ft = vim.bo[buf].filetype
  local have_nls = #require("null-ls.sources").get_available(ft, "NULL_LS_FORMATTING") > 0

  vim.lsp.buf.format({
    bufnr = buf,
    filter = function(client)
      if have_nls then
        return client.name == "null-ls"
      end
      return client.name ~= "null-ls"
    end,
  })
end

function M.diagnostic_goto(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    go({ severity = severity })
  end
end

function M.lsp_attach_autocmd(on_attach)
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local buffer = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      on_attach(client, buffer)
    end,
  })
end

function M.format_on_attach(client, bufnr)
  if
    client.config
    and client.config.capabilities
    and client.config.capabilities.documentFormattingProvider == false
  then
    return
  end

  if client.supports_method("textDocument/formatting") then
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = vim.api.nvim_create_augroup("LspFormat." .. bufnr, {}),
      buffer = bufnr,
      callback = function()
        if autoformat then
          M.format()
        end
      end,
    })
  end
end

function M.keymap_on_attach(client, bufnr)
  vim.keymap.set("n", "<localleader>k", vim.lsp.buf.hover, { desc = "Hover", buffer = bufnr })
  vim.keymap.set("n", "<localleader>d", vim.diagnostic.open_float, { desc = "Line Diagnostics", buffer = bufnr })
  vim.keymap.set("n", "<localleader>gr", "<cmd>Telescope lsp_references<cr>", { desc = "References", buffer = bufnr })
  vim.keymap.set("n", "<localleader>gD", vim.lsp.buf.declaration, { desc = "Goto Declaration", buffer = bufnr })
  vim.keymap.set(
    "n",
    "<localleader>gi",
    "<cmd>Telescope lsp_implementations<cr>",
    { desc = "Goto Implementation", buffer = bufnr }
  )
  vim.keymap.set(
    "n",
    "<localleader>gt",
    "<cmd>Telescope lsp_type_definitions<cr>",
    { desc = "Goto Type Definition", buffer = bufnr }
  )

  vim.keymap.set("n", "]d", M.diagnostic_goto(true), { desc = "Next Diagnostic", buffer = bufnr })
  vim.keymap.set("n", "[d", M.diagnostic_goto(false), { desc = "Prev Diagnostic", buffer = bufnr })
  vim.keymap.set("n", "]w", M.diagnostic_goto(true, "WARN"), { desc = "Next Warning", buffer = bufnr })
  vim.keymap.set("n", "[w", M.diagnostic_goto(false, "WARN"), { desc = "Prev Warning", buffer = bufnr })
  vim.keymap.set("n", "]e", M.diagnostic_goto(true, "ERROR"), { desc = "Next Error", buffer = bufnr })
  vim.keymap.set("n", "[e", M.diagnostic_goto(false, "ERROR"), { desc = "Prev Error", buffer = bufnr })

  if client.server_capabilities.codeActionProvider then
    vim.keymap.set({ "n", "v" }, "<localleader>.", vim.lsp.buf.code_action, { desc = "Code Action", buffer = bufnr })
  end

  if client.server_capabilities.renameProvider then
    vim.keymap.set("n", "<localleader>r", vim.lsp.buf.rename, { desc = "Rename", buffer = bufnr })
  end

  if client.server_capabilities.signatureHelpProvider then
    vim.keymap.set("n", "<localleader>s", vim.lsp.buf.signature_help, { desc = "Signature Help", buffer = bufnr })
  end

  if client.server_capabilities.definitionProvider then
    vim.keymap.set(
      "n",
      "<localleader>gd",
      "<cmd>Telescope lsp_definitions<cr>",
      { desc = "Goto Definition", buffer = bufnr }
    )
  end

  local format = function()
    M.format({ force = true })
  end

  if client.server_capabilities.documentFormattingProvider then
    vim.keymap.set("n", "<localleader>=", format, { desc = "Format Document", buffer = bufnr })
  end

  if client.server_capabilities.documentRangeFormattingProvider then
    vim.keymap.set("v", "<localleader>=", format, { desc = "Format Range", buffer = bufnr })
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

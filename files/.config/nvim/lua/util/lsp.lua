local Util = require("lazy.core.util")

local M = {}

M.autoformat = true

function M.toggle_autoformat()
  if vim.b.autoformat == false then
    vim.b.autoformat = nil
    M.autoformat = true
  else
    M.autoformat = not M.autoformat
  end
  if M.autoformat then
    Util.info("Enabled format on save", { title = "Format" })
  else
    Util.warn("Disabled format on save", { title = "Format" })
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

function M.autocmd_on_attach(on_attach)
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local buffer = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      on_attach(client, buffer)
    end,
  })
end

function M.format_on_attach(client, buf)
  if
    client.config
    and client.config.capabilities
    and client.config.capabilities.documentFormattingProvider == false
  then
    return
  end

  if client.supports_method("textDocument/formatting") then
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = vim.api.nvim_create_augroup("LspFormat." .. buf, {}),
      buffer = buf,
      callback = function()
        if M.autoformat then
          M.format()
        end
      end,
    })
  end
end

function M.keymap_on_attach(client, buffer)
  vim.keymap.set("n", "]e", M.diagnostic_goto(true), { desc = "Next Diagnostic", buffer = buffer })
  vim.keymap.set("n", "[e", M.diagnostic_goto(false), { desc = "Prev Diagnostic", buffer = buffer })
  vim.keymap.set("n", "<localleader>k", vim.lsp.buf.hover, { desc = "Hover", buffer = buffer })
  vim.keymap.set("n", "<localleader>d", vim.diagnostic.open_float, { desc = "Line Diagnostics", buffer = buffer })
  vim.keymap.set("n", "<localleader>gr", "<cmd>Telescope lsp_references<cr>", { desc = "References", buffer = buffer })
  vim.keymap.set("n", "<localleader>gD", vim.lsp.buf.declaration, { desc = "Goto Declaration", buffer = buffer })
  vim.keymap.set(
    "n",
    "<localleader>gi",
    "<cmd>Telescope lsp_implementations<cr>",
    { desc = "Goto Implementation", buffer = buffer }
  )
  vim.keymap.set(
    "n",
    "<localleader>gt",
    "<cmd>Telescope lsp_type_definitions<cr>",
    { desc = "Goto Type Definition", buffer = buffer }
  )

  -- TODO: Stick to d for diagnostics?
  vim.keymap.set("n", "]d", M.diagnostic_goto(true), { desc = "Next Diagnostic", buffer = buffer })
  vim.keymap.set("n", "[d", M.diagnostic_goto(false), { desc = "Prev Diagnostic", buffer = buffer })

  if client.server_capabilities.codeActionProvider then
    vim.keymap.set({ "n", "v" }, "<localleader>.", vim.lsp.buf.code_action, { desc = "Code Action", buffer = buffer })
  end

  if client.server_capabilities.renameProvider then
    vim.keymap.set("n", "<localleader>r", vim.lsp.buf.rename, { desc = "Rename", buffer = buffer })
  end

  if client.server_capabilities.signatureHelpProvider then
    vim.keymap.set("n", "<localleader>s", vim.lsp.buf.signature_help, { desc = "Signature Help", buffer = buffer })
  end

  if client.server_capabilities.definitionProvider then
    vim.keymap.set(
      "n",
      "<localleader>gd",
      "<cmd>Telescope lsp_definitions<cr>",
      { desc = "Goto Definition", buffer = buffer }
    )
  end

  local format = function()
    M.format({ force = true })
  end

  if client.server_capabilities.documentFormattingProvider then
    vim.keymap.set("n", "<localleader>=", format, { desc = "Format Document", buffer = buffer })
  end

  if client.server_capabilities.documentRangeFormattingProvider then
    vim.keymap.set("v", "<localleader>=", format, { desc = "Format Range", buffer = buffer })
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

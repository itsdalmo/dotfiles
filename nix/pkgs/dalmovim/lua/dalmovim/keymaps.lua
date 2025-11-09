local function map(mode, shortcut, command, desc, opts)
  opts = opts or {}
  opts.desc = desc
  vim.keymap.set(mode, shortcut, command, opts)
end

-- Keep search matches in the middle of the window.
map("n", "n", [[nzzzv]])
map("n", "N", [[Nzzzv]])

-- Indent visual selected code without unselecting and going back to normal mode
map("v", ">", [[>gv]])
map("v", "<", [[<gv]])

-- Jump between splits
map("n", "<C-k>", [[<cmd>wincmd k<cr>]])
map("n", "<C-j>", [[<cmd>wincmd j<cr>]])
map("n", "<C-h>", [[<cmd>wincmd h<cr>]])
map("n", "<C-l>", [[<cmd>wincmd l<cr>]])

-- [ (most of these are set up with mini.bracketed)
map("n", "]t", "gt", "Next tab")
map("n", "[t", "gT", "Prev tab")

-- Buffers
map("n", "<leader>bb", [[<cmd>Pick buffers<cr>]], "Show all buffers")
map("n", "<leader>bd", [[<cmd>lua MiniBufremove.delete()<cr>]], "Delete buffer")
map("n", "<leader>bD", [[<cmd>lua MiniBufremove.delete(0, true)<cr>]], "Delete buffer!")

-- Files
map("n", "<leader>fn", [[<cmd>enew<cr>]], "New file")
map("n", "<leader>ff", [[<cmd>Pick files<cr>]], "Find files (cwd)")
map("n", "<leader>fF", [[<cmd>Pick files cwd=vim.fn.expand("%:h")<cr>]], "Find files")
map("n", "<leader>fr", [[<cmd>Pick visit_paths filter=MiniVisits.gen_filter.this_session()<cr>]], "Recent files")
map("n", "<leader>ft", [[<cmd>lua MiniFiles.open()<cr>]], "File tree (cwd)")
map("n", "<leader>fl", [[<cmd>lua MiniFiles.open(vim.api.nvim_buf_get_name(0), true)<cr>]], "File tree (current file)")

-- Git
map("n", "<leader>gg", [[<cmd>lua Snacks.lazygit.open()<cr>]], "Lazygit")
map("n", "<leader>gs", [[<cmd>lua MiniGit.show_at_cursor()<cr>]], "Show at cursor")
map("n", "<leader>gl", [[<cmd>lua Snacks.lazygit.log_file()<cr>]], "Show log (buffer)")
map("n", "<leader>gL", [[<cmd>lua Snacks.lazygit.log()<cr>]], "Show log (repository)")
map("n", "<leader>gd", [[<cmd>lua require("dalmovim.utils").toggle_diff()<cr>]], "Toggle diff")
map("n", "<leader>go", [[<cmd>lua require("dalmovim.utils").open_github()<cr>]], "Open current file on Github")
map("n", "<leader>gb", [[<cmd>vert Git blame -- %<cr>]], "Blame")

-- LSP
map("n", "<leader>li", [[<cmd>LspInfo<cr>]], "Info")
map("n", "<leader>lr", [[<cmd>LspRestart<cr>]], "Restart")

-- Major
map({ "n", "v" }, "<localleader>.", [[<cmd>lua vim.lsp.buf.code_action()<cr>]], "Code Action")
map("n", "<localleader>=", [[<cmd>lua require("dalmovim.utils").format({ force = true })<cr>]], "Format")
map("n", "<localleader>+", [[<cmd>lua MiniTrailspace.trim()<cr>]], "Trim whitespace")
map("n", "<localleader>k", [[<cmd>lua vim.lsp.buf.hover()<cr>]], "Hover")
map("n", "<localleader>r", [[<cmd>lua vim.lsp.buf.rename()<cr>]], "Rename")
map("n", "<localleader>s", [[<cmd>lua vim.lsp.buf.signature_help()<cr>]], "Signature Help")
map("n", "<localleader>d", [[<cmd>lua vim.diagnostic.open_float()<cr>]], "Line Diagnostics")
map("n", "<localleader>gr", [[<cmd>Pick lsp scope="references"<cr>]], "References")
map("n", "<localleader>gd", [[<cmd>Pick lsp scope="definition"<cr>]], "Goto Definition")
map("n", "<localleader>gD", [[<cmd>Pick lsp scope="declaration"<cr>]], "Goto Declaration")
map("n", "<localleader>gi", [[<cmd>Pick lsp scope="implementation"<cr>]], "Goto Implementation")
map("n", "<localleader>gt", [[<cmd>Pick lsp scope="type_definition"<cr>]], "Goto Type Definition")

-- Notes
map("n", "<leader>nn", [[<cmd>ZkNew { } <cr>]], "New note")
map("n", "<leader>nf", [[<cmd>ZkNotes { sort = { 'modified' } }<cr>]], "Find note")
map("n", "<leader>nd", [[<cmd>ZkNew { dir = "daily" }<cr>]], "Open daily note")
map("n", "<leader>nt", [[<cmd>ZkNew { dir = "daily", date = "tomorrow" }<cr>]], "Open tomorrows daily note")

-- Quit
map("n", "<leader>qq", [[<cmd>qa<cr>]], "Quit all")

-- Search
map("n", "<leader>sc", [[<cmd>noh<cr>]], "Clear search")
map("n", "<leader>ss", [[<cmd>Pick grep_live tool="rg"<cr>]], "Grep (cwd)")
map("n", "<leader>sS", [[<cmd>Pick grep_live tool="rg" cwd=vim.fn.expand("%:h")<cr>]], "Grep")
map("n", "<leader>sb", [[<cmd>Pick buf_lines scope="current"<cr>]], "Buffer")
map("n", "<leader>sh", [[<cmd>Pick help<cr>]], "Help")
map("n", "<leader>sr", [[<cmd>Pick resume<cr>]], "Resume")
map("n", "<leader>sd", [[<cmd>Pick diagnostic scope="current"<cr>]], "Diagnostics (buffer)")
map("n", "<leader>sD", [[<cmd>Pick diagnostic<cr>]], "Diagnostics (workspace)")
map("n", "<leader>sj", [[<cmd>Pick lsp scope="document_symbol"<cr>]], "Goto symbol")
map("n", "<leader>sJ", [[<cmd>Pick lsp scope="workspace_symbol"<cr>]], "Goto symbol (workspace)")
map("n", "<leader>st", [[<cmd>Pick comments<cr>]], "Todo/note/hack/fixme (cwd)")
map("n", "<leader>sT", [[<cmd>Pick comments cwd=vim.fn.expand("%:h")<cr>]], "Todo/note/hack/fixme")
map("n", "<leader>s:", [[<cmd>Pick history scope=":"<cr>]], "Command history")

-- Toggles
map("n", "<leader>tf", [[<cmd>lua require("dalmovim.utils").toggle_autoformat()<cr>]], "Autoformat")
map("n", "<leader>tc", [[<cmd>lua require("dalmovim.utils").toggle_conceal()<cr>]], "Conceal")
map("n", "<leader>td", [[<cmd>lua require("dalmovim.utils").toggle_diagnostics()<cr>]], "Diagnostics")
map("n", "<leader>tw", [[<cmd>lua require("dalmovim.utils").toggle_wrap()<cr>]], "Wrap (soft)")
map("n", "<leader>tD", [[<cmd>lua require("dalmovim.utils").toggle_diffthis()<cr>]], "Diffthis")
map("n", "<leader>tb", [[<cmd>lua require("dalmovim.utils").toggle_winbar()<cr>]], "Breadcrumbs (navic)")

-- Visits
map("n", "<leader>vv", [[<cmd>Pick visit_paths recency_weight=0 filter="core"<cr>]], "Select visits")
map("n", "<leader>va", [[<cmd>lua MiniVisits.add_label("core")<cr>]], "Add to visits")
map("n", "<leader>vd", [[<cmd>lua MiniVisits.remove_label("core")<cr>]], "Remove from visits")

-- Window
map("n", "<leader>wv", [[<cmd>vsplit<cr>]], "Split vertical")
map("n", "<leader>ws", [[<cmd>split<cr>]], "Split horizontal")
map("n", "<leader>w<left>", [[<C-w><]], "Resize left")
map("n", "<leader>w<right>", [[<C-w>>]], "Resize right")
map("n", "<leader>w<up>", [[<C-w>+]], "Resize up")
map("n", "<leader>w<down>", [[<C-w>-]], "Resize down")
map("n", "<C-z>", [[<cmd>lua require("dalmovim.utils").toggle_zoom()<cr>]], "Zoom window")

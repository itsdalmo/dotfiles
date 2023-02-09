local present, wk = pcall(require, "which-key")

if not present then
  return
end

local options = {
  icons = {
    breadcrumb = "»",
    separator = "  ",
    group = "+",
  },

  popup_mappings = {
    scroll_down = "<c-d>",
    scroll_up = "<c-u>",
  },

  window = {
    border = "none",
  },

  layout = {
    spacing = 6,
  },

  hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " },

  triggers_blacklist = {
    i = { "j", "k" },
    v = { "j", "k" },
  },
}

local major = {
  name = "+major",

  ["<tab>"] = { "<C-o>", "Go back" },
  ["."] = { ":lua vim.lsp.buf.code_action()<CR>", "Quick fix" },
  [" "] = { ":lua vim.lsp.buf.code_action()<CR>", "Code action" },
  ["="] = { ":lua vim.lsp.buf.format({ async = true })<CR>", "Format code" },

  r = { ":lua vim.lsp.buf.rename()<CR>", "Rename" },
  k = { ":lua vim.lsp.buf.hover()<CR>", "Hover" },
  g = {
    name = "+goto",
    r = { "<cmd>Trouble lsp_references<CR>", "Go to references" },
    d = { "<cmd>Trouble lsp_definitions<CR>", "Go to definition" },
    i = { "<cmd>Trouble lsp_implementations<CR>", "Go to implementation" },
    t = { "<cmd>Trouble lsp_type_definitions<CR>", "Go to type definition" },
    j = { ':lua require("telescope.builtin").lsp_document_symbols()<CR>', "Jump to symbol" },
    J = { ':lua require("telescope.builtin").lsp_workspace_symbols()<CR>', "Jump to symbol in workspace" },
  },
}

local leader = {
  ["<leader>"] = { ':lua require("telescope.builtin").commands()<CR>', "Commands" },
  ["<tab>"] = { ":e #<cr>lua", "Last buffer" },

  b = {
    name = "+buffers",
    b = { ':lua require("telescope.builtin").buffers()<CR>', "Show all buffers" },
    d = { ":bd<CR>", "Close active buffer" },
  },
  e = {
    name = "+errors",
    e = { "<cmd>TroubleToggle<cr>", "Show errors" },
    l = { "<cmd>Trouble document_diagnostics<cr>", "List document errors" },
    L = { "<cmd>Trouble workspace_diagnostics<cr>", "List workspace errors" },
    n = { ":lua vim.diagnostic.goto_next()<CR>", "Go to next error" },
    p = { ":lua vim.diagnostic.goto_prev()<CR>", "Go to previous error" },
  },
  f = {
    name = "+files",
    f = { ':lua require("telescope.builtin").find_files({ hidden = true })<CR>', "Find file" },
    r = { ':lua require("telescope.builtin").oldfiles({ only_cwd = true })<CR>', "Recent files" },
    t = { ':lua require("nvim-tree").toggle(false)<CR>', "File tree" },
    l = { ':lua require("nvim-tree").open({ find_file = true })<CR>', "Show active file in tree" },
    n = { ":enew<cr>", "New file" },
  },
  g = {
    c = { "<Cmd>Telescope git_branches<CR>", "branches" },
    l = { "<Cmd>Telescope git_commits<CR>", "commits" },
    s = { ':lua require("neogit").open()<CR>', "status" },
    d = { ':lua require("gitsigns").diffthis()<CR>', "diff" },
  },
  s = {
    name = "+search",
    s = { ':lua require("telescope.builtin").live_grep()<CR>', "Search in files" },
    c = { ":noh<CR>", "Clear search" },
    j = { ':lua require("telescope.builtin").lsp_document_symbols()<CR>', "Jump to symbol" },
    J = { ':lua require("telescope.builtin").lsp_workspace_symbols()<CR>', "Jump to symbol in workspace" },
  },
  w = {
    name = "+window",
    s = { ":split<CR>", "Split horizontal" },
    v = { ":vsplit<CR>", "Split vertical" },
    q = { "<C-w>q", "Quit a window" },
    ["<left>"] = { "<C-w><", "Resize left" },
    ["<right>"] = { "<C-w>>", "Resize right" },
    ["<up>"] = { "<C-w>+", "Resize up" },
    ["<down>"] = { "<C-w>-", "Resize down" },
  },
  q = {
    name = "+quit",
    q = { ":qa<CR>", "Quit" },
    r = { ":source $MYVIMRC<CR>", "Reload config" }, -- TODO: https://dev.to/reobin/reload-init-vim-without-restarting-neovim-1h82
  },
}

wk.setup(options)

wk.register(major, {
  prefix = "<localleader>",
})

wk.register(leader, {
  prefix = "<leader>",
})

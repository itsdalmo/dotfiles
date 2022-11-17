local present, telescope = pcall(require, "telescope")

if not present then
  return
end

local actions = require "telescope.actions"

local options = {
  defaults = {
    prompt_prefix = "   ",
    mappings = {
      n = {
        ["q"] = actions.close,
        ["<C-j>"] = actions.preview_scrolling_down,
        ["<C-k>"] = actions.preview_scrolling_up,
        ["<C-d>"] = actions.delete_buffer,
      },
      i = {
        ["<C-j>"] = actions.preview_scrolling_down,
        ["<C-k>"] = actions.preview_scrolling_up,
        ["<C-d>"] = actions.delete_buffer,
      },
    },
    vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "--hidden",
      "--glob=!.git/",
    },
  },
  pickers = {
    find_files = {
      find_command = { "fd", "--type", "f", "--strip-cwd-prefix" },
    },
  },
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_dropdown {}
    }
  }
}

telescope.setup(options)
telescope.load_extension('fzf')
telescope.load_extension("ui-select")

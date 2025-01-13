local words = require("mini.extra").gen_highlighter.words
require("mini.hipatterns").setup({
  highlighters = {
    TODO = words({ "TODO" }, "MiniHipatternsTodo"),
    NOTE = words({ "NOTE" }, "MiniHipatternsNote"),
    HACK = words({ "HACK" }, "MiniHipatternsHack"),
    FIXME = words({ "FIXME" }, "MiniHipatternsFixme"),
  },
})

-- Custom picker for comments
local pick = require("mini.pick")
pick.registry.comments = function(local_opts)
  local search = function(cb, opts)
    local ok, Job = pcall(require, "plenary.job")
    if not ok then
      error("search requires https://github.com/nvim-lua/plenary.nvim")
      return
    end

    Job:new({
      command = "rg",
      args = {
        "--vimgrep",
        "--only-matching",
        "--color=never",
        "(TODO|NOTE|HACK|FIXME).*$",
        opts.cwd,
      },
      on_exit = vim.schedule_wrap(function(j, code)
        if code == 2 then
          error("rg" .. " failed with code " .. code .. "\n" .. table.concat(j:stderr_result(), "\n"))
        end
        cb(j:result())
      end),
    }):start()
  end

  local callback = function(lines)
    local items = {}
    for _, line in pairs(lines) do
      local file, row, col, text = line:match("^(.+):(%d+):(%d+):(.*)$")
      if file then
        table.insert(items, {
          text = text,
          path = file,
          lnum = tonumber(row),
          col = tonumber(col),
        })
      end
    end
    pick.set_picker_items(items)
  end

  local source = {
    name = "TODO/NOTE/HACK/FIXME",
    items = search(callback, { cwd = local_opts.cwd or vim.fn.getcwd() }),
  }
  return pick.start({ source = source })
end

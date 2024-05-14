local wezterm = require("wezterm")

local cfg = {}

-- General
cfg.initial_cols = 180
cfg.initial_rows = 48
cfg.audible_bell = "Disabled"
cfg.enable_tab_bar = true
cfg.enable_scroll_bar = false
cfg.window_close_confirmation = "NeverPrompt"
cfg.window_padding = {
  bottom = 0,
}

-- Colors
cfg.color_scheme = "tokyonight"

-- Font
cfg.font = wezterm.font("JetBrainsMono Nerd Font")
cfg.font_size = 13.0
cfg.line_height = 1.2
cfg.adjust_window_size_when_changing_font_size = false

-- Keys
cfg.keys = {
  {
    key = "Enter",
    mods = "SUPER",
    action = wezterm.action_callback(function(_, pane)
      local tab = pane:tab()
      local panes = tab:panes_with_info()
      if #panes == 1 then
        pane:split({
          direction = "Bottom",
          size = 0.4,
        })
      elseif not panes[1].is_zoomed then
        panes[1].pane:activate()
        tab:set_zoomed(true)
      elseif panes[1].is_zoomed then
        tab:set_zoomed(false)
        panes[2].pane:activate()
      end
    end),
  },
}

return cfg

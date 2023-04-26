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
-- cfg.font = wezterm.font("JetBrainsMono Nerd Font Mono", {
--   weight = "Medium",
-- })
cfg.font = wezterm.font_with_fallback({
  { family = "JetBrains Mono", weight = "Medium" },
  { family = "Symbols Nerd Font Mono", scale = 0.75 },
})
cfg.font_size = 13.0
cfg.line_height = 1.2
cfg.adjust_window_size_when_changing_font_size = false

return cfg

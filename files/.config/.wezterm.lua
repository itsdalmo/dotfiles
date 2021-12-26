local wezterm = require 'wezterm';

local cfg = {}

-- General

-- Colors
cfg.color_scheme = "OneHalfDark"

-- Font
cfg.font = wezterm.font("JetBrainsMono Nerd Font Mono")
cfg.font_size = 13.0
cfg.adjust_window_size_when_changing_font_size = false

return cfg

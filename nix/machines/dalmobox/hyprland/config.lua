hl.config({
  xwayland = {
    force_zero_scaling = true,
  },

  input = {
    kb_layout = "us",
    follow_mouse = 1,
    sensitivity = -0.6,
    accel_profile = "flat",
  },

  general = {
    gaps_in = 5,
    gaps_out = 10,
    border_size = 2,
    col = {
      active_border = "rgb(7aa2f7)",
      inactive_border = "rgb(414868)",
    },
    layout = "dwindle",
  },

  decoration = {
    rounding = 6,
    active_opacity = 1.0,
    inactive_opacity = 0.96,
    shadow = {
      enabled = true,
    },
    blur = {
      enabled = true,
    },
  },

  animations = {
    enabled = true,
  },

  dwindle = {
    preserve_split = true,
  },

  misc = {
    disable_hyprland_logo = true,
    background_color = "rgb(1a1b26)",
  },
})

hl.animation({ leaf = "windows", enabled = true, speed = 4, bezier = "default" })
hl.animation({ leaf = "fade", enabled = true, speed = 4, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "default" })

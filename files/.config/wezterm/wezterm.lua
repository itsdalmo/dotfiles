local wezterm = require("wezterm")
local act = wezterm.action

local cfg = {}

-- General
cfg.initial_cols = 180
cfg.initial_rows = 48
cfg.audible_bell = "Disabled"
cfg.enable_tab_bar = true
cfg.use_fancy_tab_bar = false
cfg.tab_max_width = 60
cfg.enable_scroll_bar = false
cfg.window_close_confirmation = "NeverPrompt"
cfg.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
cfg.window_padding = { bottom = 0 }

-- Colors
cfg.color_scheme = "tokyonight"

-- Font
cfg.font = wezterm.font("JetBrainsMono Nerd Font")
cfg.font_size = 13.0
cfg.line_height = 1.2
cfg.adjust_window_size_when_changing_font_size = false

-- maximize window size on startup
wezterm.on("gui-startup", function(cmd)
  local tab, pane, window = wezterm.mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

-- Toggle terminal with cmd+enter
local toggle_terminal = function(_, pane)
  local tab = pane:tab()
  local panes = tab:panes_with_info()
  if #panes == 1 then
    pane:split({
      direction = "Bottom",
      size = 0.3,
    })
  elseif not panes[1].is_zoomed then
    panes[1].pane:activate()
    tab:set_zoomed(true)
  elseif panes[1].is_zoomed then
    tab:set_zoomed(false)
    panes[2].pane:activate()
  end
end

-- Keymaps
local super = "SUPER"
cfg.leader = { key = "a", mods = super }

cfg.disable_default_key_bindings = true
cfg.keys = {
  -- General
  { key = "q", mods = super, action = act.QuitApplication },
  { key = "r", mods = super, action = act.ReloadConfiguration },
  { key = "c", mods = super, action = act.CopyTo("Clipboard") },
  { key = "v", mods = super, action = act.PasteFrom("Clipboard") },
  { key = "f", mods = super, action = act.Search("CurrentSelectionOrEmptyString") },
  { key = "x", mods = super, action = act.ActivateCopyMode },

  -- Tabs
  { key = "t", mods = super, action = act.SpawnTab("CurrentPaneDomain") },
  { key = "w", mods = super, action = act.CloseCurrentPane({ confirm = true }) },
  { key = "W", mods = super, action = act.CloseCurrentTab({ confirm = true }) },
  { key = "1", mods = super, action = act.ActivateTab(0) },
  { key = "2", mods = super, action = act.ActivateTab(1) },
  { key = "3", mods = super, action = act.ActivateTab(2) },
  { key = "4", mods = super, action = act.ActivateTab(3) },
  { key = "5", mods = super, action = act.ActivateTab(4) },
  { key = "6", mods = super, action = act.ActivateTab(5) },
  { key = "7", mods = super, action = act.ActivateTab(6) },
  { key = "8", mods = super, action = act.ActivateTab(7) },
  { key = "9", mods = super, action = act.ActivateTab(-1) },
  { key = "LeftArrow", mods = super, action = act.MoveTabRelative(-1) },
  { key = "RightArrow", mods = super, action = act.MoveTabRelative(1) },

  -- Terminal
  { key = "Enter", mods = super, action = wezterm.action_callback(toggle_terminal) },

  -- Navigation
  { key = "h", mods = super, action = act.ActivatePaneDirection("Left") },
  { key = "l", mods = super, action = act.ActivatePaneDirection("Right") },
  { key = "k", mods = super, action = act.ActivatePaneDirection("Up") },
  { key = "j", mods = super, action = act.ActivatePaneDirection("Down") },

  -- Zoom
  { key = "z", mods = super, action = act.TogglePaneZoomState },
  { key = "=", mods = super, action = act.IncreaseFontSize },
  { key = "-", mods = super, action = act.DecreaseFontSize },
  { key = "0", mods = super, action = act.ResetFontSize },

  -- Leader
  { key = "p", mods = "LEADER", action = act.ActivateCommandPalette },
  { key = "s", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
  { key = "v", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
  { key = "r", mods = "LEADER", action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false }) },
}

cfg.key_tables = {
  resize_pane = {
    { key = "Escape", action = "PopKeyTable" },
    { key = "h", action = act.AdjustPaneSize({ "Left", 1 }) },
    { key = "l", action = act.AdjustPaneSize({ "Right", 1 }) },
    { key = "k", action = act.AdjustPaneSize({ "Up", 1 }) },
    { key = "j", action = act.AdjustPaneSize({ "Down", 1 }) },
    { key = "LeftArrow", action = act.AdjustPaneSize({ "Left", 1 }) },
    { key = "RightArrow", action = act.AdjustPaneSize({ "Right", 1 }) },
    { key = "UpArrow", action = act.AdjustPaneSize({ "Up", 1 }) },
    { key = "DownArrow", action = act.AdjustPaneSize({ "Down", 1 }) },
  },
  search_mode = {
    { key = "Escape", action = act.CopyMode("Close") },
    { key = "Enter", action = act.CopyMode("PriorMatch") },
    { key = "Enter", mods = "SHIFT", action = act.CopyMode("NextMatch") },
    { key = "r", mods = "SHIFT", action = act.CopyMode("CycleMatchType") },
    { key = "c", mods = "SHIFT", action = act.CopyMode("ClearPattern") },
  },
  copy_mode = {
    { key = "Escape", action = act.CopyMode("Close") },
    { key = "q", mods = "NONE", action = act.CopyMode("Close") },
    { key = "h", mods = "NONE", action = act.CopyMode("MoveLeft") },
    { key = "j", mods = "NONE", action = act.CopyMode("MoveDown") },
    { key = "k", mods = "NONE", action = act.CopyMode("MoveUp") },
    { key = "l", mods = "NONE", action = act.CopyMode("MoveRight") },
    { key = "v", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
    { key = "V", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Line" }) },
    { key = "w", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
    { key = "e", mods = "NONE", action = act.CopyMode("MoveForwardWordEnd") },
    { key = "b", mods = "NONE", action = act.CopyMode("MoveBackwardWord") },
    { key = "0", mods = "NONE", action = act.CopyMode("MoveToStartOfLine") },
    { key = "$", mods = "NONE", action = act.CopyMode("MoveToEndOfLineContent") },
    { key = "d", mods = "CTRL", action = act.CopyMode({ MoveByPage = 0.5 }) },
    { key = "u", mods = "CTRL", action = act.CopyMode({ MoveByPage = -0.5 }) },
    {
      key = "y",
      mods = "NONE",
      action = act.Multiple({ { CopyTo = "ClipboardAndPrimarySelection" }, { CopyMode = "Close" } }),
    },
  },
}

return cfg

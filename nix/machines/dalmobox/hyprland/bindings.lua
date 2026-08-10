local mod = "SUPER"

local function exec(command)
  return hl.dsp.exec_cmd(command)
end

-- Applications and Noctalia surfaces.
hl.bind(mod .. " + Return", exec("uwsm app -- ghostty"))
hl.bind(mod .. " + SHIFT + Return", exec("uwsm app -- brave"))
hl.bind(mod .. " + SHIFT + F", exec("uwsm app -- nautilus"))
hl.bind(mod .. " + Space", exec("noctalia msg panel-toggle launcher"))
hl.bind(mod .. " + Escape", exec("noctalia msg panel-toggle session"))
hl.bind(mod .. " + CTRL + L", exec("noctalia msg session lock"))
hl.bind(mod .. " + CTRL + C", exec("noctalia msg screenshot-region"))
hl.bind(mod .. " + CTRL + A", exec("noctalia msg panel-toggle control-center audio"))
hl.bind(mod .. " + CTRL + B", exec("noctalia msg panel-toggle control-center bluetooth"))
hl.bind(mod .. " + CTRL + N", exec("noctalia msg nightlight-toggle"))
hl.bind(mod .. " + CTRL + T", exec("uwsm app -- ghostty -e btop"))
hl.bind(mod .. " + CTRL + V", exec("noctalia msg panel-toggle clipboard"))
hl.bind(mod .. " + CTRL + W", exec("noctalia msg panel-toggle control-center network"))

-- Window state and layout.
hl.bind(mod .. " + W", hl.dsp.window.close())
hl.bind(mod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + O", hl.dsp.window.pin())
hl.bind(mod .. " + P", hl.dsp.window.pseudo({ action = "toggle" }))
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))

-- Clipboard shortcuts that work in applications which prefer Insert variants.
hl.bind(mod .. " + C", hl.dsp.send_shortcut({ mods = "CTRL", key = "Insert", window = "activewindow" }))
hl.bind(mod .. " + V", hl.dsp.send_shortcut({ mods = "SHIFT", key = "Insert", window = "activewindow" }))
hl.bind(mod .. " + X", hl.dsp.send_shortcut({ mods = "CTRL", key = "X", window = "activewindow" }))

hl.bind(mod .. " + code:61", exec("cycle-monitor-scale"))
hl.bind(mod .. " + ALT + code:61", exec("cycle-monitor-scale --reverse"))

local directions = {
  left = "left",
  down = "down",
  up = "up",
  right = "right",
}

for key, direction in pairs(directions) do
  hl.bind(mod .. " + " .. key, hl.dsp.focus({ direction = direction }))
  hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.swap({ direction = direction }))
end

-- Workspaces.
for workspace = 1, 4 do
  hl.bind(mod .. " + " .. workspace, hl.dsp.focus({ workspace = workspace }))
  hl.bind(mod .. " + SHIFT + " .. workspace, hl.dsp.window.move({ workspace = workspace, follow = true }))
  hl.bind(mod .. " + SHIFT + ALT + " .. workspace, hl.dsp.window.move({ workspace = workspace, follow = false }))
end

hl.bind(mod .. " + Tab", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + SHIFT + Tab", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mod .. " + CTRL + Tab", hl.dsp.focus({ workspace = "previous" }))

hl.bind(mod .. " + equal", hl.dsp.window.resize({ x = -100, y = 0, relative = true }), { repeating = true })
hl.bind(mod .. " + minus", hl.dsp.window.resize({ x = 100, y = 0, relative = true }), { repeating = true })
hl.bind(mod .. " + SHIFT + equal", hl.dsp.window.resize({ x = 0, y = 100, relative = true }), { repeating = true })
hl.bind(mod .. " + SHIFT + minus", hl.dsp.window.resize({ x = 0, y = -100, relative = true }), { repeating = true })

hl.bind(mod .. " + G", hl.dsp.group.toggle())
hl.bind(mod .. " + ALT + G", hl.dsp.window.move({ out_of_group = true }))
hl.bind(mod .. " + ALT + Tab", hl.dsp.group.next())

hl.bind(mod .. " + S", hl.dsp.workspace.toggle_special("scratchpad"))
hl.bind(mod .. " + ALT + S", hl.dsp.window.move({ workspace = "special:scratchpad" }))

local function cycle_window(next_window)
  return function()
    hl.dispatch(hl.dsp.window.cycle_next({ next = next_window }))
    hl.dispatch(hl.dsp.window.alter_zorder({ mode = "top" }))
  end
end

hl.bind("ALT + Tab", cycle_window(true))
hl.bind("ALT + SHIFT + Tab", cycle_window(false))

hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Noctalia owns audio and brightness state and displays the matching OSD.
hl.bind("XF86AudioRaiseVolume", exec("noctalia msg volume-up"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", exec("noctalia msg volume-down"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", exec("noctalia msg volume-mute"), { locked = true })
hl.bind("XF86AudioMicMute", exec("noctalia msg mic-mute"), { locked = true })
hl.bind("XF86MonBrightnessUp", exec("noctalia msg brightness-up"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", exec("noctalia msg brightness-down"), { locked = true, repeating = true })

hl.bind("XF86AudioPlay", exec("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", exec("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", exec("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", exec("playerctl previous"), { locked = true })
hl.bind("XF86AudioStop", exec("playerctl stop"), { locked = true })

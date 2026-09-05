-- Safe hotplug baseline: every display gets its preferred mode, automatic
-- placement, and PPI-derived scale unless a physical-display override exists.
hl.monitor({
  output = "",
  mode = "preferred",
  position = "auto",
  scale = "auto",
})

local m28u_description = "GIGA-BYTE TECHNOLOGY CO. LTD. M28U"

local state_home = os.getenv("XDG_STATE_HOME")
if state_home == nil or state_home == "" then
  state_home = os.getenv("HOME") .. "/.local/state"
end

local state_file = state_home .. "/hypr/monitor-scales.tsv"
local file = io.open(state_file, "r")

if file ~= nil then
  for line in file:lines() do
    local description, scale = line:match("^([^\t]+)\t([%d%.]+)$")
    scale = tonumber(scale)

    if
      description ~= nil
      and scale ~= nil
      and description:sub(1, #m28u_description) ~= m28u_description
    then
      hl.monitor({
        output = "desc:" .. description,
        mode = "preferred",
        position = "auto",
        scale = scale,
      })
    end
  end

  file:close()
end

-- Keep the M28U's tested mode and scale authoritative over saved scale state.
-- Match the display description so this also survives connector changes.
hl.monitor({
  output = "desc:" .. m28u_description,
  mode = "3840x2160@144",
  position = "auto",
  scale = 1.5,
})

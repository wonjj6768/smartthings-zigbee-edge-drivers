local zcl = require "protocol.zcl"

local standard_ts110e = {
  _TZ3210_zxbtub8r = true, _TZ3210_cyuyd5az = true,
  _TZ3210_hzdhb62z = true, _TZ3210_v5yquxma = true,
  _TZ3210_wdexaypg = true, _TZ3210_tkkb1ym8 = true,
}
local function kind(fingerprint)
  if fingerprint.model == "TS110E" then
    return standard_ts110e[fingerprint.manufacturer] and "on_then_level" or "tuya_level"
  end
  if fingerprint.model == "TS1101" or fingerprint.model == "TS0052" or
      fingerprint.manufacturer == "_TYZB01_qezuin6k" or
      fingerprint.manufacturer == "_TYZB01_v8gtiaed" then return "standard" end
end

local function sender(device, _, value, context)
  if type(value) ~= "number" or value ~= value or value < 0 or value > 100 then return false end
  local mode = kind({manufacturer = device:get_manufacturer(), model = device:get_model()})
  local endpoint = context.endpoint or 1
  local brightness = math.floor(value * 254 / 100 + 0.5)
  if mode == "tuya_level" then
    local component = context.component_id or "main"
    local old = device:get_latest_state(component, "switchLevel", "level")
    if device:get_latest_state(component, "switch", "switch") == "off" and
        type(old) == "number" and math.abs(brightness - math.floor(old * 254 / 100 + 0.5)) <= 1 then
      return zcl.send_raw_cluster_command(device, 6, 1, "", endpoint)
    end
    local level = math.floor(value * 10 + 0.5)
    return zcl.send_raw_cluster_command(device, 8, 0xF0, string.pack("<I2I2", level, 100), endpoint)
  end
  if mode == "on_then_level" and brightness > 1 then
    if zcl.send_raw_cluster_command(device, 6, 1, "", endpoint) == false then return false end
  end
  local transition = math.max(0, math.min(65535, math.floor(tonumber(context.transition_time) or 0)))
  return zcl.send_raw_cluster_command(device, 8, 4, string.pack("<BI2BB", brightness, transition, 0, 0), endpoint)
end

local function apply(registrations)
  for _, entry in ipairs(registrations) do
    local mode = kind(entry.fingerprints[1])
    if mode then
      local extra = {}
      for i, mapping in ipairs(entry.zcl_clusters) do
        if mapping.name == "brightness" then
          if mode == "tuya_level" then
            entry.zcl_clusters[i] = zcl.tuya_dimmer_level({
              endpoint = mapping.endpoint, component = mapping.component, sender = sender,
            })
          else
            if mapping.attribute_id == 0xF000 then
              entry.zcl_clusters[i] = zcl.level({
                endpoint = mapping.endpoint, component = mapping.component,
                configure_reporting = false, sender = sender,
              })
            else
              mapping.sender = sender
            end
            extra[#extra + 1] = zcl.tuya_dimmer_level({
              name = "tuya_brightness_report", endpoint = mapping.endpoint,
              component = mapping.component, read_only = true,
            })
          end
        end
      end
      for _, mapping in ipairs(extra) do entry.zcl_clusters[#entry.zcl_clusters + 1] = mapping end
    end
  end
end

return {apply = apply}

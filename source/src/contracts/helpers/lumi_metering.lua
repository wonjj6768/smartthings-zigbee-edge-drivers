local zcl = require "protocol.zcl"
local emit = require "capabilities.events.all"
local data_types = require "st.zigbee.data_types"
local buf = require "st.buf"

local lumi = {}

-- Lumi embeds one-byte tag + ZCL type + little-endian typed value in FF01/F7.
local function decode_metering(value)
  if type(value) == "table" then value = value.value end
  if type(value) ~= "string" then return nil end
  local reader, values = buf.Reader(value), {}
  while reader:remain() > 1 do
    local tag, type_id = reader:read_u8(), reader:read_u8()
    local ok, item = pcall(data_types.parse_data_type, type_id, reader)
    if not ok then return nil end
    if tag >= 149 and tag <= 152 and type(item.value) == "number" then
      values[tag] = item.value
    end
  end
  return values
end

local function heartbeat(include_current)
  return function(device, values)
    local events = {}
    local function append(event)
      if type(event) == "table" and event[1] ~= nil then
        for _, item in ipairs(event) do events[#events + 1] = item end
      elseif event ~= nil then
        events[#events + 1] = event
      end
    end
    if values[149] ~= nil then append(emit.energy()(device, values[149])) end
    if values[150] ~= nil then append(emit.voltage()(device, values[150] / 10)) end
    if include_current and values[151] ~= nil then append(emit.current()(device, values[151] / 1000)) end
    if values[152] ~= nil then append(emit.power()(device, values[152])) end
    return events
  end
end

function lumi.adapt(original, include_current, profile)
  local definition, mappings = {}, {}
  for key, value in pairs(original) do definition[key] = value end
  -- Keep the existing relay mapping(s); replace the incompatible meter blocks.
  for _, mapping in ipairs(original.zcl_clusters) do
    if mapping.metering_kind == nil then mappings[#mappings + 1] = mapping end
  end
  mappings[#mappings + 1] = zcl.cluster_attribute(0x000C, 0x0055, {
    name = "power", data_type = data_types.SinglePrecisionFloat,
    component = "main", emit = emit.power(), read_only = true,
    endpoint = function(device) return device:get_endpoint(0x000C) end,
    read_on_configure = true, poll_interval = 300,
    metering_kind = "power", ignore_reported_scaler = true,
  })
  for _, attribute in ipairs({{0x0000, 0xFF01}, {0xFCC0, 0x00F7}}) do
    mappings[#mappings + 1] = zcl.cluster_attribute(attribute[1], attribute[2], {
      name = "lumi_metering", data_type = data_types.OctetString,
      endpoint = 1, component = "main", read_only = true,
      read_on_configure = false, read_on_refresh = false,
      from_device = decode_metering, emit = heartbeat(include_current),
      handler = function(device, values)
        if values[152] ~= nil then
          zcl.handle_metering_value(device, nil, values[152], {metering_kind = "power"})
        end
      end,
    })
  end
  definition.profile = profile
  definition.zcl_clusters = mappings
  return definition
end

return lumi

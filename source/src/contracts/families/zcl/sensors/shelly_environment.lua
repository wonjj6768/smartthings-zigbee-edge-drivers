local zcl = require "protocol.zcl"
local device_helpers = require "contracts.helpers.family"
local emit = require "capabilities.events.all"
local data_types = require "st.zigbee.data_types"

local device_definitions, register_device_definition = device_helpers.definition_registry()

local function light_level(name, event_factory)
  return zcl.cluster_attribute(0xFC21, 0x0000, {
    name = name,
    endpoint = 1,
    data_type = data_types.Uint8,
    mfg_code = 0x1490,
    read_only = true,
    read_on_configure = true,
    minimum_interval = 60,
    maximum_interval = 900,
    reportable_change = 0,
    emit = event_factory,
    from_device = function(value)
      return ({ [0] = "dark", [1] = "twilight", [2] = "bright" })[value]
    end,
  })
end

local function light_threshold(name, attribute_id, event_factory)
  return zcl.cluster_attribute(0xFC21, attribute_id, {
    name = name,
    endpoint = 1,
    data_type = data_types.Uint24,
    write_type = data_types.Uint24,
    mfg_code = 0x1490,
    read_on_configure = true,
    emit = event_factory,
    to_device = function(value)
      if type(value) ~= "number" or value % 1 ~= 0 or value < 0 or value > 65535 then return nil end
      return value
    end,
  })
end

local function battery(endpoint)
  return zcl.battery({endpoint=endpoint, read_only=true, read_on_configure=true,
    minimum_interval=3600, maximum_interval=65000, reportable_change=10,
    from_device=function(value, _, context)
      if context.raw_value ~= 255 then return value end
    end})
end

local function battery_low(name, event_factory, endpoint)
  return zcl.battery_low({name=name, endpoint=endpoint, emit=event_factory,
    read_only=true, read_on_configure=true, configure_reporting=false,
    converter={from=function(value)
      if type(value) == "table" then value = value.value end
      return (value & 8) ~= 0 and "low" or "normal"
    end}})
end

local function identify(name)
  return zcl.cluster_attribute(0x0003, 0, {name=name, endpoint=1,
    write_only=true, suppress_optimistic_state=true, tx_command_id=0,
    to_device=function(value)
      if type(value) ~= "number" or value % 1 ~= 0 or value < 1 or value > 30 then return nil end
      return string.pack("<I2", value)
    end})
end

local display = {
  profile = "sensors-illuminance-temp-humidity-battery-shelly-display",
  capability_commands = {
    {capability_id="concertmirror08464.shellyDisplayIdentify", command_name="identify",
      mapping_name="shelly_display_identify", value=3},
    {capability_id="concertmirror08464.shellyDisplayIdentify", command_name="setIdentifyTime",
      argument_name="identifyTime", mapping_name="shelly_display_identify"},
  },
  zcl_clusters = {
    zcl.temperature({minimum_interval=10, maximum_interval=3600, reportable_change=100}),
    zcl.humidity({minimum_interval=10, maximum_interval=3600, reportable_change=100,
      from_device=function(value, _, context)
        if context.raw_value ~= 0xFFFF then return value end
      end}),
    light_level("shelly_blu_display_light_level", emit.shellyBluDisplayLightLevel()),
    light_threshold("shelly_blu_display_dark_threshold", 0x0001, emit.shellyDisplayDarkThresholdV2()),
    light_threshold("shelly_blu_display_bright_threshold", 0x0002, emit.shellyDisplayBrightThresholdV2()),
    battery(),
    identify("shelly_display_identify"),
  },
}

local function read_door_enrollment(device)
  zcl.read_attribute(device, 0x0500, 0x0000, 1)
  zcl.read_attribute(device, 0x0500, 0x0010, 1)
end

local function door_enroll_response(device, message)
  if message.address_header.src_endpoint.value ~= 1 then return false end
  local command = zcl.get_generated_server_command(0x0500, 0x00)
  local response = command(device, 0, 0):to_endpoint(1)
  response.body.zcl_header.seqno = message.body.zcl_header.seqno
  device:send(response)
  device.thread:call_with_delay(0.5, function() read_door_enrollment(device) end,
    "Shelly door enrollment readback")
  return true
end

local door = {
  profile = "safety-contact-illuminance-battery-low-handle-shelly",
  initial_custom_state_query = false,
  configure = function(driver, device)
    device:remove_configured_attribute(0x0500, 0x0002)
    device:set_field("shelly_door_expected_cie", driver.environment_info.hub_zigbee_eui)
    zcl.bind_cluster(device, 0x0500, driver.environment_info.hub_zigbee_eui, 1)
  end,
  ias_zone_enroll_response = door_enroll_response,
  capability_commands = {
    {capability_id="concertmirror08464.shellyDoorIdentify", command_name="setIdentifyTime",
      argument_name="identifyTime", mapping_name="shelly_door_identify"},
  },
  zcl_clusters = {
    zcl.contact_alarm_1_or_2({endpoint=1, read_only=true, read_on_configure=true, configure_reporting=false,
      ias_configure_method=3}), -- SDK AUTO_ENROLL_REQUEST: wait for the device's request.
    zcl.shelly_handle_position({endpoint=1, read_only=true, read_on_configure=true, configure_reporting=false}),
    battery_low("shelly_door_battery_low", emit.shellyDoorBatteryLow(), 1),
    light_level("shelly_blu_door_light_level", emit.shellyBluDoorLightLevel()),
    light_threshold("shelly_blu_door_dark_threshold", 0x0001, emit.shellyDoorDarkThreshold()),
    light_threshold("shelly_blu_door_bright_threshold", 0x0002, emit.shellyDoorBrightThreshold()),
    battery(1),
    identify("shelly_door_identify"),
    zcl.cluster_attribute(0x0500, 0x0000, {
      name="shelly_door_zone_state", endpoint=1, data_type=data_types.Enum8, read_only=true,
      handler=function(device, value)
        device:set_field("shelly_door_zone_state", value)
      end,
    }),
    zcl.cluster_attribute(0x0500, 0x0010, {
      name="shelly_door_cie_address", endpoint=1, data_type=data_types.IeeeAddress, read_only=true,
      handler=function(device, value)
        device:set_field("shelly_door_cie_address", value)
        local expected = device:get_field("shelly_door_expected_cie")
        if expected ~= nil then
          device:set_field("shelly_door_cie_matches_hub", value == expected)
        end
      end,
    }),
  },
}

local function read_motion_enrollment(device)
  zcl.read_attribute(device, 0x0500, 0x0000, 1)
  zcl.read_attribute(device, 0x0500, 0x0010, 1)
end

local function motion_enroll_response(device, message)
  if message.address_header.src_endpoint.value ~= 1 then return false end
  local command = zcl.get_generated_server_command(0x0500, 0x00)
  local response = command(device, 0, 0):to_endpoint(1)
  response.body.zcl_header.seqno = message.body.zcl_header.seqno
  device:send(response)
  device.thread:call_with_delay(0.5, function() read_motion_enrollment(device) end,
    "Shelly motion enrollment readback")
  return true
end

local motion = {
  profile = "safety-motion-illuminance-battery-low-battery",
  capability_commands = {
    {capability_id="concertmirror08464.shellyMotionIdentify", command_name="identify",
      mapping_name="shelly_motion_identify", value=3},
    {capability_id="concertmirror08464.shellyMotionIdentify", command_name="setIdentifyTime",
      argument_name="identifyTime", mapping_name="shelly_motion_identify"},
  },
  configure = function(driver, device)
    device:remove_configured_attribute(0x0500, 0x0002)
    device:set_field("shelly_motion_expected_cie", driver.environment_info.hub_zigbee_eui)
    zcl.bind_cluster(device, 0x0500, driver.environment_info.hub_zigbee_eui, 1)
  end,
  ias_zone_enroll_response = motion_enroll_response,
  zcl_clusters = {
    zcl.motion({endpoint=1, read_only=true, read_on_configure=true, configure_reporting=false,
      ias_configure_method=3}), -- SDK AUTO_ENROLL_REQUEST; no unsolicited response.
    light_level("shelly_blu_motion_light_level", emit.shellyBluMotionLightLevel()),
    light_threshold("shelly_blu_motion_dark_threshold", 0x0001, emit.shellyMotionDarkThresholdV2()),
    light_threshold("shelly_blu_motion_bright_threshold", 0x0002, emit.shellyMotionBrightThresholdV2()),
    battery_low("shelly_motion_battery_low", emit.shellyMotionBatteryLow(), 1),
    battery(),
    zcl.cluster_attribute(0x0500, 0x0013, {
      name = "shelly_blu_motion_sensitivity",
      endpoint = 1,
      data_type = data_types.Uint8,
      write_type = data_types.Uint8,
      read_on_configure = true,
      emit = emit.shellyBluSensitivity(),
      from_device = function(value)
        return ({ "low", "medium", "high" })[value]
      end,
      to_device = function(value)
        return ({ low = 1, medium = 2, high = 3 })[value]
      end,
    }),
    identify("shelly_motion_identify"),
    zcl.cluster_attribute(0x0500, 0x0000, {
      name="shelly_motion_zone_state", endpoint=1, data_type=data_types.Enum8, read_only=true,
      handler=function(device, value) device:set_field("shelly_motion_zone_state", value) end,
    }),
    zcl.cluster_attribute(0x0500, 0x0010, {
      name="shelly_motion_cie_address", endpoint=1, data_type=data_types.IeeeAddress, read_only=true,
      handler=function(device, value)
        device:set_field("shelly_motion_cie_address", value)
        local expected=device:get_field("shelly_motion_expected_cie")
        if expected~=nil then device:set_field("shelly_motion_cie_matches_hub", value==expected) end
      end,
    }),
  },
}

register_device_definition(display, {
  device_helpers.create_fingerprint("Shelly", "BLU H&T Display ZB"),
})
register_device_definition(door, {
  device_helpers.create_fingerprint("Shelly", "BLU DoorWindow ZB"),
  device_helpers.create_fingerprint("Shelly", "BLU DoorWindow Mini ZB"),
})
register_device_definition(motion, {
  device_helpers.create_fingerprint("Shelly", "BLU Motion ZB"),
})

-- ZCL REPORTING CAPABILITIES BEGIN
zcl.attach_reporting_capabilities(device_definitions, {
  {1, "rpt-bbx"},
  {2, "rpt-bicq"},
  {3, "rpt-blp"},
})
-- ZCL REPORTING CAPABILITIES END

return {
  id = "zcl.sensors.shelly_environment",
  registrations = device_definitions,
}

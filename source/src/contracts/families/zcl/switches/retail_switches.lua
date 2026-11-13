local zcl = require "protocol.zcl"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"
local fp = device_helpers.create_fingerprint
local zcl_device_helpers = require "contracts.helpers.zcl"
local data_types = require "st.zigbee.data_types"
local capabilities = require "st.capabilities"
local device_management = require "st.zigbee.device_management"
local cluster_base = require "st.zigbee.cluster_base"
local generic_body = require "st.zigbee.generic_body"

local device_definitions, register = device_helpers.definition_registry()

local function create_model_fingerprints(manufacturer, models)
  local fingerprints = {}
  for _, model in ipairs(models) do
    fingerprints[#fingerprints + 1] = device_helpers.create_fingerprint(manufacturer, model)
  end
  return fingerprints
end

local function switch_definition(profile, endpoints)
  local clusters = {}
  for index, endpoint in ipairs(endpoints) do
    clusters[#clusters + 1] = zcl.switch({
      endpoint = endpoint,
      component = index == 1 and "main" or ("switch" .. tostring(index)),
    })
  end
  return {
    profile = profile,
    zcl_clusters = clusters,
    configure = function(driver, device)
      for _, endpoint in ipairs(endpoints) do
        device:send(device_management.build_bind_request(
          device,
          zcl.CLUSTER_ON_OFF,
          driver.environment_info.hub_zigbee_eui,
          endpoint
        ))
      end
    end,
  }
end

local switch_1 = switch_definition("switches-switch-1", { 1 })
local switch_2 = switch_definition("switches-switch-2", { 1, 2 })
local heiman_switch_report = {minimum_interval=0,maximum_interval=3600}
local heiman_temperature_report = {minimum_interval=300,maximum_interval=3600,reportable_change=1}
local function heiman_switch(profile, count)
  local clusters = {}
  for endpoint = 1, count do
    clusters[#clusters+1] = zcl.switch({endpoint=endpoint,component=endpoint==1 and "main" or "switch"..endpoint,
      configure_reporting=false,read_on_configure=false,suppress_optimistic_state=true,data_type=data_types.Boolean,
      reporting_defaults=count==1 and heiman_switch_report or nil})
  end
  clusters[#clusters+1] = zcl.cluster_attribute(2,0,{name="device_temperature",endpoint=1,component="main",
    data_type=data_types.Int16,read_only=true,read_on_configure=false,emit=emit.temperature("C"),
    reporting_defaults=heiman_temperature_report})
  return {profile=profile,zcl_clusters=clusters,
    configure=function(driver,device)
      local hub=driver.environment_info.hub_zigbee_eui
      for endpoint=1,count do zcl.bind_cluster(device,6,hub,endpoint) end
      zcl.bind_cluster(device,2,hub,1)
      for _,mapping in ipairs(clusters) do
        local defaults=mapping.reporting_defaults
        if defaults then zcl.configure_reporting(device,{
          cluster=mapping.cluster_id,attribute=mapping.attribute_id,data_type=mapping.data_type,
          minimum_interval=defaults.minimum_interval,maximum_interval=defaults.maximum_interval,
          reportable_change=defaults.reportable_change},mapping.endpoint,{defer_on_override=true}) end
      end
    end,
  }
end
local heiman_switch_1 = heiman_switch("switches-heiman-one",1)
local heiman_switch_2 = heiman_switch("switches-heiman-two",2)
local heiman_switch_3 = heiman_switch("switches-switch-3-device-temperature",3)

local switch_1_ep10 = switch_definition("switches-switch-1", { 10 })
local switch_2_ep10 = switch_definition("switches-switch-2", { 10, 11 })
local switch_3_ep10 = switch_definition("switches-switch-3", { 10, 11, 12 })
local switch_4 = switch_definition("switches-switch-4", { 1, 2, 3, 4 })
local switch_5_ep5 = switch_definition("switches-switch-5", { 1, 2, 3, 4, 5 })
local switch_5_ep5_tuya_options = switch_definition("switches-switch-5-tuya-options", { 1, 2, 3, 4, 5 })
zcl_device_helpers.append_clusters(switch_5_ep5_tuya_options.zcl_clusters,
  zcl.tuya_magic_packet(),
  zcl.tuya_power_outage_memory(),
  zcl.child_lock()
)
local plug_1 = switch_definition("plugs-switch", { 1 })
local plug_2 = switch_definition("plugs-switch-2", { 1, 2 })
local battery_switch = {
  profile = "switches-switch-1-battery",
  zcl_clusters = {
    zcl.switch(),
    zcl.battery(),
  },
}
local dual_metered_switch_ep3 = switch_definition("switches-switch-2-power-options", { 1, 2 })
for _, cluster in ipairs(zcl_device_helpers.metering_clusters({
  endpoint = 3,
  include_switch = false,
  include_current = true,
})) do
  cluster.use_reported_unity_scaler = true
  dual_metered_switch_ep3.zcl_clusters[#dual_metered_switch_ep3.zcl_clusters + 1] = cluster
end

local function candeo_power_on_behavior(endpoint, component)
  return zcl.cluster_attribute(zcl.CLUSTER_ON_OFF, 0x4003, {
    name = "candeo_sm30_power_on_behavior",
    endpoint = endpoint,
    component = component,
    emit = emit.candeoSm30PowerBehavior(),
    from_device = function(value)
      value = type(value) == "table" and value.value or value
      return ({ [0] = "off", [1] = "on", [255] = "previous" })[value]
    end,
    to_device = function(value)
      return ({ off = 0, on = 1, previous = 255 })[value]
    end,
    data_type = data_types.Enum8,
    write_type = data_types.Enum8,
    read_on_configure = true,
  })
end

dual_metered_switch_ep3.profile = "switches-candeo-sm30-2g"
zcl_device_helpers.append_clusters(dual_metered_switch_ep3.zcl_clusters,
  candeo_power_on_behavior(1, "main"),
  candeo_power_on_behavior(2, "switch2")
)
dual_metered_switch_ep3.configure = function(driver, device)
  for _, endpoint in ipairs({ 1, 2 }) do
    device:send(device_management.build_bind_request(
      device,
      zcl.CLUSTER_ON_OFF,
      driver.environment_info.hub_zigbee_eui,
      endpoint
    ))
    device:send(cluster_base.configure_reporting(
      device,
      data_types.ClusterId(zcl.CLUSTER_ON_OFF),
      data_types.AttributeId(0x4003),
      data_types.ZigbeeDataType(data_types.Enum8.ID),
      0,
      0xFFFF,
      1
    ):to_endpoint(endpoint))
  end
end
--[[
The retail metered-plug definition now belongs to the ZCL plugs catalog.
This seven-line spacer preserves the source locations of the remaining
SONOFF functions, keeping their bytecode identities stable after the move.
No plug registration or executable definition remains in this module.
The package ownership boundary is enforced by the focused catalog test.
]]
local SONOFF_CLUSTER = 0xFC11
local SONOFF_MFG_CODE = 0x1286
local SONOFF_CAPABILITY = "concertmirror08464.sonoffZbminir2"

local function read_sonoff_startup(device)
  zcl.read_attribute(device, 0x0006, 0x4003, 1)
end

local function sonoff_settings_start(device, preset)
  device.thread:call_with_delay(2, function()
    zcl.read_configured_attributes(device, preset.zcl_clusters)
    zcl.read_attribute(device, 0x0000, 0x0001, 1)
    zcl.read_attribute(device, 0x0000, 0x4000, 1)
  end, "SONOFF stored settings")
end

local function sonoff_settings_message(device, message)
  local address = message.address_header
  if address.profile.value == 0 and address.cluster.value == 0x0013 then
    device.thread:call_with_delay(1, function()
      read_sonoff_startup(device)
      zcl.read_attribute(device, 0x0000, 0x0001, 1)
      zcl.read_attribute(device, 0x0000, 0x4000, 1)
    end, "SONOFF rejoin settings")
  end
end

local function send_sonoff_startup(device, mapping, value)
  local raw = mapping.to_device(value)
  if raw == nil then return false end
  local attribute = zcl.get_generated_attribute(0x0006, 0x4003)
  device:send(attribute:write(device, data_types.Enum8(raw)):to_endpoint(1))
  device.thread:call_with_delay(1, function() read_sonoff_startup(device) end, "SONOFF startup readback")
  return true
end

local function on_off_from_device(value)
  return (value == true or value == 1) and "on" or "off"
end

local function on_off_to_device(value)
  return value == "on" or value == true
end

local function sonoff_boolean(attribute_id, name, emitter, options)
  options = options or {}
  return zcl.cluster_attribute(SONOFF_CLUSTER, attribute_id, {
    name = name,
    emit = emitter,
    data_type = options.data_type or data_types.Boolean,
    write_type = options.write_type or data_types.Boolean,
    from_device = options.from_device or on_off_from_device,
    to_device = options.to_device or on_off_to_device,
    read_on_configure = true,
  })
end

local function latest_sonoff_state(device, suffix, default)
  local capability_id = SONOFF_CAPABILITY .. suffix
  local attribute = suffix:sub(1, 1):lower() .. suffix:sub(2)
  return device:get_latest_state("main", capability_id, attribute) or default
end

local function send_sonoff_inching(device, mapping, value, context)
  local control = latest_sonoff_state(device, "InchingControl", "off")
  local time = tonumber(latest_sonoff_state(device, "InchingTime", 0.5)) or 0.5
  local mode = latest_sonoff_state(device, "InchingMode", "off")

  if mapping.name == "sonoff_zbmini_r2_inching_control" then
    control = value
  elseif mapping.name == "sonoff_zbmini_r2_inching_time" then
    time = tonumber(value) or time
  elseif mapping.name == "sonoff_zbmini_r2_inching_mode" then
    mode = value
  end

  local encoded_time = math.floor((math.max(0.5, math.min(3599.5, time)) * 2) + 0.5)
  local mode_byte = (control == "on" and 0x80 or 0) + (mode == "on" and 0x01 or 0)
  local bytes = { 0x01, 0x17, 0x07, 0x80, mode_byte, 0x00, encoded_time % 0x100, math.floor(encoded_time / 0x100), 0x00, 0x00 }
  local checksum = 0
  for _, byte in ipairs(bytes) do checksum = checksum ~ byte end
  bytes[#bytes + 1] = checksum

  return zcl.send_raw_cluster_command(
    device,
    SONOFF_CLUSTER,
    0x01,
    string.char(table.unpack(bytes)),
    context.endpoint,
    nil,
    SONOFF_MFG_CODE
  )
end

local sonoff_zbmini_r2 = {
  profile = "switches-switch-1-sonoff-zbmini-r2",
  runtime_start = sonoff_settings_start,
  zigbee_message_handler = sonoff_settings_message,
  zcl_clusters = {
    zcl.switch(),
    zcl.cluster_attribute(zcl.CLUSTER_ON_OFF, 0x4003, {
      name = "sonoff_zbmini_r2_power_on_behavior",
      endpoint = 1,
      suppress_optimistic_state = true,
      sender = send_sonoff_startup,
      emit = emit.sonoffZbminir2PowerOnBehavior(),
      data_type = data_types.Enum8,
      write_type = data_types.Enum8,
      from_device = function(value)
        return ({ [0] = "off", [1] = "on", [2] = "toggle", [255] = "previous" })[value]
      end,
      to_device = function(value)
        return ({ off = 0, on = 1, toggle = 2, previous = 255 })[value]
      end,
      read_on_configure = true,
    }),
    zcl.cluster_attribute(zcl.CLUSTER_ON_OFF, zcl.ATTR_ON_OFF, {
      name = "sonoff_zbmini_r2_toggle",
      emit = emit.switch(),
      read_only = true,
      command_id = 0x02,
      command_extractor = function(_, device)
        return device:get_latest_state("main", capabilities.switch.ID, "switch") ~= "on"
      end,
    }),
    sonoff_boolean(0x0001, "sonoff_zbmini_r2_network_indicator", emit.sonoffZbminir2NetworkIndicator()),
    sonoff_boolean(0x0012, "sonoff_zbmini_r2_turbo_mode", emit.sonoffZbminir2TurboMode(), {
      data_type = data_types.Int16,
      write_type = data_types.Int16,
      from_device = function(value) return value == 0x14 and "on" or "off" end,
      to_device = function(value) return value == "on" and 0x14 or 0x09 end,
    }),
    sonoff_boolean(0x0014, "sonoff_zbmini_r2_delayed_power_on_state", emit.sonoffZbminir2DelayPowerState()),
    zcl.cluster_attribute(SONOFF_CLUSTER, 0x0015, {
      name = "sonoff_zbmini_r2_delayed_power_on_time",
      emit = emit.sonoffZbminir2DelayPowerTime(),
      data_type = data_types.Uint16,
      write_type = data_types.Uint16,
      from_device = function(value) return value / 2 end,
      to_device = function(value) return value * 2 end,
      numeric_range = { minimum = 0.5, maximum = 3599.5, step = 0.5, unit = "s" },
      read_on_configure = true,
    }),
    sonoff_boolean(0x0017, "sonoff_zbmini_r2_detach_relay_mode", emit.sonoffZbminir2DetachRelayMode()),
    zcl.cluster_attribute(SONOFF_CLUSTER, 0x0016, {
      name = "sonoff_zbmini_r2_external_trigger_mode",
      emit = emit.sonoffZbminir2ExtTriggerMode(),
      data_type = data_types.Uint8,
      write_type = data_types.Uint8,
      from_device = function(value) return ({ [0] = "edge", [1] = "pulse", [2] = "following_off", [130] = "following_on" })[value] end,
      to_device = function(value) return ({ edge = 0, pulse = 1, following_off = 2, following_on = 130 })[value] end,
      read_on_configure = true,
    }),
    zcl.cluster_attribute(SONOFF_CLUSTER, nil, { name = "sonoff_zbmini_r2_inching_control", write_only = true, sender = send_sonoff_inching }),
    zcl.cluster_attribute(SONOFF_CLUSTER, nil, { name = "sonoff_zbmini_r2_inching_time", write_only = true, sender = send_sonoff_inching }),
    zcl.cluster_attribute(SONOFF_CLUSTER, nil, { name = "sonoff_zbmini_r2_inching_mode", write_only = true, sender = send_sonoff_inching }),
  },
}

local zunzunbee_sswz8t = {
  profile = "buttons-zunzunbee-sswz8t",
  button_actions = { "pushed", "held" },
  zcl_clusters = {
    zcl.cluster_attribute(zcl.CLUSTER_IAS_ZONE, zcl.ATTR_ZONE_STATUS, {
      name = "zunzunbee_button_action",
      endpoint = 1,
      read_only = true,
      read_on_refresh = false,
      data_type = data_types.Bitmap16,
      command_id = 0x00,
      command_extractor = function(zb_rx)
        local body = zb_rx.body.zcl_body
        local status = body.zone_status or body.zonestatus
        return type(status) == "table" and status.value or status
      end,
      from_device = function(value)
        value = type(value) == "table" and value.value or value
        local button = ({ [2] = 1, [4] = 2, [8] = 3, [16] = 4,
          [32] = 5, [64] = 6, [128] = 7, [256] = 8 })[bit32.band(value, 0x01FE)]
        if button == nil then return nil end
        return { component = "button" .. button, action = value % 2 == 1 and "held" or "pushed" }
      end,
      handler = function(device, decoded)
        device:emit_component_event(
          { id = decoded.component },
          capabilities.button.button(decoded.action, { state_change = true })
        )
        zcl.schedule_battery_refresh_after_button(device)
      end,
    }),
    zcl.battery({ endpoint = 1, minimum_interval = 3600, maximum_interval = 65000, reportable_change = 10 }),
    zcl.temperature({ endpoint = 1, minimum_interval = 10, maximum_interval = 3600, reportable_change = 100 }),
  },
}

register(plug_1, {
  fp("Third Reality", "3RSP0186Z"),
  fp("Third Reality", "3RSPJ0187Z"),
  fp("Third Reality", "3RSPE02065Z"),
  fp("Third Reality", "3RSPU01080Z"),
})

register(plug_2, {
  fp("Third Reality", "3RWP01073Z"),
})

register(battery_switch, {
  fp("Third Reality, Inc", "3RSS009Z"),
  fp("Third Reality, Inc", "3RSS008Z"),
})

register(switch_1, {
  fp("Third Reality, Inc", "3RSS007Z"),
})

register(sonoff_zbmini_r2, {
  fp("SONOFF", "MINI-ZBD"),
  fp("SONOFF", "ZBMINIR2"),
})

register(dual_metered_switch_ep3, {
  fp("Candeo", "C-ZB-SM30-2G"),
})

register(switch_1, {
  fp("Candeo", "C205"),
  fp("IKEA", "E2006"),
})

register(heiman_switch_1, {
  fp("HEIMAN", "HS2SW1A-EF-3.0"),
  fp("HEIMAN", "HS2SW1A-EFR-3.0"),
  fp("HEIMAN", "HS2SW1L-EFR-3.0"),
  fp("HEIMAN", "HS6SW1A-W-EF-3.0"),
})

register(switch_1, {
  fp("KlikAanKlikUit", "Built-in Switch"),
  fp("Oz Smart Things", "WSP403"),
  fp("Sibling", "Powerswitch-ZK(W)"),
  fp("Sunricher", "SR-ZG9101SAC-HP-SWITCH-B"),
  fp("BTicino", "3584C"),
  fp("BTicino", "3577C"),
  fp("BTicino", "FC80AC"),
  fp("BTicino", "FC80CC"),
  fp("BTicino", "FC80RC"),
  fp("BTicino", "LN4570CWI"),
  fp("Elko", "EKO07250"),
  fp("Elko", "EKO07251"),
  fp("Elko", "EKO07252"),
  fp("Elko", "EKO07253"),
  fp("Elko", "EKO20004"),
  fp("Elko", "EKO30198"),
  fp("Elko", "EKO30199"),
  fp("Gira", "2430-100"),
  fp("Gira", "2435-10"),
  fp("Jung", "ZLLHS4"),
  fp("Legrand", "199142"),
  fp("Sunricher", "SR-ZG9100A-S"),
})

register(switch_1, {
  fp("Schneider Electric", "1GANG/SWITCH/1"),
  fp("Schneider Electric", "CH10AX/SWITCH/1"),
  fp("Schneider Electric", "CH2AX/SWITCH/1"),
  fp("Schneider Electric", "NHPB/SWITCH/1"),
  fp("Schneider Electric", "PUCK/SWITCH/1"),
  fp("Schneider Electric", "U201SRY2KWZB"),
})

register(switch_1, {
  fp("TERNCY", "TERNCY-LS01"),
})

register(switch_1_ep10, {
  fp("Schneider Electric", "A3N31SR800ZB_xx_C1"),
  fp("Schneider Electric", "E8331SRY800ZB"),
})

register(switch_2_ep10, {
  fp("Schneider Electric", "A3N32SR800ZB_xx_C1"),
  fp("Schneider Electric", "E8332SRY800ZB"),
})

register(switch_3_ep10, {
  fp("Schneider Electric", "A3N33SR800ZB_xx_C1"),
  fp("Schneider Electric", "E8333SRY800ZB"),
})

register(switch_1, create_model_fingerprints("Sunricher", {
  "ON/OFF",
  "ZIGBEE-SWITCH",
  "Micro Smart OnOff",
  "HK-SL-RELAY-A",
}))

register(switch_2, {
  fp("Candeo", "C-ZB-SM205-2G"),
})

register(heiman_switch_2, {
  fp("HEIMAN", "HS2SW2A-EF-3.0"),
  fp("HEIMAN", "HS2SW2A-EFR-3.0"),
  fp("HEIMAN", "HS2SW2L-EFR-3.0"),
  fp("HEIMAN", "HS6SW2A-W-EF-3.0"),
})

register(switch_2, {
  fp("LED-Trading", "UP-SA-9127D"),
  fp("Sunricher", "ON/OFF(2CH)"),
  fp("Sunricher", "SR-ZG9101SAC-HP-SWITCH-2CH"),
})

register(heiman_switch_3, {
  fp("HEIMAN", "HS2SW3A-EF-3.0"),
  fp("HEIMAN", "HS2SW3A-EFR-3.0"),
  fp("HEIMAN", "HS2SW3L-EFR-3.0"),
  fp("HEIMAN", "HS6SW3A-W-EF-3.0"),
})

register(switch_4, {
  fp("Nova Digital", "TPZ-4"),
  fp("Tuya", "DS-111"),
  fp("MHCOZY", "TYWB 4ch-RF"),
  fp("AVATTO", "TS0004_1"),
  fp("AVATTO", "ZBTS60-04"),
  fp("RSH", "SB04-Zigbee"),
  fp("AVATTO", "ZWSM16-4"),
  fp("Moes", "ZM4LT4"),
  fp("iHseno", "_TZ3000_knoj8lpk"),
  fp("AVATTO", "ZWOT12"),
  fp("Coibeu", "ZB414"),
  fp("Nova Digital", "SA-4"),
  fp("Mercator Ikuü", "SSW04"),
  fp("OXT", "SWTZ27"),
  fp("TUYATEC", "GDKES-04TZXD"),
  fp("MakeGood", "MG-ZG04W/B/G"),
  fp("TERNCY", "TERNCY-WS01-S4"),
  fp("_TZ3210_qjvi92wz", "TS0014"),
  fp("_TZ3210_w3hl6rao", "TS0014"),
  fp("_TZ3210_z4hgsevd", "TS0014"),
  fp("Vizo", "VZ-221S"),
  fp("Vizo", "VZ-222S"),
  fp("Vizo", "VZ-223S"),
  fp("LELLKI", "WP33-EU"),
})

register(switch_5_ep5, {
  fp("Sunricher", "SR-ZG9023A-EU"),
})

register(zunzunbee_sswz8t, {
  fp("zunzunbee", "SSWZ8T"),
})

-- ZCL REPORTING CAPABILITIES BEGIN
zcl.attach_reporting_capabilities(device_definitions, {
  {1, "rpt-zvs"},
  {2, "rpt-zef", {zr000600001 = "Switch", zr000600002 = "SwitchTwo"}},
  {3, "rpt-zej"},
  {4, "rpt-sit"},
  {5, "rpt-mcf"},
  {6, "rpt-cba", {zr000600001 = "Switch", zr000600002 = "SwitchTwo"}},
  {7, "rpt-sit"},
  {8, "rpt-hzd"},
  {9, "rpt-sit"},
  {10, "rpt-sit"},
  {11, "rpt-sit"},
  {12, "rpt-sit"},
  {13, "rpt-lpm", {zr0006000010 = "Switch", zr0006000011 = "SwitchTwo"}},
  {14, "rpt-lek", {zr0006000010 = "Switch", zr0006000011 = "SwitchTwo", zr0006000012 = "SwitchThree"}},
  {15, "rpt-sit"},
  {16, "rpt-lpm", {zr000600001 = "Switch", zr000600002 = "SwitchTwo"}},
  {17, "rpt-hjl"},
  {18, "rpt-lpm", {zr000600001 = "Switch", zr000600002 = "SwitchTwo"}},
  {19, "rpt-hns"},
  {20, "rpt-tmr", {zr000600001 = "Switch", zr000600002 = "SwitchTwo", zr000600003 = "SwitchThree", zr000600004 = "SwitchFour"}},
  {21, "rpt-swt", {zr000600001 = "Switch", zr000600002 = "SwitchTwo", zr000600003 = "SwitchThree", zr000600004 = "SwitchFour", zr000600005 = "SwitchFive"}},
  {22, "rpt-sfh"},
})
-- ZCL REPORTING CAPABILITIES END

return {
  id = "zcl.switches.retail_switches",
  registrations = device_definitions,
}

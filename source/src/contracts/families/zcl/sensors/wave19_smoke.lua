-- Frozen Zigbee2MQTT v26.99 eWeLink 7035 smoke-alarm candidate.

local zcl = require "protocol.zcl"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"
local fp = device_helpers.create_fingerprint
local data_types = require "st.zigbee.data_types"
local capabilities = require "st.capabilities"
local cluster_base = require "st.zigbee.cluster_base"

local registrations, register_device_definition = device_helpers.definition_registry()

local function alarm1(value)
  if type(value) == "table" then
    if type(value.is_alarm1_set) == "function" then
      return value:is_alarm1_set()
    end
    value = value.value
  end

  if type(value) ~= "number" then return nil end
  return value % 2 == 1
end

local function battery_percent(value, _, context)
  local raw_value = type(context) == "table" and context.raw_value or value
  if type(raw_value) ~= "number" or raw_value >= 0xFF then return nil end
  if type(context) == "table" then return value end
  return raw_value / 2
end

-- The frozen iasZoneAlarm extension does not configure ZoneStatus reporting;
-- this device's explicit configure hook only binds IAS Zone and reads its four
-- state attributes. Keep the common IAS enrolment/read adapter, but remove the
-- reporting cadence supplied by the common smoke preset.
local function unreported_alarm()
  local mapping = zcl.smoke({
    endpoint = 1,
    read_only = true,
    from_device = alarm1,
  })
  mapping.minimum_interval = nil
  mapping.maximum_interval = nil
  mapping.reportable_change = nil
  return mapping
end

local ewelink_7035 = {
  profile = "safety-wave19-ewelink-7035",
  zcl_clusters = {
    unreported_alarm(),
    zcl.battery({
      endpoint = 1,
      read_only = true,
      minimum_interval = 3600,
      maximum_interval = 65000,
      reportable_change = 10,
      from_device = battery_percent,
    }),
    zcl.cluster_attribute(0xFC11, 0x2000, {
      name = "ewelink_7035_tamper",
      endpoint = 1,
      mfg_code = 0x1286,
      data_type = data_types.Uint8,
      read_only = true,
      read_on_configure = true,
      from_device = function(value)
        if value == 0x01 then return true end
        if value == 0x00 then return false end
        return nil
      end,
      emit = emit.tamper(),
    }),
  },
  configure = function(_, device)
    -- The IAS adapter binds/enrols and reads ZoneStatus. Preserve the other
    -- three endpoint-1 IAS reads from the frozen definition as well.
    for _, attribute_id in ipairs({ 0x0000, 0x0010, 0x0011 }) do
      zcl.read_attribute(device, zcl.CLUSTER_IAS_ZONE, attribute_id, 1)
    end
  end,
}

register_device_definition(ewelink_7035, {
  fp(
    "eWeLink",
    "CK-TLSR8656-Z123SE22DY-01(7035)"
  ),
})

local function smszb_battery_events(_, value)
  if value == 0xFF then return nil end
  local percent = math.floor(math.max(0, math.min(100, (value - 25) * 20)) + 0.5)
  return {
    capabilities.battery.battery(percent),
    capabilities.voltageMeasurement.voltage({value=value/10, unit="V"}),
  }
end

local develco_smszb_core = {
  profile = "safety-smoke-smszb120-core",
  zcl_clusters = {
    zcl.smoke({endpoint=35, read_only=true, from_device=alarm1,
      minimum_interval=0, maximum_interval=65000, reportable_change=0}),
    zcl.battery_low({endpoint=35,read_on_configure=true,
      minimum_interval=0,maximum_interval=65000,reportable_change=0,
      emit=function(_,value)
        return value and capabilities.batteryLevel.battery.critical() or capabilities.batteryLevel.battery.normal()
      end}),
    zcl.temperature({endpoint=38, minimum_interval=10, maximum_interval=3600, reportable_change=100}),
    zcl.cluster_attribute(0x0001, 0x0020, {
      name="smszb_battery_voltage", endpoint=35, data_type=data_types.Uint8, read_only=true,
      minimum_interval=3600, maximum_interval=65000, reportable_change=10,
      emit=smszb_battery_events,
    }),
  },
}
for _, mapping in ipairs(develco_smszb_core.zcl_clusters) do
  if mapping.cluster_id == 0x0500 then
    mapping.minimum_interval = nil
    mapping.maximum_interval = nil
    mapping.reportable_change = nil
  end
end
register_device_definition(develco_smszb_core, {
  fp("Develco Products A/S", "SMSZB-120"),
  fp("Develco Products A/S", "GWA1512_SmokeSensor"),
  fp("frient A/S", "SMSZB-120"),
})

local function multir_smoke_mapping()
  local mapping = zcl.smoke({endpoint=1, read_only=true, from_device=function(value)
    if type(value) == "table" then value = value.value end
    -- The device DDF uses the generic fire item's alarm1+alarm2 mask.
    return (value & 3) ~= 0
  end})
  mapping.minimum_interval = nil
  mapping.maximum_interval = nil
  mapping.reportable_change = nil
  return mapping
end

local multir_sm100_core = {
  profile = "safety-smoke-multir-sm100-core",
  zcl_clusters = {
    multir_smoke_mapping(),
    zcl.battery({endpoint=1, read_only=true, minimum_interval=3600, maximum_interval=65000,
      reportable_change=10, from_device=battery_percent}),
  },
}
register_device_definition(multir_sm100_core, {
  fp("MultIR", "MIR-SM100-E"),
})

local function aqara_battery(voltage_mv, minimum)
  minimum = minimum or 2475
  return {
    capabilities.battery.battery(math.floor(math.max(0,math.min(100,(voltage_mv-minimum)*100/(3000-minimum)))+0.5)),
    capabilities.voltageMeasurement.voltage({value=voltage_mv/1000, unit="V"}),
  }
end

local function smoke_heartbeat(minimum, include_smoke)
  return function(_, value)
  local fields = type(value) == "table" and value.value or value
  if fields == nil then fields = value end
  if type(fields) == "string" then
    local decoded, offset = {}, 1
    while offset + 1 <= #fields do
      local key, kind = fields:byte(offset, offset + 1)
      local width = kind >= 0x20 and kind <= 0x2F and ((kind % 8)+1) or kind == 0x10 and 1
      if not width or offset + 1 + width > #fields then break end
      decoded[key] = string.unpack("<"..(kind >= 0x28 and "i" or "I")..width, fields, offset+2)
      offset = offset + 2 + width
    end
    fields = decoded
  end
  if type(fields) ~= "table" then return nil end
  local voltage = fields[1] or fields["1"]
  local events = type(voltage) == "number" and aqara_battery(voltage, minimum) or {}
  local smoke = fields[160] or fields["160"]
  if include_smoke and smoke ~= nil then
    events[#events+1] = capabilities.smokeDetector.smoke(smoke == 1 and "detected" or "clear")
  end
  return #events > 0 and events or nil
  end
end

local aqara_smoke_heartbeat = smoke_heartbeat(2475, true)
local aqara_smoke_ias = unreported_alarm()
aqara_smoke_ias.read_on_configure = false
aqara_smoke_ias.ias_configure_method = 0

local aqara_smoke_acn03_core = {
  profile = "safety-smoke-aqara-acn03-core",
  zcl_clusters = {
    aqara_smoke_ias,
    zcl.cluster_attribute(0xFCC0, 0x013A, {
      name="aqara_smoke", endpoint=1, mfg_code=0x115F, data_type=data_types.Uint8,
      read_only=true, read_on_configure=true, from_device=function(value) return value == 1 end,
      emit=emit.smoke(),
    }),
    zcl.cluster_attribute(0xFCC0, 0x00F7, {
      name="aqara_smoke_heartbeat", endpoint=1, read_only=true, read_on_configure=false,
      emit=aqara_smoke_heartbeat,
    }),
    zcl.cluster_attribute(0x0000, 0xFF01, {
      name="aqara_smoke_basic_heartbeat", endpoint=1, read_only=true, read_on_configure=false,
      emit=aqara_smoke_heartbeat,
    }),
    zcl.cluster_attribute(0x0001, 0x0020, {
      name="aqara_smoke_battery_voltage", endpoint=1, data_type=data_types.Uint8,
      read_only=true, read_on_configure=true, emit=function(_, value)
        if value == 0xFF then return nil end
        return aqara_battery(value*100)
      end,
    }),
    zcl.power_configuration_battery({endpoint=1, read_only=true, scale=2,
      emit=emit.battery(), read_on_configure=false, from_device=battery_percent}),
  },
  configure=function(_, device)
    device:send(cluster_base.write_manufacturer_specific_attribute(
      device, 0xFCC0, 0x014B, 0x115F, data_types.Uint8, 1):to_endpoint(1))
  end,
}
register_device_definition(aqara_smoke_acn03_core, {
  fp("LUMI", "lumi.sensor_smoke.acn03"),
})

local function mijia_smoke_mapping()
  local mapping = unreported_alarm()
  mapping.read_on_configure = false
  mapping.ias_configure_method = 0 -- SDK CUSTOM: this Xiaomi model needs no enrolment writes.
  return mapping
end

local mijia_smoke_core = {
  profile = "safety-smoke-mijia-core",
  zcl_clusters = {
    mijia_smoke_mapping(),
    zcl.cluster_attribute(0, 0xFF01, {
      name="mijia_smoke_battery", endpoint=1, read_only=true, read_on_configure=false,
      emit=smoke_heartbeat(2850, false),
    }),
    zcl.cluster_attribute(0, 0xFF02, {
      name="mijia_smoke_struct_battery", endpoint=1, read_only=true, read_on_configure=false,
      emit=function(_, value)
        local elements = value.elements
        local raw = elements and elements[2] and elements[2].data
        local voltage = type(raw) == "table" and raw.value or raw
        if type(voltage) == "number" then return aqara_battery(voltage,2850) end
      end,
    }),
  },
}
register_device_definition(mijia_smoke_core, {
  fp("LUMI", "lumi.sensor_smoke"),
})

local function standard_smoke_core_clusters(feibit)
  local smoke=unreported_alarm()
  smoke.read_on_configure=false
  local low=zcl.battery_low({endpoint=1,read_on_configure=false,
    emit=function(_,value)
      return value and capabilities.batteryLevel.battery.critical() or capabilities.batteryLevel.battery.normal()
    end})
  low.minimum_interval,low.maximum_interval,low.reportable_change=nil,nil,nil
  local mappings={
    smoke,
    low,
    zcl.battery({endpoint=1,read_only=true,read_on_configure=true,
      minimum_interval=3600,maximum_interval=65000,reportable_change=0,
      from_device=battery_percent}),
    zcl.cluster_attribute(1,0x20,{
      name="smoke_core_voltage",endpoint=1,data_type=data_types.Uint8,read_only=true,read_on_configure=false,
      emit=function(_,value)
        if type(value)=="table" then value=value.value end
        if value~=255 then return capabilities.voltageMeasurement.voltage({value=value/10,unit="V"}) end
      end,
    }),
    zcl.cluster_attribute(1,0x3E,{
      name="smoke_core_battery_alarm",endpoint=1,data_type=data_types.Bitmap32,read_only=true,
      read_on_configure=feibit==true,
      minimum_interval=feibit and 3600 or nil,maximum_interval=feibit and 65000 or nil,
      reportable_change=feibit and 0 or nil,
      emit=function(_,value)
        return (value & 0xF03C0F)~=0 and capabilities.batteryLevel.battery.critical() or capabilities.batteryLevel.battery.normal()
      end,
    }),
  }
  if feibit then
    local tamper=zcl.tamper({endpoint=1,read_on_configure=false})
    tamper.minimum_interval,tamper.maximum_interval,tamper.reportable_change=nil,nil,nil
    mappings[#mappings+1]=tamper
  end
  return mappings
end

local feibit_ssa01_core = {
  profile="safety-smoke-feibit-ssa01-core",magic_packet=false,
  zcl_clusters=standard_smoke_core_clusters(true),
}
register_device_definition(feibit_ssa01_core, {
  fp("feibit","FNB56-SMF06FB1.6"),
  fp("Feibit Inc co.","FNB56-SMF06FB1.6"),
  fp("Feibit Inc co.","FNB56-SMF06FB2.0"),
})

local heimgard_htsmo2_core = {
  profile="safety-smoke-heimgard-htsmo2-core",magic_packet=false,
  zcl_clusters=standard_smoke_core_clusters(false),
}
register_device_definition(heimgard_htsmo2_core, {
  fp("Heimgard","HT-SMO-2"),
})

local function ts0205_core_clusters()
  local smoke=unreported_alarm()
  smoke.read_on_configure=false
  local tamper=zcl.tamper({endpoint=1,read_on_configure=false})
  local battery=zcl.battery({endpoint=1,read_on_configure=false,from_device=battery_percent})
  for _, mapping in ipairs({tamper,battery}) do
    mapping.minimum_interval,mapping.maximum_interval,mapping.reportable_change=nil,nil,nil
  end
  return {smoke,tamper,battery}
end

local tuya_ts0205_core = {
  profile="safety-smoke-tuya-ts0205-core",magic_packet=false,
  zcl_clusters=ts0205_core_clusters(),
  parent_refresh=function(device)
    zcl.read_attribute(device,1,0x21,1)
    zcl.read_attribute(device,1,0x20,1)
  end,
}
register_device_definition(tuya_ts0205_core, {
  fp("_TYZB01_dsjszp0x","TS0205"),
  fp("_TZ3000_hl7yraue","TS0205"),
  fp("_TYZB01_hr7c7xlf","TS0205"),
  fp("_TYZB01_yt1wd5db","TS0205"),
  fp("_TZ3210_4c6b5m1e","TS0205"),
  fp("_TZ3000_2szo322m","TS0205"),
})

local function gs_sshm_core_clusters()
  local smoke=unreported_alarm()
  smoke.read_on_configure=false
  local tamper=zcl.tamper({endpoint=1,read_on_configure=false})
  local low=zcl.battery_low({endpoint=1,read_on_configure=false,
    emit=function(_,value)
      return value and capabilities.batteryLevel.battery.critical() or capabilities.batteryLevel.battery.normal()
    end})
  for _, mapping in ipairs({tamper,low}) do
    mapping.minimum_interval,mapping.maximum_interval,mapping.reportable_change=nil,nil,nil
  end
  return {smoke,tamper,low,zcl.battery({endpoint=1,read_on_configure=true,
    minimum_interval=3600,maximum_interval=65000,reportable_change=10,
    from_device=battery_percent})}
end

local gs_sshm_i1_core = {
  profile="safety-smoke-gs-sshm-i1-core",magic_packet=false,
  zcl_clusters=gs_sshm_core_clusters(),
}
register_device_definition(gs_sshm_i1_core, {
  fp("GS","SSHM-I1"),
})

local function bitron_smoke_core_clusters()
  local smoke=unreported_alarm()
  smoke.read_on_configure=false
  local tamper=zcl.tamper({endpoint=1,read_on_configure=false})
  local low=zcl.battery_low({endpoint=1,read_on_configure=false,
    emit=function(_,value)
      return value and capabilities.batteryLevel.battery.critical() or capabilities.batteryLevel.battery.normal()
    end})
  for _, mapping in ipairs({tamper,low}) do
    mapping.minimum_interval,mapping.maximum_interval,mapping.reportable_change=nil,nil,nil
  end
  return {smoke,tamper,low}
end

local bitron_av2010_24_core = {
  profile="safety-smoke-bitron-av2010-24-core",magic_packet=false,
  zcl_clusters=bitron_smoke_core_clusters(),
}
register_device_definition(bitron_av2010_24_core, {
  fp("SMaBiT","902010/24"),
  fp("SMaBiT","AV2010/24"),
  fp("Bitron Home","902010/24"),
  fp("Bitron Home","AV2010/24"),
  fp("Bitron Video","902010/24"),
  fp("Bitron Video","AV2010/24"),
  fp("SMaBiT","902010/24A"),
  fp("SMaBiT","AV2010/24A"),
  fp("Bitron Home","902010/24A"),
  fp("Bitron Home","AV2010/24A"),
  fp("Bitron Video","902010/24A"),
  fp("Bitron Video","AV2010/24A"),
})

return {
  id = "zcl.sensors.wave19_smoke",
  registrations = registrations,
}

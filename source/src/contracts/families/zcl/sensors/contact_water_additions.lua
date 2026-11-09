local zcl = require "protocol.zcl"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"
local fp = device_helpers.create_fingerprint
local data_types = require "st.zigbee.data_types"
local caps = require "st.capabilities"
local clusters = require "st.zigbee.zcl.clusters"

local device_definitions, register = device_helpers.definition_registry()

local function core_battery_value(value, _, context)
  if context and context.raw_value == 0xFF then return nil end
  return value
end

local function core_battery(options)
  options.from_device = options.from_device or core_battery_value
  return zcl.battery(options)
end

local function core_voltage(options)
  options.from_device = options.from_device or core_battery_value
  return zcl.battery_voltage(options)
end

local function voltage_battery_events(minimum,maximum)
  return function(_,value)
    if value==255 then return end
    return {caps.battery.battery(math.floor(math.max(0,math.min(100,(value-minimum)*100/(maximum-minimum)))+0.5)),
      caps.voltageMeasurement.voltage({value=value/10,unit="V"})}
  end
end
local linear_voltage_events=voltage_battery_events(25,30)

local function core_battery_alarm(_,value)
  return (value & 0xF03C0F)~=0 and caps.batteryLevel.battery.critical() or caps.batteryLevel.battery.normal()
end

local function low_battery_event(_,value)
  return value and caps.batteryLevel.battery.critical() or caps.batteryLevel.battery.normal()
end

local function notification(mapping,emitter)
    mapping.minimum_interval=nil
    mapping.maximum_interval=nil
    mapping.reportable_change=nil
    mapping.read_on_configure=false
    mapping.emit=function(device,value,context)
      if context.command_id==0 then return emitter(device,value) end
    end
    return mapping
end
local function iris_3326_battery(value)
  if value == 0xFF then return nil end
  local voltage = value * 100
  local percent = 100
  if voltage < 2100 then percent = 0
  elseif voltage < 2440 then percent = 6 - (2440-voltage)*6/340
  elseif voltage < 2740 then percent = 18 - (2740-voltage)*12/300
  elseif voltage < 2900 then percent = 42 - (2900-voltage)*24/160
  elseif voltage < 3000 then percent = 100 - (3000-voltage)*58/100 end
  return math.floor(percent+0.5)
end

local function iris_voltage_events(_,value)
  if value==255 then return end
  return {caps.battery.battery(iris_3326_battery(value)),caps.voltageMeasurement.voltage({value=value/10,unit="V"})}
end

do
local iris_3315_l = {
  profile="safety-water-iris-3315l",
  zcl_clusters={
    notification(zcl.water({endpoint=1,read_only=true,read_on_refresh=false,ias_configure_method=0}),emit.water()),
    notification(zcl.tamper({endpoint=1,read_only=true,read_on_refresh=false,ias_configure_method=0}),emit.tamper()),
    notification(zcl.battery_low({endpoint=1,read_only=true,read_on_refresh=false,ias_configure_method=0}),low_battery_event),
    zcl.temperature({endpoint=1,read_only=true,read_on_configure=false,read_on_refresh=false,
      minimum_interval=10,maximum_interval=3600,reportable_change=100}),
    zcl.cluster_attribute(1,0x20,{name="iris3315_voltage",endpoint=1,data_type=data_types.Uint8,
      read_only=true,read_on_configure=true,read_on_refresh=false,
      minimum_interval=3600,maximum_interval=65000,reportable_change=0,emit=linear_voltage_events}),
    zcl.cluster_attribute(1,0x3E,{name="iris3315_alarm",endpoint=1,data_type=data_types.Bitmap32,
      read_only=true,read_on_configure=false,read_on_refresh=false,emit=core_battery_alarm}),
  },
}
register(iris_3315_l,{fp("CentraLite","3315-L"),fp("CentraLite","3315-S"),fp("CentraLite","3315-Seu"),fp("CentraLite","3315-G")})
end

local function configure_measurements(rows, query, after)
  return function(driver,device)
    for _,mapping in ipairs(rows) do
      if mapping.reporting_defaults then zcl.bind_cluster(device,mapping.cluster_id,driver.environment_info.hub_zigbee_eui,1) end
    end
    for _,mapping in ipairs(rows) do
      local defaults=mapping.reporting_defaults
      if defaults then zcl.configure_reporting(device,{cluster=mapping.cluster_id,attribute=mapping.attribute_id,
        data_type=mapping.data_type,minimum_interval=defaults.minimum_interval,
        maximum_interval=defaults.maximum_interval,reportable_change=defaults.reportable_change},1) end
    end
    if query then zcl.read_attribute(device,1,query,1) end
    if after then after(device) end
  end
end


local function ias_alarm_rows(factory,options,attribute_reports)
  local rows={factory(options),zcl.tamper(options),zcl.battery_low(options)}
  rows[3].emit=low_battery_event
  if not attribute_reports then
    for index,mapping in ipairs(rows) do rows[index]=notification(mapping,mapping.emit) end
  end
  return rows
end

local function centralite_contact(profile, attribute_reports, battery, after, voltage_emit)
  local rows=ias_alarm_rows(zcl.contact,{endpoint=1,read_only=true,read_on_configure=false,read_on_refresh=false,
    configure_reporting=false,ias_configure_method=0},attribute_reports)
  rows[#rows+1]=zcl.temperature({endpoint=1,data_type=data_types.Int16,read_only=true,
    configure_reporting=false,read_on_configure=false,read_on_refresh=false,
    reporting_defaults={minimum_interval=10,maximum_interval=3600,reportable_change=100}})
  if battery then
    rows[#rows+1]=zcl.cluster_attribute(1,0x20,{name="centralite_contact_voltage",endpoint=1,data_type=data_types.Uint8,
      read_only=true,read_on_configure=false,read_on_refresh=false,emit=voltage_emit or linear_voltage_events,
      reporting_defaults={minimum_interval=3600,maximum_interval=65000,reportable_change=0}})
    rows[#rows+1]=zcl.cluster_attribute(1,0x3E,{name="centralite_contact_alarm",endpoint=1,data_type=data_types.Bitmap32,
      read_only=true,read_on_configure=false,read_on_refresh=false,emit=core_battery_alarm})
  end
  return {profile=profile,zcl_clusters=rows,configure=configure_measurements(rows,battery and 0x20,after),
    announce_handler=after}
end
do
local centralite_3300_s=centralite_contact("safety-contact-centralite-3300s",true,true)
local centralite_3323_g=centralite_contact("safety-contact-centralite-3323g",false,false)
register(centralite_3300_s,{fp("CentraLite","3300-S")})
register(centralite_3323_g,{fp("CentraLite","3323-G"),fp("Ecolink","4655BC0-R")})
end


do
local function smartthings_water(profile, percentage)
  local rows=ias_alarm_rows(zcl.water,{endpoint=1,read_only=true,read_on_configure=false,read_on_refresh=false,
    configure_reporting=false,ias_configure_method=0},percentage)
  if percentage then
    for _,mapping in ipairs(rows) do
      local emitter=mapping.emit
      mapping.emit=function(device,value,context)
        if context.command_id==0 or context.zb_rx.body.zcl_header.cmd.value==10 then return emitter(device,value) end
      end
    end
  end
  local temperature=zcl.temperature({endpoint=1,data_type=data_types.Int16,read_only=true,
    configure_reporting=false,read_on_configure=false,read_on_refresh=false,
    reporting_defaults={minimum_interval=10,maximum_interval=3600,reportable_change=100}})
  if percentage then
    rows[#rows+1]=temperature
    rows[#rows+1]=core_battery({endpoint=1,data_type=data_types.Uint8,read_only=true,
      configure_reporting=false,read_on_configure=false,read_on_refresh=false,
      reporting_defaults={minimum_interval=3600,maximum_interval=65000,reportable_change=0}})
    rows[#rows+1]=core_voltage({endpoint=1,read_only=true,configure_reporting=false,read_on_configure=false,read_on_refresh=false})
  else
    rows[#rows+1]=zcl.cluster_attribute(1,0x20,{name="smartthings_water_voltage",endpoint=1,data_type=data_types.Uint8,
      read_only=true,read_on_configure=false,read_on_refresh=false,emit=linear_voltage_events,
      reporting_defaults={minimum_interval=3600,maximum_interval=65000,reportable_change=0}})
    rows[#rows+1]=temperature
  end
  rows[#rows+1]=zcl.cluster_attribute(1,0x3E,{name="smartthings_water_alarm",endpoint=1,data_type=data_types.Bitmap32,
    read_only=true,read_on_configure=false,read_on_refresh=false,emit=core_battery_alarm})
  return {profile=profile,zcl_clusters=rows,configure=configure_measurements(rows,percentage and 0x21 or 0x20)}
end
local samjin_water=smartthings_water("safety-water-samjin",true)
local smartthings_moisture_v4=smartthings_water("safety-water-smartthings-v4",false)
register(samjin_water,{fp("Samjin","water")})
register(smartthings_moisture_v4,{fp("SmartThings","moisturev4")})
end


do
local function visonic_poll_interval(device)
  if not device.zigbee_endpoints[1] then return false end
  return pcall(device.send,device,clusters.PollControl.commands.SetLongPollInterval(device,1200):to_endpoint(1))
end
local visonic_mct350=centralite_contact("safety-contact-visonic-mct350",false,false,visonic_poll_interval)
register(visonic_mct350,{fp("Visonic","MCT-350 SMA")})

local visonic_mct340=centralite_contact("safety-contact-visonic-mct340",false,true,nil,iris_voltage_events)
register(visonic_mct340,{fp("Visonic","MCT-340 E"),fp("Visonic","MCT-340 SMA"),fp("Sercomm Corp.","SZ-DWS04")})
end

-- ZCL REPORTING CAPABILITIES BEGIN
zcl.attach_reporting_capabilities(device_definitions, {
  {1, "rpt-zum"},
  {2, "rpt-zlb"},
  {3, "rpt-zpf"},
  {4, "rpt-wpn"},
  {5, "rpt-mdi"},
  {6, "rpt-zpf"},
  {7, "rpt-zlb"},
})
-- ZCL REPORTING CAPABILITIES END

return {
  id = "zcl.sensors.contact_water_additions",
  registrations = device_definitions,
}

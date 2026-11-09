local zcl = require "protocol.zcl"
local emit = require "capabilities.events.all"
local device_helpers = require "contracts.helpers.family"
local fp = device_helpers.create_fingerprint
local data_types = require "st.zigbee.data_types"
local caps = require "st.capabilities"
local device_management = require "st.zigbee.device_management"

local device_definitions, register = device_helpers.definition_registry()

local function core_battery_value(value, _, context)
  if context and context.raw_value == 0xFF then return nil end
  return value
end

local function voltage_preferred_battery(value,_,context)
        local body=context.zb_rx.body.zcl_body
        local voltage=type(body.get_attribute_data)=="function" and body:get_attribute_data(0x20)
        if type(voltage)=="table" then voltage=voltage.value end
        if type(voltage)=="number" and voltage<255 then return end
        if context.raw_value~=255 then return value end
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
local function without_reporting(mapping)
  mapping.minimum_interval = nil
  mapping.maximum_interval = nil
  mapping.reportable_change = nil
  return mapping
end

local function ias_alarm_rows(factory,options,attribute_reports)
  local rows={factory(options),zcl.tamper(options),zcl.battery_low(options)}
  rows[3].emit=low_battery_event
  if not attribute_reports then
    for index,mapping in ipairs(rows) do rows[index]=notification(mapping,mapping.emit) end
  end
  return rows
end

local function read_power_battery(device)
  for _,attribute in ipairs({0x21,0x20}) do
    pcall(zcl.read_attribute,device,1,attribute,device:get_endpoint(1))
  end
end

do
local function sengled_power_endpoint(device,_,context)
  return context and context.zb_rx and context.endpoint or device:get_endpoint(1)
end
local function configure_power_battery(driver,device)
  local endpoint=device:get_endpoint(1)
  for _,attribute in ipairs({0x21,0x20}) do
    zcl.bind_cluster(device,1,driver.environment_info.hub_zigbee_eui,endpoint)
    zcl.configure_reporting(device,{cluster=1,attribute=attribute,data_type=data_types.Uint8,
      minimum_interval=3600,maximum_interval=65000,reportable_change=10},endpoint,{auto_endpoint=true})
    pcall(zcl.read_attribute,device,1,attribute,endpoint)
  end
end
local function configure_temperatures(driver,device)
  for _,endpoint in pairs(device.zigbee_endpoints) do
    if device:supports_server_cluster(0x0402,endpoint.id) then
      zcl.bind_cluster(device,0x0402,driver.environment_info.hub_zigbee_eui,endpoint.id)
      zcl.configure_reporting(device,{cluster=0x0402,attribute=0,data_type=data_types.Int16,
        minimum_interval=10,maximum_interval=3600,reportable_change=100},endpoint.id,{auto_endpoint=true})
      pcall(zcl.read_attribute,device,0x0402,0,endpoint.id)
    end
  end
end
do
local sengled_contact = {
  profile="safety-contact-sengled-g73",magic_packet=false,
  parent_refresh=read_power_battery,
  configure=configure_power_battery,
  zcl_clusters={
    without_reporting(zcl.contact({component="main",read_on_configure=false,read_on_refresh=false,ias_configure_method=0})),
    without_reporting(zcl.tamper({component="main",read_on_configure=false,read_on_refresh=false,ias_configure_method=0})),
    without_reporting(zcl.battery_low({component="main",read_on_configure=false,read_on_refresh=false,
      ias_configure_method=0,emit=low_battery_event})),
  },
}
for _,factory in ipairs({core_battery,core_voltage}) do
  sengled_contact.zcl_clusters[#sengled_contact.zcl_clusters+1]=without_reporting(factory({
    endpoint=sengled_power_endpoint,component="main",read_on_configure=false,read_on_refresh=false,
    reporting_defaults={minimum_interval=3600,maximum_interval=65000,reportable_change=10}}))
end
register(sengled_contact,{fp("sengled","E1D-G73"),fp("sengled","E2D-G73")})
end

do
local ecolink_sound = {
  profile="safety-sound-ecolink-ffzb1",magic_packet=false,
  parent_refresh=function(device)
    pcall(zcl.read_attribute,device,0x0402,0,device:get_endpoint(0x0402))
    read_power_battery(device)
  end,
  configure=configure_temperatures,
  zcl_clusters={
    without_reporting(zcl.alarm({component="main",read_only=true,read_on_configure=false,read_on_refresh=false,ias_configure_method=0,
      emit=function(_,value) return value and caps.soundSensor.sound.detected() or caps.soundSensor.sound.not_detected() end})),
    without_reporting(zcl.tamper({component="main",read_only=true,read_on_configure=false,read_on_refresh=false,ias_configure_method=0})),
    without_reporting(zcl.battery_low({component="main",read_only=true,read_on_configure=false,read_on_refresh=false,
      ias_configure_method=0,emit=low_battery_event})),
    without_reporting(zcl.temperature({component="main",data_type=data_types.Int16,read_only=true,read_on_configure=false,read_on_refresh=false,
      reporting_defaults={minimum_interval=10,maximum_interval=3600,reportable_change=100,all_endpoints=true}})),
    without_reporting(core_battery({component="main",read_only=true,read_on_configure=false,read_on_refresh=false,
      from_device=voltage_preferred_battery})),
    zcl.cluster_attribute(1,0x20,{name="ecolink_sound_voltage",component="main",data_type=data_types.Uint8,
      read_only=true,read_on_configure=false,read_on_refresh=false,emit=voltage_battery_events(22,30)}),
  },
}
register(ecolink_sound,{fp("Ecolink","FFZB1-SM-ECO")})
end

do
local function waxman_alerts(zb_rx,device)
  local water,low=false,false
  for _,alert in ipairs(zb_rx.body.zcl_body.alert_structure_list or {}) do
    local value=alert.value
    if (value&0x3000)~=0 then
      if (value&255)==0x82 then low=true else water=true end
    end
  end
  device:emit_event(water and caps.waterSensor.water.wet() or caps.waterSensor.water.dry())
  device:emit_event(low_battery_event(nil,low))
end
local waxman_8840100h={
  profile="safety-water-waxman-8840100h",magic_packet=false,
  parent_refresh=function(device)
    pcall(zcl.send_raw_cluster_command,device,0x0B02,0,"",1)
    read_power_battery(device)
    pcall(zcl.read_attribute,device,0x0402,0,device:get_endpoint(0x0402))
  end,
  configure=function(driver,device)
    if device:supports_server_cluster(0x0500) then device_management.configure_ias_zone(device,1,driver.environment_info.hub_zigbee_eui) end
    zcl.bind_cluster(device,0x0B02,driver.environment_info.hub_zigbee_eui,1)
    configure_power_battery(driver,device)
    configure_temperatures(driver,device)
  end,
  zcl_clusters={
    {cluster_id=0x0B02,command_id=0,command_extractor=waxman_alerts,read_only=true},
    {cluster_id=0x0B02,command_id=1,command_extractor=waxman_alerts,read_only=true},
    without_reporting(zcl.temperature({component="main",data_type=data_types.Int16,read_only=true,read_on_configure=false,read_on_refresh=false,
      reporting_defaults={minimum_interval=10,maximum_interval=3600,reportable_change=100,all_endpoints=true}})),
    zcl.cluster_attribute(1,0x3E,{name="waxman_battery_alarm",component="main",data_type=data_types.Bitmap32,
      read_only=true,read_on_configure=false,read_on_refresh=false,emit=core_battery_alarm}),
  },
}
for _,factory in ipairs({core_battery,core_voltage}) do
  waxman_8840100h.zcl_clusters[#waxman_8840100h.zcl_clusters+1]=without_reporting(factory({
    endpoint=sengled_power_endpoint,component="main",read_on_configure=false,read_on_refresh=false,
    reporting_defaults={minimum_interval=3600,maximum_interval=65000,reportable_change=10}}))
end
register(waxman_8840100h,{fp("WAXMAN","leakSMART Water Sensor V2")})
end
end

do
local function passive_ias(profile,factory,battery)
  local rows=ias_alarm_rows(factory,{component="main",read_only=true,read_on_configure=false,read_on_refresh=false,
    configure_reporting=false,ias_configure_method=1})
  if battery then
    for _,mapping in ipairs({core_battery,core_voltage}) do
      rows[#rows+1]=without_reporting(mapping({component="main",read_only=true,read_on_configure=false,read_on_refresh=false}))
    end
    rows[#rows+1]=zcl.cluster_attribute(1,0x3E,{name="battery_alarm",component="main",data_type=data_types.Bitmap32,
      read_only=true,read_on_configure=false,read_on_refresh=false,emit=core_battery_alarm})
  end
  return {profile=profile,magic_packet=false,zcl_clusters=rows}
end
local aurora_window=passive_ias("safety-contact-aurora-window",zcl.contact,true)
register(aurora_window,{fp("Aurora","WindowSensor51AU")})
local livingwise_contact=passive_ias("safety-contact-livingwise-lvs",zcl.contact)
register(livingwise_contact,{fp("ORVIBO","e70f96b3773a4c9283c6862dbafb6a99")})
local orvibo_sw21=passive_ias("safety-water-orvibo-sw21",zcl.water)
register(orvibo_sw21,{fp("HEIMAN","da2edf1ded0d44e1815d06f45ce02029"),fp("Heiman","2f077707a13f4120846e0775df7e2efe")})
local climax_co8=passive_ias("safety-co-climax-co8",zcl.carbon_monoxide,true)
register(climax_co8,{fp("ClimaxTechnology","CO_00.00.00.15TC"),fp("ClimaxTechnology","CO_00.00.00.22TC")})
end

do
local percentages={[16]=1,[17]=15,[18]=30,[19]=30,[20]=50,[21]=50,[22]=70,[23]=70,[24]=90,[25]=90,[26]=100,[27]=100,[28]=100}
local pgc314_battery=emit.battery()
local smartthings_pgc314={
  profile="safety-motion-smartthings-pgc314",magic_packet=false,additional_zcl_profiles={0xFC01},
  zcl_clusters=ias_alarm_rows(zcl.motion,{component="main",read_only=true,read_on_configure=false,read_on_refresh=false,
    configure_reporting=false,ias_configure_method=1}),
}
smartthings_pgc314.zcl_clusters[#smartthings_pgc314.zcl_clusters+1]={
  cluster_id=0xFC04,command_id=0,mfg_code=0x110A,profile_id=0xFC01,read_only=true,
  command_extractor=function(zb_rx,device)
    if zb_rx.address_header.profile.value~=0xFC01 then return end
    local value=zb_rx.body.zcl_body.body_bytes:byte()
    if (value&1)==0 then
      local voltage=value>>2
      device:emit_event(pgc314_battery(device,percentages[math.min(28,voltage)] or 0))
      device:emit_event(caps.voltageMeasurement.voltage({value=voltage/10,unit="V"}))
    end
    device:emit_event((value&2)~=0 and caps.motionSensor.motion.active() or caps.motionSensor.motion.inactive())
  end,
}
register(smartthings_pgc314,{fp("SmartThings","PGC314")})
end

-- ZCL REPORTING CAPABILITIES BEGIN
zcl.attach_reporting_capabilities(device_definitions, {
  {1, "rpt-edw"},
  {2, "rpt-fws"},
  {3, "rpt-ldr"},
})
-- ZCL REPORTING CAPABILITIES END

return {
  id = "zcl.sensors.passive_alarm_additions",
  registrations = device_definitions,
}

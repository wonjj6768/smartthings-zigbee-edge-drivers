local zcl = require "protocol.zcl"
local emit = require "capabilities.events.all"
local helpers = require "contracts.helpers.family"
local zcl_helpers = require "contracts.helpers.zcl"
local capabilities = require "st.capabilities"
local types = require "st.zigbee.data_types"
local base = require "st.zigbee.cluster_base"
local definitions, register = helpers.definition_registry()

local function finite(value, minimum, maximum)
  return type(value)=="number" and value==value and value>=minimum and value<=maximum
end
local function half_degree(value)
  local doubled=value*2
  local whole=math.floor(doubled)
  local bits=string.unpack("<I8",string.pack("<d",doubled))
  local exponent=((bits>>52)&0x7FF)-1022
  local mantissa=(bits&0xFFFFFFFFFFFFF)|0x10000000000000
  if mantissa*20 >= (whole*20+9)*(1<<(53-exponent)) then whole=whole+1 end
  return whole*50
end
local function received(value, _, context, mapping)
  local rx=context.zb_rx
  for _, record in ipairs(rx.body.zcl_body.attr_records or {}) do
    if record.attr_id.value==mapping.attribute_id and record.data==context.typed_value then
      if (record.status and record.status.value~=0) or record.data_type.value~=mapping.data_type.ID then return end
      value=type(value)=="table" and value.value or value
      if type(value)=="number" and value%1==0 then return value end
    end
  end
end
local function scaled(divisor, minimum, maximum)
  return function(value, device, context, mapping)
    value=received(value,device,context,mapping)
    if value~=nil and finite(value/divisor,minimum,maximum) then return value/divisor end
  end
end
local function lookup(values)
  return function(value,device,context,mapping) return values[received(value,device,context,mapping)] end
end
local function write(device, mapping, value)
  if value==nil then return false end
  local request=base.write_attribute(device,types.ClusterId(mapping.cluster_id),types.AttributeId(mapping.attribute_id),
    mapping.data_type(value)):to_endpoint(device:get_endpoint(mapping.cluster_id))
  if mapping.mfg_code then
    request.body.zcl_header.frame_ctrl:set_mfg_specific()
    request.body.zcl_header.mfg_code=types.Uint16(mapping.mfg_code)
  end
  request.body.zcl_header.frame_ctrl:set_disable_default_response()
  return pcall(device.send,device,request)
end
local function setpoint(device,mapping,value)
  local minimum=mapping.attribute_id==0x12 and 16 or 18
  return write(device,mapping,finite(value,minimum,30) and half_degree(value) or nil)
end
local mode_rx={[0]="off",[1]="auto",[3]="cool",[4]="heat",[5]="emergency heat",[6]="precooling",[7]="fanonly",[8]="dryair",[9]="asleep"}
local mode_tx={off=0,auto=1,cool=3,heat=4,fanonly=7,dryair=8}
local fan_rx={[0]="off",[1]="low",[2]="medium",[3]="high",[4]="on",[5]="auto",[6]="smart"}
local fan_tx={off=0,low=1,medium=2,high=3,auto=5}
local louver_rx={[0]="fully_closed",[1]="fully_closed",[2]="fully_open",[3]="quarter_open",[4]="half_open",[5]="three_quarters_open"}
local louver_tx={fully_closed=1,fully_open=2,quarter_open=3,half_open=4,three_quarters_open=5}
local mappings={}
local function attribute(cluster,id,name,kind,from,event,reporting,sender,manufacturer)
  mappings[#mappings+1]=zcl.cluster_attribute(cluster,id,{
    name=name,data_type=kind,from_device=from,emit=event,sender=sender,mfg_code=manufacturer,
    read_only=sender==nil,read_on_configure=false,read_on_refresh=true,
    suppress_optimistic_state=true,reporting_defaults=reporting,
  })
end
attribute(0x0405,0,"nodon_irb_humidity",types.Uint16,scaled(100,0,100),emit.humidity(),
  {minimum_interval=10,maximum_interval=3600,reportable_change=100})
attribute(0x0201,0,"nodon_irb_temperature",types.Int16,scaled(100,-273.15,327.67),emit.temperature("C"),
  {minimum_interval=0,maximum_interval=3600,reportable_change=10})
attribute(0x0201,0x10,"nodon_irb_local_calibration",types.Int8,scaled(10,-12.8,12.7),emit.nodonIrbLocalCalibration(),nil,
  function(device,mapping,value) return write(device,mapping,finite(value,-2.5,2.5) and math.floor(value*10+0.5) or nil) end)
attribute(0x0201,0x12,"current_heating_setpoint",types.Int16,scaled(100,-273.15,327.67),emit.heating_setpoint("C"),
  {minimum_interval=0,maximum_interval=3600,reportable_change=10},setpoint)
attribute(0x0201,0x11,"current_cooling_setpoint",types.Int16,scaled(100,-327.68,327.67),emit.cooling_setpoint("C"),
  {minimum_interval=0,maximum_interval=3600,reportable_change=10},setpoint)
attribute(0x0201,0x1C,"system_mode",types.Enum8,lookup(mode_rx),emit.thermostat_mode(),
  {minimum_interval=0,maximum_interval=3600},
  function(device,mapping,value) return write(device,mapping,mode_tx[value]) end)
attribute(0x0202,0,"nodon_irb_fan",types.Enum8,lookup(fan_rx),emit.value(capabilities.airConditionerFanMode.fanMode),
  {minimum_interval=0,maximum_interval=3600},
  function(device,mapping,value) return write(device,mapping,type(value)=="string" and fan_tx[value:lower()] or nil) end)
attribute(0x0201,0x45,"nodon_irb_louver",types.Enum8,lookup(louver_rx),emit.nodonIrbLouver(),
  {minimum_interval=0,maximum_interval=3600},
  function(device,mapping,value) return write(device,mapping,louver_tx[value]) end)
attribute(0xFC82,0x8001,"nodon_irb_holder_calibration",types.Int16,scaled(10,-3276.8,3276.7),emit.nodonIrbHolderCalibration(),nil,
  function(device,mapping,value) return write(device,mapping,finite(value,-10,10) and math.floor(value*10+0.5) or nil) end,0x128B)

local function read(device,mapping)
  local request=base.read_attribute(device,types.ClusterId(mapping.cluster_id),types.AttributeId(mapping.attribute_id),
    mapping.mfg_code):to_endpoint(device:get_endpoint(mapping.cluster_id))
  if mapping.mfg_code then
    request.body.zcl_header.frame_ctrl:set_mfg_specific()
    request.body.zcl_header.mfg_code=types.Uint16(mapping.mfg_code)
  end
  request.body.zcl_header.frame_ctrl:set_disable_default_response()
  return pcall(device.send,device,request)
end
local family={
  profile="thermostats-nodon-irb",magic_packet=false,initial_custom_state_query=false,zcl_clusters=mappings,
  thermostat_supported_modes={"off","heat","cool","auto","dryair","fanonly"},
  component_to_endpoint=function(device) return device:get_endpoint(0x0201) end,
  protocol_writers={nodon_irb_identify=zcl_helpers.identify},
  capability_commands={
    {capability_id="airConditionerFanMode",command_name="setFanMode",mapping_name="nodon_irb_fan",argument_name="fanMode"},
    {capability_id="concertmirror08464.nodonIrbIdentify",command_name="identify",mapping_name="nodon_irb_identify",value=3},
    {capability_id="concertmirror08464.nodonIrbIdentify",command_name="setIdentifyTime",mapping_name="nodon_irb_identify",argument_name="identifyTime"},
  },
  runtime_start=function(device)
    device:emit_event(capabilities.thermostatMode.supportedThermostatModes({"off","heat","cool","auto","dryair","fanonly"},{visibility={displayed=false}}))
    device:emit_event(capabilities.thermostatHeatingSetpoint.heatingSetpointRange({value={minimum=16,maximum=30,step=0.5},unit="C"}))
    device:emit_event(capabilities.thermostatCoolingSetpoint.coolingSetpointRange({value={minimum=18,maximum=30,step=0.5},unit="C"}))
    device:emit_event(capabilities.airConditionerFanMode.supportedAcFanModes({"off","low","medium","high","auto"},{visibility={displayed=false}}))
  end,
  parent_refresh=function(device,definition)
    if definition.zcl_refresh_before_read_all then definition.zcl_refresh_before_read_all(device,definition) end
    for _,mapping in ipairs(mappings) do read(device,mapping) end
  end,
  configure=function(driver,device)
    local hub=driver.environment_info.hub_zigbee_eui
    -- Holder calibration has no primary configure action; its GET remains in refresh.
    for index=1,8 do
      local mapping=mappings[index]
      local endpoint=device:get_endpoint(mapping.cluster_id)
      if index==2 or index==7 then zcl.bind_cluster(device,mapping.cluster_id,hub,endpoint) end
      local defaults=mapping.reporting_defaults
      if defaults then
        zcl.bind_cluster(device,mapping.cluster_id,hub,endpoint)
        zcl.configure_reporting(device,{
          cluster=mapping.cluster_id,attribute=mapping.attribute_id,data_type=mapping.data_type,
          minimum_interval=defaults.minimum_interval,maximum_interval=defaults.maximum_interval,
          reportable_change=defaults.reportable_change,
        },endpoint,{defer_on_override=true,disable_default_response=true})
      end
      read(device,mapping)
    end
  end,
}
register(family,{helpers.create_fingerprint("NodOn","IRB-4-1-00")})
-- ZCL REPORTING CAPABILITIES BEGIN
zcl.attach_reporting_capabilities(definitions, {
  {1, "rpt-iyj"},
})
-- ZCL REPORTING CAPABILITIES END

return {id="zcl.thermostats.nodon_irb",registrations=definitions,}

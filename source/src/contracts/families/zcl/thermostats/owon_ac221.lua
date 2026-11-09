-- OWON / AC221 only. Pinned ZHC cff1de4731a14a84094a8568d8bbf92aa5feb0db.
-- BEGIN PURE CODEC
local function finite(value, low, high)
  return type(value)=="number" and value==value and value>=low and value<=high
end
local function trim(value)
  local whitespace={[9]=true,[10]=true,[11]=true,[12]=true,[13]=true,[32]=true,[0xA0]=true,[0x1680]=true,
    [0x2028]=true,[0x2029]=true,[0x202F]=true,[0x205F]=true,[0x3000]=true,[0xFEFF]=true}
  for code=0x2000,0x200A do whitespace[code]=true end
  if not utf8.len(value) then return end
  local first,last
  for offset,code in utf8.codes(value) do
    if not whitespace[code] then first=first or offset;last=offset+#utf8.char(code)-1 end
  end
  return first and value:sub(first,last) or ""
end
local function pairing_action(value)
  if type(value)=="boolean" then return value and 1 or 0 end
  if type(value)~="string" then return end
  local text=trim(value)
  if not text then return end
  text=text:lower()
  if text=="start" or text=="on" or text=="true" then return 1 end
  if text=="end" or text=="off" or text=="false" then return 0 end
end
local function pairing_code(value)
  if type(value)=="number" then
    if not finite(value,-1,65536) then return end
    value=math.modf(value)
    if value<0 or value>65535 then return end
    return value
  end
  if type(value)~="string" then return end
  local text=trim(value)
  if not text or not text:match("^%d+$") then return end
  local result=tonumber(text)
  if finite(result,0,65535) then return result end
end
local function pairing_result(payload)
  if type(payload)~="string" or #payload==0 then return "null" end
  local count,codes=payload:byte(1),{}
  for offset=2,math.min(#payload-1,count*2),2 do
    codes[#codes+1]=tostring(string.unpack("<I2",payload,offset))
  end
  return string.format('{"count":%d,"codes_found":[%s]}',count,table.concat(codes,","))
end
local function code_state(payload)
  if type(payload)~="string" or #payload<2 then return end
  local value=string.unpack("<I2",payload)
  return value==65535 and "null" or tostring(value)
end
local function setpoint_wire(value)
  if not finite(value,8,30) then return end
  -- Exact binary64 decision boundary of primary toFixed(1), then Math.round.
  local doubled=value*2
  local whole=math.floor(doubled)
  local bits=string.unpack("<I8",string.pack("<d",doubled))
  local exponent=((bits>>52)&0x7FF)-1022
  local mantissa=(bits&0xFFFFFFFFFFFFF)|0x10000000000000
  if mantissa*20 >= (whole*20+9)*(1<<(53-exponent)) then whole=whole+1 end
  return whole*50
end
local louver_tx={fully_closed=1,fully_open=2,quarter_open=3,half_open=4,three_quarters_open=5}
local louver_rx={[0]="fully_closed","fully_closed","fully_open","quarter_open","half_open","three_quarters_open"}
-- END PURE CODEC
local zcl=require "protocol.zcl"
local emit=require "capabilities.events.all"
local helpers=require "contracts.helpers.family"
local capabilities=require "st.capabilities"
local types=require "st.zigbee.data_types"
local base=require "st.zigbee.cluster_base"
local definitions,register=helpers.definition_registry()
local mappings,commands,writers={},{},{}
local THERMOSTAT,FAN,AC,OWON=0x0201,0x0202,0xFFAC,0x113C
local status_event=emit.owonAc221PairingStatus()
local result_event=emit.owonAc221PairingResult()
local code_event=emit.owonAc221PairingCode()
local function flags(tx)
  tx.body.zcl_header.frame_ctrl:set_disable_default_response()
  return tx:to_endpoint(1)
end
local function read(device,cluster,attribute)
  device:send(flags(base.read_attribute(device,types.ClusterId(cluster),types.AttributeId(attribute))))
end
local function write(device,cluster,attribute,kind,value)
  local tx=base.write_attribute(device,types.ClusterId(cluster),types.AttributeId(attribute),kind(value))
  if not pcall(device.send,device,flags(tx)) then return false end
  -- Only actual controller RX changes state. This extra read is an Edge adapter.
  return pcall(read,device,cluster,attribute)
end
local function private_command(device,command,payload)
  local tx=base.build_manufacturer_specific_command(device,AC,command,OWON,payload)
  return pcall(device.send,device,flags(tx))
end
local function command(cap,name,mapping,argument,value)
  commands[#commands+1]={capability_id=cap,command_name=name,mapping_name=mapping,argument_name=argument,value=value}
end
local function add(cluster,attribute,name,kind,convert,event,defaults)
  local mapping=zcl.cluster_attribute(cluster,attribute,{name=name,data_type=kind,endpoint=1,
    from_device=convert,emit=event,read_only=true,read_on_configure=false,read_on_refresh=false})
  mapping.reporting_defaults=defaults
  mappings[#mappings+1]=mapping
  return mapping
end
local function typed(value,context,mapping,kind)
  for _,record in ipairs(context and context.zb_rx and context.zb_rx.body.zcl_body.attr_records or {}) do
    if record.attr_id.value==mapping.attribute_id and record.data==context.typed_value then
      if record.status and record.status.value~=0 then return end
      if not record.data_type or record.data_type.value~=kind then return end
      return type(value)=="table" and value.value or value
    end
  end
end
local function temperature(guard)
  return function(value,_,context,mapping)
    value=typed(value,context,mapping,0x29)
    if not finite(value,-32767,32767) or value%1~=0 then return end
    value=value/100
    if not guard or value>=-273.15 then return value end
  end
end
local function lookup(values)
  return function(value,_,context,mapping)
    value=typed(value,context,mapping,0x30)
    return values[value]
  end
end
add(THERMOSTAT,0,"owon_ac221_local_temperature",types.Int16,temperature(true),emit.temperature("C"),
  {minimum_interval=60,maximum_interval=600,reportable_change=0}) -- primary0.1 encodes Int16 0000
add(THERMOSTAT,0x12,"owon_ac221_heating_rx",types.Int16,temperature(true),emit.heating_setpoint("C"),
  {minimum_interval=0,maximum_interval=3600,reportable_change=10})
add(THERMOSTAT,0x11,"owon_ac221_cooling_rx",types.Int16,temperature(false),emit.cooling_setpoint("C"),
  {minimum_interval=0,maximum_interval=3600,reportable_change=10})
for _,item in ipairs({{"heating","thermostatHeatingSetpoint","setHeatingSetpoint",0x12},{"cooling","thermostatCoolingSetpoint","setCoolingSetpoint",0x11}}) do
  local route="owon_ac221_"..item[1]
  writers[route]=function(device,value)
    local raw=setpoint_wire(value)
    if raw==nil then return false end
    return write(device,THERMOSTAT,item[4],types.Int16,raw)
  end
  command(item[2],item[3],route,"setpoint")
end
local mode_tx={off=0,auto=1,cool=3,heat=4,fanonly=7,dryair=8}
local mode_rx={[0]="off",[1]="auto",[3]="cool",[4]="heat",[5]="emergencyheat",[6]="precooling",[7]="fanonly",[8]="dryair",[9]="asleep"}
add(THERMOSTAT,0x1C,"owon_ac221_mode_rx",types.Enum8,lookup(mode_rx),emit.thermostat_mode(),
  {minimum_interval=10,maximum_interval=3600})
writers.owon_ac221_mode=function(device,value)
  local raw=mode_tx[value]
  if raw==nil then return false end
  return write(device,THERMOSTAT,0x1C,types.Enum8,raw)
end
command("thermostatMode","setThermostatMode","owon_ac221_mode","mode")
for _,mode in ipairs({"off","auto","cool","heat"}) do command("thermostatMode",mode,"owon_ac221_mode",nil,mode) end
local fan_tx={off=0,low=1,medium=2,high=3,on=4,auto=5,smart=6}
local fan_rx={[0]="off","low","medium","high","on","auto","smart"}
add(FAN,0,"owon_ac221_fan_rx",types.Enum8,lookup(fan_rx),emit.value(capabilities.airConditionerFanMode.fanMode),
  {minimum_interval=0,maximum_interval=3600})
writers.owon_ac221_fan=function(device,value)
  if type(value)~="string" then return false end
  local raw=fan_tx[value:lower()]
  if raw==nil then return false end
  return write(device,FAN,0,types.Enum8,raw)
end
command("airConditionerFanMode","setFanMode","owon_ac221_fan","fanMode")
local louver=add(THERMOSTAT,0x45,"owon_ac221_louver",types.Enum8,lookup(louver_rx),emit.owonAc221Louver())
louver.read_only=false
louver.sender=function(device,_,value)
  local raw=louver_tx[value]
  if raw==nil then return false end
  return write(device,THERMOSTAT,0x45,types.Enum8,raw)
end
command("concertmirror08464.owonAc221Louver","setLouverPosition","owon_ac221_louver","position")
writers.owon_ac221_read_louver=function(device) return pcall(read,device,THERMOSTAT,0x45) end
command("concertmirror08464.owonAc221Louver","readLouverPosition","owon_ac221_read_louver")
writers.owon_ac221_one_key_pairing=function(device,value)
  local raw=pairing_action(value)
  if raw==nil then return false end
  return private_command(device,0x52,string.char(raw))
end
command("concertmirror08464.owonAc221OneKeyPairing","setPairing","owon_ac221_one_key_pairing","action")
command("concertmirror08464.owonAc221OneKeyPairing","startPairing","owon_ac221_one_key_pairing",nil,"start")
command("concertmirror08464.owonAc221OneKeyPairing","endPairing","owon_ac221_one_key_pairing",nil,"end")
writers.owon_ac221_pairing_code=function(device,value)
  local raw=pairing_code(value)
  if raw==nil then return false end
  return private_command(device,0x20,string.pack("<I2",raw))
end
writers.owon_ac221_read_pairing_code=function(device) return private_command(device,0,"") end
command("concertmirror08464.owonAc221PairingCode","setPairingCode","owon_ac221_pairing_code","pairingCode")
command("concertmirror08464.owonAc221PairingCode","readPairingCode","owon_ac221_read_pairing_code")
local function publish(device,factory,value)
  if value~=nil then device:emit_component_event({id="main"},factory(device,value)) end
end
local function receive(device,rx)
  if rx.address_header.src_endpoint.value~=1 or rx.address_header.cluster.value~=AC then return end
  local header,body=rx.body.zcl_header,rx.body.zcl_body
  if (header.frame_ctrl.value&0x0B)~=0x09 or not header.mfg_code or header.mfg_code.value~=OWON then return end
  local payload=body.body_bytes
  if type(payload)~="string" then return end
  if header.cmd.value==0x52 and #payload>=1 then
    publish(device,status_event,payload:byte(1)==0 and "SUCCESS" or "FAILURE")
  elseif header.cmd.value==0x80 then
    publish(device,result_event,pairing_result(payload))
  elseif header.cmd.value==0 then
    publish(device,code_event,code_state(payload))
  end
end
local family={profile="thermostats-owon-ac221",zcl_clusters=mappings,capability_commands=commands,protocol_writers=writers,
  initial_custom_state_query=false,zigbee_message_handler=receive,
  runtime_start=function(device)
    device:emit_event(capabilities.thermostatMode.supportedThermostatModes({"off","auto","cool","heat","fanonly","dryair"},{visibility={displayed=false}}))
    device:emit_event(capabilities.airConditionerFanMode.supportedAcFanModes({"low","medium","high","on","auto"},{visibility={displayed=false}}))
  end,
  configure=function(driver,device)
    zcl.bind_cluster(device,THERMOSTAT,driver.environment_info.hub_zigbee_eui,1)
    zcl.bind_cluster(device,FAN,driver.environment_info.hub_zigbee_eui,1)
    for _,mapping in ipairs(mappings) do
      local defaults=mapping.reporting_defaults
      if defaults then
        zcl.configure_reporting(device,{cluster=mapping.cluster_id,attribute=mapping.attribute_id,data_type=mapping.data_type,
          minimum_interval=defaults.minimum_interval,maximum_interval=defaults.maximum_interval,reportable_change=defaults.reportable_change},
          1,{disable_default_response=true})
      end
    end
  end,
  parent_refresh=function(device)
    for _,attribute in ipairs({0,0x12,0x11,0x1C,0x45}) do read(device,THERMOSTAT,attribute) end
    read(device,FAN,0)
    return private_command(device,0,"")
  end,
}
register(family,{helpers.create_fingerprint("OWON","AC221")})
-- ZCL REPORTING CAPABILITIES BEGIN
zcl.attach_reporting_capabilities(definitions, {
  {1, "rpt-ajn"},
})
-- ZCL REPORTING CAPABILITIES END

return {id="zcl.thermostats.owon_ac221",registrations=definitions,}

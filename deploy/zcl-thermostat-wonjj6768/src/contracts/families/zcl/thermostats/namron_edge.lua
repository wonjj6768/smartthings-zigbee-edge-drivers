local zcl=require"protocol.zcl"
local emit=require"capabilities.events.all"
local device_helpers=require"contracts.helpers.family"
local capabilities=require"st.capabilities"
local data_types=require"st.zigbee.data_types"
local cluster_base=require"st.zigbee.cluster_base"
local device_definitions,register_device_definition=device_helpers.definition_registry()local SENSOR_MODES={[0]="air","floor","air_floor","external","external_floor","floor_percent","regulator"}local SCREEN_TIMES={[0]="always_on","10s","30s","60s"}local WEEK_PROGRAMS={[0]="mon_fri_sat_sun","mon_sat_sun","no_time_off","time_off"}local FAULTS={[0]="er0","zigbee_error","bluetooth_error","internal_sensor_error","floor_sensor_error","external_sensor_error","overheat_error","overload_error"}
local function scalar(value)
if type(value)=="table"then return value.value end
return value
end
local function programming_mode(value)
local raw=scalar(value)return bit32.band(raw,4)~=0 and"eco"or bit32.band(raw,1)~=0 and"schedule"or"setpoint"
end
local function read_edge(device,attribute)
device:send(cluster_base.read_attribute(
device,data_types.ClusterId(0x0201),data_types.AttributeId(attribute)):to_endpoint(1))
end
local function read_edge_all(device)
for cluster,attributes in pairs({
[0x0000]={0x4000,0x0006},[0x0201]={0x0000,0x0012,0x0011,0x001C,0x0029,0x0010,0x0008,0x0025,0x0003,0x0004,0x8000,0x8001,0x8002,0x8003,0x8004,0x8005,0x8006,0x8007,0x800A,0x800B,0x8011,0x8012,0x8013,0x801D,0x801F,0x8020,0x8021,0x8022,0x8023,0x8024,0x8025,0x8029},[0x0204]={0x0000,0x0001},[0x0702]={0x0000,0x0301,0x0302},[0x0B04]={0x050B,0x0508,0x0604,0x0605},})do
for _,attribute in ipairs(attributes)do
device:send(cluster_base.read_attribute(device,data_types.ClusterId(cluster),data_types.AttributeId(attribute)):to_endpoint(1))
end
end
end
local function write_edge(device,attribute,typed_value,read_before,read_after)
if read_before then read_edge(device,attribute)end
local request=cluster_base.write_attribute(
device,data_types.ClusterId(0x0201),data_types.AttributeId(attribute),typed_value):to_endpoint(1)request.body.zcl_header.frame_ctrl:unset_disable_default_response()device:send(request)if read_after then
device.thread:call_with_delay(1,function()
for _,attr in ipairs(read_after)do read_edge(device,attr)end
end)
end
end
local function sync_edge_time(device,read_before)
local local_unix=os.time()+(device:get_field("nam_edge_time_zone")or 0)*3600
write_edge(device,0x800B,data_types.Uint32(local_unix),read_before)write_edge(device,0x800A,data_types.Boolean(false),read_before)read_edge(device,0x800B)return true
end
local function remember_mode(device,name,value,context)
if context then
for _,record in ipairs(context.zb_rx.body.zcl_body.attr_records or{})do
if record.data then
local attr,raw=record.attr_id.value,scalar(record.data)local item,state
if attr==0x001C then item,state="system_mode",({[0]="off",[3]="cool",[4]="heat"})[raw]elseif attr==0x0025 then item,state="programming_operation_mode",programming_mode(raw)elseif attr==0x8001 then item,state="frost",(raw==true or raw==1)and"ON"or"OFF"
elseif attr==0x8004 then item,state="sensor_mode",SENSOR_MODES[raw]elseif attr==0x801F then item,state="vacation_mode",(raw==true or raw==1)and"ON"or"OFF"
elseif attr==0x8023 then item,state="countdown_set",raw*5 end
if item and state~=nil then device:set_field("nam_edge_"..item,state,{persist=true})end
end
end
end
if value==nil then return nil end
device:set_field("nam_edge_"..name,value,{persist=true})local mode="manual"
if device:get_field("nam_edge_frost")=="ON"then mode="frost"
elseif device:get_field("nam_edge_vacation_mode")=="ON"then mode="holiday"
elseif device:get_field("nam_edge_sensor_mode")=="regulator"then mode="regulator"
elseif(device:get_field("nam_edge_countdown_set")or 0)>0 then mode="countdown"
elseif device:get_field("nam_edge_programming_operation_mode")=="schedule"then mode="schedule"
elseif device:get_field("nam_edge_programming_operation_mode")=="eco"then mode="eco"end
device:emit_component_event({id="main"},emit.namEdgeThermostatMode()(device,mode))return value
end
local function edge_setting_sender(device,mapping,value,context)
local meta=zcl.mapping_meta(mapping)local attr=meta.attribute_id
if attr==0x8004 and value=="regulator"and device:get_field("nam_edge_system_mode")=="cool"then return false end
if attr==0x8023 and device:get_field("nam_edge_system_mode")=="cool"then return false end
local encoded=value
if meta.to_device then encoded=meta.to_device(value,device,context,mapping)end
if encoded==nil then return false end
local before=attr==0x8000 or attr==0x8001 or attr==0x8004 or attr==0x8005 or
attr==0x801F or attr==0x8020 or attr==0x8021 or attr==0x8022 or attr==0x8023 or attr==0x8029
local after=attr==0x8004 and{0x8004,0x801D,0x8007}or
(attr==0x8005 or attr==0x8029)and{attr}or nil
write_edge(device,attr,meta.data_type(encoded),before,after)if attr==0x8001 then remember_mode(device,"frost",value)elseif attr==0x801F then remember_mode(device,"vacation_mode",value)elseif attr==0x8023 then remember_mode(device,"countdown_set",value)elseif attr==0x8013 or attr==0x8025 then
local fahrenheit=math.floor((value*9/5+32)*10+0.5)/10
write_edge(device,attr==0x8013 and 0x801B or 0x8026,data_types.Int16(math.floor(fahrenheit*(attr==0x8013 and 100 or 10)+0.5)))
end
return true
end
local function date_from_device(value)
local raw=scalar(value)
if raw==0 then return nil end
return os.date("!%Y-%m-%d",raw*86400)
end
local function date_to_device(value)
local year,month,day=value:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)$")
if year==nil then return nil end
year,month,day=tonumber(year),tonumber(month),tonumber(day)
if month<1 or month>12 or day<1 or day>31 then return nil end
year=year-(month<=2 and 1 or 0)local era=math.floor(year/400)local y=year-era*400
local days=era*146097+y*365+math.floor(y/4)-math.floor(y/100)+
math.floor((153*(month+(month>2 and-3 or 9))+2)/5)+day-1-719468
return days>0 and date_from_device(days)==value and days or nil
end
local function fahrenheit_temperature(value,device)
if device:get_field("nam_edge_display_unit")~="fahrenheit"then return nil end
return math.floor(((scalar(value)/100-32)*5/9)*10+0.5)/10
end
local function week_schedule(rx,device)
local bytes=rx.body.zcl_body.body_bytes
if type(bytes)~="string"or #bytes~=32 then return nil end
local entries={}for offset=1,29,4 do
local temperature=(bit32.band(bytes:byte(offset+2),0x0F)*256+bytes:byte(offset+3))/10
if device:get_field("nam_edge_display_unit")=="fahrenheit"then
temperature=math.floor((temperature-32)*5/9*2+0.5)/2
end
entries[#entries+1]=string.format("%02d:%02d %g",bytes:byte(offset),bytes:byte(offset+1),temperature)
end
device:emit_component_event({id="main"},emit.namEdgeWeekSchedule()(device,"Work days: "..table.concat(entries,", ",1,6).." | Days off: "..table.concat(entries,", ",7,8)))
end
local namron_edge={
profile="thermostats-namron-edge",thermostat_supported_modes={"off","heat","cool"},heating_setpoint_range={minimum=5,maximum=35,step=0.5,unit="C"},cooling_setpoint_range={minimum=10,maximum=40,step=0.5,unit="C"},
runtime_start=function(device)
device:emit_component_event({id="main"},capabilities.thermostatMode.supportedThermostatModes({"off","heat","cool"}))device:emit_component_event({id="main"},capabilities.thermostatHeatingSetpoint.heatingSetpointRange({
value={minimum=5,maximum=35,step=0.5},unit="C",}))device:emit_component_event({id="main"},capabilities.thermostatCoolingSetpoint.coolingSetpointRange({
value={minimum=10,maximum=40,step=0.5},unit="C",}))device:emit_component_event({id="main"},emit.namEdgeTimeZone()(device,device:get_field("nam_edge_time_zone")or 0))read_edge_all(device)
end,
protocol_writers={
nam_edge_time_zone=function(device,offset)
device:set_field("nam_edge_time_zone",offset,{persist=true})return sync_edge_time(device,true)
end,
},zcl_clusters={
zcl.switch({endpoint=1,configure_reporting=true,minimum_interval=0,maximum_interval=65000}),zcl.local_temperature({endpoint=1,read_only=true,minimum_interval=10,maximum_interval=300,reportable_change=10}),zcl.heating_setpoint({endpoint=1,minimum_interval=10,maximum_interval=300,reportable_change=50,
to_device=function(value)return math.max(5,math.min(35,math.floor(value*2+0.5)/2))end,
}),zcl.cooling_setpoint({endpoint=1,minimum_interval=10,maximum_interval=300,reportable_change=50,
to_device=function(value)return math.max(10,math.min(40,math.floor(value*2+0.5)/2))end,
}),zcl.thermostat_system_mode({endpoint=1,name="system_mode",emit=emit.thermostat_mode(),read_on_configure=true,
from_device=function(value,device,context)
return remember_mode(device,"system_mode",({[0]="off",[3]="cool",[4]="heat"})[scalar(value)],context)
end,
sender=function(device,mapping,value)
if value=="cool"and device:get_field("nam_edge_sensor_mode")=="regulator"then return false end
local raw=({off=0,cool=3,heat=4})[value]
if raw==nil then return false end
write_edge(device,0x001C,data_types.Enum8(raw))remember_mode(device,"system_mode",value)return true
end,
}),zcl.thermostat_running_state({endpoint=1,name="thermostat_operating_state",read_only=true,read_on_configure=true,emit=emit.thermostat_operating_state(),
from_device=function(value)
local raw=scalar(value)return bit32.band(raw,1)~=0 and"heating"or bit32.band(raw,2)~=0 and"cooling"or"idle"
end,
}),zcl.humidity({endpoint=1,read_only=true,minimum_interval=10,maximum_interval=300,reportable_change=100}),zcl.cluster_attribute(0x0B04,0x050B,{endpoint=1,name="power",emit=emit.power(),data_type=data_types.Int16,metering_kind="power",scale=1,read_only=true,read_on_configure=true}),zcl.cluster_attribute(0x0B04,0x0508,{endpoint=1,name="current",emit=emit.current(),data_type=data_types.Uint16,metering_kind="current",scale=1,read_only=true,read_on_configure=true}),zcl.cluster_attribute(0x0702,0x0000,{endpoint=1,name="energy",emit=emit.energy(),data_type=data_types.Uint48,metering_kind="energy",scale=1,read_only=true,read_on_configure=true}),zcl.cluster_attribute(0x0201,0x0010,{
endpoint=1,name="nam_edge_temperature_calibration",emit=emit.namEdgeTemperatureCalibration(),data_type=data_types.Int8,read_on_configure=true,
from_device=function(value)return value/10 end,
to_device=function(value)return math.floor(value*10+0.5)end,
}),zcl.cluster_attribute(0x0201,0x0008,{
endpoint=1,name="nam_edge_pi_heating_demand",emit=emit.namEdgePiHeatingDemand(),data_type=data_types.Uint8,read_only=true,read_on_configure=true,
from_device=function(value)return value*100/255 end,
}),zcl.cluster_attribute(0x0201,0x0025,{
endpoint=1,name="nam_edge_programming_operation_mode",emit=emit.namEdgeProgrammingOperationMode(),data_type=data_types.Bitmap8,read_on_configure=true,
from_device=function(value,device,context)return remember_mode(device,"programming_operation_mode",programming_mode(value),context)end,
sender=function(device,mapping,value)
if value~="eco"then zcl.send_raw_cluster_command(device,0x0201,0x08,string.char(0),1)end
write_edge(device,0x801F,data_types.Boolean(false),true)remember_mode(device,"vacation_mode","OFF")if value=="eco"then zcl.send_raw_cluster_command(device,0x0201,0x08,string.char(1),1)
else zcl.send_raw_cluster_command(device,0x0201,0x07,string.char(value=="schedule"and 1 or 0),1)end
remember_mode(device,"programming_operation_mode",value)return true
end,
}),zcl.cluster_attribute(0x0201,0x8000,{
endpoint=1,name="nam_edge_window_open_check",emit=emit.namEdgeWindowOpenCheck(),data_type=data_types.Boolean,read_on_configure=true,sender=edge_setting_sender,
from_device=function(value)return(value==true or value==1)and"ON"or"OFF"end,
to_device=function(value)return value=="ON"end,
}),zcl.cluster_attribute(0x0201,0x8001,{
endpoint=1,name="nam_edge_frost",emit=emit.namEdgeFrost(),data_type=data_types.Boolean,read_on_configure=true,sender=edge_setting_sender,
from_device=function(value,device,context)return remember_mode(device,"frost",(value==true or value==1)and"ON"or"OFF",context)end,
to_device=function(value)return value=="ON"end,
}),zcl.cluster_attribute(0x0201,0x8002,{
endpoint=1,name="nam_edge_window_state",emit=emit.namEdgeWindowState(),data_type=data_types.Boolean,read_on_configure=true,read_only=true,
from_device=function(value)return(value==true or value==1)and"open"or"closed"end,
}),zcl.cluster_attribute(0x0201,0x8004,{
endpoint=1,name="nam_edge_sensor_mode",emit=emit.namEdgeSensorMode(),data_type=data_types.Enum8,read_on_configure=true,sender=edge_setting_sender,suppress_optimistic_state=true,
from_device=function(value,device,context)return remember_mode(device,"sensor_mode",SENSOR_MODES[scalar(value)],context)end,
to_device=function(value)for raw,name in pairs(SENSOR_MODES)do if value==name then return raw end end end,
}),zcl.cluster_attribute(0x0201,0x8005,{
endpoint=1,name="nam_edge_panel_brightness",emit=emit.namEdgePanelBrightness(),data_type=data_types.Uint8,read_on_configure=true,sender=edge_setting_sender,}),zcl.cluster_attribute(0x0201,0x8006,{
endpoint=1,name="nam_edge_fault",emit=emit.namEdgeFault(),data_type=data_types.Bitmap32,read_on_configure=true,read_only=true,
from_device=function(value)
local bits={}local raw=scalar(value)
for bit=0,7 do if bit32.band(raw,2 ^ bit)~=0 then bits[#bits+1]=FAULTS[bit]end end
return #bits>0 and table.concat(bits,",")or"none"
end,
}),zcl.cluster_attribute(0x0201,0x8007,{
endpoint=1,name="nam_edge_regulator_cycle",emit=emit.namEdgeRegulatorCycleStatus(),data_type=data_types.Uint8,read_on_configure=true,read_only=true,}),zcl.cluster_attribute(0x0201,0x8003,{
endpoint=1,name="nam_edge_week_program",emit=emit.namEdgeWeekProgram(),data_type=data_types.Enum8,read_on_configure=true,read_only=true,poll_interval=900,
from_device=function(value)return WEEK_PROGRAMS[scalar(value)]end,
}),zcl.cluster_attribute(0x0201,0x800A,{
endpoint=1,name="nam_edge_auto_time_pending",emit=emit.namEdgeAutoTimePending(),data_type=data_types.Boolean,read_only=true,read_on_configure=true,
from_device=function(value)return(scalar(value)==true or scalar(value)==1)and"ON"or"OFF"end,
handler=function(device,value)
if value=="ON"then sync_edge_time(device,false);read_edge(device,0x800A)end
end,
}),zcl.cluster_attribute(0x0201,0x800B,{
endpoint=1,name="nam_edge_clock_last_synced",emit=emit.namEdgeClockLastSynced(),data_type=data_types.Uint32,read_only=true,read_on_configure=true,
from_device=function(value)return os.date("!%Y-%m-%d %H:%M:%S",value)end,
}),zcl.cluster_attribute(0x0201,0x8013,{
endpoint=1,name="nam_edge_holiday_temp_set",emit=emit.namEdgeHolidayTempSet(),data_type=data_types.Int16,read_on_configure=true,sender=edge_setting_sender,
from_device=function(value)return value/100 end,
to_device=function(value)return math.floor(value*100+0.5)end,
}),zcl.cluster_attribute(0x0201,0x801D,{
endpoint=1,name="nam_edge_regulator_percentage",emit=emit.namEdgeRegulatorPercentage(),data_type=data_types.Int16,read_on_configure=true,sender=edge_setting_sender,}),zcl.cluster_attribute(0x0201,0x801F,{
endpoint=1,name="nam_edge_vacation_mode",emit=emit.namEdgeVacationMode(),data_type=data_types.Boolean,read_on_configure=true,sender=edge_setting_sender,
from_device=function(value,device,context)return remember_mode(device,"vacation_mode",(value==true or value==1)and"ON"or"OFF",context)end,
to_device=function(value)return value=="ON"end,
}),zcl.cluster_attribute(0x0201,0x8020,{
endpoint=1,name="nam_edge_vacation_start",emit=emit.namEdgeVacationStart(),data_type=data_types.Uint32,read_on_configure=true,sender=edge_setting_sender,from_device=date_from_device,to_device=date_to_device,}),zcl.cluster_attribute(0x0201,0x8021,{
endpoint=1,name="nam_edge_vacation_end",emit=emit.namEdgeVacationEnd(),data_type=data_types.Uint32,read_on_configure=true,sender=edge_setting_sender,from_device=date_from_device,to_device=date_to_device,}),zcl.cluster_attribute(0x0201,0x8022,{
endpoint=1,name="nam_edge_auto_time",emit=emit.namEdgeAutoTime(),data_type=data_types.Boolean,read_on_configure=true,sender=edge_setting_sender,
from_device=function(value)return(value==true or value==1)and"ON"or"OFF"end,
to_device=function(value)return value=="ON"end,
}),zcl.cluster_attribute(0x0201,0x8023,{
endpoint=1,name="nam_edge_countdown_set",emit=emit.namEdgeCountdownSet(),data_type=data_types.Enum8,read_on_configure=true,sender=edge_setting_sender,
from_device=function(value,device,context)return remember_mode(device,"countdown_set",scalar(value)*5,context)end,
to_device=function(value)return value/5 end,
}),zcl.cluster_attribute(0x0201,0x8024,{
endpoint=1,name="nam_edge_countdown_left",emit=emit.namEdgeCountdownLeft(),data_type=data_types.Uint32,read_on_configure=true,read_only=true,
from_device=function(value)return value>120 and 0 or value end,
}),zcl.cluster_attribute(0x0201,0x8025,{
endpoint=1,name="nam_edge_max_heat_temp",emit=emit.namEdgeMaxHeatTemp(),data_type=data_types.Int16,read_on_configure=true,sender=edge_setting_sender,
from_device=function(value)return value/10 end,
to_device=function(value)return math.floor(value*10+0.5)end,
}),zcl.cluster_attribute(0x0201,0x8029,{
endpoint=1,name="nam_edge_screen_on_time",emit=emit.namEdgeScreenOnTime(),data_type=data_types.Enum8,read_on_configure=true,sender=edge_setting_sender,
from_device=function(value)return SCREEN_TIMES[scalar(value)]end,
to_device=function(value)for raw,name in pairs(SCREEN_TIMES)do if value==name then return raw end end end,
}),zcl.cluster_attribute(0x0201,0xFFFF,{
endpoint=1,name="nam_edge_sync_time",write_only=true,suppress_optimistic_state=true,
sender=function(device)return sync_edge_time(device,true)end,
}),zcl.cluster_attribute(0x0204,0x0000,{
endpoint=1,name="nam_edge_temperature_display_mode",emit=emit.namEdgeTemperatureDisplayMode(),data_type=data_types.Enum8,read_on_configure=true,
from_device=function(value,device)
local unit=({[0]="celsius",[1]="fahrenheit"})[scalar(value)]
if unit then device:set_field("nam_edge_display_unit",unit,{persist=true})end
return unit
end,
to_device=function(value)return({celsius=0,fahrenheit=1})[value]end,
sender=function(device,mapping,value)
local raw=({celsius=0,fahrenheit=1})[value]device:send(cluster_base.write_attribute(device,data_types.ClusterId(0x0204),data_types.AttributeId(0),data_types.Enum8(raw)):to_endpoint(1))device:set_field("nam_edge_display_unit",value,{persist=true})return true
end,
}),zcl.cluster_attribute(0x0204,0x0001,{
endpoint=1,name="nam_edge_keypad_lockout",emit=emit.namEdgeKeypadLockout(),data_type=data_types.Enum8,read_on_configure=true,
from_device=function(value)return({[0]="UNLOCK",[1]="LOCK"})[scalar(value)]end,
to_device=function(value)return({UNLOCK=0,LOCK=1})[value]end,
}),zcl.cluster_attribute(0x0000,0x4000,{
endpoint=1,name="nam_edge_firmware_version",emit=emit.namEdgeFirmwareVersion(),data_type=data_types.CharString,read_on_configure=true,read_only=true,}),zcl.cluster_attribute(0x0000,0x0006,{
endpoint=1,name="nam_edge_firmware_date",emit=emit.namEdgeFirmwareDate(),data_type=data_types.CharString,read_on_configure=true,read_only=true,}),zcl.cluster_attribute(0x0201,0x0003,{endpoint=1,name="nam_edge_abs_min_heat",emit=emit.namEdgeAbsMinHeat(),
data_type=data_types.Int16,read_only=true,read_on_configure=true,from_device=function(value)return value>=-27315 and value/100 or nil end}),
zcl.cluster_attribute(0x0201,0x0004,{endpoint=1,name="nam_edge_abs_max_heat",emit=emit.namEdgeAbsMaxHeat(),
data_type=data_types.Int16,read_only=true,read_on_configure=true,from_device=function(value)return value>=-27315 and value/100 or nil end}),
zcl.cluster_attribute(0x0201,0x8011,{endpoint=1,name="heating_setpoint_f",emit=emit.heating_setpoint(),data_type=data_types.Int16,read_only=true,read_on_configure=true,from_device=fahrenheit_temperature}),zcl.cluster_attribute(0x0201,0x8012,{endpoint=1,name="temperature_f",emit=emit.temperature(),data_type=data_types.Int16,read_only=true,read_on_configure=true,from_device=fahrenheit_temperature}),zcl.cluster_attribute(0xE002,nil,{endpoint=1,name="nam_edge_week_schedule",emit=emit.namEdgeWeekSchedule(),command_id=0x07,command_extractor=week_schedule,read_only=true,read_on_configure=false}),},
configure=function(driver,device)
for _,cluster in ipairs({0x0006,0x000A,0x0201,0x0204,0x0405,0x0702,0x0B04})do
zcl.bind_cluster(device,cluster,driver.environment_info.hub_zigbee_eui,1)
end
read_edge_all(device)
end,
}register_device_definition(namron_edge,{
device_helpers.create_fingerprint("Namron AS","4566702"),device_helpers.create_fingerprint("Namron AS","4512783"),})return{
id="zcl.thermostats.namron_edge",registrations=device_definitions,}

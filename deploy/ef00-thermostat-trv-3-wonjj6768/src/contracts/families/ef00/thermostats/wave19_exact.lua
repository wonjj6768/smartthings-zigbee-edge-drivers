local tuya=require "protocol.tuya"
local emit=require "capabilities.events.all"
local device_helpers=require "contracts.helpers.family"
local thermostat_metadata=require "contracts.helpers.ef00_thermostat_metadata"
local converter=tuya.converter
local device_definitions,register_device_definition=device_helpers.definition_registry()
local function custom(capability_id)
return assert(emit[capability_id],"missing Wave19 thermostat emitter: " .. capability_id)()
end
local function round(value)
local numeric=tonumber(value)
if numeric==nil then return nil end
return math.floor(numeric + 0.5)
end
local function clamp(value,minimum,maximum)
local numeric=tonumber(value)
if numeric==nil then return nil end
return math.max(minimum,math.min(maximum,numeric))
end
local function bool(value)
return value==true or value==1
end
local function on_off(value)
return bool(value)and "ON" or "OFF"
end
local function comma_bytes(value)
if type(value)~="string" then return nil end
local fields={}
for index=1,#value do fields[#fields + 1]=tostring(string.byte(value,index))end
return table.concat(fields,",")
end
local function named_overlay(datapoints,overrides)
local mappings=tuya.build_named_map(datapoints,"name")
for name,mapping in pairs(overrides)do mappings[name]=mapping end
return mappings
end
local function lifecycle(profile,datapoints)
datapoints.profile=profile
datapoints.package_group="wave19-thermostat"
datapoints.transport_classification="CUSTOM_PAYLOAD"
datapoints.z2m_converter_source="frozen legacy thermostat converter"
datapoints.wire_cluster="manuSpecificTuya"
datapoints.magic_packet=true
datapoints.query_on_configure=true
datapoints.named_datapoints=true
datapoints.time_start="2000"
datapoints.placeholder_custom_states=false
return datapoints
end
local IMMAX_DAY_BY_DP={
[101]="monday",
[102]="tuesday",
[103]="wednesday",
[104]="thursday",
[105]="friday",
[106]="saturday",
[107]="away_or_vacation",
}
local function u16be(value)
local numeric=math.floor(tonumber(value)or 0)
return string.char(math.floor(numeric / 0x100)% 0x100,numeric % 0x100)
end
local function immax_weekly_from(dp)
return function(value)
if type(value)~="string" or #value < 16 then return nil end
local transitions={}
for index=0,3 do
local offset=index * 4 + 1
local minutes_high,minutes_low,heat_high,heat_low=string.byte(value,offset,offset + 3)
transitions[#transitions + 1]={
time=minutes_high * 0x100 + minutes_low,
heating_setpoint=string.format("%.1f",(heat_high * 0x100 + heat_low)/ 10),
}
end
return{days={IMMAX_DAY_BY_DP[dp]},transitions=transitions}
end
end
local function immax_weekly_write(_,value)
if type(value)~="table" then return nil end
local frames={}
for _,schedule in pairs(value)do
if type(schedule)~="table" then return nil end
local day=tonumber(schedule.dayofweek)
local count=tonumber(schedule.numoftrans)
local mode=tonumber(schedule.mode)
local transitions=schedule.transitions
if day==nil or day < 1 or day > 7 or mode ~=1 or type(transitions)~="table"
or count ~=#transitions or #transitions < 1 or #transitions > 4 then
return nil
end
local padded={}
for index=1,#transitions do padded[index]=transitions[index]end
while #padded < 4 do padded[#padded + 1]=padded[#padded]end
local payload={}
for _,transition in ipairs(padded)do
local minutes=tonumber(transition.transitionTime)
local heat=tonumber(transition.heatSetpoint)
if minutes==nil or heat==nil then return nil end
payload[#payload + 1]=u16be(minutes)
payload[#payload + 1]=u16be(math.floor(heat * 10))
end
frames[#frames + 1]={
dp=100 + day,
datatype=tuya.DP_TYPE_RAW,
value=table.concat(payload),
transaction=1,
}
end
return frames
end
local function delayed_immax_mode(device,mode)
if mode=="off" then
return{dp=1,datatype=tuya.DP_TYPE_BOOL,value=false,transaction=1}
end
local raw_mode=({heat=0,auto=2})[mode]
if raw_mode==nil then return nil end
if tuya.send_datapoint(device,1,tuya.DP_TYPE_BOOL,true,tuya.SET_DATA,false,1)==nil then return nil end
device.thread:call_with_delay(0.5,function()
tuya.send_datapoint(device,4,tuya.DP_TYPE_ENUM,raw_mode,tuya.SET_DATA,false,1)
end,"Wave19 Immax system mode DP delay")
return nil
end
local function delayed_immax_away(device,value)
if value=="OFF" then
return{dp=4,datatype=tuya.DP_TYPE_ENUM,value=0,transaction=1}
end
if value ~="ON" then return nil end
if tuya.send_datapoint(device,1,tuya.DP_TYPE_BOOL,true,tuya.SET_DATA,false,1)==nil then return nil end
device.thread:call_with_delay(0.5,function()
tuya.send_datapoint(device,4,tuya.DP_TYPE_ENUM,1,tuya.SET_DATA,false,1)
end,"Wave19 Immax away mode DP delay")
return nil
end
local function bit_state(mask,active,clear)
return converter.from_only(function(value)
return bit32.band(tonumber(value)or 0,mask)~=0 and active or clear
end)
end
local immax=lifecycle("thermostats-wave19-immax-07703l",{
tuya.dp_binary(1,{
name="immax_trv_power_mode_report",read_only=true,
from_device=function(value)return bool(value)and nil or "off" end,
emit=emit.thermostat_mode(),
}),
tuya.dp_bitmap(13,{name="immax_trv_high_temperature",read_only=true,converter=bit_state(0x01,"ON","OFF")}),
tuya.dp_bitmap(13,{name="immax_trv_low_temperature",read_only=true,converter=bit_state(0x02,"ON","OFF")}),
tuya.dp_bitmap(13,{name="immax_trv_internal_sensor_error",read_only=true,converter=bit_state(0x04,"ON","OFF")}),
tuya.dp_bitmap(13,{name="immax_trv_external_sensor_error",read_only=true,converter=bit_state(0x08,"ON","OFF")}),
tuya.dp_bitmap(13,{
name="immaxTrv_battery_low",read_only=true,
converter=bit_state(0x10,"low","normal"),emit=custom("immaxTrvBatteryLow"),
}),
tuya.dp_bitmap(13,{name="immax_trv_device_offline",read_only=true,converter=bit_state(0x20,"ON","OFF")}),
tuya.dp_child_lock(7,{
name="immaxTrv_child_lock",
converter=converter.lookup_from_to({LOCK=true,UNLOCK=false}),
emit=custom("immaxTrvChildLock"),
}),
tuya.dp_current_heating_setpoint(2,{scale=10,emit=emit.heating_setpoint("C")}),
tuya.dp_local_temperature(3,{scale=10,read_only=true,emit=emit.temperature("C")}),
tuya.dp_enum(4,{
name="system_mode",read_only=true,
converter=converter.from_only(function(value)return({[0]="heat",[1]="heat",[2]="auto"})[tonumber(value)]end),
emit=emit.thermostat_mode(),
}),
tuya.dp_enum(4,{
name="immaxTrv_away_mode",read_only=true,
converter=converter.from_only(function(value)
return({[0]="OFF",[1]="ON",[2]="OFF"})[tonumber(value)]
end),
emit=custom("immaxTrvAwayMode"),
}),
tuya.dp_enum(4,{
name="immax_trv_preset",read_only=true,
converter=converter.from_only(function(value)
return({[0]="none",[1]="away",[2]="none"})[tonumber(value)]
end),
}),
tuya.dp_binary(14,{
name="running_state",read_only=true,
converter=converter.from_only(function(value)return bool(value)and "heating" or "idle" end),
emit=emit.thermostat_operating_state(),
}),
tuya.dp_raw(101,{name="immax_weekly_monday",read_only=true,converter=converter.from_only(immax_weekly_from(101))}),
tuya.dp_raw(102,{name="immax_weekly_tuesday",read_only=true,converter=converter.from_only(immax_weekly_from(102))}),
tuya.dp_raw(103,{name="immax_weekly_wednesday",read_only=true,converter=converter.from_only(immax_weekly_from(103))}),
tuya.dp_raw(104,{name="immax_weekly_thursday",read_only=true,converter=converter.from_only(immax_weekly_from(104))}),
tuya.dp_raw(105,{name="immax_weekly_friday",read_only=true,converter=converter.from_only(immax_weekly_from(105))}),
tuya.dp_raw(106,{name="immax_weekly_saturday",read_only=true,converter=converter.from_only(immax_weekly_from(106))}),
tuya.dp_raw(107,{name="immax_weekly_day_seven",read_only=true,converter=converter.from_only(immax_weekly_from(107))}),
})
immax.named_mapping={
named_mappings=named_overlay(immax,{
system_mode=delayed_immax_mode,
immaxTrv_away_mode=delayed_immax_away,
weekly_schedule=immax_weekly_write,
}),
}
thermostat_metadata.attach(immax,{"off","heat","auto"},5,35,0.5)
register_device_definition(immax,{
device_helpers.create_fingerprint("_TZE200_wlosfena","TS0601"),
})
local half_degree=converter.from_to(
function(value)local numeric=tonumber(value);return numeric and tonumber(string.format("%.1f",numeric / 2))or nil end,
function(value)
local numeric=clamp(value,0,30)
return numeric and round(numeric * 2)or nil
end
)
local tenth_degree=converter.from_to(
function(value)local numeric=tonumber(value);return numeric and tonumber(string.format("%.1f",numeric / 10))or nil end,
function(value)
local numeric=tonumber(value)
return numeric and round(numeric * 10)or nil
end
)
local woox_calibration=converter.from_to(
function(value)local numeric=tonumber(value);return numeric and tonumber(string.format("%.1f",numeric / 10))or nil end,
function(value)
local numeric=tonumber(value)
if numeric==nil then return nil end
if numeric < 0 then numeric=numeric + 4096 end
return round(numeric * 10)
end
)
local function woox_mode_write(device,value)
local raw_mode,setpoint=({auto=0,heat=1})[value],({auto=220,heat=170})[value]
if raw_mode==nil then return nil end
if tuya.send_datapoint(device,2,tuya.DP_TYPE_ENUM,raw_mode,tuya.SET_DATA,false,1)==nil then return nil end
return{dp=119,datatype=tuya.DP_TYPE_VALUE,value=setpoint,transaction=1}
end
local function woox_away_write(device,value)
if value=="ON" then
return{dp=2,datatype=tuya.DP_TYPE_ENUM,value=2,transaction=1}
end
if tuya.send_datapoint(device,2,tuya.DP_TYPE_ENUM,0,tuya.SET_DATA,false,1)==nil then return nil end
return{dp=119,datatype=tuya.DP_TYPE_VALUE,value=220,transaction=1}
end
local function woox_setpoint_write(_,value)
local numeric=tonumber(value)
if numeric==nil then return nil end
return{dp=119,datatype=tuya.DP_TYPE_VALUE,value=round(numeric * 10),transaction=1}
end
local function woox_schedule_no_wire()return nil end
local woox=lifecycle("thermostats-wave19-woox-r7067",{
tuya.dp_enum(2,{
name="system_mode",read_only=true,
converter=converter.from_only(function(value)
return({[0]="auto",[1]="heat",[2]="auto"})[tonumber(value)]or "off"
end),
emit=emit.thermostat_mode(),
}),
tuya.dp_enum(2,{
name="wooxTrv_away_mode",read_only=true,
converter=converter.from_only(function(value)return tonumber(value)==2 and "ON" or "OFF" end),
emit=custom("wooxTrvAwayMode"),
}),
tuya.dp_numeric(16,{name="woox_manual_setpoint_report",read_only=true,converter=half_degree,emit=emit.heating_setpoint("C")}),
tuya.dp_numeric(105,{name="woox_auto_setpoint_report",read_only=true,converter=half_degree,emit=emit.heating_setpoint("C")}),
tuya.dp_numeric(24,{name="local_temperature",read_only=true,converter=tenth_degree,emit=emit.temperature("C")}),
tuya.dp_numeric(104,{name="wooxTrv_temperature_calibration",converter=woox_calibration,emit=custom("wooxTrvTemperatureCalibration")}),
tuya.dp_raw(107,{
name="wooxTrv_window_detection",read_only=true,
converter=converter.from_only(function(value)
if type(value)~="string" or #value < 1 then return nil end
return string.byte(value,1)~=0 and "OPEN" or "CLOSED"
end),
emit=custom("wooxTrvWindowDetection"),
}),
tuya.dp_numeric(116,{name="wooxTrv_window_temperature",converter=half_degree,emit=custom("wooxTrvWindowTemperature")}),
tuya.dp_numeric(117,{name="wooxTrv_window_time",emit=custom("wooxTrvWindowTime")}),
tuya.dp_binary(30,{
name="wooxTrv_child_lock",
converter=converter.lookup_from_to({LOCK=true,UNLOCK=false}),
emit=custom("wooxTrvChildLock"),
}),
tuya.dp_numeric(34,{name="woox_hidden_battery",read_only=true}),
tuya.dp_numeric(34,{
name="woox_hidden_battery_low",read_only=true,
from_device=function(value)return(tonumber(value)or 0)< 30 and 1 or 0 end,
}),
tuya.dp_numeric(118,{name="wooxTrv_boost_time",read_only=true,emit=custom("wooxTrvBoostTime")}),
tuya.dp_numeric(102,{name="wooxTrv_eco_temperature",converter=half_degree,emit=custom("wooxTrvEcoTemperature")}),
tuya.dp_numeric(101,{name="wooxTrv_comfort_temperature",converter=half_degree,emit=custom("wooxTrvComfortTemperature")}),
tuya.dp_binary(106,{
name="wooxTrv_boost_heating",
converter=converter.lookup_from_to({ON=true,OFF=false}),
emit=custom("wooxTrvBoostHeating"),
}),
tuya.dp_numeric(45,{name="wooxTrv_error_status",read_only=true,emit=custom("wooxTrvErrorStatus")}),
tuya.dp_raw(103,{name="wooxTrv_holidays_schedule",read_only=true,converter=converter.from_only(comma_bytes),emit=custom("wooxTrvHolidaysSchedule")}),
tuya.dp_raw(109,{name="wooxTrv_monday_schedule",read_only=true,converter=converter.from_only(comma_bytes),emit=custom("wooxTrvMondaySchedule")}),
tuya.dp_raw(110,{name="wooxTrv_tuesday_schedule",read_only=true,converter=converter.from_only(comma_bytes),emit=custom("wooxTrvTuesdaySchedule")}),
tuya.dp_raw(111,{name="wooxTrv_wednesday_schedule",read_only=true,converter=converter.from_only(comma_bytes),emit=custom("wooxTrvWednesdaySchedule")}),
tuya.dp_raw(112,{name="wooxTrv_thursday_schedule",read_only=true,converter=converter.from_only(comma_bytes),emit=custom("wooxTrvThursdaySchedule")}),
tuya.dp_raw(113,{name="wooxTrv_friday_schedule",read_only=true,converter=converter.from_only(comma_bytes),emit=custom("wooxTrvFridaySchedule")}),
tuya.dp_raw(114,{name="wooxTrv_saturday_schedule",read_only=true,converter=converter.from_only(comma_bytes),emit=custom("wooxTrvSaturdaySchedule")}),
tuya.dp_raw(115,{name="wooxTrv_sunday_schedule",read_only=true,converter=converter.from_only(comma_bytes),emit=custom("wooxTrvSundaySchedule")}),
})
woox.bind_basic_on_configure=true
woox.named_mapping={
named_mappings=named_overlay(woox,{
current_heating_setpoint=woox_setpoint_write,
system_mode=woox_mode_write,
wooxTrv_away_mode=woox_away_write,
wooxTrv_holidays_schedule=woox_schedule_no_wire,
wooxTrv_monday_schedule=woox_schedule_no_wire,
wooxTrv_tuesday_schedule=woox_schedule_no_wire,
wooxTrv_wednesday_schedule=woox_schedule_no_wire,
wooxTrv_thursday_schedule=woox_schedule_no_wire,
wooxTrv_friday_schedule=woox_schedule_no_wire,
wooxTrv_saturday_schedule=woox_schedule_no_wire,
wooxTrv_sunday_schedule=woox_schedule_no_wire,
}),
}
thermostat_metadata.attach(woox,{"auto","heat"},0,30,0.5)
register_device_definition(woox,{
device_helpers.create_fingerprint("_TZE200_wnvhlcgl","TS0601"),
})
return{
id="ef00.thermostats.wave19.exact",
registrations=device_definitions,
}

local tuya=require "protocol.tuya"
local emit=require "capabilities.events.all"
local device_helpers=require "contracts.helpers.family"
local device_management=require "st.zigbee.device_management"
local zcl_clusters=require "st.zigbee.zcl.clusters"
local converter=tuya.converter
local device_definitions,register_device_definition=device_helpers.definition_registry()
local function custom(capability_id)
return assert(emit[capability_id],"missing Wave19 valve emitter: " .. capability_id)()
end
local function add(definition,mapping)
definition.datapoints[#definition.datapoints + 1]=mapping
end
local function numeric(dp,name,capability_id,read_only)
return tuya.dp_numeric(dp,{
name=name,
emit=custom(capability_id),
read_only=read_only==true,
transaction=1,
})
end
local function enum(dp,name,capability_id,values,read_only,write_only)
return tuya.dp_enum(dp,{
name=name,
emit=custom(capability_id),
converter=converter.lookup_from_to(values),
read_only=read_only==true,
write_only=write_only==true,
transaction=1,
})
end
local function binary(dp,name,capability_id,read_only)
return tuya.dp_binary(dp,{
name=name,
emit=custom(capability_id),
converter=converter.lookup_from_to({ON=true,OFF=false}),
read_only=read_only==true,
transaction=1,
})
end
local frankever={
profile="valves-wave19-frankever-fk-bv05",
package_group="wave19-valve",
transport_classification="EF00_DP",
z2m_converter_source="meta.tuyaDatapoints",
wire_cluster="manuSpecificTuya",
magic_packet=true,
query_on_configure=false,
time_start="off",
datapoints={},
}
add(frankever,tuya.dp_on_off(1,{name="switch",emit=emit.switch(),transaction=1}))
add(frankever,numeric(2,"frank_bv_five_threshold","frankBvFiveThreshold",false))
add(frankever,numeric(3,"frank_bv_five_position","frankBvFivePosition",true))
add(frankever,numeric(5,"frank_bv_five_water_last","frankBvFiveWaterLast",true))
add(frankever,numeric(6,"frank_bv_five_water_total","frankBvFiveWaterTotal",true))
add(frankever,enum(10,"frank_bv_five_weather_delay","frankBvFiveWeatherDelay",{
cancel=0,["24h"]=1,["48h"]=2,["72h"]=3,
},false))
add(frankever,numeric(11,"frank_bv_five_countdown","frankBvFiveCountdown",false))
add(frankever,tuya.dp_numeric(22,{
name="water_temperature",
emit=emit.temperature("C"),
read_only=true,
transaction=1,
}))
add(frankever,enum(101,"frank_bv_five_leak_state","frankBvFiveLeakState",{
water_leakage_yes=0,water_leakage_no=1,
},true))
add(frankever,binary(102,"frank_bv_five_single_limit_enabled","frankBvFiveSingleLimitEnabled",false))
add(frankever,numeric(103,"frank_bv_five_single_limit_volume","frankBvFiveSingleLimitVolume",false))
add(frankever,binary(104,"frank_bv_five_daily_limit_enabled","frankBvFiveDailyLimitEnabled",false))
add(frankever,numeric(105,"frank_bv_five_daily_limit_volume","frankBvFiveDailyLimitVolume",false))
add(frankever,binary(106,"frank_bv_five_volume_alarm_enabled","frankBvFiveVolumeAlarmEnabled",false))
add(frankever,numeric(107,"frank_bv_five_volume_alarm","frankBvFiveVolumeAlarm",false))
add(frankever,binary(108,"frank_bv_five_temp_alarm_enabled","frankBvFiveTempAlarmEnabled",false))
add(frankever,numeric(109,"frank_bv_five_temp_alarm_max","frankBvFiveTempAlarmMax",false))
add(frankever,enum(110,"frank_bv_five_power_off_state","frankBvFivePowerOffState",{
off=0,on=1,maintain=2,
},false))
add(frankever,binary(112,"frank_bv_five_creep_enabled","frankBvFiveCreepEnabled",false))
add(frankever,numeric(113,"frank_bv_five_temp_alarm_min","frankBvFiveTempAlarmMin",false))
register_device_definition(frankever,{
device_helpers.create_fingerprint("_TZE200_nbqnmkee","TS0601"),
})
local function field_table(device)
if type(device)~="table" then return nil end
device.__wave19_lidl_fields=device.__wave19_lidl_fields or{}
return device.__wave19_lidl_fields
end
local function set_field(device,key,value,persist)
if type(device)=="table" and type(device.set_field)=="function" then
device:set_field(key,value,{persist=persist==true})
else
local fields=field_table(device)
if fields ~=nil then fields[key]=value end
end
end
local function get_field(device,key)
if type(device)=="table" and type(device.get_field)=="function" then
local value=device:get_field(key)
if value ~=nil then return value end
end
local fields=field_table(device)
return fields ~=nil and fields[key]or nil
end
local function byte_at(value,index)
if type(value)=="string" then return string.byte(value,index)end
if type(value)=="table" then
local item=value[index]
if type(item)=="table" and item.value ~=nil then item=item.value end
return tonumber(item)
end
return nil
end
local function clamp(value,minimum,maximum)
value=tonumber(value)
if value==nil then return nil end
if value < minimum then return minimum end
if value > maximum then return maximum end
return value
end
local LIDL_STATE_FIELD="__wave19_lidl_state"
local LIDL_TIME_LEFT_FIELD="__wave19_lidl_time_left"
local LIDL_SCHEDULE_MODE_FIELD="__wave19_lidl_schedule_mode"
local LIDL_SCHEDULE_PERIODIC_FIELD="__wave19_lidl_schedule_periodic"
local LIDL_SCHEDULE_TIMER_FIELD="__wave19_lidl_schedule_timer"
local LIDL_RESET_SCHEDULED_FIELD="__wave19_lidl_initial_frost_reset_scheduled"
local function weekday_field(day)
return "__wave19_lidl_weekday_" .. day
end
local function slot_field(slot,field)
return string.format("__wave19_lidl_slot_%d_%s",slot,field)
end
local day_names={"monday","tuesday","wednesday","thursday","friday","saturday","sunday"}
local day_capability_suffix={"Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"}
local slot_words={"One","Two","Three","Four","Five","Six"}
local function cancel_lidl_timer(device)
local timer=get_field(device,LIDL_SCHEDULE_TIMER_FIELD)
if timer ~=nil and type(timer.cancel)=="function" then timer:cancel()end
set_field(device,LIDL_SCHEDULE_TIMER_FIELD,nil,false)
end
local function emit_time_left_direct(device,value)
if type(device)~="table" or type(device.emit_event)~="function" then return end
local event=custom("lidlPsbzsTimeLeft")(device,value)
if event ~=nil then device:emit_event(event)end
end
local function start_lidl_minute_timer(device,minutes)
cancel_lidl_timer(device)
if type(device)~="table" or type(device.thread)~="table"
or type(device.thread.call_with_delay)~="function" or minutes <=1 then return end
local remaining=minutes
local function tick()
remaining=remaining - 1
if remaining <=0 then
set_field(device,LIDL_TIME_LEFT_FIELD,0,false)
set_field(device,LIDL_SCHEDULE_TIMER_FIELD,nil,false)
return
end
set_field(device,LIDL_TIME_LEFT_FIELD,remaining,false)
emit_time_left_direct(device,remaining)
local timer=device.thread:call_with_delay(60,tick,"Lidl watering schedule time left")
set_field(device,LIDL_SCHEDULE_TIMER_FIELD,timer,false)
end
local timer=device.thread:call_with_delay(60,tick,"Lidl watering schedule time left")
set_field(device,LIDL_SCHEDULE_TIMER_FIELD,timer,false)
end
local function scheduled_slot_now(device)
if get_field(device,LIDL_SCHEDULE_MODE_FIELD)=="OFF" then return nil end
local now=os.date("*t")
for slot=1,6 do
if get_field(device,slot_field(slot,"enabled"))=="ON"
and get_field(device,slot_field(slot,"start_hour"))==now.hour
and get_field(device,slot_field(slot,"start_minute"))==now.min then
return slot
end
end
return nil
end
local switch_event=emit.switch()
local time_left_event=custom("lidlPsbzsTimeLeft")
local function emit_watering_state(device,value,dp_info,context)
local enabled=value==true or tonumber(value)==1
local previous=get_field(device,LIDL_STATE_FIELD)
set_field(device,LIDL_STATE_FIELD,enabled,false)
local events={}
local state_event=switch_event(device,enabled,dp_info,context)
if state_event ~=nil then events[#events + 1]=state_event end
if not enabled then
cancel_lidl_timer(device)
set_field(device,LIDL_TIME_LEFT_FIELD,0,false)
local left=time_left_event(device,0,dp_info,context)
if left ~=nil then events[#events + 1]=left end
elseif previous ~=true and(get_field(device,LIDL_TIME_LEFT_FIELD)or 0)==0 then
local slot=scheduled_slot_now(device)
if slot ~=nil then
local minutes=get_field(device,slot_field(slot,"timer"))or 1
set_field(device,LIDL_TIME_LEFT_FIELD,minutes,false)
local left=time_left_event(device,minutes,dp_info,context)
if left ~=nil then events[#events + 1]=left end
start_lidl_minute_timer(device,minutes)
end
end
return events[1]~=nil and events or nil
end
local lidl={
profile="valves-wave19-lidl-psbzs-a-one",
package_group="wave19-valve",
transport_classification="CUSTOM_PAYLOAD",
z2m_converter_source="meta.tuyaDatapoints+valueConverterLocal.watering*",
wire_cluster="manuSpecificTuya + genOnOff configure-only",
magic_packet=true,
query_on_configure=false,
force_time_updates=true,
time_start="1970",
datapoints={},
}
add(lidl,tuya.dp_binary(1,{
name="switch",
emit=emit_watering_state,
transaction=1,
}))
add(lidl,numeric(5,"lidl_psbzs_timer","lidlPsbzsTimer",false))
add(lidl,tuya.dp_numeric(6,{
name="lidl_psbzs_time_left",
read_only=true,
transaction=1,
converter=converter.from_only(function(value,device)
local numeric_value=tonumber(value)
if numeric_value ~=nil then set_field(device,LIDL_TIME_LEFT_FIELD,numeric_value,false)end
return numeric_value
end),
emit=time_left_event,
}))
add(lidl,tuya.dp_numeric(11,{
name="battery",read_only=true,transaction=1,emit=emit.battery(),
}))
add(lidl,binary(108,"lidl_psbzs_frost_lock","lidlPsbzsFrostLock",true))
add(lidl,enum(109,"lidl_psbzs_reset_frost_lock","lidlPsbzsResetFrostLock",{
RESET=0,
},false,true))
add(lidl,tuya.dp_binary(108,{
name="lidl_psbzs_frost_reset_internal",
write_only=true,
converter=converter.lookup_from_to({OFF=false}),
transaction=1,
}))
local function decode_schedule(value,device)
local mode,schedule_value=byte_at(value,1),byte_at(value,2)
if mode==nil or schedule_value==nil then return nil end
local is_weekday=mode==0
local schedule_mode=schedule_value==0 and "OFF" or(is_weekday and "WEEKDAY" or "PERIODIC")
set_field(device,LIDL_SCHEDULE_MODE_FIELD,schedule_mode,false)
set_field(device,LIDL_SCHEDULE_PERIODIC_FIELD,is_weekday and 0 or schedule_value,false)
for index,day in ipairs(day_names)do
local enabled=is_weekday and bit32.band(schedule_value,2 ^(index - 1))~=0
set_field(device,weekday_field(day),enabled and "ON" or "OFF",false)
end
return{mode=schedule_mode,periodic=is_weekday and 0 or schedule_value}
end
add(lidl,tuya.dp_raw(107,{
name="lidl_psbzs_schedule_mode",
read_only=true,
converter=converter.from_only(function(value,device)
local decoded=decode_schedule(value,device)
return decoded ~=nil and decoded.mode or nil
end),
emit=custom("lidlPsbzsScheduleMode"),
}))
add(lidl,tuya.dp_raw(107,{
name="lidl_psbzs_schedule_periodic",
converter=converter.from_only(function(value,device)
local decoded=decode_schedule(value,device)
return decoded ~=nil and decoded.periodic or nil
end),
emit=custom("lidlPsbzsSchedulePeriodic"),
}))
for index,day in ipairs(day_names)do
local current_day=day
local capability_id="lidlPsbzs" .. day_capability_suffix[index]
add(lidl,tuya.dp_raw(107,{
name="lidl_psbzs_" .. current_day,
converter=converter.from_only(function(value,device)
if decode_schedule(value,device)==nil then return nil end
return get_field(device,weekday_field(current_day))
end),
emit=custom(capability_id),
}))
end
local slot_specs={
{field="enabled",capability="Enabled",kind="enum"},
{field="start_hour",capability="StartHour",kind="numeric"},
{field="start_minute",capability="StartMinute",kind="numeric"},
{field="timer",capability="Timer",kind="numeric"},
{field="pause",capability="Pause",kind="numeric"},
{field="iterations",capability="Iterations",kind="numeric"},
}
local function decode_slot(value,device,slot)
if byte_at(value,10)==nil then return nil end
local decoded={
enabled=byte_at(value,1)==1 and "ON" or "OFF",
start_hour=clamp(byte_at(value,2),0,23),
start_minute=clamp(byte_at(value,3),0,59),
timer=clamp((byte_at(value,4)or 0)* 60 +(byte_at(value,5)or 0),1,599),
pause=clamp((byte_at(value,7)or 0)* 60 +(byte_at(value,8)or 0),0,599),
iterations=clamp(byte_at(value,10),1,9),
}
for field,item in pairs(decoded)do set_field(device,slot_field(slot,field),item,false)end
return decoded
end
for slot=1,6 do
for _,spec in ipairs(slot_specs)do
local current_slot=slot
local current_field=spec.field
local mapping_name=string.format("lidl_psbzs_slot_%s_%s",string.lower(slot_words[current_slot]),current_field)
local capability_id="lidlPsbzsSlot" .. slot_words[current_slot].. spec.capability
add(lidl,tuya.dp_raw(100 + current_slot,{
name=mapping_name,
converter=converter.from_only(function(value,device)
local decoded=decode_slot(value,device,current_slot)
return decoded ~=nil and decoded[current_field]or nil
end),
emit=custom(capability_id),
}))
end
end
local function schedule_periodic_writer(device,value)
local numeric_value=tonumber(value)
if numeric_value==nil or numeric_value < 0 or numeric_value > 7 then return nil end
numeric_value=math.floor(numeric_value)
local mode=numeric_value > 0 and 1 or 0
set_field(device,LIDL_SCHEDULE_PERIODIC_FIELD,numeric_value,false)
set_field(device,LIDL_SCHEDULE_MODE_FIELD,numeric_value > 0 and "PERIODIC" or "OFF",false)
return{{dp=107,datatype=tuya.DP_TYPE_RAW,value=string.char(mode,numeric_value)}}
end
local function weekday_writer(day)
return function(device,value)
if value ~="ON" and value ~="OFF" then return nil end
set_field(device,weekday_field(day),value,false)
local mask=0
for index,name in ipairs(day_names)do
if get_field(device,weekday_field(name))=="ON" then mask=mask + 2 ^(index - 1)end
end
set_field(device,LIDL_SCHEDULE_MODE_FIELD,mask==0 and "OFF" or "WEEKDAY",false)
return{{dp=107,datatype=tuya.DP_TYPE_RAW,value=string.char(0,mask)}}
end
end
local function slot_writer(slot,changed_field)
return function(device,value)
local enabled=get_field(device,slot_field(slot,"enabled"))or "OFF"
local start_hour=get_field(device,slot_field(slot,"start_hour"))or 23
local start_minute=get_field(device,slot_field(slot,"start_minute"))or 59
local timer=get_field(device,slot_field(slot,"timer"))or 1
local pause=get_field(device,slot_field(slot,"pause"))or 0
local iterations=get_field(device,slot_field(slot,"iterations"))or 1
if changed_field=="enabled" then enabled=value
elseif changed_field=="start_hour" then start_hour=tonumber(value)
elseif changed_field=="start_minute" then start_minute=tonumber(value)
elseif changed_field=="timer" then timer=tonumber(value)
elseif changed_field=="pause" then pause=tonumber(value)
elseif changed_field=="iterations" then iterations=tonumber(value)
end
if(enabled ~="ON" and enabled ~="OFF")
or start_hour==nil or start_hour < 0 or start_hour > 23
or start_minute==nil or start_minute < 0 or start_minute > 59
or timer==nil or timer < 1 or timer > 599
or pause==nil or pause < 0 or pause > 599
or iterations==nil or iterations < 1 or iterations > 9
or(iterations > 1 and pause==0)then return nil end
start_hour,start_minute=math.floor(start_hour),math.floor(start_minute)
timer,pause,iterations=math.floor(timer),math.floor(pause),math.floor(iterations)
set_field(device,slot_field(slot,"enabled"),enabled,false)
set_field(device,slot_field(slot,"start_hour"),start_hour,false)
set_field(device,slot_field(slot,"start_minute"),start_minute,false)
set_field(device,slot_field(slot,"timer"),timer,false)
set_field(device,slot_field(slot,"pause"),pause,false)
set_field(device,slot_field(slot,"iterations"),iterations,false)
return{{
dp=100 + slot,
datatype=tuya.DP_TYPE_RAW,
value=string.char(
enabled=="ON" and 1 or 0,
start_hour,
start_minute,
math.floor(timer / 60),timer % 60,
0,
math.floor(pause / 60),pause % 60,
0,
iterations
),
}}
end
end
local lidl_named=tuya.build_named_map(lidl.datapoints,"name")
lidl_named.lidl_psbzs_schedule_periodic=schedule_periodic_writer
for _,day in ipairs(day_names)do lidl_named["lidl_psbzs_" .. day]=weekday_writer(day)end
for slot=1,6 do
for _,spec in ipairs(slot_specs)do
local name=string.format("lidl_psbzs_slot_%s_%s",string.lower(slot_words[slot]),spec.field)
lidl_named[name]=slot_writer(slot,spec.field)
end
end
lidl.named_mapping={named_mappings=lidl_named}
lidl.configure=function(driver,device)
device:send(device_management.build_bind_request(
device,
0x0006,
driver.environment_info.hub_zigbee_eui,
1
))
device:send(zcl_clusters.OnOff.attributes.OnOff:configure_reporting(device,0,0xFFFF):to_endpoint(1))
if not get_field(device,LIDL_RESET_SCHEDULED_FIELD)
and type(device.thread)=="table" and type(device.thread.call_with_delay)=="function" then
set_field(device,LIDL_RESET_SCHEDULED_FIELD,true,true)
device.thread:call_with_delay(10,function()
tuya.send_datapoint(device,109,tuya.DP_TYPE_BOOL,false,tuya.SET_DATA,false,1)
tuya.send_named_mapping(device,lidl_named,"lidl_psbzs_frost_reset_internal","OFF")
end,"Lidl frost state initialization")
end
end
register_device_definition(lidl,{
device_helpers.create_fingerprint("_TZE200_htnnfasr","TS0601"),
})
return{
id="ef00.valves.wave19",
registrations=device_definitions,
}

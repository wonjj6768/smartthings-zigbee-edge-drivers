local tuya=require"protocol.tuya"
local thermostat_common={}
function thermostat_common.valve_position_to_running_state(value)
local numeric=tonumber(value)if numeric==nil then
return nil
end
if numeric>0 then
return"heating"
end
return"idle"
end
function thermostat_common.variant1_mode_from_device(value)
local lookup={
[0]="auto",[1]="heat",[2]="off",[3]="heat",}return lookup[tonumber(value)]
end
function thermostat_common.variant1_mode_to_device(value)
local lookup={
auto=0,heat=1,off=2,}return lookup[value]
end
function thermostat_common.power_mode_from_device(power_field,mode_field,default_mode)
return function(value,device)
local is_on=value==true
device:set_field(power_field,is_on,{persist=false})if not is_on then
return"off"
end
return device:get_field(mode_field)or default_mode
end
end
function thermostat_common.enum_mode_from_device(power_field,mode_field,lookup)
return function(value,device)
local mode=lookup[tonumber(value)]if mode==nil then
return nil
end
device:set_field(mode_field,mode,{persist=false})if device:get_field(power_field)==false then
return"off"
end
return mode
end
end
function thermostat_common.power_mode_write(power_dp,mode_dp,lookup)
return function(_,value)
if value=="off"then
return{
{dp=power_dp,datatype=tuya.DP_TYPE_BOOL,value=false},}
end
local mode=lookup[value]if mode==nil then
return nil
end
return{
{dp=power_dp,datatype=tuya.DP_TYPE_BOOL,value=true},{dp=mode_dp,datatype=tuya.DP_TYPE_ENUM,value=mode},}
end
end
function thermostat_common.binary_power_schedule_mode_write(power_dp,schedule_dp)
return function(_,value)
if value~="off"and value~="heat"and value~="auto"then
return nil
end
return{
{dp=power_dp,datatype=tuya.DP_TYPE_BOOL,value=value~="off"},{dp=schedule_dp,datatype=tuya.DP_TYPE_BOOL,value=value=="auto"},}
end
end
function thermostat_common.true_mode_from_device(mode)
return function(value)
if value then
return mode
end
return nil
end
end
function thermostat_common.boolean_label_from_device(false_label,true_label)
return function(value)
if value then
return true_label
end
return false_label
end
end
function thermostat_common.x5h_local_temperature_from_device(value)
local numeric=tonumber(value)if numeric==nil then
return nil
end
if numeric>=0x8000 then
numeric=numeric-0x10000+1
end
return numeric/10
end
local function error_or_battery_low_value(value)
local numeric=tonumber(value)if numeric==nil or numeric%1~=0 or numeric<0 or numeric>0xFFFFFFFF then
return nil
end
return numeric
end
function thermostat_common.error_or_battery_low_emitter(error_emitter,battery_emitter)
return function(device,value,...)
local events={}if value.error~=nil and value.error<=0xFF then
local error_event=error_emitter(device,value.error,...)
if error_event~=nil then events[#events+1]=error_event end
end
local battery_event=battery_emitter(device,value.battery_low,...)
if battery_event~=nil then events[#events+1]=battery_event end
return events
end
end
function thermostat_common.error_or_battery_low_state(value)
local numeric=error_or_battery_low_value(value)if numeric==nil then
return nil
end
return numeric==1 and"low"or"normal"
end
function thermostat_common.daily_schedule(day,count)
return{
from=function(value)
if type(value)~="string"or #value~=1+count*4 then return nil end
local periods={}for index=0,count-1 do
local hour,minute,temperature=string.unpack(">BBI2",value,2+index*4)periods[#periods+1]=string.format("%02d:%02d/%.1f",hour,minute,temperature/10)
end
return table.concat(periods," ")
end,
to=function(value)
if type(value)~="string"then return nil end
local periods={string.char(day)}for period in value:gmatch("%S+")do
local hour,minute,temperature=period:match("^(%d+):(%d+)/(%d+%.?%d*)$")hour,minute,temperature=tonumber(hour),tonumber(minute),tonumber(temperature)
if not hour or not minute or not temperature then return nil end
temperature=math.floor(temperature*10)
if hour>24 or minute>60 or temperature<50 or temperature>350 then return nil end
periods[#periods+1]=string.pack(">BBI2",hour,minute,temperature)
end
if #periods~=count+1 then return nil end
return table.concat(periods)
end,
}
end
function thermostat_common.saswell_schedule(day)
return{
from=function(value)
if type(value)~="string"or #value~=17 then return nil end
local periods={}for index=0,3 do
local minutes,temperature=string.unpack(">I2I2",value,2+index*4)periods[#periods+1]=string.format("%02d:%02d/%.1f",minutes//60,minutes%60,temperature/10)
end
return table.concat(periods," ")
end,
to=function(value)
local periods={}for period in value:gmatch("%S+")do
local hour,minute,temperature=period:match("^(%d%d?):(%d%d)/(%d+%.?%d*)$")hour,minute,temperature=tonumber(hour),tonumber(minute),tonumber(temperature)
if not hour or not minute or not temperature or hour>23 or minute>59 or temperature>6553.5 then return nil end
periods[#periods+1]=string.pack(">I2I2",hour*60+minute,math.floor(temperature*10))
end
if #periods<1 or #periods>4 then return nil end
while #periods<4 do periods[#periods+1]=periods[#periods]end
return string.char(1<<day,4)..table.concat(periods)
end,
}
end
return thermostat_common

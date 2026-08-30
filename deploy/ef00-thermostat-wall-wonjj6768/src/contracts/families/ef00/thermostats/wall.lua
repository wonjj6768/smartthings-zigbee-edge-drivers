local tuya=require "protocol.tuya"
local emit=require "capabilities.events.all"
local device_helpers=require "contracts.helpers.family"
local ef00_helpers=require "contracts.helpers.ef00"
local thermostat_metadata=require "contracts.helpers.ef00_thermostat_metadata"
local thermostat_common=require "contracts.helpers.ef00_thermostats"
local converter=tuya.converter
local device_definitions,register_device_definition=device_helpers.definition_registry()
local bht002_on_off=converter.lookup_from_to({off=false,on=true})
local bht002_preset_hold=converter.lookup_from_to({hold=0,program=1})
local bht002_preset_schedule=converter.lookup_from_to({program=0,hold=1})
local bht002_sensor=converter.lookup_from_to({IN=0,AL=1,OU=2})
local function bht002_signed_temperature(value)
local numeric=tonumber(value)
if numeric==nil then return nil end
if numeric >=0x8000 then numeric=numeric - 0xFFFF end
return numeric
end
local function bht002_calibration_from(value)
local numeric=tonumber(value)
if numeric==nil then return nil end
return numeric > 4000 and(numeric - 4096)or numeric
end
local function bht002_calibration_to(value)
local numeric=tonumber(value)
if numeric==nil then return nil end
return numeric < 0 and(4096 + numeric)or numeric
end
local function bht002_program_from(value)
if type(value)~="string" or #value < 36 then return nil end
local items={}
for index=0,11 do
local offset=index * 3
local hour,minute,half=string.byte(value,offset + 1,offset + 3)
if hour==nil or minute==nil or half==nil then return nil end
local temperature=half / 2
local text=string.format("%02d:%02d/%.1f",hour,minute,temperature):gsub("%.0$","")
items[#items + 1]=text
end
return table.concat(items," ")
end
local function bht002_program_to(value)
if type(value)~="string" then return nil end
local payload={}
for hour,minute,temperature in value:gmatch("(%d+):(%d+)/([%d%.]+)")do
hour,minute,temperature=tonumber(hour),tonumber(minute),tonumber(temperature)
if hour==nil or hour < 0 or hour > 23 or minute==nil or minute < 0 or minute > 59 or
temperature==nil or temperature < 5 or temperature > 35 then
return nil
end
local half=math.floor((temperature * 2)+ 0.5)
if math.abs((half / 2)- temperature)> 0.001 then return nil end
payload[#payload + 1]=hour
payload[#payload + 1]=minute
payload[#payload + 1]=half
end
if #payload ~=36 then return nil end
return string.char(table.unpack(payload))
end
local function bht002_preset_write(_,value)
if value ~="hold" and value ~="program" then return nil end
return{
{dp=2,datatype=tuya.DP_TYPE_ENUM,value=value=="hold" and 0 or 1},
{dp=3,datatype=tuya.DP_TYPE_ENUM,value=value=="program" and 0 or 1},
}
end
local function bht002_definition(profile,setpoint_scale,local_temperature_scale,option_scale,calibration_emit,setpoint_step)
local local_converter
if local_temperature_scale==10 and option_scale==10 then
local_converter=converter.divide_by_pair(10)
elseif local_temperature_scale==10 then
local_converter=converter.from_to(function(value)
local signed=bht002_signed_temperature(value)
return signed==nil and nil or signed / 10
end,function(value)return tonumber(value)and tonumber(value)* 10 or nil end)
else
local_converter=converter.from_to(bht002_signed_temperature,function(value)return tonumber(value)end)
end
local definition={
profile=profile,
time_start="1970",
named_mapping={named_mappings={bht002_preset=bht002_preset_write}},
tuya.dp_binary(1,{name="system_mode",converter=converter.lookup_from_to({off=false,heat=true}),emit=emit.thermostat_mode()}),
tuya.dp_enum(2,{name="bht002_preset",read_only=true,converter=bht002_preset_hold,emit=emit.bhtPreset()}),
tuya.dp_enum(3,{name="bht002_preset",read_only=true,converter=bht002_preset_schedule,emit=emit.bhtPreset()}),
tuya.dp_current_heating_setpoint(16,{scale=setpoint_scale,emit=emit.heating_setpoint("C")}),
tuya.dp_numeric(18,{name="bht002_maximum_temperature_limit",emit=emit.bhtMaximumTemperatureLimit(),converter=converter.divide_by_pair(option_scale)}),
tuya.dp_numeric(20,{name="bht002_deadzone_temperature",emit=emit.bhtDeadzoneTemperature(),converter=converter.divide_by_pair(option_scale)}),
tuya.dp_numeric(24,{name="local_temperature",read_only=true,emit=emit.temperature("C"),converter=local_converter}),
tuya.dp_numeric(26,{name="bht002_minimum_temperature_limit",emit=emit.bhtMinimumTemperatureLimit(),converter=converter.divide_by_pair(option_scale)}),
tuya.dp_numeric(27,{name="bht002_temperature_calibration",emit=calibration_emit,converter=converter.from_to(bht002_calibration_from,bht002_calibration_to)}),
tuya.dp_binary(36,{name="running_state",read_only=true,emit=emit.thermostat_operating_state(),converter=converter.from_only(function(value)return value==true and "idle" or "heating" end)}),
tuya.dp_binary(40,{name="bht002_child_lock",emit=emit.bhtChildLock(),converter=bht002_on_off}),
tuya.dp_enum(43,{name="bht002_temperature_sensor",emit=emit.bhtTemperatureSensor(),converter=bht002_sensor}),
tuya.dp_raw(101,{name="bht002_program",emit=emit.bhtProgram(),converter=converter.from_to(bht002_program_from,bht002_program_to)}),
}
return thermostat_metadata.attach(definition,{"off","heat"},5,90,setpoint_step)
end
local bht002_fine=bht002_definition("thermostats-bht002-fine",1,10,1,emit.bhtTemperatureCalibrationFine(),1)
register_device_definition(bht002_fine,device_helpers.create_fingerprints("TS0601",{
"_TZE200_u9bfwha0","_TZE204_u9bfwha0",
}))
local bht002_fine_unscaled_local=bht002_definition("thermostats-bht002-fine",1,1,1,emit.bhtTemperatureCalibrationFine(),1)
register_device_definition(bht002_fine_unscaled_local,device_helpers.create_fingerprints("TS0601",{
"_TZE200_ztvwu4nk","_TZE200_ye5jkfsb","_TZE284_ye5jkfsb",
}))
local bht002_fine_scaled_options=bht002_definition("thermostats-bht002-fine",10,10,10,emit.bhtTemperatureCalibrationFine(),1)
register_device_definition(bht002_fine_scaled_options,device_helpers.create_fingerprints("TS0601",{
"_TZE200_5toc8efa",
}))
local bht002_half=bht002_definition("thermostats-bht002-half",10,10,10,emit.bhtTemperatureCalibrationFine(),0.5)
register_device_definition(bht002_half,device_helpers.create_fingerprints("TS0601",{
"_TZE204_5toc8efa",
}))
local bht002_whole=bht002_definition("thermostats-bht002-whole",1,10,1,emit.bhtTemperatureCalibrationWhole(),1)
register_device_definition(bht002_whole,device_helpers.create_fingerprints("TS0601",{
"_TZE204_aoclfnxz",
}))
local bht002_no_cool=bht002_definition("thermostats-bht002-fine",1,10,1,emit.bhtTemperatureCalibrationFine(),1)
register_device_definition(bht002_no_cool,device_helpers.create_fingerprints("TS0601",{
"_TZE200_aoclfnxz",
}))
local thermostat_zwt198={
profile="thermostats-thermostat-zwt198",
tuya.dp_binary(1,{
name="system_mode",
converter=converter.lookup_from_to({
heat=true,
off=false,
}),
emit=emit.thermostat_mode(),
}),
tuya.dp_current_heating_setpoint(2,{scale=10}),
tuya.dp_local_temperature(3,{scale=10}),
tuya.dp_enum(4,{
name="preset",
emit=emit.zwt198Preset(),
converter=converter.lookup_from_to({auto=0,manual=1,temporaryManual=2}),
}),
tuya.dp_child_lock(9,{emit=emit.zwt198ChildLock()}),
tuya.dp_numeric(11,{name="fault_alarm",read_only=true,emit=emit.zwt198FaultAlarm()}),
tuya.dp_max_temperature_limit(15,{scale=10,emit=emit.zwt198MaxTemperatureLimit()}),
tuya.dp_local_temperature_calibration(19,{scale=10,emit=emit.zwt198TempCalibration()}),
tuya.dp_running_state(101,{
converter=converter.lookup_from_to({
heating=1,
idle=0,
}),
emit=emit.thermostat_operating_state(),
}),
tuya.dp_frost_protection(102,{emit=emit.zwt198FrostProtection()}),
tuya.dp_binary(103,{
name="factory_reset",
emit=emit.zwt198FactoryReset(),
converter=converter.lookup_from_to({off=false,on=true}),
}),
tuya.dp_enum(104,{
name="working_day",
emit=emit.zwt198WorkingDay(),
converter=converter.lookup_from_to({disabled=0,fiveTwo=1,sixOne=2,seven=3}),
}),
tuya.dp_temperature_sensor_select_internal_external_both(106,{
name="sensor",
emit=emit.zwt198Sensor(),
}),
tuya.dp_deadzone_temperature(107,{scale=10,emit=emit.zwt198DeadzoneTemperature()}),
tuya.dp_enum(110,{
name="backlight_mode",
emit=emit.zwt198BacklightMode(),
converter=converter.lookup_from_to({off=0,low=1,medium=2,high=3}),
}),
}
register_device_definition(thermostat_zwt198,ef00_helpers.ts0601_fingerprints({
"_TZE204_xnbkhhdr",
"_TZE284_xnbkhhdr",
"_TZE204_oh8y8pv8",
"_TZE284_gops3slb",
"_TZE284_zjhoqbrd",
"_TZE204_zjhoqbrd",
}))
register_device_definition(thermostat_zwt198,{
device_helpers.create_fingerprint("AVATTO","WT-100-BH"),
})
local function with_replaced_dp(definition,dp,replacement)
local copied={}
for key,value in pairs(definition)do
copied[key]=value
end
for index,mapping in ipairs(definition)do
if mapping.dp==dp then
copied[index]=replacement
end
end
return copied
end
local thermostat_zwt198_swapped_preset=with_replaced_dp(thermostat_zwt198,4,tuya.dp_enum(4,{
name="preset",
emit=emit.zwt198Preset(),
converter=converter.lookup_from_to({manual=0,auto=1,temporaryManual=2}),
}))
register_device_definition(thermostat_zwt198_swapped_preset,ef00_helpers.ts0601_fingerprints({
"_TZE204_lzriup1j",
"_TZE204_gops3slb",
}))
local thermostat_zwt198_swapped_workday=with_replaced_dp(thermostat_zwt198,104,tuya.dp_enum(104,{
name="working_day",
emit=emit.zwt198WorkingDay(),
converter=converter.lookup_from_to({disabled=0,sixOne=1,fiveTwo=2,seven=3}),
}))
register_device_definition(thermostat_zwt198_swapped_workday,ef00_helpers.ts0601_fingerprints({
"_TZE200_viy9ihs7",
}))
local thermostat_zwt100={
profile="thermostats-thermostat-zwt100",
tuya.dp_on_off(1,{name="state",emit=emit.switch()}),
tuya.dp_current_heating_setpoint(2,{scale=10}),
tuya.dp_local_temperature(3,{scale=10}),
tuya.dp_enum(4,{
name="mode",
emit=emit.zwt100Mode(),
converter=converter.lookup_from_to({manual=0,program=1,temporary=2}),
}),
tuya.dp_child_lock(9,{emit=emit.zwt100ChildLock()}),
tuya.dp_numeric(11,{name="fault",read_only=true,emit=emit.zwt100Fault()}),
tuya.dp_max_temperature_limit(15,{
name="upper_temperature_limit",
scale=10,
emit=emit.zwt100UpperTempLimit(),
}),
tuya.dp_local_temperature_calibration(19,{scale=10,emit=emit.zwt100TempCalibration()}),
tuya.dp_running_state(101,{
converter=converter.lookup_from_to({idle=0,heating=1}),
emit=emit.thermostat_operating_state(),
}),
tuya.dp_frost_protection(102,{emit=emit.zwt100FrostProtection()}),
tuya.dp_binary(103,{
name="reset",
emit=emit.zwt100Reset(),
converter=converter.lookup_from_to({off=false,on=true}),
}),
tuya.dp_enum(104,{
name="work_days",
emit=emit.zwt100WorkDays(),
converter=converter.lookup_from_to({
programmingOff=0,
twoDayWeekend=1,
singleDayOff=2,
noRest=3,
}),
}),
tuya.dp_binary(105,{
name="sound",
emit=emit.zwt100Sound(),
converter=converter.lookup_from_to({off=false,on=true}),
}),
tuya.dp_enum(106,{
name="sensor_selection",
emit=emit.zwt100SensorSelection(),
converter=converter.lookup_from_to({["in"]=0,out=1,all=2}),
}),
tuya.dp_numeric(107,{
name="temperature_variation",
converter=converter.divide_by_pair(10),
emit=emit.zwt100TempVariation(),
}),
tuya.dp_numeric(108,{
name="sensor_temperature_limit",
emit=emit.zwt100SensorTempLimit(),
}),
tuya.dp_enum(110,{
name="backlight",
emit=emit.zwt100Backlight(),
converter=converter.lookup_from_to({off=0,micro=1,medium=2,high=3}),
}),
tuya.dp_binary(111,{
name="direction_mode",
emit=emit.zwt100DirectionMode(),
converter=converter.lookup_from_to({off=false,on=true}),
}),
}
register_device_definition(thermostat_zwt100,ef00_helpers.ts0601_fingerprints({
"_TZE204_aaeaifez",
"_TZE284_aaeaifez",
"_TZE28C1000000_aaeaifez",
}))
local thermostat_zwt07={
profile="thermostats-thermostat-zwt07",
tuya.dp_binary(1,{
name="system_mode",
converter=converter.lookup_from_to({
heat=true,
off=false,
}),
emit=emit.thermostat_mode(),
}),
tuya.dp_enum(2,{
name="preset",
emit=emit.thermostatPresetZwt07Program(),
converter=converter.lookup_from_to({
program=0,
manual=1,
}),
}),
tuya.dp_binary(10,{
name="frost_protection",
emit=emit.zwt07FrostProtection(),
converter=converter.lookup_from_to({off=false,on=true}),
}),
tuya.dp_current_heating_setpoint(16,{scale=10}),
tuya.dp_local_temperature(24,{scale=10}),
tuya.dp_running_state(36,{
converter=converter.lookup_from_to({
idle=0,
heating=1,
}),
emit=emit.thermostat_operating_state(),
}),
}
register_device_definition(thermostat_zwt07,ef00_helpers.ts0601_fingerprints({
"_TZE200_g9a3awaj",
}))
local HY08WE_POWER_FIELD="hy08we_power_state"
local HY08WE_MODE_FIELD="hy08we_system_mode_device"
local hy08we_state_from_device=thermostat_common.power_mode_from_device(
HY08WE_POWER_FIELD,
HY08WE_MODE_FIELD,
"heat"
)
local hy08we_mode_from_device=thermostat_common.enum_mode_from_device(
HY08WE_POWER_FIELD,
HY08WE_MODE_FIELD,
{[0]="heat",[1]="auto",[2]="heat"}
)
local hy08we_system_mode_write=thermostat_common.power_mode_write(
125,
128,
{heat=0,auto=1}
)
local hy08we_setpoint=tuya.dp_current_heating_setpoint(126,{
scale=10,
emit=emit.heating_setpoint("C"),
})
local thermostat_hy08we={
profile="thermostats-thermostat-hy08we",
named_mapping={
named_mappings={
system_mode=hy08we_system_mode_write,
current_heating_setpoint=hy08we_setpoint,
},
},
tuya.dp_binary(102,{
name="running_state",
converter=converter.lookup_from_to({
heating=true,
idle=false,
}),
emit=emit.thermostat_operating_state(),
}),
tuya.dp_temperature(103,{
name="external_temperature",
scale=10,
read_only=true,
emit=emit.hy08weExternalTemperature(),
}),
tuya.dp_numeric(104,{name="away_preset_days",emit=emit.hy08weAwayDays()}),
tuya.dp_numeric(105,{name="away_preset_temperature",emit=emit.hy08weAwayTemperature()}),
tuya.dp_binary(106,{
name="max_temperature_protection",
emit=emit.hy08weMaxTempProtection(),
converter=converter.lookup_from_to({off=false,on=true}),
}),
tuya.dp_binary(107,{
name="min_temperature_protection",
emit=emit.hy08weMinTempProtection(),
converter=converter.lookup_from_to({off=false,on=true}),
}),
tuya.dp_local_temperature_calibration(109,{scale=10,emit=emit.hy08weTempCalibration()}),
tuya.dp_numeric(110,{
name="hysteresis",
converter=converter.divide_by_pair(10),
emit=emit.hy08weHysteresis(),
}),
tuya.dp_numeric(111,{
name="hysteresis_for_protection",
emit=emit.hy08weProtectionHysteresis(),
}),
tuya.dp_numeric(112,{
name="max_temperature_for_protection",
emit=emit.hy08weProtectionMaxTemp(),
}),
tuya.dp_numeric(113,{
name="min_temperature_for_protection",
emit=emit.hy08weProtectionMinTemp(),
}),
tuya.dp_numeric(114,{name="max_temperature",emit=emit.hy08weMaxTemperature()}),
tuya.dp_numeric(115,{name="min_temperature",emit=emit.hy08weMinTemperature()}),
tuya.dp_enum(116,{
name="sensor_type",
emit=emit.hy08weSensorType(),
converter=converter.lookup_from_to({internal=0,external=1,both=2}),
}),
tuya.dp_enum(117,{
name="power_on_behavior",
emit=emit.hy08wePowerOnBehavior(),
converter=converter.lookup_from_to({restore=0,off=1,on=2}),
}),
tuya.dp_enum(118,{
name="week_format",
emit=emit.hy08weWeekFormat(),
converter=converter.lookup_from_to({fiveTwo=0,sixOne=1,seven=2}),
}),
tuya.dp_child_lock(129,{emit=emit.hy08weChildLock()}),
tuya.dp_numeric(130,{
name="alarm",
read_only=true,
emit=emit.hy08weAlarm(),
converter=converter.from_only(function(value)
return(tonumber(value)or 0)> 0 and "detected" or "clear"
end),
}),
tuya.dp_binary(125,{
name="state",
from_device=hy08we_state_from_device,
emit=emit.thermostat_mode(),
read_only=true,
}),
hy08we_setpoint,
tuya.dp_local_temperature(127,{scale=10}),
tuya.dp_system_mode(128,{
from_device=hy08we_mode_from_device,
emit=emit.thermostat_mode(),
read_only=true,
}),
}
register_device_definition(thermostat_hy08we,ef00_helpers.ts0601_fingerprints({
"_TZE200_znzs7yaw",
}))
local thermostat_tervix={
profile="thermostats-thermostat-tervix",
tuya.dp_system_mode(1,{
converter=converter.lookup_from_to({
off=0,
heat=1,
}),
}),
tuya.dp_enum(2,{
name="preset",
emit=emit.thermostatPresetTervixProgram(),
converter=converter.lookup_from_to({
manual=0,
program=1,
}),
}),
tuya.dp_running_state(3,{
converter=converter.lookup_from_to({
idle=0,
heating=1,
}),
emit=emit.thermostat_operating_state(),
}),
tuya.dp_enum(3,{
name="working_status",
read_only=true,
emit=emit.tervixWorkingStatus(),
converter=converter.from_only(converter.lookup_value({
[0]="keeping_warm",
[1]="working",
})),
}),
tuya.dp_binary(8,{
name="window_check",
converter=converter.lookup_from_to({on=true,off=false}),
emit=emit.tervixWindowCheck(),
}),
tuya.dp_frost_protection(10,{emit=emit.tervixFrostProtection()}),
tuya.dp_current_heating_setpoint(16,{scale=10}),
tuya.dp_max_temperature_limit(19,{
name="upper_temp",
scale=10,
emit=emit.tervixUpperTemp(),
}),
tuya.dp_local_temperature(24,{scale=10}),
tuya.dp_binary(25,{
name="window_state",
read_only=true,
emit=emit.tervixWindowState(),
converter=converter.from_only(function(value)
return value and "open" or "close"
end),
}),
tuya.dp_local_temperature_calibration(27,{
scale=1,
name="temperature_correction",
emit=emit.tervixTempCorrection(),
}),
tuya.dp_humidity(34,{emit=emit.humidity()}),
tuya.dp_binary(39,{
name="factory_reset",
emit=emit.tervixFactoryReset(),
converter=converter.lookup_from_to({off=false,on=true}),
}),
tuya.dp_child_lock(40,{emit=emit.tervixChildLock()}),
tuya.dp_enum(43,{
name="sensor_choose",
converter=converter.lookup_from_to({
["in"]=0,
out=1,
}),
emit=emit.tervixSensorChoose(),
}),
tuya.dp_raw(48,{name="week_schedule"}),-- profile 미포함
tuya.dp_enum(58,{
name="run_mode",
emit=emit.tervixRunMode(),
converter=converter.lookup_from_to({heat_mode=1,cool_mode=2}),
}),
tuya.dp_enum(61,{
name="week_program_periods",
read_only=true,
emit=emit.tervixWeekProgramPeriods(),
converter=converter.from_only(function()
return "periods_4"
end),
}),
tuya.dp_numeric(101,{
name="switch_sensitivity",
scale=10,
emit=emit.tervixSwitchSensitivity(),
}),
tuya.dp_temperature(102,{
name="floor_temp_protection",
scale=10,
emit=emit.tervixFloorTempProtection(),
}),
tuya.dp_temperature(103,{
name="floor_low_protection",
scale=10,
emit=emit.tervixFloorLowProtection(),
}),
tuya.dp_numeric(104,{
name="window_open_detection_time",
emit=emit.tervixWindowDetectTime(),
}),
tuya.dp_numeric(105,{
name="window_open_detection_temp",
emit=emit.tervixWindowDetectTemp(),
}),
tuya.dp_numeric(106,{
name="window_open_delay_time",
emit=emit.tervixWindowDelayTime(),
}),
tuya.dp_binary(107,{
name="humidity_control",
emit=emit.tervixHumidityControl(),
converter=converter.lookup_from_to({off=false,on=true}),
}),
tuya.dp_numeric(108,{
name="upper_humidity_limit",
emit=emit.tervixUpperHumidityLimit(),
}),
}
register_device_definition(thermostat_tervix,ef00_helpers.ts0601_fingerprints({
"_TZE284_6kijc7nd",
"_TZE204_6kijc7nd",
}))
local thermostat_x5h={
profile="thermostats-thermostat-x5h",
tuya.dp_binary(1,{
name="system_mode",
converter=converter.lookup_from_to({
heat=true,
off=false,
}),
emit=emit.thermostat_mode(),
}),
tuya.dp_enum(2,{
name="preset",
emit=emit.thermostatPresetX5hProgram(),
converter=converter.lookup_from_to({
manual=0,
program=1,
}),
}),
tuya.dp_running_state(3,{
converter=converter.lookup_from_to({
heating=true,
idle=false,
}),
emit=emit.thermostat_operating_state(),
}),
tuya.dp_binary(7,{
name="sound",
emit=emit.x5hSound(),
converter=converter.lookup_from_to({off=false,on=true}),
}),
tuya.dp_frost_protection(10,{emit=emit.x5hFrostProtection()}),
tuya.dp_current_heating_setpoint(16,{scale=10}),
tuya.dp_max_temperature_limit(19,{
name="upper_temp",
scale=1,
emit=emit.x5hUpperTemp(),
}),
tuya.dp_numeric(24,{
name="local_temperature",
from_device=thermostat_common.x5h_local_temperature_from_device,
emit=emit.temperature("C"),
}),
tuya.dp_local_temperature_calibration(27,{scale=10,emit=emit.x5hTempCalibration()}),
tuya.dp_raw(30,{name="schedule"}),-- profile 미포함
tuya.dp_enum(31,{
name="working_day",
converter=converter.lookup_from_to({
mon_fri=0,
mon_sat=1,
all_days=2,
}),
emit=emit.workingDayX5h(),
}),
tuya.dp_binary(39,{
name="factory_reset",
emit=emit.x5hFactoryReset(),
converter=converter.lookup_from_to({off=false,on=true}),
}),
tuya.dp_child_lock(40,{emit=emit.x5hChildLock()}),
tuya.dp_enum(43,{
name="temperature_sensor_select",
converter=converter.lookup_from_to({
internal=0,
external=1,
both=2,
}),
emit=emit.temperatureSensorSelectX5hThree(),
}),
tuya.dp_numeric(45,{
name="fault_alarm",
read_only=true,
emit=emit.x5hFaultAlarm(),
}),
tuya.dp_deadzone_temperature(101,{scale=10,emit=emit.tempDeltaXhCToNinetyFive()}),
tuya.dp_temperature(102,{
name="heating_temp_limit",
scale=1,
emit=emit.x5hHeatingTempLimit(),
}),
tuya.dp_binary(103,{
name="output_reverse",
emit=emit.x5hOutputReverse(),
converter=converter.lookup_from_to({off=false,on=true}),
}),
tuya.dp_enum(104,{
name="brightness_state",
emit=emit.x5hBrightnessState(),
converter=converter.lookup_from_to({off=0,low=1,medium=2,high=3}),
}),
}
register_device_definition(thermostat_x5h,ef00_helpers.ts0601_fingerprints({
"_TZE200_2ekuz3dz",
}))
local thermostat_thermosphere={
profile="thermostats-thermostat-thermosphere",
tuya.dp_binary(1,{
name="system_mode",
converter=converter.lookup_from_to({
auto=true,
off=false,
}),
emit=emit.thermostat_mode(),
}),
tuya.dp_current_heating_setpoint(2,{scale=10}),
tuya.dp_enum(4,{
name="boost",
emit=emit.tsphereBoost(),
converter=converter.lookup_from_to({off=1,on=2}),
}),
tuya.dp_binary(18,{
name="open_window_active",
emit=emit.tsphereOpenWindowActive(),
converter=converter.lookup_from_to({off=false,on=true}),
}),
tuya.dp_binary(37,{
name="adaptive_start",
emit=emit.tsphereAdaptiveStart(),
converter=converter.lookup_from_to({off=false,on=true}),
}),
tuya.dp_local_temperature(38,{scale=10,emit=emit.temperature("C")}),
tuya.dp_max_temperature_limit(39,{scale=10,emit=emit.tsphereMaxTemperatureLimit()}),
tuya.dp_numeric(40,{
name="open_window_sensing_time",
emit=emit.tsphereOpenWindowSensingTime(),
}),
tuya.dp_numeric(41,{name="holiday_days",emit=emit.tsphereHolidayDays()}),
tuya.dp_holiday_temperature(42,{scale=10,emit=emit.tsphereHolidayTemperature()}),
tuya.dp_enum(43,{
name="sensor_mode",
emit=emit.tsphereSensorMode(),
converter=converter.lookup_from_to({room=0,floor=1,roomWithFloorLimit=2}),
}),
tuya.dp_numeric(45,{
name="open_window_drop_limit",
converter=converter.divide_by_pair(10),
emit=emit.tsphereOpenWindowDropLimit(),
}),
tuya.dp_numeric(47,{
name="open_window_off_time",
emit=emit.tsphereOpenWindowOffTime(),
}),
tuya.dp_numeric(50,{name="power_rating",emit=emit.tspherePowerRating()}),
tuya.dp_binary(52,{
name="frost_protection",
emit=emit.tsphereFrostProtection(),
converter=converter.lookup_from_to({off=false,on=true}),
}),
tuya.dp_min_temperature_limit(53,{scale=10,emit=emit.tsphereMinTemperatureLimit()}),
tuya.dp_numeric(54,{name="switch_delay",emit=emit.tsphereSwitchDelay()}),
tuya.dp_numeric(55,{name="display_brightness",emit=emit.tsphereDisplayBrightness()}),
}
register_device_definition(thermostat_thermosphere,ef00_helpers.ts0601_fingerprints({
"_TZE200_ha0vwoew",
}))
local thermostat_floor={
profile="thermostats-thermostat-floor",
tuya.dp_binary(1,{
name="system_mode",
converter=converter.lookup_from_to({
heat=true,
off=false,
}),
emit=emit.thermostat_mode(),
}),
tuya.dp_enum(2,{
name="preset",
emit=emit.thermostatPresetFloorManualAuto(),
converter=converter.lookup_from_to({
manual=0,
auto=1,
}),
}),
tuya.dp_current_heating_setpoint(16,{scale=10}),
tuya.dp_temperature(24,{
name="device_temperature",
scale=10,
read_only=true,
emit=emit.floorDeviceTemperature(),
}),
tuya.dp_local_temperature_calibration(27,{scale=1,emit=emit.floorTempCalibration()}),
tuya.dp_running_state(36,{
converter=converter.lookup_from_to({
heating=0,
idle=1,
}),
emit=emit.thermostat_operating_state(),
}),
tuya.dp_child_lock(40,{emit=emit.floorChildLock()}),
tuya.dp_local_temperature(102,{scale=10}),
tuya.dp_deadzone_temperature(103,{scale=1,emit=emit.floorDeadzoneTemperature()}),
tuya.dp_raw(101,{name="schedule_sunday"}),-- profile 미포함
tuya.dp_raw(105,{name="schedule_saturday"}),-- profile 미포함
tuya.dp_raw(106,{name="schedule_friday"}),-- profile 미포함
tuya.dp_raw(107,{name="schedule_thursday"}),-- profile 미포함
tuya.dp_raw(108,{name="schedule_wednesday"}),-- profile 미포함
tuya.dp_raw(109,{name="schedule_tuesday"}),-- profile 미포함
tuya.dp_raw(110,{name="schedule_monday"}),-- profile 미포함
}
register_device_definition(thermostat_floor,ef00_helpers.ts0601_fingerprints({
"_TZE200_edl8pz1k",
"_TZE204_edl8pz1k",
"_TZE204_6a4vxfnv",
"_TZE200_spyvfeti",
}))
local thermostat_bot_r9v={
profile="thermostats-thermostat-bot-r9v",
tuya.dp_binary(1,{
name="system_mode",
converter=converter.lookup_from_to({
heat=true,
off=false,
}),
emit=emit.thermostat_mode(),
}),
tuya.dp_enum(2,{
name="preset",
emit=emit.botr9vPreset(),
converter=converter.lookup_from_to({
auto=0,
manual=1,
eco=2,
}),
}),
tuya.dp_frost_protection(10,{name="frost",emit=emit.botr9vFrost()}),
tuya.dp_current_heating_setpoint(16,{scale=10}),
tuya.dp_min_temperature_limit(18,{scale=10,emit=emit.botr9vMinTemperatureLimit()}),
tuya.dp_max_temperature_limit(19,{scale=10,emit=emit.botr9vMaxTemperatureLimit()}),
tuya.dp_local_temperature(24,{scale=10}),
tuya.dp_running_state(36,{
converter=converter.lookup_from_to({
idle=false,
heating=true,
}),
emit=emit.thermostat_operating_state(),
}),
tuya.dp_binary(36,{
name="valve_state",
read_only=true,
emit=emit.botr9vValveState(),
converter=converter.from_only(function(value)
return value and "open" or "close"
end),
}),
tuya.dp_child_lock(40,{emit=emit.botr9vChildLock()}),
tuya.dp_raw(65,{name="schedule_monday"}),-- profile 미포함
tuya.dp_raw(66,{name="schedule_tuesday"}),-- profile 미포함
tuya.dp_raw(67,{name="schedule_wednesday"}),-- profile 미포함
tuya.dp_raw(68,{name="schedule_thursday"}),-- profile 미포함
tuya.dp_raw(69,{name="schedule_friday"}),-- profile 미포함
tuya.dp_raw(70,{name="schedule_saturday"}),-- profile 미포함
tuya.dp_raw(71,{name="schedule_sunday"}),-- profile 미포함
tuya.dp_battery(107,{emit=emit.battery()}),
tuya.dp_local_temperature_calibration(109,{scale=10,emit=emit.botr9vTempCalibration()}),
tuya.dp_deadzone_temperature(112,{scale=10,emit=emit.botr9vDeadzoneTemperature()}),
tuya.dp_eco_temperature(116,{scale=10,emit=emit.botr9vEcoTemperature()}),
}
register_device_definition(thermostat_bot_r9v,ef00_helpers.ts0601_fingerprints({
"_TZE204_wc2w9t1s",
}))
local thermostat_bot_r15w={
profile="thermostats-thermostat-battery-bot-r15w",
tuya.dp_binary(1,{
name="system_mode",
converter=converter.lookup_from_to({
heat=true,
off=false,
}),
emit=emit.thermostat_mode(),
}),
tuya.dp_current_heating_setpoint(2,{scale=10}),
tuya.dp_local_temperature(3,{scale=10}),
tuya.dp_enum(4,{
name="preset",
emit=emit.botr15wPreset2(),
converter=converter.lookup_from_to({
manual=0,
auto=1,
mixed=2,
away=3,
}),
}),
tuya.dp_child_lock(9,{emit=emit.botr15wChildLock()}),
tuya.dp_max_temperature_limit(15,{scale=10,emit=emit.botr15wMaxTemperatureLimit()}),
tuya.dp_local_temperature_calibration(19,{scale=10,emit=emit.botr15wTempCalibration()}),
tuya.dp_running_state(101,{
converter=converter.lookup_from_to({
idle=0,
heating=1,
}),
emit=emit.thermostat_operating_state(),
}),
tuya.dp_frost_protection(102,{emit=emit.botr15wFrostProtection()}),
tuya.dp_binary(103,{
name="factory_reset",
emit=emit.botr15wFactoryReset(),
converter=converter.lookup_from_to({off=false,on=true}),
}),
tuya.dp_deadzone_temperature(107,{name="temperature_delta",scale=10,emit=emit.tempDeltaBotRToTen()}),
tuya.dp_battery(113,{emit=emit.battery()}),
}
register_device_definition(thermostat_bot_r15w,ef00_helpers.ts0601_fingerprints({
"_TZE284_agcxaw3f",
}))
local thermostat_te_1z={
profile="thermostats-thermostat-khah2lkr",
tuya.dp_local_temperature(16,{scale=10}),
tuya.dp_current_heating_setpoint(50,{scale=10}),
tuya.dp_running_state(102,{
converter=converter.lookup_from_to({
idle=false,
heating=true,
}),
emit=emit.thermostat_operating_state(),
}),
tuya.dp_temperature(103,{
name="temperature_sensor",
scale=10,
read_only=true,
emit=emit.khahTemperatureSensor(),
}),
tuya.dp_binary(106,{
name="high_temperature_protection_state",
emit=emit.khahHighTempProtection(),
converter=converter.lookup_from_to({off=false,on=true}),
}),
tuya.dp_binary(107,{
name="low_temperature_protection_state",
emit=emit.khahLowTempProtection(),
converter=converter.lookup_from_to({off=false,on=true}),
}),
tuya.dp_local_temperature_calibration(109,{
scale=10,
emit=emit.khahTempCalibration(),
}),
tuya.dp_numeric(110,{
name="temperature_return_difference",
emit=emit.khahReturnDifference(),
}),
tuya.dp_deadzone_temperature(111,{scale=1,emit=emit.khahDeadzoneTemperature()}),
tuya.dp_temperature(112,{
name="high_temperature_protection_setting",
scale=1,
emit=emit.khahHighTempSetting(),
}),
tuya.dp_temperature(113,{
name="low_temperature_protection_setting",
scale=1,
emit=emit.khahLowTempSetting(),
}),
tuya.dp_max_temperature_limit(114,{
name="max_temperature",
scale=1,
emit=emit.khahMaxTemperature(),
}),
tuya.dp_enum(116,{
name="sensor_mode",
emit=emit.khahSensorMode(),
converter=converter.lookup_from_to({["in"]=0,ou=1,al=2}),
}),
tuya.dp_binary(125,{
name="system_mode",
converter=converter.lookup_from_to({
heat=true,
off=false,
}),
emit=emit.thermostat_mode(),
}),
tuya.dp_enum(128,{
name="preset",
emit=emit.khahPreset(),
converter=converter.lookup_from_to({
manual=0,
auto=1,
mixed=3,
}),
}),
tuya.dp_child_lock(129,{emit=emit.khahChildLock()}),
tuya.dp_numeric(130,{
name="error_status",
read_only=true,
emit=emit.khahErrorStatus(),
}),
}
register_device_definition(thermostat_te_1z,ef00_helpers.ts0601_fingerprints({
"_TZE284_khah2lkr",
}))
local thermostat_pilot_wire={
profile="thermostats-thermostat-pilot-wire-no-operating",
tuya.dp_binary(1,{
name="system_mode",
converter=converter.lookup_from_to({
heat=true,
off=false,
}),
emit=emit.thermostat_mode(),
}),
tuya.dp_enum(2,{
name="preset",
emit=emit.pilotWirePreset(),
converter=converter.lookup_from_to({
comfort=0,
eco=1,
antifrost=2,
off=3,
comfort_1=4,
comfort_2=5,
program=6,
manual=7,
}),
}),
tuya.dp_power(11,{name="power",scale=10,emit=emit.power()}),
tuya.dp_local_temperature(16,{scale=10}),
tuya.dp_enum(17,{
name="window",
read_only=true,
emit=emit.pilotWireWindow(),
converter=converter.from_only(converter.lookup_value({
[0]="close",
[1]="open",
})),
}),
tuya.dp_local_temperature_calibration(19,{scale=1,emit=emit.pilotWireTempCalibration()}),
tuya.dp_numeric(20,{name="fault",read_only=true,emit=emit.pilotWireFault()}),
tuya.dp_binary(29,{
name="window_detection",
converter=converter.lookup_from_to({on=true,off=false}),
emit=emit.windowDetectionPilotWire(),
}),
tuya.dp_child_lock(39,{emit=emit.pilotWireChildLock()}),
tuya.dp_current_heating_setpoint(50,{scale=10}),
tuya.dp_voltage(101,{name="voltage",scale=10,emit=emit.voltage()}),
tuya.dp_current(102,{name="current",scale=1000,emit=emit.current()}),
tuya.dp_numeric(103,{
name="temperature_sensibility",
scale=10,
emit=emit.pilotWireTempSensibility(),
}),
tuya.dp_energy(104,{name="energy_today",scale=10,emit=emit.energyTodayPilotWire()}),
tuya.dp_energy(105,{name="energy_yesterday",scale=10,emit=emit.energyYesterdayPilotWire()}),
tuya.dp_enum(106,{
name="device_mode_type",
emit=emit.pilotWireDeviceModeType(),
converter=converter.lookup_from_to({four=0,six=1,switch=2}),
}),
tuya.dp_energy(107,{name="energy",scale=10,emit=emit.energy()}),
}
register_device_definition(thermostat_pilot_wire,ef00_helpers.ts0601_fingerprints({
"_TZE204_0hcjew5p",
"_TZE204_3regm3h6",
"_TZE204_6vwfjkcj",
"_TZE204_ouy7vpm1",
"_TZE284_3regm3h6",
"_TZE204_3q3maeoo",
"_TZE204_d6i25bwg",
}))
local thermostat_pro_900z={
profile="thermostats-thermostat-pro900z",
tuya.dp_binary(1,{
name="system_mode",
converter=converter.lookup_from_to({
off=false,
heat=true,
}),
emit=emit.thermostat_mode(),
}),
tuya.dp_enum(2,{
name="preset",
emit=emit.pro900zPreset(),
converter=converter.lookup_from_to({
auto=0,
manual=1,
}),
}),
tuya.dp_current_heating_setpoint(16,{scale=10}),
tuya.dp_max_temperature_limit(19,{name="max_temperature",emit=emit.pro900zMaxTemperature(),scale=10}),-- profile 미포함
tuya.dp_local_temperature(24,{scale=10}),
tuya.dp_min_temperature_limit(26,{name="min_temperature",emit=emit.pro900zMinTemperature(),scale=10}),-- profile 미포함
tuya.dp_local_temperature_calibration(27,{scale=1,emit=emit.pro900zTempCalibration()}),
tuya.dp_binary(28,{name="factory_reset",emit=emit.pro900zFactoryReset()}),-- profile 미포함
tuya.dp_running_state(36,{
converter=converter.lookup_from_to({
heat=0,
idle=1,
}),
emit=emit.thermostat_operating_state(),
}),
tuya.dp_child_lock(39,{emit=emit.pro900zChildLock()}),
tuya.dp_binary(40,{name="eco_mode",emit=emit.pro900zEcoMode()}),-- profile 미포함
tuya.dp_temperature_sensor_select_internal_external_both(43,{
emit=emit.pro900zSensor(),
converter=converter.lookup_from_to({
["in"]=0,
["al"]=1,
["ou"]=2,
}),
}),
tuya.dp_raw(101,{name="schedule_monday"}),-- profile 미포함
tuya.dp_temperature(102,{name="external_temperature_input",emit=emit.pro900zExternalTemperature(),scale=10}),-- profile 미포함
tuya.dp_deadzone_temperature(103,{scale=1,emit=emit.pro900zDeadzoneTemperature()}),
tuya.dp_max_temperature_limit(104,{
name="max_temperature_limit",
scale=10,
emit=emit.pro900zMaxTemperatureLimit(),
}),
tuya.dp_raw(105,{name="schedule_tuesday"}),-- profile 미포함
tuya.dp_raw(106,{name="schedule_wednesday"}),-- profile 미포함
tuya.dp_raw(107,{name="schedule_thursday"}),-- profile 미포함
tuya.dp_raw(108,{name="schedule_friday"}),-- profile 미포함
tuya.dp_raw(109,{name="schedule_saturday"}),-- profile 미포함
tuya.dp_raw(110,{name="schedule_sunday"}),-- profile 미포함
tuya.dp_min_temperature_limit(111,{
name="min_temperature_limit",
scale=10,
emit=emit.pro900zMinTemperatureLimit(),
}),
tuya.dp_eco_temperature(112,{scale=10,emit=emit.pro900zEcoTemperature()}),
tuya.dp_numeric(113,{name="brightness",emit=emit.pro900zBrightness()}),-- profile 미포함
tuya.dp_numeric(114,{name="display_brightness",emit=emit.displayBrightnessPro900zLevel8()}),
}
register_device_definition(thermostat_pro_900z,ef00_helpers.ts0601_fingerprints({
"_TZE204_tagezcph",
}))
return{
id="ef00.thermostats.wall",
registrations=device_definitions,
}

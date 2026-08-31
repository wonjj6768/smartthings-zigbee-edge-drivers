local tuya=require "protocol.tuya"
local emit=require "capabilities.events.all"
local device_helpers=require "contracts.helpers.family"
local ef00_helpers=require "contracts.helpers.ef00"
local thermostat_metadata=require "contracts.helpers.ef00_thermostat_metadata"
local wave12=require "contracts.helpers.ef00_thermostat_wave12"
local converter=tuya.converter
local device_definitions,register_device_definition=device_helpers.definition_registry()
local function mode_state_machine(field_prefix)
local power_field="__wave12_" .. field_prefix .. "_power"
local mode_field="__wave12_" .. field_prefix .. "_mode"
local function power_from_device(value,device)
local enabled=value==true or value==1
device:set_field(power_field,enabled,{persist=false})
if not enabled then return "off" end
return device:get_field(mode_field)or "heat"
end
local function mode_from_device(value,device)
local mode=({[0]="heat",[1]="cool"})[tonumber(value)]or "heat"
device:set_field(mode_field,mode,{persist=false})
if device:get_field(power_field)==false then return "off" end
return mode
end
local function write(_,value)
if value=="off" then
return{{dp=1,datatype=tuya.DP_TYPE_BOOL,value=false}}
end
local raw=({heat=0,cool=1})[value]
if raw==nil then return nil end
return{
{dp=1,datatype=tuya.DP_TYPE_BOOL,value=true},
{dp=2,datatype=tuya.DP_TYPE_ENUM,value=raw},
}
end
return power_from_device,mode_from_device,write
end
local eone_power_from,eone_mode_from,eone_mode_write=mode_state_machine("engo_eone_djurk")
local eone={
profile="thermostats-wave12-engo-eone",
package_group="wall-2",
query_on_configure=false,
time_start="1970",
force_time_updates=true,
tuya.dp_binary(1,{name="system_mode",from_device=eone_power_from,read_only=true,emit=emit.thermostat_mode()}),
tuya.dp_enum(2,{name="system_mode",from_device=eone_mode_from,read_only=true,emit=emit.thermostat_mode()}),
tuya.dp_running_state(3,{
name="running_state",read_only=true,
converter=converter.from_only(function(value)
return({[1]="heating",[3]="cooling"})[tonumber(value)]or "idle"
end),
emit=emit.thermostat_operating_state(),
}),
tuya.dp_current_heating_setpoint(16,{scale=10,emit=emit.heating_setpoint("C")}),
wave12.numeric(19,"engo_eone_wave12_max_temperature","engoEoneDjurkMaxTemperature",10,false),
tuya.dp_local_temperature(24,{scale=10,read_only=true,emit=emit.temperature("C")}),
wave12.numeric(26,"engo_eone_wave12_min_temperature","engoEoneDjurkMinTemperature",10,false),
wave12.numeric(27,"engo_eone_wave12_temp_calibration","engoEoneDjurkTempCalibration",1,false,{signed=true}),
wave12.numeric(32,"engo_eone_wave12_holiday_temperature","engoEoneDjurkHolidayTemperature",10,false),
wave12.numeric(33,"engo_eone_wave12_holiday_days","engoEoneDjurkHolidayDays",1,false),
tuya.dp_numeric(34,{name="humidity",read_only=true,emit=emit.humidity()}),
tuya.dp_battery(35,{read_only=true,emit=emit.battery()}),
wave12.binary(40,"engo_eone_wave12_child_lock","engoEoneDjurkChildLock",{LOCK=true,UNLOCK=false}),
wave12.enum(43,"engo_eone_wave12_sensor_choose","engoEoneDjurkSensorChoose",{internal=0,floor=1,external=2,occupancy=3}),
wave12.numeric(44,"engo_eone_wave12_brightness","engoEoneDjurkBrightness",1,false),
wave12.enum(58,"engo_eone_wave12_preset","engoEoneDjurkPreset",{
manual=0,schedule=1,holiday=2,temporary=3,occupancy_off=4,frost=5,
}),
wave12.enum(101,"engo_eone_wave12_control_algorithm","engoEoneDjurkControlAlgorithm",{
TPI_UFH=0,TPI_RAD=1,TPI_ELE=2,HIS_02=3,HIS_04=4,HIS_06=5,
HIS_08=6,HIS_10=7,HIS_20=8,HIS_30=9,HIS_40=10,
}),
wave12.numeric(106,"engo_eone_wave12_frost_set","engoEoneDjurkFrostSet",10,false),
wave12.binary(107,"engo_eone_wave12_valve_protection","engoEoneDjurkValveProtection",{ON=true,OFF=false}),
wave12.enum(118,"engo_eone_wave12_warm_floor","engoEoneDjurkWarmFloor",{
OFF=0,["7_min"]=1,["11_min"]=2,["15_min"]=3,["19_min"]=4,["23_min"]=5,
}),
wave12.enum(120,"engo_eone_wave12_sensor_error","engoEoneDjurkSensorError",{Normal=0,E1=1,E2=2},true),
}
wave12.add_day_schedules(eone,"engo_eone_wave12","engoEoneDjurk",109,6,false)
wave12.override_named_writer(eone,"system_mode",eone_mode_write)
thermostat_metadata.attach(eone,{"off","heat","cool"},5,45,0.5)
register_device_definition(eone,ef00_helpers.ts0601_fingerprints({"_TZE204_djurk6p5"}))
local e25={
profile="thermostats-wave12-engo-e25-230",
package_group="wall-2",
query_on_configure=false,
tuya.dp_on_off(1,{name="switch",emit=emit.switch()}),
tuya.dp_system_mode(2,{
name="system_mode",converter=converter.lookup_from_to({heat=0,cool=1}),emit=emit.thermostat_mode(),
}),
tuya.dp_running_state(3,{
name="running_state",read_only=true,
converter=converter.from_only(converter.lookup_value({[2]="heating",[3]="cooling",[4]="idle",[5]="idle"})),
emit=emit.thermostat_operating_state(),
}),
tuya.dp_current_heating_setpoint(16,{scale=10,emit=emit.heating_setpoint("C")}),
wave12.numeric(19,"engo_e25_max_temperature","engoE25MaxTemperature",10,false),
tuya.dp_local_temperature(24,{scale=10,read_only=true,emit=emit.temperature("C")}),
wave12.numeric(26,"engo_e25_min_temperature","engoE25MinTemperature",10,false),
wave12.numeric(27,"engo_e25_temp_calibration","engoE25TempCalibration",10,false,{signed=true}),
wave12.binary(40,"engo_e25_child_lock","engoE25ChildLock",{LOCK=true,UNLOCK=false}),
wave12.numeric(44,"engo_e25_backlight","engoE25Backlight",1,false),
wave12.enum(58,"engo_e25_preset","engoE25Preset",{Manual=0,Frost=3}),
wave12.enum(101,"engo_e25_control_algorithm","engoE25ControlAlgorithm",{
TPI_UFH=0,TPI_RAD=1,TPI_ELE=2,HIS_04=3,HIS_08=4,
HIS_12=5,HIS_16=6,HIS_20=8,HIS_30=9,HIS_40=10,
}),
wave12.numeric(106,"engo_e25_frost_set","engoE25FrostSet",10,false),
wave12.binary(107,"engo_e25_valve_protection","engoE25ValveProtection",{ON=true,OFF=false}),
wave12.enum(108,"engo_e25_relay_mode","engoE25RelayMode",{NO=0,NC=1,OFF=2}),
}
thermostat_metadata.attach(e25,{"heat","cool"},5,35,0.5)
register_device_definition(e25,ef00_helpers.ts0601_fingerprints({"_TZE204_cmyc8g5i"}))
local e25_bat={
profile="thermostats-wave12-engo-e25-batb",
package_group="wall-2",
query_on_configure=false,
tuya.dp_on_off(1,{name="switch",emit=emit.switch()}),
tuya.dp_system_mode(2,{name="system_mode",converter=converter.lookup_from_to({heat=0,cool=1}),emit=emit.thermostat_mode()}),
tuya.dp_running_state(3,{
name="running_state",read_only=true,
converter=converter.from_only(function(value)
return({[2]="heating",[3]="cooling"})[tonumber(value)]or "idle"
end),emit=emit.thermostat_operating_state(),
}),
tuya.dp_current_heating_setpoint(16,{scale=10,emit=emit.heating_setpoint("C")}),
wave12.numeric(19,"engo_e25_bat_max_temperature","engoE25BatbMaxTemperature",10,false),
tuya.dp_local_temperature(24,{scale=10,read_only=true,emit=emit.temperature("C")}),
wave12.numeric(26,"engo_e25_bat_min_temperature","engoE25BatbMinTemperature",10,false),
wave12.numeric(27,"engo_e25_bat_temp_calibration","engoE25BatbTempCalibration",10,false,{signed=true}),
tuya.dp_battery(35,{read_only=true,emit=emit.battery()}),
wave12.binary(40,"engo_e25_bat_child_lock","engoE25BatbChildLock",{LOCK=true,UNLOCK=false}),
wave12.numeric(44,"engo_e25_bat_backlight","engoE25BatbBacklight",1,false),
wave12.enum(58,"engo_e25_bat_preset","engoE25BatbPreset",{manual=0,schedule=1,["frost protection"]=3}),
wave12.enum(101,"engo_e25_bat_control_type","engoE25BatbControlType",{
TPI_UFH=0,TPI_RAD=1,TPI_ELE=2,HIS_02=3,HIS_04=4,HIS_08=5,
HIS_12=6,HIS_16=7,HIS_20=8,HIS_30=9,HIS_40=10,
}),
wave12.numeric(102,"engo_e25_bat_delta_algorithm","engoE25BatbDeltaAlgorithm",10,false),
wave12.enum(103,"engo_e25_bat_pair_state","engoE25BatbPairState",{none=0,commutation_center=1,trv=2},true),
wave12.numeric(106,"engo_e25_bat_frost_set","engoE25BatbFrostSet",10,false),
wave12.binary(107,"engo_e25_bat_valve_protection","engoE25BatbValveProtection",{ON=true,OFF=false}),
wave12.numeric(123,"engo_e25_bat_trv_work_state","engoE25BatbTrvWorkState",1,true),
wave12.numeric(136,"engo_e25_bat_latest_firmware","engoE25BatbLatestFirmware",10,true),
wave12.numeric(137,"engo_e25_bat_current_firmware","engoE25BatbCurrentFirmware",1,true),
}
wave12.add_day_schedules(e25_bat,"engo_e25_bat","engoE25Batb",109,6,false)
thermostat_metadata.attach(e25_bat,{"heat","cool"},5,35,0.5)
register_device_definition(e25_bat,ef00_helpers.ts0601_fingerprints({"_TZE204_cg8hdnjv"}))
local eone_bat={
profile="thermostats-wave12-engo-eone-batb",
package_group="wall-2",
query_on_configure=true,
time_start="2000",
tuya.dp_on_off(1,{name="switch",emit=emit.switch()}),
tuya.dp_system_mode(2,{name="system_mode",converter=converter.lookup_from_to({heat=0,cool=1}),emit=emit.thermostat_mode()}),
tuya.dp_running_state(3,{
name="running_state",read_only=true,
converter=converter.from_only(converter.lookup_value({[1]="heating",[2]="idle"})),
emit=emit.thermostat_operating_state(),
}),
tuya.dp_current_heating_setpoint(16,{scale=10,emit=emit.heating_setpoint("C")}),
wave12.numeric(19,"engo_eone_bat_max_temperature","engoEoneBatMaxTemperature",10,false),
tuya.dp_local_temperature(24,{scale=10,read_only=true,emit=emit.temperature("C")}),
wave12.numeric(26,"engo_eone_bat_min_temperature","engoEoneBatMinTemperature",10,false),
wave12.numeric(27,"engo_eone_bat_temp_calibration","engoEoneBatTempCalibration",10,false,{signed=true}),
wave12.numeric(32,"engo_eone_bat_holiday_temperature","engoEoneBatHolidayTemperature",10,false),
wave12.numeric(33,"engo_eone_bat_holiday_days","engoEoneBatHolidayDays",1,false),
tuya.dp_numeric(34,{name="humidity",read_only=true,emit=emit.humidity()}),
tuya.dp_battery(35,{read_only=true,emit=emit.battery()}),
wave12.binary(40,"engo_eone_bat_child_lock","engoEoneBatChildLock",{LOCK=true,UNLOCK=false}),
wave12.enum(43,"engo_eone_bat_sensor_choose","engoEoneBatSensorChoose",{internal=0,floor_temp=1,external=2,external_on_off=3}),
wave12.numeric(44,"engo_eone_bat_backlight","engoEoneBatBacklight",1,false),
wave12.enum(58,"engo_eone_bat_preset","engoEoneBatPreset",{manual=0,schedule=1,holiday=2,frost=5}),
wave12.enum(101,"engo_eone_bat_control_algorithm","engoEoneBatControlAlgorithm",{
TPI_UFH=0,TPI_RAD=1,TPI_ELE=2,HIS_02=3,HIS_04=4,HIS_06=5,
HIS_08=6,HIS_10=7,HIS_20=8,HIS_30=9,HIS_40=10,
}),
wave12.numeric(102,"engo_eone_bat_max_floor_heating","engoEoneBatMaxFloorHeating",10,false),
wave12.numeric(103,"engo_eone_bat_min_floor_heating","engoEoneBatMinFloorHeating",10,false),
wave12.numeric(104,"engo_eone_bat_max_floor_cooling","engoEoneBatMaxFloorCooling",10,false),
wave12.numeric(106,"engo_eone_bat_frost_set","engoEoneBatFrostSet",10,false),
wave12.enum(108,"engo_eone_bat_valve_protection","engoEoneBatValveProtection",{off=0,on=1,anti_stop=2}),
wave12.numeric(116,"engo_eone_bat_floor_temperature","engoEoneBatFloorTemperature",10,true),
wave12.enum(117,"engo_eone_bat_temp_resolution","engoEoneBatTempResolution",{one=0,five=1}),
wave12.enum(118,"engo_eone_bat_comfort_floor","engoEoneBatComfortFloor",{
OFF=0,LEVEL1=1,LEVEL2=2,LEVEL3=3,LEVEL4=4,LEVEL5=5,
}),
wave12.enum(120,"engo_eone_bat_sensor_error","engoEoneBatSensorError",{normal=0,E1=1,E2=2},true),
}
wave12.add_day_schedules(eone_bat,"engo_eone_bat","engoEoneBat",109,4,true)
thermostat_metadata.attach(eone_bat,{"heat","cool"},5,45,0.5)
register_device_definition(eone_bat,ef00_helpers.ts0601_fingerprints({"_TZE200_gtouvmvl"}))
local STHREE_WEEKDAY_FIELD="__wave12_sthree_schedule_weekday"
local STHREE_HOLIDAY_FIELD="__wave12_sthree_schedule_holiday"
local function sthree_schedule_part(value,first,count,device,field)
if type(value)~="string" or #value < 32 then return nil end
local result={}
for index=first,first + count - 1 do
local offset=index * 4 + 1
local hour,minute,high,low=string.byte(value,offset,offset + 3)
result[#result + 1]=string.format("%02d:%02d/%.1f°C",hour,minute,(high * 256 + low)/ 10)
end
local text=table.concat(result," ")
device:set_field(field,text,{persist=false})
return text
end
local function sthree_schedule_payload(weekday,holiday)
if type(weekday)~="string" or type(holiday)~="string" then return nil end
local payload={}
local count=0
for transition in string.gmatch(weekday .. " " .. holiday,"%S+")do
local hour_text,minute_text,temperature_text=transition:match("^(%d+):(%d+)/([%d%.%-]+)")
local hour,minute,temperature=tonumber(hour_text),tonumber(minute_text),tonumber(temperature_text)
if hour==nil or minute==nil or temperature==nil
or hour < 0 or hour >=24 or minute < 0 or minute >=60
or temperature < 5 or temperature >=35 then return nil end
local encoded=math.floor(temperature * 10 + 0.5)
payload[#payload + 1]=hour
payload[#payload + 1]=minute
payload[#payload + 1]=math.floor(encoded / 256)% 256
payload[#payload + 1]=encoded % 256
count=count + 1
end
if count ~=8 then return nil end
return string.char(table.unpack(payload))
end
local function sthree_schedule_writer(field,other_field,is_weekday)
return function(device,value)
device:set_field(field,value,{persist=false})
local other=device:get_field(other_field)
local payload=is_weekday and sthree_schedule_payload(value,other)or sthree_schedule_payload(other,value)
if payload==nil then return nil end
return{{dp=109,datatype=tuya.DP_TYPE_RAW,value=payload}}
end
end
local sthree={
profile="thermostats-wave12-moes-zht-s03",
package_group="wall-2",
query_on_configure=false,
time_start="1970",
tuya.dp_binary(1,{
name="system_mode",read_only=true,
converter=converter.from_only(function(value)return value==true and "heat" or "off" end),
emit=emit.thermostat_mode(),
}),
wave12.enum(2,"moes_zht_sthree_preset","moesZhtSthreePreset",{schedule=0,manual=1}),
wave12.binary(10,"moes_zht_sthree_frost_protection","moesZhtSthreeFrostProtection",{ON=true,OFF=false}),
tuya.dp_current_heating_setpoint(16,{scale=10,emit=emit.heating_setpoint("C")}),
tuya.dp_local_temperature(24,{scale=10,read_only=true,emit=emit.temperature("C")}),
wave12.enum(31,"moes_zht_sthree_working_day","moesZhtSthreeWorkingDay",{mon_fri=0,mon_sat=1,mon_sun=2}),
tuya.dp_running_state(36,{
name="running_state",read_only=true,
converter=converter.from_only(converter.lookup_value({[0]="idle",[1]="heating",[2]="cooling"})),
emit=emit.thermostat_operating_state(),
}),
wave12.binary(40,"moes_zht_sthree_child_lock","moesZhtSthreeChildLock",{LOCK=true,UNLOCK=false}),
tuya.dp_raw(67,{read_only=true,from_device=function(value,device)
sthree_schedule_part(value,0,6,device,STHREE_WEEKDAY_FIELD)
sthree_schedule_part(value,6,2,device,STHREE_HOLIDAY_FIELD)
return nil
end}),
wave12.raw(67,"moes_zht_sthree_schedule_weekday","moesZhtSthreeScheduleWeekday",converter.from_only(function(value,device)
return sthree_schedule_part(value,0,6,device,STHREE_WEEKDAY_FIELD)
end),true),
wave12.raw(68,"moes_zht_sthree_schedule_holiday","moesZhtSthreeScheduleHoliday",converter.from_only(function(value,device)
return sthree_schedule_part(value,6,2,device,STHREE_HOLIDAY_FIELD)
end),true),
wave12.numeric(109,"moes_zht_sthree_temp_calibration","moesZhtSthreeTempCalibration",10,false,{signed=true}),
wave12.numeric(112,"moes_zht_sthree_temperature_delta","moesZhtSthreeTemperatureDelta",10,false),
}
local sthree_named=tuya.build_named_map(sthree,"name")
sthree_named.moes_zht_sthree_schedule_weekday=sthree_schedule_writer(STHREE_WEEKDAY_FIELD,STHREE_HOLIDAY_FIELD,true)
sthree_named.moes_zht_sthree_schedule_holiday=sthree_schedule_writer(STHREE_HOLIDAY_FIELD,STHREE_WEEKDAY_FIELD,false)
sthree.named_mapping={named_mappings=sthree_named}
thermostat_metadata.attach(sthree,{"off","heat"},5,35,0.5)
register_device_definition(sthree,ef00_helpers.ts0601_fingerprints({"_TZE204_zxkwaztm"}))
local sr_calibration=converter.from_to(
function(value)
local numeric=tonumber(value)
if numeric==nil then return nil end
return numeric > 200 and numeric - 256 or numeric
end,
function(value)
local numeric=tonumber(value)
if numeric==nil then return nil end
return numeric < 0 and 256 + numeric or numeric
end
)
local sr={
profile="thermostats-wave12-moes-zht-sr",
package_group="wall-2",
query_on_configure=false,
time_start="1970",
tuya.dp_binary(1,{
name="system_mode",converter=converter.lookup_from_to({off=false,heat=true}),emit=emit.thermostat_mode(),
}),
wave12.enum(2,"moes_zht_sr_preset","moesZhtSrPreset",{Manual=0,["Temporary manual"]=1,Program=2,Eco=3},false,true),
tuya.dp_local_temperature(16,{scale=10,read_only=true,emit=emit.temperature("C")}),
wave12.numeric(18,"moes_zht_sr_min_limit","moesZhtSrMinLimit",10,false),
wave12.enum(32,"moes_zht_sr_sensor_mode","moesZhtSrSensorMode",{IN=0,AL=1,OU=2},true,true),
wave12.numeric(34,"moes_zht_sr_max_limit","moesZhtSrMaxLimit",10,false),
wave12.binary(39,"moes_zht_sr_child_lock","moesZhtSrChildLock",{LOCK=true,UNLOCK=false}),
tuya.dp_running_state(47,{
name="running_state",read_only=true,
converter=converter.from_only(converter.lookup_value({[0]="heating",[1]="idle"})),
emit=emit.thermostat_operating_state(),
}),
wave12.numeric(48,"moes_zht_sr_backlight","moesZhtSrBacklight",1,false),
tuya.dp_current_heating_setpoint(50,{scale=10,emit=emit.heating_setpoint("C")}),
wave12.numeric(101,"moes_zht_sr_temp_calibration","moesZhtSrTempCalibration",1,false,{converter=sr_calibration}),
wave12.numeric(109,"moes_zht_sr_floor_temperature","moesZhtSrFloorTemperature",10,true),
wave12.numeric(110,"moes_zht_sr_deadzone","moesZhtSrDeadzone",10,false),
wave12.numeric(111,"moes_zht_sr_high_protection","moesZhtSrHighProtection",10,false),
wave12.numeric(112,"moes_zht_sr_low_protection","moesZhtSrLowProtection",10,false),
wave12.numeric(113,"moes_zht_sr_eco_temperature","moesZhtSrEcoTemperature",10,false),
wave12.enum(114,"moes_zht_sr_screen_time","moesZhtSrScreenTime",{
["10_seconds"]=0,["20_seconds"]=1,["30_seconds"]=2,
["40_seconds"]=3,["50_seconds"]=4,["60_seconds"]=5,
},false,true),
wave12.binary(115,"moes_zht_sr_rgb_light","moesZhtSrRgbLight",{ON=true,OFF=false}),
}
thermostat_metadata.attach(sr,{"off","heat"},5,45,0.5)
register_device_definition(sr,ef00_helpers.ts0601_fingerprints({"_TZE204_lpedvtvr"}))
local pilot_modes={
standby=0,comfort=1,comfort_1=2,comfort_2=3,
eco=4,antifrost=5,program=6,thermostat=7,
}
local pilot_presets={
off=0,comfort=1,comfort_1=2,comfort_2=3,
eco=4,antifrost=5,program=6,thermostat=7,
}
local pilot={
profile="thermostats-wave12-moes-pilot",
package_group="wall-2",
query_on_configure=false,
time_start="1970",
wave12.enum(2,"moes_pilot_mode","moesPilotMode",pilot_modes),
tuya.dp_system_mode(2,{
name="system_mode",read_only=true,
converter=converter.from_only(converter.lookup_value({[0]="off",[6]="auto",[7]="heat"})),
emit=emit.thermostat_mode(),
}),
wave12.enum(2,"moes_pilot_preset","moesPilotPreset",pilot_presets),
tuya.dp_local_temperature(16,{scale=10,read_only=true,emit=emit.temperature("C")}),
wave12.enum(17,"moes_pilot_window_open","moesPilotWindowOpen",{close=0,open=1},true),
wave12.numeric(18,"moes_pilot_lower_temperature","moesPilotLowerTemperature",10,false),
wave12.numeric(19,"moes_pilot_temp_calibration","moesPilotTempCalibration",10,false,{signed=true}),
wave12.binary(29,"moes_pilot_window_detection","moesPilotWindowDetection",{ON=true,OFF=false}),
wave12.numeric(34,"moes_pilot_upper_temperature","moesPilotUpperTemperature",10,false),
wave12.binary(39,"moes_pilot_child_lock","moesPilotChildLock",{LOCK=true,UNLOCK=false}),
wave12.enum(46,"moes_pilot_temp_unit","moesPilotTempUnit",{c=0,f=1}),
tuya.dp_current_heating_setpoint(50,{scale=10,emit=emit.heating_setpoint("C")}),
wave12.numeric(102,"moes_pilot_boost_duration","moesPilotBoostDuration",1,false),
wave12.numeric(103,"moes_pilot_electricity","moesPilotElectricity",1,true),
wave12.numeric(104,"moes_pilot_daily_energy","moesPilotDailyEnergy",1,true),
wave12.numeric(105,"moes_pilot_monthly_energy","moesPilotMonthlyEnergy",1,true),
wave12.numeric(106,"moes_pilot_yearly_energy","moesPilotYearlyEnergy",1,true),
wave12.numeric(110,"moes_pilot_window_keep_time","moesPilotWindowKeepTime",1,false),
wave12.enum(113,"moes_pilot_running_mode","moesPilotRunningMode",{
standby=0,comfort=1,comfort_1=2,comfort_2=3,eco=4,antifrost=5,
},true),
}
thermostat_metadata.attach(pilot,{"off","heat","auto"},5,30,0.5)
register_device_definition(pilot,ef00_helpers.ts0601_fingerprints({"_TZE204_x9usygq1"}))
local SONE_DEFAULTS={
weekday={
{6,0,20},{8,0,16},{11,30,20},
{12,30,16},{17,0,20},{22,0,16},
},
weekend={{8,0,20},{23,0,16}},
}
local function sone_field_key(group,index,field)
return string.format("__wave12_sone_%s_%d_%s",group,index,field)
end
local function sone_build_payload(device)
local payload={}
for _,group in ipairs({"weekday","weekend"})do
for index,defaults in ipairs(SONE_DEFAULTS[group])do
local hour=device:get_field(sone_field_key(group,index,"hour"))
local minute=device:get_field(sone_field_key(group,index,"minute"))
local temperature=device:get_field(sone_field_key(group,index,"temp"))
payload[#payload + 1]=math.floor(tonumber(hour)or defaults[1])
payload[#payload + 1]=math.floor(tonumber(minute)or defaults[2])
payload[#payload + 1]=math.floor(tonumber(temperature)or defaults[3])
end
end
return string.char(table.unpack(payload))
end
local function sone_schedule_converter(group,index,field,byte_offset)
local key=sone_field_key(group,index,field)
return converter.from_to(
function(value,device)
if type(value)~="string" or #value < 24 then return nil end
local numeric=string.byte(value,byte_offset)
device:set_field(key,numeric,{persist=false})
return numeric
end,
function(value,device)
local numeric=tonumber(value)
if numeric==nil then return nil end
device:set_field(key,numeric,{persist=false})
return sone_build_payload(device)
end
)
end
local function sone_fault(value)
local numeric=math.floor(tonumber(value)or 0)
if numeric==0 then return "none" end
local faults={}
if numeric % 2 >=1 then faults[#faults + 1]="e1" end
if math.floor(numeric / 2)% 2 >=1 then faults[#faults + 1]="e2" end
if math.floor(numeric / 4)% 2 >=1 then faults[#faults + 1]="e3" end
return #faults > 0 and table.concat(faults,"_")or "none"
end
local sone={
profile="thermostats-wave12-moes-zht-s01",
package_group="wall-2",
query_on_configure=false,
time_start="1970",
force_time_updates=true,
tuya.dp_binary(1,{
name="system_mode",converter=converter.lookup_from_to({off=false,heat=true}),emit=emit.thermostat_mode(),
}),
wave12.enum(2,"moes_zht_sone_preset","moesZhtSonePreset",{auto=0,manual=1,eco=2}),
wave12.enum(3,"moes_zht_sone_backlight","moesZhtSoneBacklight",{off=0,low=1,medium=2,high=3}),
wave12.numeric(19,"moes_zht_sone_temp_calibration","moesZhtSoneTempCalibration",1,false,{signed=true}),
wave12.enum(20,"moes_zht_sone_fault_alarm","moesZhtSoneFaultAlarm",{
none=0,e1=1,e2=2,e3=4,e1_e2=3,e1_e3=5,e2_e3=6,e1_e2_e3=7,
},true,true),
wave12.enum(32,"moes_zht_sone_sensor","moesZhtSoneSensor",{internal=0,external=1,both=2}),
wave12.binary(39,"moes_zht_sone_child_lock","moesZhtSoneChildLock",{LOCK=true,UNLOCK=false}),
wave12.enum(46,"moes_zht_sone_temperature_scale","moesZhtSoneTemperatureScale",{celsius=0,fahrenheit=1}),
tuya.dp_running_state(47,{
name="running_state",read_only=true,
converter=converter.from_only(converter.lookup_value({[0]="heating",[1]="idle"})),
emit=emit.thermostat_operating_state(),
}),
wave12.enum(47,"moes_zht_sone_valve_state","moesZhtSoneValveState",{OPEN=0,CLOSED=1},true),
wave12.numeric(101,"moes_zht_sone_floor_temperature","moesZhtSoneFloorTemperature",10,true),
wave12.binary(103,"moes_zht_sone_antifreeze","moesZhtSoneAntifreeze",{ON=true,OFF=false}),
wave12.enum(104,"moes_zht_sone_program_mode","moesZhtSoneProgramMode",{off=0,weekend=1,single_break=2,no_day_off=3}),
wave12.numeric(106,"moes_zht_sone_deadzone","moesZhtSoneDeadzone",10,false),
wave12.numeric(107,"moes_zht_sone_eco_temperature","moesZhtSoneEcoTemperature",1,false),
tuya.dp_current_heating_setpoint(111,{scale=10,emit=emit.heating_setpoint("C")}),
wave12.numeric(114,"moes_zht_sone_max_limit","moesZhtSoneMaxLimit",10,false),
wave12.numeric(116,"moes_zht_sone_min_limit","moesZhtSoneMinLimit",10,false),
tuya.dp_local_temperature(117,{scale=10,read_only=true,emit=emit.temperature("C")}),
}
sone[5].from_device=sone_fault
local schedule_groups={
{key="weekday",words={"One","Two","Three","Four","Five","Six"},count=6,base=1},
{key="weekend",words={"One","Two"},count=2,base=19},
}
for _,group in ipairs(schedule_groups)do
for index=1,group.count do
local word=group.words[index]
local base=group.base +(index - 1)* 3
for offset,field in ipairs({"hour","minute","temp"})do
local title=field=="hour" and "Hour" or field=="minute" and "Minute" or "Temp"
sone[#sone + 1]=wave12.raw(
108,
string.format("moes_zht_sone_%s_%d_%s",group.key,index,field),
"moesZhtSone" ..(group.key=="weekday" and "Weekday" or "Weekend").. word .. title,
sone_schedule_converter(group.key,index,field,base + offset - 1),
false
)
end
end
end
thermostat_metadata.attach(sone,{"off","heat"},5,35,0.5)
register_device_definition(sone,ef00_helpers.ts0601_fingerprints({"_TZE284_rlytpmij"}))
local namron={
profile="thermostats-wave12-namron-touch",
package_group="wall-2",
query_on_configure=false,
time_start="2000",
tuya.dp_binary(1,{
name="system_mode",converter=converter.lookup_from_to({off=false,heat=true}),emit=emit.thermostat_mode(),
}),
wave12.enum(2,"namron_touch_preset","namronTouchPreset",{manual=0,home=1,away=2}),
tuya.dp_current_heating_setpoint(16,{scale=1,emit=emit.heating_setpoint("C")}),
tuya.dp_local_temperature(24,{scale=1,read_only=true,emit=emit.temperature("C")}),
wave12.numeric(28,"namron_touch_temp_calibration","namronTouchTempCalibration",1,false,{signed=true}),
wave12.binary(30,"namron_touch_child_lock","namronTouchChildLock",{LOCK=true,UNLOCK=false}),
wave12.numeric(101,"namron_touch_floor_temperature","namronTouchFloorTemperature",1,true),
wave12.enum(102,"namron_touch_sensor","namronTouchSensor",{air_sensor=0,floor_sensor=1,both=2}),
wave12.numeric(103,"namron_touch_hysteresis","namronTouchHysteresis",1,false),
tuya.dp_binary(104,{
name="running_state",read_only=true,
converter=converter.from_only(function(value)return value==true and "heating" or "idle" end),
emit=emit.thermostat_operating_state(),
}),
wave12.binary(106,"namron_touch_window_detection","namronTouchWindowDetection",{ON=true,OFF=false}),
wave12.numeric(107,"namron_touch_max_protection","namronTouchMaxProtection",1,false),
wave12.enum(108,"namron_touch_mode","namronTouchMode",{regulator=0,thermostat=1}),
wave12.enum(109,"namron_touch_regulator_period","namronTouchRegulatorPeriod",{
["15min"]=0,["30min"]=1,["45min"]=2,["60min"]=3,["90min"]=4,
}),
wave12.numeric(110,"namron_touch_regulator_setpoint","namronTouchRegulatorSetpoint",1,false),
tuya.dp_numeric(120,{name="current",converter=converter.divide_by_pair(10),read_only=true,emit=emit.current()}),
tuya.dp_numeric(121,{name="voltage",read_only=true,emit=emit.voltage()}),
tuya.dp_numeric(122,{name="power",read_only=true,emit=emit.power()}),
tuya.dp_numeric(123,{name="energy",converter=converter.divide_by_pair(100),read_only=true,emit=emit.energy()}),
}
thermostat_metadata.attach(namron,{"off","heat"},5,35,1)
register_device_definition(namron,ef00_helpers.ts0601_fingerprints({"_TZE204_p3lqqy2r"}))
local beca={
profile="thermostats-wave12-beca-bht209",
package_group="wall-2",
query_on_configure=false,
time_start="1970",
force_time_updates=true,
tuya.dp_on_off(1,{name="switch",emit=emit.switch()}),
tuya.dp_current_heating_setpoint(16,{scale=10,emit=emit.heating_setpoint("C")}),
wave12.numeric(18,"beca_bht_deadzone","becaBhtDeadzone",1,false),
tuya.dp_local_temperature(24,{scale=10,read_only=true,emit=emit.temperature("C")}),
wave12.numeric(27,"beca_bht_temp_calibration","becaBhtTempCalibration",1,false,{signed=true}),
wave12.numeric(34,"beca_bht_max_limit","becaBhtMaxLimit",1,false),
tuya.dp_numeric(36,{
name="running_state",read_only=true,
converter=converter.from_only(converter.lookup_value({[0]="heating",[1]="idle"})),
emit=emit.thermostat_operating_state(),
}),
wave12.binary(40,"beca_bht_child_lock","becaBhtChildLock",{LOCK=true,UNLOCK=false}),
wave12.binary(104,"beca_bht_heating_mode","becaBhtHeatingMode",{ON=true,OFF=false}),
}
wave12.attach_setpoint_range(beca,5,45,0.5)
register_device_definition(beca,ef00_helpers.ts0601_fingerprints({"_TZE284_4cgmagba"}))
return{
id="ef00.thermostats.wave12_wall",
registrations=device_definitions,
}

local tuya=require "protocol.tuya"
local emit=require "capabilities.events.all"
local device_helpers=require "contracts.helpers.family"
local converter=tuya.converter
local registrations,register_device_definition=device_helpers.definition_registry()
local function is_first_frame_datapoint(dp_info,context)
local frame=type(context)=="table" and context.frame or nil
local datapoints=type(frame)=="table" and frame.datapoints or nil
return type(datapoints)~="table" or datapoints[1]==dp_info
end
local function first_from(transform)
return converter.from_only(function(value,device,dp_info,context)
if not is_first_frame_datapoint(dp_info,context)then return nil end
return transform(value,device,dp_info,context)
end)
end
local function first_pair(from_transform,to_transform)
return converter.from_to(
function(value,device,dp_info,context)
if not is_first_frame_datapoint(dp_info,context)then return nil end
return from_transform(value,device,dp_info,context)
end,
to_transform
)
end
local function number_value(value)
if type(value)=="number" then return value end
return nil
end
local function raw_one_byte_value(value)
if type(value)~="string" or #value ~=1 then return nil end
return string.byte(value,1)
end
local function numeric_or_raw_one_byte_value(value)
local numeric=number_value(value)
if numeric ~=nil then return numeric end
return raw_one_byte_value(value)
end
local function signed_raw_one_byte_value(value)
local numeric=raw_one_byte_value(value)
if numeric==nil then return nil end
if numeric >=0x80 then return numeric - 0x100 end
return numeric
end
local function binary_value(value)
if value==true then return true end
if value==false then return false end
local numeric=number_value(value)
if numeric ~=nil then return numeric ~=0 end
return nil
end
local function signed_number_value(value,_,dp_info)
if type(dp_info)=="table" and type(dp_info.signed_value)=="number" then
return dp_info.signed_value
end
local numeric=number_value(value)
if numeric ~=nil and numeric > 0x7FFFFFFF then
return numeric - 0x100000000
end
return numeric
end
local function signed_numeric_or_raw_one_byte_value(value,device,dp_info)
if type(value)=="string" then
return signed_raw_one_byte_value(value)
end
return signed_number_value(value,device,dp_info)
end
local function raw_byte(value)
local numeric=tonumber(value)
if numeric==nil then return nil end
return string.char(math.floor(numeric)% 0x100)
end
local javis_motion_converter=first_from(function(value)
local numeric=number_value(value)
if numeric==nil then return nil end
return numeric > 0 and numeric < 5
end)
local javis_number_converter=first_from(number_value)
local javis_led_converter=first_pair(
function(value)
local numeric=numeric_or_raw_one_byte_value(value)
if numeric==1 then return "enabled" end
if numeric==0 then return "disabled" end
return nil
end,
function(value)
if value=="enabled" then return string.char(1)end
if value=="disabled" then return string.char(0)end
return nil
end
)
local javis_keep_time_converter=first_pair(
function(value)
local numeric=numeric_or_raw_one_byte_value(value)
if numeric==nil or numeric < 0 or numeric > 7 then return nil end
return tostring(math.floor(numeric))
end,
function(value)
local numeric=tonumber(value)
if numeric==nil or numeric < 0 or numeric > 7 then return nil end
return string.char(math.floor(numeric))
end
)
local javis_sensitivity_lookup={
[25]="25",[50]="50",[75]="75",[100]="100",
}
local javis_sensitivity_converter=first_pair(
function(value)
return javis_sensitivity_lookup[numeric_or_raw_one_byte_value(value)]
end,
function(value)
local numeric=tonumber(value)
if javis_sensitivity_lookup[numeric]==nil then return nil end
return string.char(numeric)
end
)
local javis_calibration_converter=first_pair(signed_numeric_or_raw_one_byte_value,raw_byte)
local function javis_definition(keep_time_dp,led_dp,calibration_dp)
return{
profile="safety-wave19-javis-microwave",
named_datapoints=true,
magic_packet=false,
query_on_configure=false,
time_start="off",
datapoints={
tuya.dp_enum(1,{
name="motion",endpoint=1,transaction=1,read_only=true,
converter=javis_motion_converter,emit=emit.motion(),
}),
tuya.dp_numeric(101,{
name="illuminance_primary",endpoint=1,transaction=1,read_only=true,
converter=javis_number_converter,emit=emit.illuminance(),
}),
tuya.dp_numeric(104,{
name="illuminance_secondary",endpoint=1,transaction=1,read_only=true,
converter=javis_number_converter,emit=emit.illuminance(),
}),
tuya.dp_raw(2,{
name="javis_mc_sensitivity",endpoint=1,transaction=1,
converter=javis_sensitivity_converter,emit=emit.javisMcSensitivity(),
}),
tuya.dp_raw(keep_time_dp,{
name="javis_mc_keep_time",endpoint=1,transaction=1,
converter=javis_keep_time_converter,emit=emit.javisMcKeepTime(),
}),
tuya.dp_raw(led_dp,{
name="javis_mc_led_enable",endpoint=1,transaction=1,
converter=javis_led_converter,emit=emit.javisMcLedEnable(),
}),
tuya.dp_raw(calibration_dp,{
name="javis_mc_illuminance_calibration",endpoint=1,transaction=1,
converter=javis_calibration_converter,emit=emit.javisMcIlluminanceCalibration(),
}),
},
}
end
register_device_definition(javis_definition(102,103,105),{
device_helpers.create_fingerprint("_TZE200_i0b1dbqu","TS0601"),
device_helpers.create_fingerprint("_TZE200_lgstepha","TS0601"),
})
register_device_definition(javis_definition(106,107,102),{
device_helpers.create_fingerprint("_TZE200_kagkgk0i","TS0601"),
})
local neo_power_type_lookup={
[0]="battery_full",
[1]="battery_high",
[2]="battery_medium",
[3]="battery_low",
[4]="usb",
}
local neo_alarm_lookup={
[0]="over_temperature",
[1]="over_humidity",
[2]="below_min_temperature",
[3]="below_min_humdity",
[4]="off",
}
local neo_motion_converter=first_from(function(value)
local enabled=binary_value(value)
return enabled
end)
local neo_power_type_converter=first_from(function(value)
return neo_power_type_lookup[number_value(value)]
end)
local neo_battery_low_converter=first_from(function(value)
local numeric=number_value(value)
if numeric==nil then return nil end
return numeric==3 and "low" or "normal"
end)
local neo_tamper_converter=first_from(binary_value)
local neo_temperature_converter=first_from(function(value)
local numeric=number_value(value)
if numeric==nil then return nil end
return numeric / 10
end)
local neo_numeric_converter=first_pair(number_value,number_value)
local neo_signed_numeric_converter=first_pair(signed_number_value,number_value)
local neo_alarm_converter=first_from(function(value)
return neo_alarm_lookup[number_value(value)]
end)
local neo_temperature_scale_converter=first_pair(
function(value)
local celsius=binary_value(value)
if celsius==nil then return nil end
return celsius and "celsius" or "fahrenheit"
end,
function(value)
if value=="celsius" then return true end
if value=="fahrenheit" then return false end
return nil
end
)
local neo_nas_pd07={
profile="safety-wave19-neo-nas-pd07",
named_datapoints=true,
magic_packet=true,
query_on_configure=false,
mcu_version_request_on_configure=true,
time_start="off",
datapoints={
tuya.dp_binary(101,{
name="motion",endpoint=1,transaction=1,read_only=true,
converter=neo_motion_converter,emit=emit.motion(),
}),
tuya.dp_enum(102,{
name="neo_nas_pd_seven_power_type",endpoint=1,transaction=1,read_only=true,
converter=neo_power_type_converter,emit=emit.neoNasPdSevenPowerType(),
}),
tuya.dp_enum(102,{
name="neo_nas_pd_seven_battery_low",endpoint=1,transaction=1,read_only=true,
converter=neo_battery_low_converter,emit=emit.neoNasPdSevenBatteryLow(),
}),
tuya.dp_binary(103,{
name="tamper",endpoint=1,transaction=1,read_only=true,
converter=neo_tamper_converter,emit=emit.tamper(),
}),
tuya.dp_numeric(104,{
name="temperature",endpoint=1,transaction=1,read_only=true,
converter=neo_temperature_converter,emit=emit.temperature(),
}),
tuya.dp_numeric(105,{
name="humidity",endpoint=1,transaction=1,read_only=true,
converter=first_from(number_value),emit=emit.humidity(),
}),
tuya.dp_numeric(107,{
name="neo_nas_pd_seven_minimum_temperature",endpoint=1,transaction=1,
signed=true,converter=neo_signed_numeric_converter,emit=emit.neoNasPdSevenTemperatureMin(),
}),
tuya.dp_numeric(108,{
name="neo_nas_pd_seven_maximum_temperature",endpoint=1,transaction=1,
signed=true,converter=neo_signed_numeric_converter,emit=emit.neoNasPdSevenTemperatureMax(),
}),
tuya.dp_binary(106,{
name="neo_nas_pd_seven_temperature_scale",endpoint=1,transaction=1,
converter=neo_temperature_scale_converter,emit=emit.neoNasPdSevenTemperatureScale(),
}),
tuya.dp_numeric(109,{
name="neo_nas_pd_seven_minimum_humidity",endpoint=1,transaction=1,
converter=neo_numeric_converter,emit=emit.neoNasPdSevenHumidityMin(),
}),
tuya.dp_numeric(110,{
name="neo_nas_pd_seven_maximum_humidity",endpoint=1,transaction=1,
converter=neo_numeric_converter,emit=emit.neoNasPdSevenHumidityMax(),
}),
tuya.dp_enum(113,{
name="neo_nas_pd_seven_alarm",endpoint=1,transaction=1,read_only=true,
converter=neo_alarm_converter,emit=emit.neoNasPdSevenAlarm(),
}),
},
}
register_device_definition(neo_nas_pd07,{
device_helpers.create_fingerprint("_TZE200_7hfcudw5","TS0601"),
})
return{
id="ef00.presence.wave19.sensors",
registrations=registrations,
}

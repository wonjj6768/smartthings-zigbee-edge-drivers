local capabilities=require "st.capabilities"
local tuya=require "protocol.tuya"
local emit=require "capabilities.events.all"
local device_helpers=require "contracts.helpers.family"
local device_definitions,register_device_definition=device_helpers.definition_registry()
local converter=tuya.converter
local function clamp(value,minimum,maximum)
if value < minimum then return minimum end
if value > maximum then return maximum end
return value
end
local function round(value)
return math.floor(value + 0.5)
end
local WZ5_HUE_FIELD="wz5_color_hue"
local WZ5_SATURATION_FIELD="wz5_color_saturation"
local WZ5_BRIGHTNESS_FIELD="wz5_color_brightness"
local WZ5_COLOR_TEMPERATURE_RANGE={minimum=2203,maximum=4000}
local function wz5_color_part(value,offset)
if type(value)~="string" or #value < 12 then return nil end
return tonumber(value:sub(offset,offset + 3),16)
end
local function wz5_hue_from_device(value,device)
local degrees=wz5_color_part(value,1)
if degrees==nil then return nil end
local hue=clamp(degrees / 3.6,0,100)
device:set_field(WZ5_HUE_FIELD,hue,{persist=false})
return hue
end
local function wz5_saturation_from_device(value,device)
local raw=wz5_color_part(value,5)
if raw==nil then return nil end
local saturation=clamp(raw / 10,0,100)
device:set_field(WZ5_SATURATION_FIELD,saturation,{persist=false})
return saturation
end
local function wz5_color_brightness_from_device(value,device)
local raw=wz5_color_part(value,9)
if raw==nil then return nil end
local brightness=clamp(round(raw / 10),0,100)
device:set_field(WZ5_BRIGHTNESS_FIELD,brightness,{persist=false})
return brightness
end
local function wz5_white_brightness_from_device(value)
return clamp(round((tonumber(value)or 0)* 255 / 1000),0,254)
end
local function wz5_latest(device,field,capability_id,attribute_name,fallback)
local value=device:get_field(field)
if value==nil and type(device.get_latest_state)=="function" then
value=device:get_latest_state("main",capability_id,attribute_name)
end
local numeric=tonumber(value)
if numeric==nil then return fallback end
return numeric
end
local function wz5_color_payload(device,hue,saturation,brightness)
local degrees=360
local requested_hue=false
local hue_value=tonumber(hue)
if hue_value ~=nil and hue_value ~=0 then
degrees=hue_value * 3.6
requested_hue=true
else
local latest_hue=wz5_latest(device,WZ5_HUE_FIELD,"colorControl","hue",0)
if latest_hue ~=0 then degrees=latest_hue * 3.6 end
end
if requested_hue and degrees >=360 then degrees=359 end
degrees=clamp(round(degrees),0,requested_hue and 359 or 360)
local saturation_raw=1000
local saturation_value=tonumber(saturation)
if saturation_value ~=nil and saturation_value ~=0 then
saturation_raw=round(clamp(saturation_value,0,100)* 10)
else
local latest_saturation=wz5_latest(
device,WZ5_SATURATION_FIELD,"colorControl","saturation",0
)
if latest_saturation ~=0 then
saturation_raw=round(clamp(latest_saturation,0,100)* 10)
end
end
local brightness_raw=1000
local brightness_value=tonumber(brightness)
if brightness_value ~=nil then
brightness_raw=round(clamp(brightness_value,0,100)* 10)
else
local latest_brightness=wz5_latest(
device,WZ5_BRIGHTNESS_FIELD,"switchLevel","level",nil
)
if latest_brightness ~=nil then
brightness_raw=round(clamp(latest_brightness,0,100)* 10)
end
end
device:set_field(WZ5_HUE_FIELD,degrees / 3.6,{persist=false})
device:set_field(WZ5_SATURATION_FIELD,saturation_raw / 10,{persist=false})
device:set_field(WZ5_BRIGHTNESS_FIELD,brightness_raw / 10,{persist=false})
return string.format("%04x%04x%04x",degrees,saturation_raw,brightness_raw)
end
local function wz5_white_brightness_write(_,value)
local brightness=clamp(tonumber(value)or 0,0,254)
return{
{dp=2,datatype=tuya.DP_TYPE_ENUM,value=0},
{dp=3,datatype=tuya.DP_TYPE_VALUE,value=round(brightness * 1000 / 255)},
}
end
local function wz5_standard_brightness_write(_,value)
local brightness=clamp(tonumber(value)or 0,0,100)
return{
{dp=2,datatype=tuya.DP_TYPE_ENUM,value=0},
{dp=3,datatype=tuya.DP_TYPE_VALUE,value=round(brightness * 10)},
}
end
local function wz5_color_write(device,value)
if type(value)~="table" then return nil end
return{
{dp=2,datatype=tuya.DP_TYPE_ENUM,value=1},
{
dp=5,
datatype=tuya.DP_TYPE_STRING,
value=wz5_color_payload(device,value.hue,value.saturation,value.brightness),
},
}
end
local function wz5_color_brightness_write(device,value)
return{
{dp=2,datatype=tuya.DP_TYPE_ENUM,value=1},
{dp=5,datatype=tuya.DP_TYPE_STRING,value=wz5_color_payload(device,nil,nil,value)},
}
end
local function wz5_hue_write(device,value)
return wz5_color_write(device,{
hue=value,
saturation=wz5_latest(device,WZ5_SATURATION_FIELD,"colorControl","saturation",100),
})
end
local function wz5_saturation_write(device,value)
return wz5_color_write(device,{
hue=wz5_latest(device,WZ5_HUE_FIELD,"colorControl","hue",0),
saturation=value,
})
end
local function wz5_color_temperature_from_device(value)
local raw=clamp(tonumber(value)or 0,0,1000)
local mired=round(454 + raw *(250 - 454)/ 1000)
if mired <=0 then return nil end
return round(1000000 / mired)
end
local function wz5_color_temperature_write(_,value)
local kelvin=clamp(tonumber(value)or WZ5_COLOR_TEMPERATURE_RANGE.minimum,
WZ5_COLOR_TEMPERATURE_RANGE.minimum,WZ5_COLOR_TEMPERATURE_RANGE.maximum)
local mired=clamp(round(1000000 / kelvin),250,454)
local raw=round((454 - mired)* 1000 /(454 - 250))
return{
{dp=2,datatype=tuya.DP_TYPE_ENUM,value=0},
{dp=4,datatype=tuya.DP_TYPE_VALUE,value=raw},
}
end
local function wz5_color_temperature_runtime_start(device)
device:emit_component_event(
{id="main"},
capabilities.colorTemperature.colorTemperatureRange({
value=WZ5_COLOR_TEMPERATURE_RANGE,
unit="K",
})
)
return true
end
local function make_wz5_family(options)
local switch_mapping=tuya.dp_on_off(1,{
name="switch",
emit=emit.switch(),
transaction=1,
})
local named_mappings={switch=switch_mapping}
local datapoints={
switch_mapping,
tuya.dp_enum(2,{name="wz5_work_mode",read_only=true}),
}
if options.separate_white then
named_mappings.brightness=wz5_color_brightness_write
named_mappings[options.white_mapping_name]=wz5_white_brightness_write
datapoints[#datapoints + 1]=tuya.dp_numeric(3,{
name=options.white_mapping_name,
read_only=true,
emit=options.white_emitter,
converter=converter.from_only(wz5_white_brightness_from_device),
})
else
named_mappings.brightness=wz5_standard_brightness_write
datapoints[#datapoints + 1]=tuya.dp_numeric(3,{
name="brightness",
read_only=true,
emit=emit.level(),
converter=converter.from_only(function(value)
return clamp(round((tonumber(value)or 0)/ 10),0,100)
end),
})
end
if options.color_temperature then
named_mappings.color_temperature=wz5_color_temperature_write
datapoints[#datapoints + 1]=tuya.dp_numeric(4,{
name="wz5_color_temperature_report",
read_only=true,
emit=emit.color_temperature(),
converter=converter.from_only(wz5_color_temperature_from_device),
})
end
if options.color then
named_mappings.color=wz5_color_write
named_mappings.color_hue=wz5_hue_write
named_mappings.color_saturation=wz5_saturation_write
datapoints[#datapoints + 1]=tuya.dp_string(5,{
name="wz5_color_hue_report",
read_only=true,
emit=emit.color_hue(),
converter=converter.from_only(wz5_hue_from_device),
})
datapoints[#datapoints + 1]=tuya.dp_string(5,{
name="wz5_color_saturation_report",
read_only=true,
emit=emit.color_saturation(),
converter=converter.from_only(wz5_saturation_from_device),
})
datapoints[#datapoints + 1]=tuya.dp_string(5,{
name="wz5_color_brightness_report",
read_only=true,
emit=emit.level(),
converter=converter.from_only(wz5_color_brightness_from_device),
})
end
local family={
profile=options.profile,
magic_packet=false,
query_on_configure=false,
time_start="off",
auto_connection_status=false,
initial_custom_state_query=false,
refresh_state_query=false,
auto_on_before_light_command=false,
named_mapping={named_mappings=named_mappings},
datapoints=datapoints,
}
if options.color_temperature then
family.color_temperature_range=WZ5_COLOR_TEMPERATURE_RANGE
family.runtime_start=wz5_color_temperature_runtime_start
end
return family
end
local wz5_dim=make_wz5_family({profile="lights-dimmer-skydance-wz5-dim"})
register_device_definition(wz5_dim,device_helpers.create_fingerprints("TS0601",{
"_TZE200_6qoazbre",
"_TZE200_fcooykb4",
}))
local wz5_cct=make_wz5_family({
profile="lights-color-temperature-skydance-wz5-cct",
color_temperature=true,
})
register_device_definition(wz5_cct,device_helpers.create_fingerprints("TS0601",{
"_TZE200_2gtsuokt",
"_TZE200_gz3n0tzf",
"_TZE200_na98lvjp",
"_TZE200_nthosjmx",
}))
local wz5_rgb=make_wz5_family({
profile="lights-color-skydance-wz5-rgb",
color=true,
})
register_device_definition(wz5_rgb,device_helpers.create_fingerprints("TS0601",{
"_TZE200_9hghastn",
"_TZE200_9mt3kgn0",
}))
local wz5_rgbw=make_wz5_family({
profile="lights-color-skydance-wz5-rgbw",
color=true,
separate_white=true,
white_mapping_name="wz5_rgbw_white_brightness",
white_emitter=emit.wz5RgbwWhiteBrightness(),
})
register_device_definition(wz5_rgbw,device_helpers.create_fingerprints("TS0601",{
"_TZE200_3thxjahu",
"_TZE200_g9jdneiu",
}))
local wz5_rgbcct=make_wz5_family({
profile="lights-color-temperature-color-skydance-wz5-rgbcct",
color=true,
color_temperature=true,
separate_white=true,
white_mapping_name="wz5_rgbcct_white_brightness",
white_emitter=emit.wz5RgbcctWhiteBrightness(),
})
register_device_definition(wz5_rgbcct,device_helpers.create_fingerprints("TS0601",{
"_TZE200_aa9awrng",
"_TZE200_mde0utnv",
"_TZE204_zhiqbr7l",
}))
local zdms16_brightness=converter.scale_pair(0,1000,0,100)
local zdms16_switch_type=converter.lookup_from_to({
toggle=0,
state=1,
momentary=2,
})
local avatto_zdms16_1={
profile="lights-dimmer-zdms16-1",
tuya.dp_on_off(1,{name="switch",emit=emit.switch()}),
tuya.dp_numeric(2,{name="brightness",emit=emit.level(),converter=zdms16_brightness}),
tuya.dp_numeric(3,{name="zdms161_minimum_brightness",emit=emit.zdmsOneMinimumBrightness(),converter=zdms16_brightness}),
tuya.dp_enum(4,{name="zdms161_switch_type",emit=emit.zdmsOneSwitchType(),converter=zdms16_switch_type}),
tuya.dp_numeric(5,{name="zdms161_maximum_brightness",emit=emit.zdmsOneMaximumBrightness(),converter=zdms16_brightness}),
tuya.dp_countdown(6,{name="zdms161_countdown",emit=emit.zdmsOneCountdown()}),
tuya.dp_power_on_behavior(14,{name="zdms161_power_on_behavior",emit=emit.zdmsOnePowerOnBehavior()}),
}
register_device_definition(avatto_zdms16_1,device_helpers.create_fingerprints("TS0601",{
"_TZE28C1000000_nqqylykc",
}))
local siswd11_brightness=converter.from_to(
function(value)
return clamp(round((tonumber(value)or 0)* 100 / 1000),0,100)
end,
function(value)
return clamp(round((tonumber(value)or 0)* 1000 / 100),0,1000)
end
)
local light_model_mercator_siswd11_zb={
profile="lights-dimmer-mercator-siswd11-zb",
query_on_configure=false,
time_start="off",
tuya.dp_on_off(1,{name="switch",emit=emit.switch()}),
tuya.dp_numeric(2,{name="brightness",emit=emit.level(),converter=siswd11_brightness}),
}
register_device_definition(light_model_mercator_siswd11_zb,device_helpers.create_fingerprints("TS0601",{
"_TZE200_jowqowye",
}))
return{
id="ef00.lights.z2m_absorption",
registrations=device_definitions,
}

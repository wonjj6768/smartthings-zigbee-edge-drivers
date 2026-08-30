local custom_capabilities={}
local strings={"mired","paulmannRgbwwStartupCct","paulmann_rgbww_startup_color_temperature","Paulmann Rgbww Startup Cct","candeoRd1pDpmOnLevel","onLevel","candeo_rd1p_dpm_on_level","Candeo Rd1p Dpm On Level","candeoRd1pDpmStartupLevel","startupLevel","candeo_rd1p_dpm_startup_level","Candeo Rd1p Dpm Startup Level","s","candeoRd1pDpmOnTransitionTime","onTransitionTime","candeo_rd1p_dpm_on_transition_time","Candeo Rd1p Dpm On Transition Time","candeoRd1pDpmOffTransitionTime","offTransitionTime","candeo_rd1p_dpm_off_transition_time","Candeo Rd1p Dpm Off Transition Time","shellyDimmerActionGroup","Shelly Dimmer Action Group","shellyDimmerActionLevel","Shelly Dimmer Action Level","shellyDimmerActionTransition","Shelly Dimmer Action Transition","shellyDimmerActionRate","Shelly Dimmer Action Rate","shellyDimmerActionStepSize","Shelly Dimmer Action Step Size","candeoRotaryDimOnLevel","candeoRotaryDim_on_level","Candeo Rotary Dim On Level","candeoRotaryDimStartupLevel","candeoRotaryDim_startup_level","Candeo Rotary Dim Startup Level","candeoRotaryDimOnTransition","onTransition","candeoRotaryDim_on_transition","Candeo Rotary Dim On Transition","candeoRotaryDimOffTransition","offTransition","candeoRotaryDim_off_transition","Candeo Rotary Dim Off Transition","mA","terncyDimRatedCurrent","ratedCurrent","terncyDim_rated_current","Terncy Dim Rated Current","terncyDimStartupCalibration","startupCalibration","terncyDim_startup_calibration","Terncy Dim Startup Calibration","K","terncyDimMinKelvin","minKelvin","terncyDim_min_kelvin","Terncy Dim Min Kelvin","terncyDimMaxKelvin","maxKelvin","terncyDim_max_kelvin","Terncy Dim Max Kelvin","paulmannRgbwwPowerOnBehavior","paulmann_rgbww_power_on_behavior","Paulmann Rgbww Power On Behavior","off","on","toggle","previous","paulmannRgbwwEffect","paulmann_rgbww_effect","Paulmann Rgbww Effect","blink","breathe","okay","channel_change","finish_effect","stop_effect","colorloop","stop_colorloop","candeoRd1pDpmAction","dpmAction","candeo_rd1p_dpm_action","Candeo Rd1p Dpm Action","pressed","double_pressed","held","released","started_rotating_left","started_rotating_right","rotating_right","rotating_left","stopped_rotating","candeoRd1pDpmPowerBehavior","powerOnBehavior","candeo_rd1p_dpm_power_on_behavior","Candeo Rd1p Dpm Power Behavior","shellyDimmerAction","shelly_dimmer_action","Shelly Dimmer Action","on_2","on_3","on_4","off_2","off_3","off_4","toggle_2","toggle_3","toggle_4","brightness_move_to_level_4","brightness_move_up_4","brightness_move_down_4","brightness_step_up_4","brightness_step_down_4","brightness_stop_4","open_4","close_4","stop_4","shellyDimmerDhcpEnabled","shelly_dimmer_dhcp_enabled","Shelly Dimmer Dhcp Enabled","false","true","shellyDimmerWifiEnabled","shelly_dimmer_wifi_enabled","Shelly Dimmer Wifi Enabled","shellyDimmerPowerOnBehavior","shelly_dimmer_power_on_behavior","Shelly Dimmer Power On Behavior","shellyDimmerEffect","shelly_dimmer_effect","Shelly Dimmer Effect","candeoRotaryDimAction","action","candeoRotaryDim_action","Candeo Rotary Dim Action","candeoRotaryDimExtraCommands","extraCommands","candeoRotaryDim_extra_commands","Candeo Rotary Dim Extra Commands","ON","OFF","candeoRotaryDimPowerBehavior","powerBehavior","candeoRotaryDim_power_behavior","Candeo Rotary Dim Power Behavior","terncyDimIoReversed","ioReversed","terncyDim_io_reversed","Terncy Dim Io Reversed","terncyDimLightCurve","lightCurve","terncyDim_light_curve","Terncy Dim Light Curve","fast_start","uniform","slow_start","last_power_response_time","lastPowerResponseTime","Last power response time","shellyDimmerWifiStatus","shelly_dimmer_wifi_status","Shelly Dimmer Wifi Status","shellyDimmerIpAddress","shelly_dimmer_ip_address","Shelly Dimmer Ip Address","shellyDimmerWifiSsid","shelly_dimmer_wifi_ssid","Shelly Dimmer Wifi Ssid","shellyDimmerWifiPassword","shelly_dimmer_wifi_password","Shelly Dimmer Wifi Password","shellyDimmerStaticIp","shelly_dimmer_static_ip","Shelly Dimmer Static Ip","shellyDimmerNetMask","shelly_dimmer_net_mask","Shelly Dimmer Net Mask","shellyDimmerGateway","shelly_dimmer_gateway","Shelly Dimmer Gateway","shellyDimmerNameServer","shelly_dimmer_name_server","Shelly Dimmer Name Server"}
local function string_value(value)
if type(value)=="number" then return strings[value]end
return value
end
local function capability_id(value)local suffix=string_value(value);if suffix==nil then return nil end;return "concertmirror08464." .. suffix end
local table_groups={}
local function grouped_table(group_id)
if type(group_id)~="number" then return{}end
local existing=table_groups[group_id]
if existing ~=nil then return existing end
local out={}
table_groups[group_id]=out
return out
end
local function string_list(values,group_id)
if type(values)~="table" then return nil end
local out=grouped_table(group_id)
for index,value in ipairs(values)do out[index]=string_value(value)end
return out
end
local function optional_string(value,default)
if value==nil then return default end
if value==0 then return nil end
return string_value(value)
end
local function command_default(attribute_name)
if type(attribute_name)~="string" or attribute_name=="" then return nil end
return "set" .. attribute_name:sub(1,1):upper().. attribute_name:sub(2)
end
local function range(value)
if type(value)~="table" then return nil end
local out=grouped_table(value[6])
out.minimum=value[1]
out.maximum=value[2]
out.step=value[3]
out.unit=string_value(value[4])
out.allowed_values=string_list(value[5],value[7])
return out
end
local function allowed_range(allowed_values,group_id)
if allowed_values==nil and group_id==nil then return nil end
local out=grouped_table(group_id)
out.allowed_values=allowed_values
return out
end
local function numeric(row)
local attribute_name=string_value(row[4])
return{kind="numeric",emit_name=string_value(row[1]),range_key=string_value(row[2]),capability_id=capability_id(row[3]),attribute_name=attribute_name,range_attribute_name=string_value(row[5]),command_name=optional_string(row[6],command_default(attribute_name)),argument_name=optional_string(row[7],attribute_name),mapping_name=string_value(row[8]),label=string_value(row[9]),default_range=range(row[10]),event_minimum=row[11],event_maximum=row[12],event_unit=string_value(row[13])}
end
local function enum(row)
local attribute_name=string_value(row[4])
local supported_values=string_list(row[10],row[12])
local default_allowed_values=string_list(row[11],row[14])
local default_range=allowed_range(default_allowed_values,row[13])
return{kind="enum",emit_name=string_value(row[1]),range_key=string_value(row[2]),capability_id=capability_id(row[3]),attribute_name=attribute_name,supported_attribute_name=string_value(row[5]),command_name=optional_string(row[6],command_default(attribute_name)),argument_name=optional_string(row[7],attribute_name),mapping_name=string_value(row[8]),label=string_value(row[9]),supported_values=supported_values,default_range=default_range}
end
local function text(row)
local attribute_name=string_value(row[3])
return{kind="text",emit_name=string_value(row[1]),capability_id=capability_id(row[2]),attribute_name=attribute_name,command_name=optional_string(row[4],command_default(attribute_name)),argument_name=optional_string(row[5],attribute_name),mapping_name=string_value(row[6]),label=string_value(row[7]),maximum_length=row[8]}
end
local function build(rows,factory)
local out={}
for _,row in ipairs(rows)do out[#out + 1]=factory(row)end
return out
end
custom_capabilities.numeric=build({{2,nil,2,2,nil,nil,nil,3,4,{153,65535,1,1,nil,1,nil},nil,nil,1},{5,nil,5,6,nil,nil,nil,7,8,{0,255,1,nil,nil,2,nil},nil,nil,nil},{9,nil,9,10,nil,nil,nil,11,12,{0,255,1,nil,nil,3,nil},nil,nil,nil},{14,nil,14,15,nil,nil,nil,16,17,{0,6553.5,0.1,13,nil,4,nil},nil,nil,13},{18,nil,18,19,nil,nil,nil,20,21,{0,6553.5,0.1,13,nil,5,nil},nil,nil,13},{22,nil,22,22,nil,0,0,22,23,{1,65527,1,nil,nil,6,nil},nil,nil,nil},{24,nil,24,24,nil,0,0,24,25,{0,255,1,nil,nil,7,nil},nil,nil,nil},{26,nil,26,26,nil,0,0,26,27,{0,6553.5,0.1,13,nil,8,nil},nil,nil,13},{28,nil,28,28,nil,0,0,28,29,{0,255,1,nil,nil,9,nil},nil,nil,nil},{30,nil,30,30,nil,0,0,30,31,{0,255,1,nil,nil,10,nil},nil,nil,nil},{32,nil,32,6,nil,nil,nil,33,34,{0,255,1,nil,nil,11,nil},nil,nil,nil},{35,nil,35,10,nil,nil,nil,36,37,{0,255,1,nil,nil,12,nil},nil,nil,nil},{38,nil,38,39,nil,nil,nil,40,41,{0,6553.5,0.1,13,nil,13,nil},nil,nil,13},{42,nil,42,43,nil,nil,nil,44,45,{0,6553.5,0.1,13,nil,14,nil},nil,nil,13},{47,nil,47,48,nil,nil,nil,49,50,{120,4950,1,46,nil,15,nil},nil,nil,46},{51,nil,51,52,nil,nil,nil,53,54,{0,5000,1,nil,nil,16,nil},nil,nil,nil},{56,nil,56,57,nil,nil,nil,58,59,{1000,10000,1,55,nil,17,nil},nil,nil,55},{60,nil,60,61,nil,nil,nil,62,63,{1000,10000,1,55,nil,18,nil},nil,nil,55}},numeric)
custom_capabilities.enum=build({{64,nil,64,64,nil,nil,nil,65,66,{67,68,69,70},{67,68,69,70},19,20,19},{71,nil,71,71,nil,nil,nil,72,73,{74,75,76,77,78,79,80,81},{74,75,76,77,78,79,80,81},21,22,21},{82,nil,82,83,nil,0,0,84,85,{86,87,88,89,90,91,92,93,94},{86,87,88,89,90,91,92,93,94},23,24,23},{95,nil,95,96,nil,nil,nil,97,98,{67,68,69,70},{67,68,69,70},25,26,25},{99,nil,99,99,nil,0,0,100,101,{102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119},{102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119},27,28,27},{120,nil,120,120,nil,0,0,121,122,{123,124},{123,124},29,30,29},{125,nil,125,125,nil,nil,nil,126,127,{123,124},{123,124},31,32,31},{128,nil,128,128,nil,nil,nil,129,130,{67,68,69,70},{67,68,69,70},33,34,33},{131,nil,131,131,nil,nil,nil,132,133,{74,75,76,77,78,79},{74,75,76,77,78,79},35,36,35},{134,nil,134,135,nil,0,0,136,137,{87,88,89},{87,88,89},37,38,37},{138,nil,138,139,nil,nil,nil,140,141,{142,143},{142,143},39,40,39},{144,nil,144,145,nil,nil,nil,146,147,{67,68,69,70},{67,68,69,70},41,42,41},{148,nil,148,149,nil,nil,nil,150,151,{142,143},{142,143},43,44,43},{152,nil,152,153,nil,nil,nil,154,155,{156,157,158},{156,157,158},45,46,45}},enum)
custom_capabilities.text=build({{159,160,160,0,0,nil,161,64},{162,162,162,0,0,163,164,255},{165,165,165,0,0,166,167,255},{168,168,168,nil,nil,169,170,255},{171,171,171,nil,nil,172,173,255},{174,174,174,nil,nil,175,176,255},{177,177,177,nil,nil,178,179,255},{180,180,180,nil,nil,181,182,255},{183,183,183,nil,nil,184,185,255}},text)
custom_capabilities.driver_message={["attribute_name"]="driverMessage",["capability_id"]="concertmirror08464.driverMessage",["emit_name"]="driver_message",["label"]="Driver message",["maximum_length"]=512}
custom_capabilities.by_range_key={}
custom_capabilities.by_emit_name={}
custom_capabilities.by_capability_id={}
local function index_metadata(definitions)
for _,metadata in ipairs(definitions)do
custom_capabilities.by_emit_name[metadata.emit_name]=metadata
if type(metadata.capability_id)=="string" and metadata.capability_id ~="" then custom_capabilities.by_capability_id[metadata.capability_id]=metadata end
if type(metadata.range_key)=="string" and metadata.range_key ~="" then custom_capabilities.by_range_key[metadata.range_key]=metadata end
end
end
index_metadata(custom_capabilities.numeric)
index_metadata(custom_capabilities.enum)
index_metadata(custom_capabilities.text)
custom_capabilities.by_emit_name[custom_capabilities.driver_message.emit_name]=custom_capabilities.driver_message
custom_capabilities.by_capability_id[custom_capabilities.driver_message.capability_id]=custom_capabilities.driver_message
local function clone_allowed_values(allowed_values)
if type(allowed_values)~="table" then return nil end
local copied={}
for index,value in ipairs(allowed_values)do copied[index]=value end
return copied
end
function custom_capabilities.resolve_range(definition,metadata)
if type(metadata)~="table" then return nil end
local default_range=type(metadata.default_range)=="table" and metadata.default_range or nil
local ranges=type(definition)=="table" and definition.presence_capability_ranges or nil
local resolved=type(ranges)=="table" and ranges[metadata.range_key]or nil
if type(resolved)~="table" then resolved=default_range end
if type(resolved)~="table" then return nil end
return{
minimum=type(resolved.minimum)=="number" and resolved.minimum or(default_range and default_range.minimum or nil),
maximum=type(resolved.maximum)=="number" and resolved.maximum or(default_range and default_range.maximum or nil),
step=type(resolved.step)=="number" and resolved.step or(default_range and default_range.step or nil),
unit=type(resolved.unit)=="string" and resolved.unit or(default_range and default_range.unit or nil),
allowed_values=type(resolved.allowed_values)=="table" and clone_allowed_values(resolved.allowed_values)or clone_allowed_values(default_range and default_range.allowed_values or nil),
}
end
return custom_capabilities

local custom_capabilities={}
local strings={"lx","shellyPresenceDarkThreshold","shelly_presence_dark_threshold","Shelly Presence Dark Threshold","shellyPresenceBrightThreshold","shelly_presence_bright_threshold","Shelly Presence Bright Threshold","s","shellyPresencePresenceDelay","shelly_presence_presence_delay","Shelly Presence Presence Delay","shellyPresenceAbsenceDelay","shelly_presence_absence_delay","Shelly Presence Absence Delay","m","shellyPresenceInstallationHeight","shelly_presence_installation_height","Shelly Presence Installation Height","shellyPresenceMinimumRange","shelly_presence_minimum_range","Shelly Presence Minimum Range","shellyPresenceMaximumRange","shelly_presence_maximum_range","Shelly Presence Maximum Range","shellyPresenceTrackedObjects","shelly_presence_tracked_objects","Shelly Presence Tracked Objects","%","shellyPresenceLedBrightness","shelly_presence_led_brightness","Shelly Presence Led Brightness","shellyPresenceNightBrightness","shelly_presence_night_mode_brightness","Shelly Presence Night Brightness","shellyPresenceDetectionPoints","shelly_presence_detection_points","Shelly Presence Detection Points","shellyPresenceVelocityThreshold","shelly_presence_velocity_threshold","Shelly Presence Velocity Threshold","shellyPresenceSnrThreshold","shelly_presence_snr_threshold","Shelly Presence Snr Threshold","shellyPresenceMaxVelocityDiff","shelly_presence_maximum_velocity_difference","Shelly Presence Max Velocity Diff","shellyPresenceMotionActThreshold","shelly_presence_motion_activation_threshold","Shelly Presence Motion Act Threshold","shellyPresenceMotionRelThreshold","shelly_presence_motion_release_threshold","Shelly Presence Motion Rel Threshold","shellyPresenceTrackingLoss","shelly_presence_tracking_loss_threshold","Shelly Presence Tracking Loss","shellyPresenceStillTrackLimit","shelly_presence_stillness_tracking_threshold","Shelly Presence Still Track Limit","shellyPresenceStillTimeoutLimit","shelly_presence_stillness_timeout_threshold","Shelly Presence Still Timeout Limit","linknLinkEmotionAirActionGroup","Linkn Link Emotion Air Action Group","linknLinkEmotionAirActionLevel","Linkn Link Emotion Air Action Level","linknAirActionTransition","Linkn Air Action Transition","linknLinkEmotionAirActionRate","Linkn Link Emotion Air Action Rate","linknAirActionStepSize","Linkn Air Action Step Size","μg/m^3","heimanEfThreePmTen","pmTen","heiman_ef_three_pm_ten","Heiman Ef Three Pm Ten","heimanEfThreeAqi","aqi","heiman_ef_three_aqi","Heiman Ef Three Aqi","tuyaTs0210Sensitivity","sensitivity","tuya_ts0210_sensitivity","Tuya Ts0210Sensitivity","battery_low","batteryLow","Battery low","normal","low","linknLinkEmotionAirAction","linknlink_emotion_air_action","Linkn Link Emotion Air Action","on","off","toggle","brightness_move_to_level","brightness_move_up","brightness_move_down","brightness_step_up","brightness_step_down","brightness_stop","shellyPresenceLightLevel","shelly_presence_light_level","Shelly Presence Light Level","dark","twilight","bright","shellyPresenceSensorPosition","shelly_presence_sensor_position","Shelly Presence Sensor Position","center","left","right","shellyPresenceSensorFlipped","shelly_presence_sensor_flipped","Shelly Presence Sensor Flipped","false","true","shellyPresenceSensitivity","shelly_presence_sensitivity","Shelly Presence Sensitivity","medium","high","custom","shellyPresenceRadarPower","shelly_presence_radar_power","Shelly Presence Radar Power","shellyPresenceNightMode","shelly_presence_night_mode","Shelly Presence Night Mode","shellyPresenceEcoMode","shelly_presence_eco_mode","Shelly Presence Eco Mode","shellyPresenceIdentify","shelly_presence_identify","Shelly Presence Identify","identify","shellyPresenceDhcpEnabled","shelly_presence_dhcp_enabled","Shelly Presence Dhcp Enabled","shellyPresenceWifiEnabled","shelly_presence_wifi_enabled","Shelly Presence Wifi Enabled","heimanEfThreeChargingStatus","chargingStatus","heiman_ef_three_charging_status","Heiman Ef Three Charging Status","NotCharged","Charging","FullyCharged","last_power_response_time","lastPowerResponseTime","Last power response time","shellyPresenceWifiStatus","shelly_presence_wifi_status","Shelly Presence Wifi Status","shellyPresenceIpAddress","shelly_presence_ip_address","Shelly Presence Ip Address","shellyPresenceWifiSsid","shelly_presence_wifi_ssid","Shelly Presence Wifi Ssid","shellyPresenceWifiPassword","shelly_presence_wifi_password","Shelly Presence Wifi Password","shellyPresenceStaticIp","shelly_presence_static_ip","Shelly Presence Static Ip","shellyPresenceNetMask","shelly_presence_net_mask","Shelly Presence Net Mask","shellyPresenceGateway","shelly_presence_gateway","Shelly Presence Gateway","shellyPresenceNameServer","shelly_presence_name_server","Shelly Presence Name Server"}
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
custom_capabilities.numeric=build({{2,nil,2,2,nil,nil,nil,3,4,{0,65535,1,1,nil,1,nil},nil,nil,1},{5,nil,5,5,nil,nil,nil,6,7,{0,65535,1,1,nil,2,nil},nil,nil,1},{9,nil,9,9,nil,nil,nil,10,11,{0,3600,1,8,nil,3,nil},nil,nil,8},{12,nil,12,12,nil,nil,nil,13,14,{0,3600,1,8,nil,4,nil},nil,nil,8},{16,nil,16,16,nil,nil,nil,17,18,{0,5,0.1,15,nil,5,nil},nil,nil,15},{19,nil,19,19,nil,nil,nil,20,21,{0,5,0.1,15,nil,6,nil},nil,nil,15},{22,nil,22,22,nil,nil,nil,23,24,{0,5,0.1,15,nil,7,nil},nil,nil,15},{25,nil,25,25,nil,nil,nil,26,27,{1,10,1,nil,nil,8,nil},nil,nil,nil},{29,nil,29,29,nil,nil,nil,30,31,{0,100,1,28,nil,9,nil},nil,nil,28},{32,nil,32,32,nil,nil,nil,33,34,{0,100,1,28,nil,10,nil},nil,nil,28},{35,nil,35,35,nil,nil,nil,36,37,{10,100,1,nil,nil,11,nil},nil,nil,nil},{38,nil,38,38,nil,nil,nil,39,40,{0,1,0.01,nil,nil,12,nil},nil,nil,nil},{41,nil,41,41,nil,nil,nil,42,43,{10,100,1,nil,nil,13,nil},nil,nil,nil},{44,nil,44,44,nil,nil,nil,45,46,{1,50,1,nil,nil,14,nil},nil,nil,nil},{47,nil,47,47,nil,nil,nil,48,49,{1,100,1,nil,nil,15,nil},nil,nil,nil},{50,nil,50,50,nil,nil,nil,51,52,{1,100,1,nil,nil,16,nil},nil,nil,nil},{53,nil,53,53,nil,nil,nil,54,55,{1,1000,1,nil,nil,17,nil},nil,nil,nil},{56,nil,56,56,nil,nil,nil,57,58,{1,1000,1,nil,nil,18,nil},nil,nil,nil},{59,nil,59,59,nil,nil,nil,60,61,{1,65535,1,nil,nil,19,nil},nil,nil,nil},{62,nil,62,62,nil,0,0,62,63,{1,65527,1,nil,nil,20,nil},nil,nil,nil},{64,nil,64,64,nil,0,0,64,65,{0,255,1,nil,nil,21,nil},nil,nil,nil},{66,nil,66,66,nil,0,0,66,67,{0,6553.5,0.1,8,nil,22,nil},nil,nil,8},{68,nil,68,68,nil,0,0,68,69,{0,255,1,nil,nil,23,nil},nil,nil,nil},{70,nil,70,70,nil,0,0,70,71,{0,255,1,nil,nil,24,nil},nil,nil,nil},{73,nil,73,74,nil,0,0,75,76,{0,65535,1,72,nil,25,nil},nil,nil,72},{77,nil,77,78,nil,0,0,79,80,{0,65535,1,nil,nil,26,nil},nil,nil,nil},{81,nil,81,82,nil,nil,nil,83,84,{0,50,1,nil,nil,27,nil},nil,nil,nil}},numeric)
custom_capabilities.enum=build({{85,85,86,86,nil,nil,nil,85,87,{88,89},{88,89},28,29,28},{90,nil,90,90,nil,0,0,91,92,{93,94,95,96,97,98,99,100,101},{93,94,95,96,97,98,99,100,101},30,31,30},{102,nil,102,102,nil,0,0,103,104,{105,106,107},{105,106,107},32,33,32},{108,nil,108,108,nil,nil,nil,109,110,{111,112,113},{111,112,113},34,35,34},{114,nil,114,114,nil,nil,nil,115,116,{117,118},{117,118},36,37,36},{119,nil,119,119,nil,nil,nil,120,121,{89,122,123,124},{89,122,123,124},38,39,38},{125,nil,125,125,nil,nil,nil,126,127,{89,122,123},{89,122,123},40,41,40},{128,nil,128,128,nil,nil,nil,129,130,{117,118},{117,118},42,43,42},{131,nil,131,131,nil,nil,nil,132,133,{117,118},{117,118},44,45,44},{134,nil,134,134,nil,nil,nil,135,136,{137},{137},46,47,46},{138,nil,138,138,nil,0,0,139,140,{117,118},{117,118},48,49,48},{141,nil,141,141,nil,nil,nil,142,143,{117,118},{117,118},50,51,50},{144,nil,144,145,nil,0,0,146,147,{148,149,150},{148,149,150},52,53,52}},enum)
custom_capabilities.text=build({{151,152,152,0,0,nil,153,64},{154,154,154,0,0,155,156,255},{157,157,157,0,0,158,159,255},{160,160,160,nil,nil,161,162,255},{163,163,163,nil,nil,164,165,255},{166,166,166,nil,nil,167,168,255},{169,169,169,nil,nil,170,171,255},{172,172,172,nil,nil,173,174,255},{175,175,175,nil,nil,176,177,255}},text)
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

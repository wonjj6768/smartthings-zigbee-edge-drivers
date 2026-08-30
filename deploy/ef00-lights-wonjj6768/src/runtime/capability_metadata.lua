local custom_capabilities={}
local strings={"s","countdown_timer","countdownTimer","countdownTimerRange","Countdown timer","min_brightness","minimumBrightness","minBrightness","minBrightnessRange","Minimum brightness","max_brightness","maximumBrightness","maxBrightness","maxBrightnessRange","Maximum brightness","%","zdmsOneMinimumBrightness","zdms161_minimum_brightness","Zdms One Minimum Brightness","zdmsOneMaximumBrightness","zdms161_maximum_brightness","Zdms One Maximum Brightness","zdmsOneCountdown","countdown","zdms161_countdown","Zdms One Countdown","zdmsTwoMinimumBrightness","zdms162_minimum_brightness","Zdms Two Minimum Brightness","zdmsTwoMaximumBrightness","zdms162_maximum_brightness","Zdms Two Maximum Brightness","zdmsTwoCountdown","zdms162_countdown","Zdms Two Countdown","countdownTsOneTenHours","Countdown Ts One Ten Hours","ef00Ts0601MinimumBrightness","efTsMinBrightness","Ef00Ts0601Minimum Brightness","ef00Ts0601MaximumBrightness","efTsMaxBrightness","Ef00Ts0601Maximum Brightness","whpb9ytsMaxBrightness","Whpb9yts Max Brightness","whpb9ytsCountdown","Whpb9yts Countdown","p0gzbqctMinBrightness","P0gzbqct Min Brightness","dcnsggvzMinBrightness","Dcnsggvz Min Brightness","dcnsggvzMaxBrightness","Dcnsggvz Max Brightness","dcnsggvzCountdown","Dcnsggvz Countdown","dimmer2gMinBrightnessCh1","Dimmer2g Min Brightness Ch1","dimmer2gMaxBrightnessCh1","Dimmer2g Max Brightness Ch1","dimmer2gCountdownCh1","Dimmer2g Countdown Ch1","dimmer2gMinBrightnessCh2","Dimmer2g Min Brightness Ch2","dimmer2gMaxBrightnessCh2","Dimmer2g Max Brightness Ch2","dimmer2gCountdownCh2","Dimmer2g Countdown Ch2","dimmer3gMinBrightnessCh1","Dimmer3g Min Brightness Ch1","dimmer3gMaxBrightnessCh1","Dimmer3g Max Brightness Ch1","dimmer3gCountdownCh1","Dimmer3g Countdown Ch1","dimmer3gMinBrightnessCh2","Dimmer3g Min Brightness Ch2","dimmer3gMaxBrightnessCh2","Dimmer3g Max Brightness Ch2","dimmer3gCountdownCh2","Dimmer3g Countdown Ch2","dimmer3gMinBrightnessCh3","Dimmer3g Min Brightness Ch3","dimmer3gMaxBrightnessCh3","Dimmer3g Max Brightness Ch3","dimmer3gCountdownCh3","Dimmer3g Countdown Ch3","dimmer3gBacklightBrightness","backlightBrightness","backlight_brightness","Dimmer3g Backlight Brightness","fanSwitchR32FanSpeed","fanSpeed","fan_speed","Fan Switch R32Fan Speed","fanSwitchR32Countdown","Fan Switch R32Countdown","fanLightLawxFanSpeed","Fan Light Lawx Fan Speed","fanDimmerBqlMinimumSpeed","minimumSpeed","minimum_speed","Fan Dimmer Bql Minimum Speed","h","fanCeilingZ5jzCountdownHours","countdownHours","countdown_hours","Fan Ceiling Z5jz Countdown Hours","indicator_mode","indicatorMode","supportedIndicatorModes","Indicator mode","off","off/on","on/off","on","power_on_behavior","powerOnBehavior","supportedPowerOnBehaviors","Power on behavior","previous","switch_type","switchType","supportedSwitchTypes","Switch type","toggle","state","momentary","light_type","lightType","supportedLightTypes","Light type","led","incandescent","halogen","zdmsOneSwitchType","zdms161_switch_type","Zdms One Switch Type","zdmsOnePowerOnBehavior","zdms161_power_on_behavior","Zdms One Power On Behavior","zdmsTwoSwitchType","zdms162_switch_type","Zdms Two Switch Type","zdmsTwoPowerOnBehavior","zdms162_power_on_behavior","Zdms Two Power On Behavior","la2c2uo9BacklightMode","backlightMode","la2c2uo9_backlight_mode","La2c2uo9Backlight Mode","normal","inverted","whpb9ytsLightType","Whpb9yts Light Type","whpb9ytsPowerOnBehavior","Whpb9yts Power On Behavior","whpb9ytsBacklightMode","backlight_mode","Whpb9yts Backlight Mode","qzaing2gBacklightMode","Qzaing2g Backlight Mode","qzaing2gChildLock","childLock","child_lock","Qzaing2g Child Lock","unlocked","locked","p0gzbqctLightType","P0gzbqct Light Type","p0gzbqctIndicatorMode","P0gzbqct Indicator Mode","none","relay","pos","dcnsggvzLightType","Dcnsggvz Light Type","dcnsggvzPowerOnBehavior","Dcnsggvz Power On Behavior","dcnsggvzSwitchType","Dcnsggvz Switch Type","ts0601LightPowerOnBehavior","Ts0601Light Power On Behavior","dimmer2gLightTypeCh1","Dimmer2g Light Type Ch1","dimmer2gLightTypeCh2","Dimmer2g Light Type Ch2","dimmer2gPowerOnBehavior","Dimmer2g Power On Behavior","dimmer3gLightTypeCh1","Dimmer3g Light Type Ch1","dimmer3gLightTypeCh2","Dimmer3g Light Type Ch2","dimmer3gLightTypeCh3","Dimmer3g Light Type Ch3","dimmer3gPowerOnBehavior","Dimmer3g Power On Behavior","dimmer3gBacklightMode","Dimmer3g Backlight Mode","dimmer3gBacklightColor","backlightColor","backlight_color","Dimmer3g Backlight Color","red","blue","green","white","yellow","magenta","cyan","warm_white","fanSwitchR32PowerOnBehavior","Fan Switch R32Power On Behavior","fanLightHmqzPowerOnBehavior","Fan Light Hmqz Power On Behavior","fanDimmerBqlPowerOnBehavior","Fan Dimmer Bql Power On Behavior","fanDimmerBqlIndicator","indicator","Fan Dimmer Bql Indicator","off_on","fanDimmerBqlBacklight","backlight","Fan Dimmer Bql Backlight","fanDimmerBqlChildLock","Fan Dimmer Bql Child Lock","fanCeilingZ5jzPowerOnBehavior","Fan Ceiling Z5jz Power On Behavior","restore","fanCeilingZ5jzLightMode","lightMode","light_mode","Fan Ceiling Z5jz Light Mode","last_power_response_time","lastPowerResponseTime","Last power response time"}
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
custom_capabilities.numeric=build({{2,2,3,3,4,nil,nil,2,5,{0,43200,1,1,nil,1,nil},0,43200,1},{6,6,7,8,9,nil,nil,6,10,{1,1000,1,nil,nil,2,nil},1,1000,nil},{11,11,12,13,14,nil,nil,11,15,{1,1000,1,nil,nil,3,nil},1,1000,nil},{17,nil,17,7,nil,nil,nil,18,19,{0,100,1,16,nil,4,nil},nil,nil,16},{20,nil,20,12,nil,nil,nil,21,22,{0,100,1,16,nil,5,nil},nil,nil,16},{23,nil,23,24,nil,nil,nil,25,26,{0,43200,1,1,nil,6,nil},nil,nil,1},{27,nil,27,7,nil,nil,nil,28,29,{0,100,1,16,nil,7,nil},nil,nil,16},{30,nil,30,12,nil,nil,nil,31,32,{0,100,1,16,nil,8,nil},nil,nil,16},{33,nil,33,24,nil,nil,nil,34,35,{0,43200,1,1,nil,9,nil},nil,nil,1},{36,nil,36,36,nil,nil,nil,2,37,{0,43200,1,1,nil,10,nil},nil,nil,1},{38,nil,38,39,nil,nil,nil,6,40,{0,1000,1,nil,nil,11,nil},nil,nil,nil},{41,nil,41,42,nil,nil,nil,11,43,{0,1000,1,nil,nil,12,nil},nil,nil,nil},{44,nil,44,13,nil,nil,nil,11,45,{0,1000,1,nil,nil,13,nil},nil,nil,nil},{46,nil,46,24,nil,nil,nil,24,47,{0,43200,1,1,nil,14,nil},nil,nil,1},{48,nil,48,8,nil,nil,nil,6,49,{0,1000,1,nil,nil,15,nil},nil,nil,nil},{50,nil,50,8,nil,nil,nil,6,51,{0,1000,1,nil,nil,16,nil},nil,nil,nil},{52,nil,52,13,nil,nil,nil,11,53,{0,1000,1,nil,nil,17,nil},nil,nil,nil},{54,nil,54,24,nil,nil,nil,24,55,{0,43200,1,1,nil,18,nil},nil,nil,1},{56,nil,56,8,nil,nil,nil,6,57,{0,1000,1,nil,nil,19,nil},nil,nil,nil},{58,nil,58,13,nil,nil,nil,11,59,{0,1000,1,nil,nil,20,nil},nil,nil,nil},{60,nil,60,24,nil,nil,nil,24,61,{0,43200,1,1,nil,21,nil},nil,nil,1},{62,nil,62,8,nil,nil,nil,6,63,{0,1000,1,nil,nil,22,nil},nil,nil,nil},{64,nil,64,13,nil,nil,nil,11,65,{0,1000,1,nil,nil,23,nil},nil,nil,nil},{66,nil,66,24,nil,nil,nil,24,67,{0,43200,1,1,nil,24,nil},nil,nil,1},{68,nil,68,8,nil,nil,nil,6,69,{0,1000,1,nil,nil,25,nil},nil,nil,nil},{70,nil,70,13,nil,nil,nil,11,71,{0,1000,1,nil,nil,26,nil},nil,nil,nil},{72,nil,72,24,nil,nil,nil,24,73,{0,43200,1,1,nil,27,nil},nil,nil,1},{74,nil,74,8,nil,nil,nil,6,75,{0,1000,1,nil,nil,28,nil},nil,nil,nil},{76,nil,76,13,nil,nil,nil,11,77,{0,1000,1,nil,nil,29,nil},nil,nil,nil},{78,nil,78,24,nil,nil,nil,24,79,{0,43200,1,1,nil,30,nil},nil,nil,1},{80,nil,80,8,nil,nil,nil,6,81,{0,1000,1,nil,nil,31,nil},nil,nil,nil},{82,nil,82,13,nil,nil,nil,11,83,{0,1000,1,nil,nil,32,nil},nil,nil,nil},{84,nil,84,24,nil,nil,nil,24,85,{0,43200,1,1,nil,33,nil},nil,nil,1},{86,nil,86,87,nil,nil,nil,88,89,{0,1000,1,nil,nil,34,nil},nil,nil,nil},{90,nil,90,91,nil,nil,nil,92,93,{1,5,1,nil,nil,35,nil},nil,nil,nil},{94,nil,94,24,nil,nil,nil,24,95,{0,43200,1,1,nil,36,nil},nil,nil,1},{96,nil,96,91,nil,nil,nil,92,97,{1,5,1,nil,nil,37,nil},nil,nil,nil},{98,nil,98,99,nil,nil,nil,100,101,{0,100,1,16,nil,38,nil},nil,nil,16},{103,nil,103,104,nil,nil,nil,105,106,{0.25,12,0.25,102,nil,39,nil},nil,nil,102}},numeric)
custom_capabilities.enum=build({{107,107,108,108,109,nil,nil,107,110,{111,112,113,114},{111,112,113,114},40,41,40},{115,115,116,116,117,nil,nil,115,118,{111,114,119},{111,114,119},42,43,42},{120,120,121,121,122,nil,nil,120,123,{124,125,126},{124,125,126},44,45,44},{127,127,128,128,129,nil,nil,127,130,{131,132,133},{131,132,133},46,47,46},{134,nil,134,121,nil,nil,nil,135,136,{124,125,126},{124,125,126},48,49,48},{137,nil,137,116,nil,nil,nil,138,139,{111,114,119},{111,114,119},50,51,50},{140,nil,140,121,nil,nil,nil,141,142,{124,125,126},{124,125,126},52,53,52},{143,nil,143,116,nil,nil,nil,144,145,{111,114,119},{111,114,119},54,55,54},{146,nil,146,147,nil,nil,nil,148,149,{111,150,151},{111,150,151},56,57,56},{152,nil,152,128,nil,nil,nil,127,153,{131,132,133},{131,132,133},58,59,58},{154,nil,154,116,nil,nil,nil,115,155,{111,114,119},{111,114,119},60,61,60},{156,nil,156,147,nil,nil,nil,157,158,{111,150,151},{111,150,151},62,63,62},{159,nil,159,147,nil,nil,nil,157,160,{111,114},{111,114},64,65,64},{161,nil,161,162,nil,nil,nil,163,164,{165,166},{165,166},66,67,66},{167,nil,167,128,nil,nil,nil,127,168,{131,132,133},{131,132,133},68,69,68},{169,nil,169,108,nil,nil,nil,107,170,{171,172,173},{171,172,173},70,71,70},{174,nil,174,128,nil,nil,nil,127,175,{131,132,133},{131,132,133},72,73,72},{176,nil,176,116,nil,nil,nil,115,177,{111,114,119},{111,114,119},74,75,74},{178,nil,178,121,nil,nil,nil,120,179,{124,125,126},{124,125,126},76,77,76},{180,nil,180,116,nil,nil,nil,115,181,{111,114,119},{111,114,119},78,79,78},{182,nil,182,128,nil,nil,nil,127,183,{131,132,133},{131,132,133},80,81,80},{184,nil,184,128,nil,nil,nil,127,185,{131,132,133},{131,132,133},82,83,82},{186,nil,186,116,nil,nil,nil,115,187,{111,114,119},{111,114,119},84,85,84},{188,nil,188,128,nil,nil,nil,127,189,{131,132,133},{131,132,133},86,87,86},{190,nil,190,128,nil,nil,nil,127,191,{131,132,133},{131,132,133},88,89,88},{192,nil,192,128,nil,nil,nil,127,193,{131,132,133},{131,132,133},90,91,90},{194,nil,194,116,nil,nil,nil,115,195,{111,114,119},{111,114,119},92,93,92},{196,nil,196,147,nil,nil,nil,157,197,{111,150,151},{111,150,151},94,95,94},{198,nil,198,199,nil,nil,nil,200,201,{202,203,204,205,206,207,208,209},{202,203,204,205,206,207,208,209},96,97,96},{210,nil,210,116,nil,nil,nil,115,211,{111,114},{111,114},98,99,98},{212,nil,212,116,nil,nil,nil,115,213,{111,114},{111,114},100,101,100},{214,nil,214,116,nil,nil,nil,115,215,{111,114,119},{111,114,119},102,103,102},{216,nil,216,217,nil,nil,nil,107,218,{111,219,114},{111,219,114},104,105,104},{220,nil,220,221,nil,nil,nil,221,222,{111,114},{111,114},106,107,106},{223,nil,223,162,nil,nil,nil,163,224,{111,114},{111,114},108,109,108},{225,nil,225,116,nil,nil,nil,115,226,{111,114,227},{111,114,227},110,111,110},{228,nil,228,229,nil,nil,nil,230,231,{171,172,173},{171,172,173},112,113,112}},enum)
custom_capabilities.text=build({{232,233,233,0,0,nil,234,64}},text)
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

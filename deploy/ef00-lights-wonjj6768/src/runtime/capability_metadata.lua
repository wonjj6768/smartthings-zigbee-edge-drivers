local custom_capabilities={}
local strings={"min_brightness","minimumBrightness","minBrightness","minBrightnessRange","Minimum brightness","max_brightness","maximumBrightness","maxBrightness","maxBrightnessRange","Maximum brightness","%","zdmsOneMinimumBrightness","zdms161_minimum_brightness","Zdms One Minimum Brightness","zdmsOneMaximumBrightness","zdms161_maximum_brightness","Zdms One Maximum Brightness","s","zdmsOneCountdown","countdown","zdms161_countdown","Zdms One Countdown","zdmsTwoMinimumBrightness","zdms162_minimum_brightness","Zdms Two Minimum Brightness","zdmsTwoMaximumBrightness","zdms162_maximum_brightness","Zdms Two Maximum Brightness","zdmsTwoCountdown","zdms162_countdown","Zdms Two Countdown","whpb9ytsMaxBrightness","Whpb9yts Max Brightness","whpb9ytsCountdown","Whpb9yts Countdown","p0gzbqctMinBrightness","P0gzbqct Min Brightness","dcnsggvzMinBrightness","Dcnsggvz Min Brightness","dcnsggvzMaxBrightness","Dcnsggvz Max Brightness","dcnsggvzCountdown","Dcnsggvz Countdown","dimmer2gMinBrightnessCh1","Dimmer2g Min Brightness Ch1","dimmer2gMaxBrightnessCh1","Dimmer2g Max Brightness Ch1","dimmer2gCountdownCh1","Dimmer2g Countdown Ch1","dimmer2gMinBrightnessCh2","Dimmer2g Min Brightness Ch2","dimmer2gMaxBrightnessCh2","Dimmer2g Max Brightness Ch2","dimmer2gCountdownCh2","Dimmer2g Countdown Ch2","dimmer3gMinBrightnessCh1","Dimmer3g Min Brightness Ch1","dimmer3gMaxBrightnessCh1","Dimmer3g Max Brightness Ch1","dimmer3gCountdownCh1","Dimmer3g Countdown Ch1","dimmer3gMinBrightnessCh2","Dimmer3g Min Brightness Ch2","dimmer3gMaxBrightnessCh2","Dimmer3g Max Brightness Ch2","dimmer3gCountdownCh2","Dimmer3g Countdown Ch2","dimmer3gMinBrightnessCh3","Dimmer3g Min Brightness Ch3","dimmer3gMaxBrightnessCh3","Dimmer3g Max Brightness Ch3","dimmer3gCountdownCh3","Dimmer3g Countdown Ch3","dimmer3gBacklightBrightness","backlightBrightness","backlight_brightness","Dimmer3g Backlight Brightness","fanSwitchR32FanSpeed","fanSpeed","fan_speed","Fan Switch R32Fan Speed","fanSwitchR32Countdown","Fan Switch R32Countdown","fanLightLawxFanSpeed","Fan Light Lawx Fan Speed","fanDimmerBqlMinimumSpeed","minimumSpeed","minimum_speed","Fan Dimmer Bql Minimum Speed","h","fanCeilingZ5jzCountdownHours","countdownHours","countdown_hours","Fan Ceiling Z5jz Countdown Hours","ionDimmerMin","ion_min_brightness","Ion Dimmer Min","ionDimmerMax","ion_max_brightness","Ion Dimmer Max","ionDimmerCountdown","ion_countdown","Ion Dimmer Countdown","tsd1MinimumBrightness","tsd1_min_brightness","Tsd1Minimum Brightness","tsd1MaximumBrightness","tsd1_max_brightness","Tsd1Maximum Brightness","tsd1Countdown","tsd1_countdown","Tsd1Countdown","la2DimmerCountdown","la2_dimmer_countdown","La2Dimmer Countdown","dfxDimmerCountdown","dfx_dimmer_countdown","Dfx Dimmer Countdown","la2DimmerMinBrightness","la2_dimmer_min_brightness","La2Dimmer Min Brightness","dfxDimmerMinBrightness","dfx_dimmer_min_brightness","Dfx Dimmer Min Brightness","indicator_mode","indicatorMode","supportedIndicatorModes","Indicator mode","off","off/on","on/off","on","power_on_behavior","powerOnBehavior","supportedPowerOnBehaviors","Power on behavior","previous","switch_type","switchType","supportedSwitchTypes","Switch type","toggle","state","momentary","light_type","lightType","supportedLightTypes","Light type","led","incandescent","halogen","zdmsOneSwitchType","zdms161_switch_type","Zdms One Switch Type","zdmsOnePowerOnBehavior","zdms161_power_on_behavior","Zdms One Power On Behavior","zdmsTwoSwitchType","zdms162_switch_type","Zdms Two Switch Type","zdmsTwoPowerOnBehavior","zdms162_power_on_behavior","Zdms Two Power On Behavior","whpb9ytsLightType","Whpb9yts Light Type","whpb9ytsPowerOnBehavior","Whpb9yts Power On Behavior","whpb9ytsBacklightMode","backlightMode","backlight_mode","Whpb9yts Backlight Mode","normal","inverted","qzaing2gBacklightMode","Qzaing2g Backlight Mode","qzaing2gChildLock","childLock","child_lock","Qzaing2g Child Lock","unlocked","locked","p0gzbqctLightType","P0gzbqct Light Type","p0gzbqctIndicatorMode","P0gzbqct Indicator Mode","none","relay","pos","dcnsggvzLightType","Dcnsggvz Light Type","dcnsggvzPowerOnBehavior","Dcnsggvz Power On Behavior","dcnsggvzSwitchType","Dcnsggvz Switch Type","ts0601LightPowerOnBehavior","Ts0601Light Power On Behavior","dimmer2gLightTypeCh1","Dimmer2g Light Type Ch1","dimmer2gLightTypeCh2","Dimmer2g Light Type Ch2","dimmer2gPowerOnBehavior","Dimmer2g Power On Behavior","dimmer3gLightTypeCh1","Dimmer3g Light Type Ch1","dimmer3gLightTypeCh2","Dimmer3g Light Type Ch2","dimmer3gLightTypeCh3","Dimmer3g Light Type Ch3","dimmer3gPowerOnBehavior","Dimmer3g Power On Behavior","dimmer3gBacklightMode","Dimmer3g Backlight Mode","dimmer3gBacklightColor","backlightColor","backlight_color","Dimmer3g Backlight Color","red","blue","green","white","yellow","magenta","cyan","warm_white","fanSwitchR32PowerOnBehavior","Fan Switch R32Power On Behavior","fanLightHmqzPowerOnBehavior","Fan Light Hmqz Power On Behavior","fanDimmerBqlPowerOnBehavior","Fan Dimmer Bql Power On Behavior","fanDimmerBqlIndicator","indicator","Fan Dimmer Bql Indicator","off_on","fanDimmerBqlBacklight","backlight","Fan Dimmer Bql Backlight","fanDimmerBqlChildLock","Fan Dimmer Bql Child Lock","fanCeilingZ5jzPowerOnBehavior","Fan Ceiling Z5jz Power On Behavior","restore","fanCeilingZ5jzLightMode","lightMode","light_mode","Fan Ceiling Z5jz Light Mode","ionDimmerPowerOn","ion_power_on","Ion Dimmer Power On","tsd1LightType","tsd1_light_type","Tsd1Light Type","tsd1PowerOnBehavior","tsd1_power_on_behavior","Tsd1Power On Behavior","tsd1BacklightMode","tsd1_backlight_mode","Tsd1Backlight Mode","la2DimmerLightType","la2_dimmer_light_type","La2Dimmer Light Type","la2DimmerPowerOnBehavior","la2_dimmer_power_on_behavior","La2Dimmer Power On Behavior","la2DimmerBacklightMode","la2_dimmer_backlight_mode","La2Dimmer Backlight Mode","dfxDimmerLightType","dfx_dimmer_light_type","Dfx Dimmer Light Type","dfxDimmerPowerOnBehavior","dfx_dimmer_power_on_behavior","Dfx Dimmer Power On Behavior","last_power_response_time","lastPowerResponseTime","Last power response time"}
local function string_value(value)
if type(value)=="number"then return strings[value]end
return value
end
local function capability_id(value)local suffix=string_value(value);if suffix==nil then return nil end;return"concertmirror08464."..suffix end
local table_groups={}
local function grouped_table(group_id)
if type(group_id)~="number"then return{}end
local existing=table_groups[group_id]
if existing~=nil then return existing end
local out={}
table_groups[group_id]=out
return out
end
local function string_list(values,group_id)
if type(values)~="table"then return nil end
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
if type(attribute_name)~="string"or attribute_name==""then return nil end
return"set"..attribute_name:sub(1,1):upper()..attribute_name:sub(2)
end
local function range(value)
if type(value)~="table"then return nil end
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
for _,row in ipairs(rows)do out[#out+1]=factory(row)end
return out
end
custom_capabilities.numeric=build({{1,1,2,3,4,nil,nil,1,5,{1,1000,1,nil,nil,1,nil},1,1000,nil},{6,6,7,8,9,nil,nil,6,10,{1,1000,1,nil,nil,2,nil},1,1000,nil},{12,nil,12,2,nil,nil,nil,13,14,{0,100,1,11,nil,3,nil},nil,nil,11},{15,nil,15,7,nil,nil,nil,16,17,{0,100,1,11,nil,4,nil},nil,nil,11},{19,nil,19,20,nil,nil,nil,21,22,{0,43200,1,18,nil,5,nil},nil,nil,18},{23,nil,23,2,nil,nil,nil,24,25,{0,100,1,11,nil,6,nil},nil,nil,11},{26,nil,26,7,nil,nil,nil,27,28,{0,100,1,11,nil,7,nil},nil,nil,11},{29,nil,29,20,nil,nil,nil,30,31,{0,43200,1,18,nil,8,nil},nil,nil,18},{32,nil,32,8,nil,nil,nil,6,33,{0,1000,1,nil,nil,9,nil},nil,nil,nil},{34,nil,34,20,nil,nil,nil,20,35,{0,43200,1,18,nil,10,nil},nil,nil,18},{36,nil,36,3,nil,nil,nil,1,37,{0,1000,1,nil,nil,11,nil},nil,nil,nil},{38,nil,38,3,nil,nil,nil,1,39,{0,1000,1,nil,nil,12,nil},nil,nil,nil},{40,nil,40,8,nil,nil,nil,6,41,{0,1000,1,nil,nil,13,nil},nil,nil,nil},{42,nil,42,20,nil,nil,nil,20,43,{0,43200,1,18,nil,14,nil},nil,nil,18},{44,nil,44,3,nil,nil,nil,1,45,{0,1000,1,nil,nil,15,nil},nil,nil,nil},{46,nil,46,8,nil,nil,nil,6,47,{0,1000,1,nil,nil,16,nil},nil,nil,nil},{48,nil,48,20,nil,nil,nil,20,49,{0,43200,1,18,nil,17,nil},nil,nil,18},{50,nil,50,3,nil,nil,nil,1,51,{0,1000,1,nil,nil,18,nil},nil,nil,nil},{52,nil,52,8,nil,nil,nil,6,53,{0,1000,1,nil,nil,19,nil},nil,nil,nil},{54,nil,54,20,nil,nil,nil,20,55,{0,43200,1,18,nil,20,nil},nil,nil,18},{56,nil,56,3,nil,nil,nil,1,57,{0,1000,1,nil,nil,21,nil},nil,nil,nil},{58,nil,58,8,nil,nil,nil,6,59,{0,1000,1,nil,nil,22,nil},nil,nil,nil},{60,nil,60,20,nil,nil,nil,20,61,{0,43200,1,18,nil,23,nil},nil,nil,18},{62,nil,62,3,nil,nil,nil,1,63,{0,1000,1,nil,nil,24,nil},nil,nil,nil},{64,nil,64,8,nil,nil,nil,6,65,{0,1000,1,nil,nil,25,nil},nil,nil,nil},{66,nil,66,20,nil,nil,nil,20,67,{0,43200,1,18,nil,26,nil},nil,nil,18},{68,nil,68,3,nil,nil,nil,1,69,{0,1000,1,nil,nil,27,nil},nil,nil,nil},{70,nil,70,8,nil,nil,nil,6,71,{0,1000,1,nil,nil,28,nil},nil,nil,nil},{72,nil,72,20,nil,nil,nil,20,73,{0,43200,1,18,nil,29,nil},nil,nil,18},{74,nil,74,75,nil,nil,nil,76,77,{0,1000,1,nil,nil,30,nil},nil,nil,nil},{78,nil,78,79,nil,nil,nil,80,81,{1,5,1,nil,nil,31,nil},nil,nil,nil},{82,nil,82,20,nil,nil,nil,20,83,{0,43200,1,18,nil,32,nil},nil,nil,18},{84,nil,84,79,nil,nil,nil,80,85,{1,5,1,nil,nil,33,nil},nil,nil,nil},{86,nil,86,87,nil,nil,nil,88,89,{0,100,1,11,nil,34,nil},nil,nil,11},{91,nil,91,92,nil,nil,nil,93,94,{0.25,12,0.25,90,nil,35,nil},nil,nil,90},{95,nil,95,2,nil,nil,nil,96,97,{0,254,1,nil,nil,36,nil},nil,nil,nil},{98,nil,98,7,nil,nil,nil,99,100,{0,254,1,nil,nil,37,nil},nil,nil,nil},{101,nil,101,20,nil,nil,nil,102,103,{0,43200,1,18,nil,38,nil},nil,nil,18},{104,nil,104,2,nil,nil,nil,105,106,{0,254,1,nil,nil,39,nil},nil,nil,nil},{107,nil,107,7,nil,nil,nil,108,109,{0,254,1,nil,nil,40,nil},nil,nil,nil},{110,nil,110,20,nil,nil,nil,111,112,{0,43200,1,18,nil,41,nil},nil,nil,18},{113,nil,113,20,nil,nil,nil,114,115,{0,43200,1,18,nil,42,nil},nil,nil,18},{116,nil,116,20,nil,nil,nil,117,118,{0,43200,1,18,nil,43,nil},nil,nil,18},{119,nil,119,2,nil,nil,nil,120,121,{0,1000,1,nil,nil,44,nil},nil,nil,nil},{122,nil,122,2,nil,nil,nil,123,124,{0,1000,1,nil,nil,45,nil},nil,nil,nil}},numeric)
custom_capabilities.enum=build({{125,125,126,126,127,nil,nil,125,128,{129,130,131,132},{129,130,131,132},46,47,46},{133,133,134,134,135,nil,nil,133,136,{129,132,137},{129,132,137},48,49,48},{138,138,139,139,140,nil,nil,138,141,{142,143,144},{142,143,144},50,51,50},{145,145,146,146,147,nil,nil,145,148,{149,150,151},{149,150,151},52,53,52},{152,nil,152,139,nil,nil,nil,153,154,{142,143,144},{142,143,144},54,55,54},{155,nil,155,134,nil,nil,nil,156,157,{129,132,137},{129,132,137},56,57,56},{158,nil,158,139,nil,nil,nil,159,160,{142,143,144},{142,143,144},58,59,58},{161,nil,161,134,nil,nil,nil,162,163,{129,132,137},{129,132,137},60,61,60},{164,nil,164,146,nil,nil,nil,145,165,{149,150,151},{149,150,151},62,63,62},{166,nil,166,134,nil,nil,nil,133,167,{129,132,137},{129,132,137},64,65,64},{168,nil,168,169,nil,nil,nil,170,171,{129,172,173},{129,172,173},66,67,66},{174,nil,174,169,nil,nil,nil,170,175,{129,132},{129,132},68,69,68},{176,nil,176,177,nil,nil,nil,178,179,{180,181},{180,181},70,71,70},{182,nil,182,146,nil,nil,nil,145,183,{149,150,151},{149,150,151},72,73,72},{184,nil,184,126,nil,nil,nil,125,185,{186,187,188},{186,187,188},74,75,74},{189,nil,189,146,nil,nil,nil,145,190,{149,150,151},{149,150,151},76,77,76},{191,nil,191,134,nil,nil,nil,133,192,{129,132,137},{129,132,137},78,79,78},{193,nil,193,139,nil,nil,nil,138,194,{142,143,144},{142,143,144},80,81,80},{195,nil,195,134,nil,nil,nil,133,196,{129,132,137},{129,132,137},82,83,82},{197,nil,197,146,nil,nil,nil,145,198,{149,150,151},{149,150,151},84,85,84},{199,nil,199,146,nil,nil,nil,145,200,{149,150,151},{149,150,151},86,87,86},{201,nil,201,134,nil,nil,nil,133,202,{129,132,137},{129,132,137},88,89,88},{203,nil,203,146,nil,nil,nil,145,204,{149,150,151},{149,150,151},90,91,90},{205,nil,205,146,nil,nil,nil,145,206,{149,150,151},{149,150,151},92,93,92},{207,nil,207,146,nil,nil,nil,145,208,{149,150,151},{149,150,151},94,95,94},{209,nil,209,134,nil,nil,nil,133,210,{129,132,137},{129,132,137},96,97,96},{211,nil,211,169,nil,nil,nil,170,212,{129,172,173},{129,172,173},98,99,98},{213,nil,213,214,nil,nil,nil,215,216,{217,218,219,220,221,222,223,224},{217,218,219,220,221,222,223,224},100,101,100},{225,nil,225,134,nil,nil,nil,133,226,{129,132},{129,132},102,103,102},{227,nil,227,134,nil,nil,nil,133,228,{129,132},{129,132},104,105,104},{229,nil,229,134,nil,nil,nil,133,230,{129,132,137},{129,132,137},106,107,106},{231,nil,231,232,nil,nil,nil,125,233,{129,234,132},{129,234,132},108,109,108},{235,nil,235,236,nil,nil,nil,236,237,{129,132},{129,132},110,111,110},{238,nil,238,177,nil,nil,nil,178,239,{129,132},{129,132},112,113,112},{240,nil,240,134,nil,nil,nil,133,241,{129,132,242},{129,132,242},114,115,114},{243,nil,243,244,nil,nil,nil,245,246,{186,187,188},{186,187,188},116,117,116},{247,nil,247,134,nil,nil,nil,248,249,{129,132,137},{129,132,137},118,119,118},{250,nil,250,146,nil,nil,nil,251,252,{149,150,151},{149,150,151},120,121,120},{253,nil,253,134,nil,nil,nil,254,255,{129,132,137},{129,132,137},122,123,122},{256,nil,256,169,nil,nil,nil,257,258,{129,172,173},{129,172,173},124,125,124},{259,nil,259,146,nil,nil,nil,260,261,{149,150,151},{149,150,151},126,127,126},{262,nil,262,134,nil,nil,nil,263,264,{129,132,137},{129,132,137},128,129,128},{265,nil,265,169,nil,nil,nil,266,267,{129,172,173},{129,172,173},130,131,130},{268,nil,268,146,nil,nil,nil,269,270,{149,150,151},{149,150,151},132,133,132},{271,nil,271,134,nil,nil,nil,272,273,{129,132,137},{129,132,137},134,135,134}},enum)
custom_capabilities.text=build({{274,275,275,0,0,nil,276,64}},text)
custom_capabilities.driver_message={["attribute_name"]="driverMessage",["capability_id"]="concertmirror08464.driverMessage",["emit_name"]="driver_message",["label"]="Driver message",["maximum_length"]=512}
custom_capabilities.by_range_key={}
custom_capabilities.by_emit_name={}
custom_capabilities.by_capability_id={}
local function index_metadata(definitions)
for _,metadata in ipairs(definitions)do
custom_capabilities.by_emit_name[metadata.emit_name]=metadata
if type(metadata.capability_id)=="string"and metadata.capability_id~=""then custom_capabilities.by_capability_id[metadata.capability_id]=metadata end
if type(metadata.range_key)=="string"and metadata.range_key~=""then custom_capabilities.by_range_key[metadata.range_key]=metadata end
end
end
index_metadata(custom_capabilities.numeric)
index_metadata(custom_capabilities.enum)
index_metadata(custom_capabilities.text)
custom_capabilities.by_emit_name[custom_capabilities.driver_message.emit_name]=custom_capabilities.driver_message
custom_capabilities.by_capability_id[custom_capabilities.driver_message.capability_id]=custom_capabilities.driver_message
local function clone_allowed_values(allowed_values)
if type(allowed_values)~="table"then return nil end
local copied={}
for index,value in ipairs(allowed_values)do copied[index]=value end
return copied
end
function custom_capabilities.resolve_range(definition,metadata)
if type(metadata)~="table"then return nil end
local default_range=type(metadata.default_range)=="table"and metadata.default_range or nil
local ranges=type(definition)=="table"and definition.presence_capability_ranges or nil
local resolved=type(ranges)=="table"and ranges[metadata.range_key]or nil
if type(resolved)~="table"then resolved=default_range end
if type(resolved)~="table"then return nil end
return{
minimum=type(resolved.minimum)=="number"and resolved.minimum or(default_range and default_range.minimum or nil),
maximum=type(resolved.maximum)=="number"and resolved.maximum or(default_range and default_range.maximum or nil),
step=type(resolved.step)=="number"and resolved.step or(default_range and default_range.step or nil),
unit=type(resolved.unit)=="string"and resolved.unit or(default_range and default_range.unit or nil),
allowed_values=type(resolved.allowed_values)=="table"and clone_allowed_values(resolved.allowed_values)or clone_allowed_values(default_range and default_range.allowed_values or nil),}
end
return custom_capabilities

local custom_capabilities={}
local strings={"%","zdmsOneMinimumBrightness","minimumBrightness","zdms161_minimum_brightness","Zdms One Minimum Brightness","zdmsOneMaximumBrightness","maximumBrightness","zdms161_maximum_brightness","Zdms One Maximum Brightness","s","zdmsOneCountdown","countdown","zdms161_countdown","Zdms One Countdown","wz5RgbwWhiteBrightness","wzFiveRgbwWhiteBrightness","wz5_rgbw_white_brightness","Wz5Rgbw White Brightness","wz5RgbcctWhiteBrightness","wzFiveRgbcctWhiteBrightness","wz5_rgbcct_white_brightness","Wz5Rgbcct White Brightness","moesZsDOneBrightnessOne","brightness","moes_zs_d_one_brightness_one","Moes Zs DOne Brightness One","moesZsDOneBrightnessMinOne","moes_zs_d_one_brightness_min_one","Moes Zs DOne Brightness Min One","moesZsDOneBrightnessMaxOne","moes_zs_d_one_brightness_max_one","Moes Zs DOne Brightness Max One","moesZsDOneCountdownOne","moes_zs_d_one_countdown_one","Moes Zs DOne Countdown One","moesZsDTwoBrightnessOne","moes_zs_d_two_brightness_one","Moes Zs DTwo Brightness One","moesZsDTwoBrightnessMinOne","moes_zs_d_two_brightness_min_one","Moes Zs DTwo Brightness Min One","moesZsDTwoBrightnessMaxOne","moes_zs_d_two_brightness_max_one","Moes Zs DTwo Brightness Max One","moesZsDTwoCountdownOne","moes_zs_d_two_countdown_one","Moes Zs DTwo Countdown One","moesZsDTwoBrightnessTwo","moes_zs_d_two_brightness_two","Moes Zs DTwo Brightness Two","moesZsDTwoBrightnessMinTwo","moes_zs_d_two_brightness_min_two","Moes Zs DTwo Brightness Min Two","moesZsDTwoBrightnessMaxTwo","moes_zs_d_two_brightness_max_two","Moes Zs DTwo Brightness Max Two","moesZsDTwoCountdownTwo","moes_zs_d_two_countdown_two","Moes Zs DTwo Countdown Two","moesZsDThreeBrightnessOne","moes_zs_d_three_brightness_one","Moes Zs DThree Brightness One","moesZsDThreeBrightnessMinOne","moes_zs_d_three_brightness_min_one","Moes Zs DThree Brightness Min One","moesZsDThreeBrightnessMaxOne","moes_zs_d_three_brightness_max_one","Moes Zs DThree Brightness Max One","moesZsDThreeCountdownOne","moes_zs_d_three_countdown_one","Moes Zs DThree Countdown One","moesZsDThreeBrightnessTwo","moes_zs_d_three_brightness_two","Moes Zs DThree Brightness Two","moesZsDThreeBrightnessMinTwo","moes_zs_d_three_brightness_min_two","Moes Zs DThree Brightness Min Two","moesZsDThreeBrightnessMaxTwo","moes_zs_d_three_brightness_max_two","Moes Zs DThree Brightness Max Two","moesZsDThreeCountdownTwo","moes_zs_d_three_countdown_two","Moes Zs DThree Countdown Two","moesZsDThreeBrightnessThree","moes_zs_d_three_brightness_three","Moes Zs DThree Brightness Three","moesZsDThreeBrightnessMinThree","moes_zs_d_three_brightness_min_three","Moes Zs DThree Brightness Min Three","moesZsDThreeBrightnessMaxThree","moes_zs_d_three_brightness_max_three","Moes Zs DThree Brightness Max Three","moesZsDThreeCountdownThree","moes_zs_d_three_countdown_three","Moes Zs DThree Countdown Three","glSpiColorTempRaw","colorTempRaw","gl_spi_color_temp_raw","Gl Spi Color Temp Raw","glSpiMusicSensitivity","musicSensitivity","gl_spi_music_sensitivity","Gl Spi Music Sensitivity","glSpiCountdown","gl_spi_countdown","Gl Spi Countdown","glSpiPixelCount","pixelCount","gl_spi_pixel_count","Gl Spi Pixel Count","avattoWTwoMinBrightness","minBrightness","avattoWTwo_min_brightness","Avatto WTwo Min Brightness","avattoWTwoMaxBrightness","maxBrightness","avattoWTwo_max_brightness","Avatto WTwo Max Brightness","avattoWTwoCountdown","avattoWTwo_countdown","Avatto WTwo Countdown","lonsonhoVmTwoMinBrightness","lonsonhoVmTwo_min_brightness","Lonsonho Vm Two Min Brightness","lonsonhoVmTwoMaxBrightness","lonsonhoVmTwo_max_brightness","Lonsonho Vm Two Max Brightness","lonsonhoVmTwoCountdown","lonsonhoVmTwo_countdown","Lonsonho Vm Two Countdown","qaQadzFourMinBrightness","qaQadzFour_min_brightness","Qa Qadz Four Min Brightness","novaTopazioMinBrightness","novaTopazio_min_brightness","Nova Topazio Min Brightness","novaTopazioMaxBrightness","novaTopazio_max_brightness","Nova Topazio Max Brightness","novaTopazioCountdown","novaTopazio_countdown","Nova Topazio Countdown","zdmsOneSwitchType","switchType","zdms161_switch_type","Zdms One Switch Type","toggle","state","momentary","zdmsOnePowerOnBehavior","powerOnBehavior","zdms161_power_on_behavior","Zdms One Power On Behavior","off","on","previous","moesZsDOneRelayStatus","relayStatus","moes_zs_d_one_relay_status","Moes Zs DOne Relay Status","memory","moesZsDOneLightMode","lightMode","moes_zs_d_one_light_mode","Moes Zs DOne Light Mode","none","relay","pos","moesZsDOneBacklight","backlight","moes_zs_d_one_backlight","Moes Zs DOne Backlight","OFF","ON","moesZsDTwoRelayStatus","moes_zs_d_two_relay_status","Moes Zs DTwo Relay Status","moesZsDTwoLightMode","moes_zs_d_two_light_mode","Moes Zs DTwo Light Mode","moesZsDTwoBacklight","moes_zs_d_two_backlight","Moes Zs DTwo Backlight","moesZsDThreeRelayStatus","moes_zs_d_three_relay_status","Moes Zs DThree Relay Status","moesZsDThreeLightMode","moes_zs_d_three_light_mode","Moes Zs DThree Light Mode","moesZsDThreeBacklight","moes_zs_d_three_backlight","Moes Zs DThree Backlight","glSpiScene","scene","gl_spi_scene","Gl Spi Scene","ice_land_blue","glacier_express","sea_of_clouds","fireworks_at_sea","firefly_night","grass_land","northern_lights","late_autumn","game","holiday","party","trend","meditation","dating","valentines_day","neon_world","glSpiMusicMode","musicMode","gl_spi_music_mode","Gl Spi Music Mode","rock","jazz","classic","rolling","energy","spectrum","glSpiDoNotDisturb","doNotDisturb","gl_spi_do_not_disturb","Gl Spi Do Not Disturb","glSpiBeadSequence","beadSequence","gl_spi_bead_sequence","Gl Spi Bead Sequence","RGB","RBG","GRB","GBR","BRG","BGR","RGBW","RBGW","GRBW","GBRW","BRGW","BGRW","WRGB","WRBG","WGRB","WGBR","WBRG","WBGR","glSpiChipType","chipType","gl_spi_chip_type","Gl Spi Chip Type","WS2801","LPD6803","LPD8803","WS2811","TM1814B","TM1934A","SK6812","SK9822","UCS8904B","WS2805","glSpiWorkMode","workMode","gl_spi_work_mode","Gl Spi Work Mode","white","colour","music","avattoWTwoSwitchType","avattoWTwo_switch_type","Avatto WTwo Switch Type","avattoWTwoPowerBehavior","powerBehavior","avattoWTwo_power_behavior","Avatto WTwo Power Behavior","lonsonhoVmTwoSwitchType","lonsonhoVmTwo_switch_type","Lonsonho Vm Two Switch Type","lonsonhoVmTwoPowerBehavior","lonsonhoVmTwo_power_behavior","Lonsonho Vm Two Power Behavior","qaQadzFourSwitchType","qaQadzFour_switch_type","Qa Qadz Four Switch Type","qaQadzFourDimmingSpeed","dimmingSpeed","qaQadzFour_dimming_speed","Qa Qadz Four Dimming Speed","slow","middle","fast","qaQadzFourPowerBehavior","qaQadzFour_power_behavior","Qa Qadz Four Power Behavior","novaTopazioLightType","lightType","novaTopazio_light_type","Nova Topazio Light Type","led","incandescent","halogen","novaTopazioPowerBehavior","novaTopazio_power_behavior","Nova Topazio Power Behavior","novaTopazioIndicatorMode","indicatorMode","novaTopazio_indicator_mode","Nova Topazio Indicator Mode","novaTopazioBacklight","novaTopazio_backlight","Nova Topazio Backlight","last_power_response_time","lastPowerResponseTime","Last power response time"}
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
custom_capabilities.numeric=build({{2,nil,2,3,nil,nil,nil,4,5,{0,100,1,1,nil,1,nil},nil,nil,1},{6,nil,6,7,nil,nil,nil,8,9,{0,100,1,1,nil,2,nil},nil,nil,1},{11,nil,11,12,nil,nil,nil,13,14,{0,43200,1,10,nil,3,nil},nil,nil,10},{15,nil,15,16,nil,nil,nil,17,18,{0,254,1,nil,nil,4,nil},nil,nil,nil},{19,nil,19,20,nil,nil,nil,21,22,{0,254,1,nil,nil,5,nil},nil,nil,nil},{23,nil,23,24,nil,nil,nil,25,26,{10,1000,1,nil,nil,6,nil},nil,nil,nil},{27,nil,27,3,nil,nil,nil,28,29,{10,1000,1,nil,nil,7,nil},nil,nil,nil},{30,nil,30,7,nil,nil,nil,31,32,{10,1000,1,nil,nil,8,nil},nil,nil,nil},{33,nil,33,12,nil,nil,nil,34,35,{0,86400,1,10,nil,9,nil},nil,nil,10},{36,nil,36,24,nil,nil,nil,37,38,{10,1000,1,nil,nil,10,nil},nil,nil,nil},{39,nil,39,3,nil,nil,nil,40,41,{10,1000,1,nil,nil,11,nil},nil,nil,nil},{42,nil,42,7,nil,nil,nil,43,44,{10,1000,1,nil,nil,12,nil},nil,nil,nil},{45,nil,45,12,nil,nil,nil,46,47,{0,86400,1,10,nil,13,nil},nil,nil,10},{48,nil,48,24,nil,nil,nil,49,50,{10,1000,1,nil,nil,14,nil},nil,nil,nil},{51,nil,51,3,nil,nil,nil,52,53,{10,1000,1,nil,nil,15,nil},nil,nil,nil},{54,nil,54,7,nil,nil,nil,55,56,{10,1000,1,nil,nil,16,nil},nil,nil,nil},{57,nil,57,12,nil,nil,nil,58,59,{0,86400,1,10,nil,17,nil},nil,nil,10},{60,nil,60,24,nil,nil,nil,61,62,{10,1000,1,nil,nil,18,nil},nil,nil,nil},{63,nil,63,3,nil,nil,nil,64,65,{10,1000,1,nil,nil,19,nil},nil,nil,nil},{66,nil,66,7,nil,nil,nil,67,68,{10,1000,1,nil,nil,20,nil},nil,nil,nil},{69,nil,69,12,nil,nil,nil,70,71,{0,86400,1,10,nil,21,nil},nil,nil,10},{72,nil,72,24,nil,nil,nil,73,74,{10,1000,1,nil,nil,22,nil},nil,nil,nil},{75,nil,75,3,nil,nil,nil,76,77,{10,1000,1,nil,nil,23,nil},nil,nil,nil},{78,nil,78,7,nil,nil,nil,79,80,{10,1000,1,nil,nil,24,nil},nil,nil,nil},{81,nil,81,12,nil,nil,nil,82,83,{0,86400,1,10,nil,25,nil},nil,nil,10},{84,nil,84,24,nil,nil,nil,85,86,{10,1000,1,nil,nil,26,nil},nil,nil,nil},{87,nil,87,3,nil,nil,nil,88,89,{10,1000,1,nil,nil,27,nil},nil,nil,nil},{90,nil,90,7,nil,nil,nil,91,92,{10,1000,1,nil,nil,28,nil},nil,nil,nil},{93,nil,93,12,nil,nil,nil,94,95,{0,86400,1,10,nil,29,nil},nil,nil,10},{96,nil,96,97,nil,nil,nil,98,99,{0,1000,nil,nil,nil,30,nil},nil,nil,nil},{100,nil,100,101,nil,nil,nil,102,103,{1,100,nil,nil,nil,31,nil},nil,nil,nil},{104,nil,104,12,nil,nil,nil,105,106,{0,43200,1,10,nil,32,nil},nil,nil,10},{107,nil,107,108,nil,nil,nil,109,110,{10,1000,nil,nil,nil,33,nil},nil,nil,nil},{111,nil,111,112,nil,nil,nil,113,114,{0,100,1,1,nil,34,nil},nil,nil,1},{115,nil,115,116,nil,nil,nil,117,118,{0,100,1,1,nil,35,nil},nil,nil,1},{119,nil,119,12,nil,nil,nil,120,121,{0,43200,1,10,nil,36,nil},nil,nil,10},{122,nil,122,112,nil,nil,nil,123,124,{0,100,1,1,nil,37,nil},nil,nil,1},{125,nil,125,116,nil,nil,nil,126,127,{0,100,1,1,nil,38,nil},nil,nil,1},{128,nil,128,12,nil,nil,nil,129,130,{0,43200,1,10,nil,39,nil},nil,nil,10},{131,nil,131,112,nil,nil,nil,132,133,{0,100,1,1,nil,40,nil},nil,nil,1},{134,nil,134,112,nil,nil,nil,135,136,{1,100,1,1,nil,41,nil},nil,nil,1},{137,nil,137,116,nil,nil,nil,138,139,{1,100,1,1,nil,42,nil},nil,nil,1},{140,nil,140,12,nil,nil,nil,141,142,{0,86400,1,10,nil,43,nil},nil,nil,10}},numeric)
custom_capabilities.enum=build({{143,nil,143,144,nil,nil,nil,145,146,{147,148,149},{147,148,149},44,45,44},{150,nil,150,151,nil,nil,nil,152,153,{154,155,156},{154,155,156},46,47,46},{157,nil,157,158,nil,nil,nil,159,160,{154,155,161},{154,155,161},48,49,48},{162,nil,162,163,nil,nil,nil,164,165,{166,167,168},{166,167,168},50,51,50},{169,nil,169,170,nil,nil,nil,171,172,{173,174},{173,174},52,53,52},{175,nil,175,158,nil,nil,nil,176,177,{154,155,161},{154,155,161},54,55,54},{178,nil,178,163,nil,nil,nil,179,180,{166,167,168},{166,167,168},56,57,56},{181,nil,181,170,nil,nil,nil,182,183,{173,174},{173,174},58,59,58},{184,nil,184,158,nil,nil,nil,185,186,{154,155,161},{154,155,161},60,61,60},{187,nil,187,163,nil,nil,nil,188,189,{166,167,168},{166,167,168},62,63,62},{190,nil,190,170,nil,nil,nil,191,192,{173,174},{173,174},64,65,64},{193,nil,193,194,nil,nil,nil,195,196,{197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212},{197,198,199,200,201,202,203,204,205,206,207,208,209,210,211,212},66,67,66},{213,nil,213,214,nil,nil,nil,215,216,{217,218,219,220,221,222},{217,218,219,220,221,222},68,69,68},{223,nil,223,224,nil,nil,nil,225,226,{174,173},{174,173},70,71,70},{227,nil,227,228,nil,nil,nil,229,230,{231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248},{231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248},72,73,72},{249,nil,249,250,nil,nil,nil,251,252,{253,254,255,256,257,258,259,260,261,262},{253,254,255,256,257,258,259,260,261,262},74,75,74},{263,nil,263,264,nil,nil,nil,265,266,{267,268,194,269},{267,268,194,269},76,77,76},{270,nil,270,144,nil,nil,nil,271,272,{147,148,149},{147,148,149},78,79,78},{273,nil,273,274,nil,nil,nil,275,276,{154,155,156},{154,155,156},80,81,80},{277,nil,277,144,nil,nil,nil,278,279,{149,147,148},{149,147,148},82,83,82},{280,nil,280,274,nil,nil,nil,281,282,{154,155,156},{154,155,156},84,85,84},{283,nil,283,144,nil,nil,nil,284,285,{149,147},{149,147},86,87,86},{286,nil,286,287,nil,nil,nil,288,289,{290,291,292},{290,291,292},88,89,88},{293,nil,293,274,nil,nil,nil,294,295,{154,155,156},{154,155,156},90,91,90},{296,nil,296,297,nil,nil,nil,298,299,{300,301,302},{300,301,302},92,93,92},{303,nil,303,274,nil,nil,nil,304,305,{154,155,156},{154,155,156},94,95,94},{306,nil,306,307,nil,nil,nil,308,309,{166,167,168},{166,167,168},96,97,96},{310,nil,310,170,nil,nil,nil,311,312,{174,173},{174,173},98,99,98}},enum)
custom_capabilities.text=build({{313,314,314,0,0,nil,315,64}},text)
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

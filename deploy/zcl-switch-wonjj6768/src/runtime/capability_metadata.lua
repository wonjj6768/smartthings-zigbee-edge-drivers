local custom_capabilities={}
local strings={"s","power_poll_interval","powerPollIntervalV2","powerPollInterval","powerPollIntervalRange","Power poll interval","C","temperature_threshold","temperatureThreshold","temperatureThresholdRange","Temperature threshold","kW","power_threshold","powerThreshold","powerThresholdRange","Power threshold","V","over_voltage_threshold","overVoltageThreshold","overVoltageThresholdRange","Over voltage threshold","ts0003Module2CountdownOne","countdownOne","ts0003_module2_countdown_one","Ts0003Module2Countdown One","ts0003Module2CountdownTwo","countdownTwo","ts0003_module2_countdown_two","Ts0003Module2Countdown Two","ts0003Module2CountdownThree","countdownThree","ts0003_module2_countdown_three","Ts0003Module2Countdown Three","nfzb03CountdownOne","nfzb03_countdown_one","Nfzb03Countdown One","nfzb03CountdownTwo","nfzb03_countdown_two","Nfzb03Countdown Two","nfzb03CountdownThree","nfzb03_countdown_three","Nfzb03Countdown Three","nfzb03InchingTimeOne","inchingTimeOne","nfzb03_inching_time_one","Nfzb03Inching Time One","nfzb03InchingTimeTwo","inchingTimeTwo","nfzb03_inching_time_two","Nfzb03Inching Time Two","nfzb03InchingTimeThree","inchingTimeThree","nfzb03_inching_time_three","Nfzb03Inching Time Three","A","ts011fDinOverCurrentThreshold","overCurrentThreshold","ts011f_din_over_current_threshold","Ts011f Din Over Current Threshold","ts011fDinUnderVoltageThreshold","underVoltageThreshold","ts011f_din_under_voltage_threshold","Ts011f Din Under Voltage Threshold","min","haozeeHzWt02WaterCountdown","waterCountdown","haozee_hz_wt02_water_countdown","Haozee Hz Wt02Water Countdown","easyiotSp1000PlayVoice","playVoice","easyiot_sp1000_play_voice","Easyiot Sp1000Play Voice","easyiotSp1000Volume","volume","easyiot_sp1000_volume","Easyiot Sp1000Volume","sonoffZbminir2DelayPowerTime","delayedPowerOnTime","sonoff_zbmini_r2_delayed_power_on_time","Sonoff Zbminir2Delay Power Time","sonoffZbminir2InchingTime","inchingTime","sonoff_zbmini_r2_inching_time","Sonoff Zbminir2Inching Time","countdownTimerZclTwelveHours","countdown_timer","Countdown Timer Zcl Twelve Hours","temperature_breaker","temperatureBreaker","supportedTemperatureBreakers","Temperature breaker","on","off","power_breaker","powerBreaker","supportedPowerBreakers","Power breaker","over_current_breaker","overCurrentBreaker","supportedOverCurrentBreakers","Over current breaker","over_voltage_breaker","overVoltageBreaker","supportedOverVoltageBreakers","Over voltage breaker","under_voltage_breaker","underVoltageBreaker","supportedUnderVoltageBreakers","Under voltage breaker","indicator_mode","indicatorMode","supportedIndicatorModes","Indicator mode","off/on","on/off","power_on_behavior","powerOnBehavior","supportedPowerOnBehaviors","Power on behavior","previous","power_outage_memory","powerOutageMemory","supportedPowerOutageMemories","Power outage memory","restore","switch_type","switchType","supportedSwitchTypes","Switch type","toggle","state","momentary","ts0001BbebPowerOnBehavior","ts0001_bbeb_power_on_behavior","Ts0001Bbeb Power On Behavior","ts0001BbebBacklightMode","backlightMode","ts0001_bbeb_backlight_mode","Ts0001Bbeb Backlight Mode","ts0001BbebIndicatorPattern","indicatorPattern","ts0001_bbeb_indicator_mode","Ts0001Bbeb Indicator Pattern","ts0003Module2SwitchType","ts0003_module2_switch_type","Ts0003Module2Switch Type","ts0003Module2IndicatorMode","ts0003_module2_indicator_mode","Ts0003Module2Indicator Mode","off_on","on_off","nfzb03PowerOutageMemory","nfzb03_power_outage_memory","Nfzb03Power Outage Memory","nfzb03SwitchType","nfzb03_switch_type","Nfzb03Switch Type","nfzb03IndicatorMode","nfzb03_indicator_mode","Nfzb03Indicator Mode","nfzb03BacklightMode","nfzb03_backlight_mode","Nfzb03Backlight Mode","nfzb03InchingControlOne","inchingControlOne","nfzb03_inching_enabled_one","Nfzb03Inching Control One","DISABLE","ENABLE","nfzb03InchingControlTwo","inchingControlTwo","nfzb03_inching_enabled_two","Nfzb03Inching Control Two","nfzb03InchingControlThree","inchingControlThree","nfzb03_inching_enabled_three","Nfzb03Inching Control Three","lellkiWp33PowerOnBehavior","lellki_wp33_power_on_behavior","Lellki Wp33Power On Behavior","candeoSm30PowerBehavior","candeo_sm30_power_on_behavior","Candeo Sm30Power Behavior","ts011fDinIndicatorMode","ts011f_din_indicator_mode","Ts011f Din Indicator Mode","sonoffZbminir2NetworkIndicator","networkIndicator","sonoff_zbmini_r2_network_indicator","Sonoff Zbminir2Network Indicator","sonoffZbminir2TurboMode","turboMode","sonoff_zbmini_r2_turbo_mode","Sonoff Zbminir2Turbo Mode","sonoffZbminir2DelayPowerState","delayedPowerOnState","sonoff_zbmini_r2_delayed_power_on_state","Sonoff Zbminir2Delay Power State","sonoffZbminir2DetachRelayMode","detachRelayMode","sonoff_zbmini_r2_detach_relay_mode","Sonoff Zbminir2Detach Relay Mode","sonoffZbminir2ExtTriggerMode","externalTriggerMode","sonoff_zbmini_r2_external_trigger_mode","Sonoff Zbminir2Ext Trigger Mode","edge","pulse","following_off","following_on","sonoffZbminir2InchingControl","inchingControl","sonoff_zbmini_r2_inching_control","Sonoff Zbminir2Inching Control","sonoffZbminir2InchingMode","inchingMode","sonoff_zbmini_r2_inching_mode","Sonoff Zbminir2Inching Mode","sonoffZbminir2PowerOnBehavior","sonoff_zbmini_r2_power_on_behavior","Sonoff Zbminir2Power On Behavior","childLock","child_lock","Child Lock","last_power_response_time","lastPowerResponseTime","Last power response time","easyiotSp1000Status","status","easyiot_sp1000_status","Easyiot Sp1000Status"}
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
custom_capabilities.numeric=build({{2,2,3,4,5,nil,nil,2,6,{5,3600,5,1,nil,1,nil},5,3600,1},{8,8,9,9,10,nil,nil,8,11,{40,100,1,7,nil,2,nil},40,100,7},{13,13,14,14,15,nil,nil,13,16,{1,26,1,12,nil,3,nil},1,26,12},{18,18,19,19,20,nil,nil,18,21,{220,265,1,17,nil,4,nil},220,265,17},{22,nil,22,23,nil,nil,nil,24,25,{0,43200,1,1,nil,5,nil},nil,nil,1},{26,nil,26,27,nil,nil,nil,28,29,{0,43200,1,1,nil,6,nil},nil,nil,1},{30,nil,30,31,nil,nil,nil,32,33,{0,43200,1,1,nil,7,nil},nil,nil,1},{34,nil,34,23,nil,nil,nil,35,36,{0,43200,1,1,nil,8,nil},nil,nil,1},{37,nil,37,27,nil,nil,nil,38,39,{0,43200,1,1,nil,9,nil},nil,nil,1},{40,nil,40,31,nil,nil,nil,41,42,{0,43200,1,1,nil,10,nil},nil,nil,1},{43,nil,43,44,nil,nil,nil,45,46,{1,65535,1,1,nil,11,nil},nil,nil,1},{47,nil,47,48,nil,nil,nil,49,50,{1,65535,1,1,nil,12,nil},nil,nil,1},{51,nil,51,52,nil,nil,nil,53,54,{1,65535,1,1,nil,13,nil},nil,nil,1},{56,nil,56,57,nil,nil,nil,58,59,{1,65,1,55,nil,14,nil},nil,nil,55},{60,nil,60,61,nil,nil,nil,62,63,{75,240,1,17,nil,15,nil},nil,nil,17},{65,nil,65,66,nil,nil,nil,67,68,{1,1440,1,64,nil,16,nil},nil,nil,64},{69,nil,69,70,nil,nil,nil,71,72,{1,999,1,nil,nil,17,nil},nil,nil,nil},{73,nil,73,74,nil,nil,nil,75,76,{1,30,1,nil,nil,18,nil},nil,nil,nil},{77,nil,77,78,nil,nil,nil,79,80,{0.5,3599.5,0.5,1,nil,19,nil},nil,nil,1},{81,nil,81,82,nil,nil,nil,83,84,{0.5,3599.5,0.5,1,nil,20,nil},nil,nil,1},{85,nil,85,85,nil,nil,nil,86,87,{0,43200,1,1,nil,21,nil},nil,nil,1}},numeric)
custom_capabilities.enum=build({{88,88,89,89,90,nil,nil,88,91,{92,93},{92,93},22,23,22},{94,94,95,95,96,nil,nil,94,97,{92,93},{92,93},22,24,22},{98,98,99,99,100,nil,nil,98,101,{92,93},{92,93},22,25,22},{102,102,103,103,104,nil,nil,102,105,{92,93},{92,93},22,26,22},{106,106,107,107,108,nil,nil,106,109,{92,93},{92,93},22,27,22},{110,110,111,111,112,nil,nil,110,113,{93,114,115,92},{93,114,115,92},28,29,28},{116,116,117,117,118,nil,nil,116,119,{93,92,120},{93,92,120},30,31,30},{121,121,122,122,123,nil,nil,121,124,{93,92,125},{93,92,125},32,33,32},{126,126,127,127,128,nil,nil,126,129,{130,131,132},{130,131,132},34,35,34},{133,nil,133,117,nil,nil,nil,134,135,{93,92,120},{93,92,120},36,37,36},{136,nil,136,137,nil,nil,nil,138,139,{93,92},{93,92},38,39,38},{140,nil,140,141,nil,nil,nil,142,143,{93,114,115,92},{93,114,115,92},40,41,40},{144,nil,144,127,nil,nil,nil,145,146,{130,131,132},{130,131,132},42,43,42},{147,nil,147,111,nil,nil,nil,148,149,{93,150,151,92},{93,150,151,92},44,45,44},{152,nil,152,122,nil,nil,nil,153,154,{93,92,125},{93,92,125},46,47,46},{155,nil,155,127,nil,nil,nil,156,157,{130,131,132},{130,131,132},48,49,48},{158,nil,158,111,nil,nil,nil,159,160,{93,150,151,92},{93,150,151,92},50,51,50},{161,nil,161,137,nil,nil,nil,162,163,{93,92},{93,92},52,53,52},{164,nil,164,165,nil,nil,nil,166,167,{168,169},{168,169},54,55,54},{170,nil,170,171,nil,nil,nil,172,173,{168,169},{168,169},56,57,56},{174,nil,174,175,nil,nil,nil,176,177,{168,169},{168,169},58,59,58},{178,nil,178,117,nil,nil,nil,179,180,{93,92,120},{93,92,120},60,61,60},{181,nil,181,117,nil,nil,nil,182,183,{93,92,120},{93,92,120},62,63,62},{184,nil,184,111,nil,nil,nil,185,186,{93,150,151},{93,150,151},64,65,64},{187,nil,187,188,nil,nil,nil,189,190,{93,92},{93,92},66,67,66},{191,nil,191,192,nil,nil,nil,193,194,{93,92},{93,92},68,69,68},{195,nil,195,196,nil,nil,nil,197,198,{93,92},{93,92},70,71,70},{199,nil,199,200,nil,nil,nil,201,202,{93,92},{93,92},72,73,72},{203,nil,203,204,nil,nil,nil,205,206,{207,208,209,210},{207,208,209,210},74,75,74},{211,nil,211,212,nil,nil,nil,213,214,{93,92},{93,92},76,77,76},{215,nil,215,216,nil,nil,nil,217,218,{93,92},{93,92},78,79,78},{219,nil,219,117,nil,nil,nil,220,221,{93,92,130,120},{93,92,130,120},80,81,80},{222,nil,222,222,nil,nil,nil,223,224,{93,92},{93,92},82,83,82}},enum)
custom_capabilities.text=build({{225,226,226,0,0,nil,227,64},{228,228,229,0,0,230,231,16}},text)
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

local custom_capabilities={}
local strings={"kWh","zwpm16DailyEnergy","zwpmOneSixDailyEnergy","daily_energy","Zwpm16Daily Energy","zwpm16TwoDailyEnergyL1","zwpmOneSixTwoDailyEnergyLOne","daily_energy_l1","Zwpm16Two Daily Energy L1","zwpm16TwoDailyEnergyL2","zwpmOneSixTwoDailyEnergyLTwo","daily_energy_l2","Zwpm16Two Daily Energy L2","Hz","moesZmSixAcFrequency","acFrequency","moes_zm_six_ac_frequency","Moes Zm Six Ac Frequency","moesZmSixReverseEnergy","reverseEnergy","moes_zm_six_reverse_energy","Moes Zm Six Reverse Energy","moesZmSixActiveEnergy","activeEnergy","moes_zm_six_active_energy","Moes Zm Six Active Energy","moesZmSixFault","fault","moes_zm_six_fault","Moes Zm Six Fault","s","moesZmSixCountdown","countdown","moes_zm_six_countdown","Moes Zm Six Countdown","nousDFiveCountdown","nous_d_five_countdown","Nous DFive Countdown","m","nousDFiveInchingMinutes","inchingMinutes","nous_d_five_inching_minutes","Nous DFive Inching Minutes","nousDFiveInchingSeconds","inchingSeconds","nous_d_five_inching_seconds","Nous DFive Inching Seconds","nousDFiveProducedEnergy","producedEnergy","nous_d_five_produced_energy","Nous DFive Produced Energy","mA","nousDFiveLeakageCurrent","leakageCurrent","nous_d_five_leakage_current","Nous DFive Leakage Current","nousDFiveReclosingDelay","reclosingDelay","nous_d_five_reclosing_delay","Nous DFive Reclosing Delay","nousDFiveReclosingCount","reclosingCount","nous_d_five_reclosing_count","Nous DFive Reclosing Count","nousDFiveEnergyBalance","energyBalance","nous_d_five_energy_balance","Nous DFive Energy Balance","nousDFiveEnergyBalanceAdd","energyBalanceAdd","nous_d_five_energy_balance_add","Nous DFive Energy Balance Add","nousDFiveLeakageThreshold","leakageThreshold","nous_d_five_leakage_threshold","Nous DFive Leakage Threshold","°C","nousDFiveTemperatureThreshold","temperatureThreshold","nous_d_five_temperature_threshold","Nous DFive Temperature Threshold","nousDFiveOverCurrentTime","overCurrentTime","nous_d_five_over_current_time","Nous DFive Over Current Time","A","nousDFiveOverCurrentThreshold","overCurrentThreshold","nous_d_five_over_current_threshold","Nous DFive Over Current Threshold","V","nousDFiveOverVoltageThreshold","overVoltageThreshold","nous_d_five_over_voltage_threshold","Nous DFive Over Voltage Threshold","nousDFiveUnderVoltageThreshold","underVoltageThreshold","nous_d_five_under_voltage_threshold","Nous DFive Under Voltage Threshold","nousDFiveLostFlowThreshold","lostFlowThreshold","nous_d_five_lost_flow_threshold","Nous DFive Lost Flow Threshold","nousDFiveLostFlowTime","lostFlowTime","nous_d_five_lost_flow_time","Nous DFive Lost Flow Time","W","qaQaszpReactivePowerThreshold","reactivePowerThreshold","qa_qaszp_reactive_power_threshold","Qa Qaszp Reactive Power Threshold","qaQaszpMaxEffectivePower","maxEffectivePower","qa_qaszp_max_effective_power","Qa Qaszp Max Effective Power","moesZmSixClearEvent","clearEvent","moes_zm_six_clear_event","Moes Zm Six Clear Event","ON","OFF","moesZmSixOnlineState","onlineState","moes_zm_six_online_state","Moes Zm Six Online State","offline","online","moesZmSixDeviceRestart","deviceRestart","moes_zm_six_device_restart","Moes Zm Six Device Restart","nousDFivePowerOnBehavior","powerOnBehavior","nous_d_five_power_on_behavior","Nous DFive Power On Behavior","off","on","previous","nousDFiveInchingState","inchingState","nous_d_five_inching_state","Nous DFive Inching State","nousDFiveStatus","status","nous_d_five_status","Nous DFive Status","consumption","production","nousDFiveReclosing","reclosing","nous_d_five_reclosing","Nous DFive Reclosing","nousDFivePrepayment","prepayment","nous_d_five_prepayment","Nous DFive Prepayment","nousDFiveEnergyBalanceReset","energyBalanceReset","nous_d_five_energy_balance_reset","Nous DFive Energy Balance Reset","RESET","idle","nousDFiveLeakageAlarm","leakageAlarm","nous_d_five_leakage_alarm","Nous DFive Leakage Alarm","nousDFiveTemperatureAlarm","temperatureAlarm","nous_d_five_temperature_alarm","Nous DFive Temperature Alarm","nousDFiveOverCurrentAlarm","overCurrentAlarm","nous_d_five_over_current_alarm","Nous DFive Over Current Alarm","nousDFiveOverVoltageAlarm","overVoltageAlarm","nous_d_five_over_voltage_alarm","Nous DFive Over Voltage Alarm","nousDFiveUnderVoltageAlarm","underVoltageAlarm","nous_d_five_under_voltage_alarm","Nous DFive Under Voltage Alarm","nousDFiveLostFlowAlarm","lostFlowAlarm","nous_d_five_lost_flow_alarm","Nous DFive Lost Flow Alarm","qaQaszpStatusReport","statusReport","qa_qaszp_status_report","Qa Qaszp Status Report","qaQaszpSwitchStatus","switchStatus","qa_qaszp_switch_status","Qa Qaszp Switch Status","last_power_response_time","lastPowerResponseTime","Last power response time","nousDFiveFaults","faults","nous_d_five_faults","Nous DFive Faults"}
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
custom_capabilities.numeric=build({{2,nil,2,3,nil,0,0,4,5,{nil,nil,nil,1,nil,1,nil},nil,nil,1},{6,nil,6,7,nil,0,0,8,9,{nil,nil,nil,1,nil,2,nil},nil,nil,1},{10,nil,10,11,nil,0,0,12,13,{nil,nil,nil,1,nil,3,nil},nil,nil,1},{15,nil,15,16,nil,0,0,17,18,{nil,nil,nil,14,nil,4,nil},nil,nil,14},{19,nil,19,20,nil,0,0,21,22,{nil,nil,nil,1,nil,5,nil},nil,nil,1},{23,nil,23,24,nil,0,0,25,26,{nil,nil,nil,1,nil,6,nil},nil,nil,1},{27,nil,27,28,nil,0,0,29,30,{nil,nil,nil,nil,nil,7,nil},nil,nil,nil},{32,nil,32,33,nil,nil,nil,34,35,{0,2000,1,31,nil,8,nil},nil,nil,31},{36,nil,36,33,nil,nil,nil,37,38,{0,86400,1,31,nil,9,nil},nil,nil,31},{40,nil,40,41,nil,nil,nil,42,43,{0,1440,1,39,nil,10,nil},nil,nil,39},{44,nil,44,45,nil,nil,nil,46,47,{0,59,1,31,nil,11,nil},nil,nil,31},{48,nil,48,49,nil,0,0,50,51,{nil,nil,nil,1,nil,12,nil},nil,nil,1},{53,nil,53,54,nil,0,0,55,56,{nil,nil,nil,52,nil,13,nil},nil,nil,52},{57,nil,57,58,nil,nil,nil,59,60,{1,99,1,31,nil,14,nil},nil,nil,31},{61,nil,61,62,nil,nil,nil,63,64,{0,30,1,nil,nil,15,nil},nil,nil,nil},{65,nil,65,66,nil,0,0,67,68,{nil,nil,nil,1,nil,16,nil},nil,nil,1},{69,nil,69,70,nil,nil,nil,71,72,{0,999999,0.01,1,nil,17,nil},nil,nil,1},{73,nil,73,74,nil,nil,nil,75,76,{1,99,1,52,nil,18,nil},nil,nil,52},{78,nil,78,79,nil,nil,nil,80,81,{10,85,1,77,nil,19,nil},nil,nil,77},{82,nil,82,83,nil,nil,nil,84,85,{0,999,1,31,nil,20,nil},nil,nil,31},{87,nil,87,88,nil,nil,nil,89,90,{1,80,0.1,86,nil,21,nil},nil,nil,86},{92,nil,92,93,nil,nil,nil,94,95,{120,300,1,91,nil,22,nil},nil,nil,91},{96,nil,96,97,nil,nil,nil,98,99,{80,210,1,91,nil,23,nil},nil,nil,91},{100,nil,100,101,nil,nil,nil,102,103,{1,100,0.1,86,nil,24,nil},nil,nil,86},{104,nil,104,105,nil,nil,nil,106,107,{0,999,1,31,nil,25,nil},nil,nil,31},{109,nil,109,110,nil,nil,nil,111,112,{3,30,0.1,108,nil,26,nil},nil,nil,108},{113,nil,113,114,nil,nil,nil,115,116,{0,4800,1,108,nil,27,nil},nil,nil,108}},numeric)
custom_capabilities.enum=build({{117,nil,117,118,nil,nil,nil,119,120,{121,122},{121,122},28,29,28},{123,nil,123,124,nil,0,0,125,126,{127,128},{127,128},30,31,30},{129,nil,129,130,nil,nil,nil,131,132,{121,122},{121,122},32,33,32},{133,nil,133,134,nil,nil,nil,135,136,{137,138,139},{137,138,139},34,35,34},{140,nil,140,141,nil,nil,nil,142,143,{121,122},{121,122},36,37,36},{144,nil,144,145,nil,0,0,146,147,{137,148,149},{137,148,149},38,39,38},{150,nil,150,151,nil,nil,nil,152,153,{121,122},{121,122},40,41,40},{154,nil,154,155,nil,nil,nil,156,157,{121,122},{121,122},42,43,42},{158,nil,158,159,nil,nil,nil,160,161,{162,163},{162,163},44,45,44},{164,nil,164,165,nil,nil,nil,166,167,{121,122},{121,122},46,47,46},{168,nil,168,169,nil,nil,nil,170,171,{121,122},{121,122},48,49,48},{172,nil,172,173,nil,nil,nil,174,175,{121,122},{121,122},50,51,50},{176,nil,176,177,nil,nil,nil,178,179,{121,122},{121,122},52,53,52},{180,nil,180,181,nil,nil,nil,182,183,{121,122},{121,122},54,55,54},{184,nil,184,185,nil,nil,nil,186,187,{121,122},{121,122},56,57,56},{188,nil,188,189,nil,nil,nil,190,191,{121,122},{121,122},58,59,58},{192,nil,192,193,nil,0,0,194,195,{121,122},{121,122},60,61,60}},enum)
custom_capabilities.text=build({{196,197,197,0,0,nil,198,64},{199,199,200,0,0,201,202,256}},text)
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

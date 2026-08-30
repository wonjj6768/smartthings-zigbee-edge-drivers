local custom_capabilities={}
local strings={"s","power_poll_interval","powerPollIntervalV2","powerPollInterval","powerPollIntervalRange","Power poll interval","C","temperature_threshold","temperatureThreshold","temperatureThresholdRange","Temperature threshold","A","over_current_threshold","overCurrentThreshold","overCurrentThresholdRange","Over current threshold","V","over_voltage_threshold","overVoltageThreshold","overVoltageThresholdRange","Over voltage threshold","under_voltage_threshold","underVoltageThreshold","underVoltageThresholdRange","Under voltage threshold","kWh","producedEnergyBidirectionalMeter","produced_energy","Produced Energy Bidirectional Meter","Hz","acFrequencySdm01","acFrequencySdmOne","ac_frequency","Ac Frequency Sdm01","acFrequencyClamp3Phase","acFrequencyClampThreePhase","Ac Frequency Clamp3pHase","acFrequencyPc311","acFrequencyPcThreeEleven","Ac Frequency Pc311","acFrequency2ct","acFrequencyTwoCt","Ac Frequency2CT","%","powerFactorSdm01Percent","powerFactorSdmOnePercent","power_factor","Power Factor Sdm01Percent","powerFactorClamp3PhasePercent","powerFactorClampThreePhasePercent","Power Factor Clamp3pHase Percent","powerFactorPc311Percent","powerFactorPcThreeElevenPercent","Power Factor Pc311Percent","powerFactor2ctPercent","powerFactorTwoCtPercent","Power Factor2CT Percent","var","reactivePowerAtms10013z3","reactivePowerAtmsZ","power_reactive","Reactive Power Atms10013z3","updateFrequency2ctSeconds60","updateFreqTwoCtSixtySec","update_frequency","Update Frequency2CT Seconds60","updateFrequencyPj1203aSeconds60","updateFreqPjTwelveSixtySec","Update Frequency Pj1203a Seconds60","updateFrequencySdm02v1Seconds3600","updateFreqSdmHour","Update Frequency Sdm02v1Seconds3600","clamp3RelayProducedEnergy","producedEnergy","Clamp3Relay Produced Energy","spm02ProducedEnergy","Spm02Produced Energy","nousD4zProducedEnergy","Nous D4z Produced Energy","nousD4zAcFrequency","acFrequency","Nous D4z Ac Frequency","nousD4zPowerFactor","powerFactor","Nous D4z Power Factor","spm02v2ProducedEnergy","Spm02v2Produced Energy","spm02v2AcFrequency","Spm02v2Ac Frequency","spm02v2PowerFactor","Spm02v2Power Factor","spm02v25ProducedEnergy","Spm02v25Produced Energy","spm02v25AcFrequency","Spm02v25Ac Frequency","spm02v25PowerFactor","Spm02v25Power Factor","spm02v3ProducedEnergy","Spm02v3Produced Energy","spm02v3AcFrequency","Spm02v3Ac Frequency","spm02v3PowerFactor","Spm02v3Power Factor","spm02v3UpdateFrequency","updateFrequency","Spm02v3Update Frequency","spm02v1gtProducedEnergy","Spm02v1gt Produced Energy","spm02v1gtAcFrequency","Spm02v1gt Ac Frequency","spm02v1gtPowerFactor","Spm02v1gt Power Factor","spm02v1gtUpdateFrequency","Spm02v1gt Update Frequency","sdm01v1gtProducedEnergy","Sdm01v1gt Produced Energy","sdm01v1gtAcFrequency","Sdm01v1gt Ac Frequency","sdm01v1gtPowerFactor","Sdm01v1gt Power Factor","sdm01v1gtUpdateFrequency","Sdm01v1gt Update Frequency","sdm01v15ProducedEnergy","Sdm01v15Produced Energy","sdm01v15AcFrequency","Sdm01v15Ac Frequency","sdm01v15PowerFactor","Sdm01v15Power Factor","sdm01v15UpdateFrequency","Sdm01v15Update Frequency","spm01ProducedEnergy","Spm01Produced Energy","spm01v2ProducedEnergy","Spm01v2Produced Energy","spm01v2AcFrequency","Spm01v2Ac Frequency","spm01v2PowerFactor","Spm01v2Power Factor","spm01v25ProducedEnergy","Spm01v25Produced Energy","spm01v25AcFrequency","Spm01v25Ac Frequency","spm01v25PowerFactor","Spm01v25Power Factor","spm01v1gtProducedEnergy","Spm01v1gt Produced Energy","spm01v1gtAcFrequency","Spm01v1gt Ac Frequency","spm01v1gtPowerFactor","Spm01v1gt Power Factor","spm01v1gtUpdateFrequency","Spm01v1gt Update Frequency","sdm02v1gtProducedEnergy","Sdm02v1gt Produced Energy","sdm02v1gtAcFrequency","Sdm02v1gt Ac Frequency","sdm02v1gtPowerFactor","Sdm02v1gt Power Factor","sdm02v1gtUpdateFrequency","Sdm02v1gt Update Frequency","toqsa1AcFrequency","Toqsa1Ac Frequency","toqsa1PowerFactor","Toqsa1Power Factor","toqsa1OverCurrentThreshold","Toqsa1Over Current Threshold","toqsa1OverVoltageThreshold","Toqsa1Over Voltage Threshold","toqsa1UnderVoltageThreshold","Toqsa1Under Voltage Threshold","toqsa1TemperatureThreshold","Toqsa1Temperature Threshold","W","toqsa1OverPowerThreshold","overPowerThreshold","over_power_threshold","Toqsa1Over Power Threshold","atms10013z3ProducedEnergy","Atms10013z3Produced Energy","atms10013z3TotalEnergy","totalEnergy","total_energy","Atms10013z3Total Energy","atms10013z3PowerFactor","Atms10013z3Power Factor","twoCtCalibrationVoltage","calibrationVoltage","calibration_voltage","Two Ct Calibration Voltage","twoCtCalibrationAcFrequency","calibrationAcFrequency","calibration_ac_frequency","Two Ct Calibration Ac Frequency","twoCtCalibrationCurrentA","calibrationCurrent","calibration_current","Two Ct Calibration Current A","twoCtCalibrationPowerA","calibrationPower","calibration_power","Two Ct Calibration Power A","twoCtCalibrationCurrentB","Two Ct Calibration Current B","twoCtCalibrationPowerB","Two Ct Calibration Power B","pj1203aAcFrequency","Pj1203a Ac Frequency","pj1203aPowerFactor","Pj1203a Power Factor","pj1203aProducedEnergy","Pj1203a Produced Energy","pc311ProducedEnergy","Pc311Produced Energy","clamp3PhaseAcFreqHighPrecision","acFrequencyHighPrecision","ac_frequency_high_precision","Clamp3pHase Ac Freq High Precision","nousD4zEnergyReset","energyReset","energy_reset","Nous D4z Energy Reset","off","on","spm02v1gtDeviceLocating","deviceLocating","device_locating","Spm02v1gt Device Locating","sdm01v1gtDeviceLocating","Sdm01v1gt Device Locating","spm01v1gtDeviceLocating","Spm01v1gt Device Locating","sdm02v1gtDeviceLocating","Sdm02v1gt Device Locating","toqsa1OverVoltageSetting","overVoltageSetting","over_voltage_setting","Toqsa1Over Voltage Setting","ignore","alarm","toqsa1UnderVoltageSetting","underVoltageSetting","under_voltage_setting","Toqsa1Under Voltage Setting","toqsa1OverCurrentSetting","overCurrentSetting","over_current_setting","Toqsa1Over Current Setting","toqsa1OverPowerSetting","overPowerSetting","over_power_setting","Toqsa1Over Power Setting","toqsa1TemperatureSetting","temperatureSetting","temperature_setting","Toqsa1Temperature Setting","toqsa1Event","event","Toqsa1Event","normal","over_current_trip","over_power_trip","high_temp_trip","over_voltage_trip","under_voltage_trip","over_current_alarm","over_power_alarm","high_temp_alarm","over_voltage_alarm","under_voltage_alarm","remote_on","remote_off","manual_on","manual_off","leakage_trip","leakage_alarm","restore_default","automatic_closing","electricity_shortage","electricity_shortage_alarm","timing_switch_on","timing_switch_off","last_power_response_time","lastPowerResponseTime","Last power response time","nousD4zFaults","faults","Nous D4z Faults"}
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
custom_capabilities.numeric=build({{2,2,3,4,5,nil,nil,2,6,{5,3600,5,1,nil,1,nil},5,3600,1},{8,8,9,9,10,nil,nil,8,11,{40,100,1,7,nil,2,nil},40,100,7},{13,13,14,14,15,nil,nil,13,16,{1,64,1,12,nil,3,nil},1,64,12},{18,18,19,19,20,nil,nil,18,21,{220,265,1,17,nil,4,nil},220,265,17},{22,22,23,23,24,nil,nil,22,25,{76,240,1,17,nil,5,nil},76,240,17},{27,nil,27,27,nil,0,0,28,29,{0,999999,0.001,26,nil,6,nil},nil,nil,26},{31,nil,31,32,nil,0,0,33,34,{45,65,0.01,30,nil,7,nil},nil,nil,30},{35,nil,35,36,nil,0,0,33,37,{45,65,0.01,30,nil,8,nil},nil,nil,30},{38,nil,38,39,nil,0,0,33,40,{45,65,0.01,30,nil,9,nil},nil,nil,30},{41,nil,41,42,nil,0,0,33,43,{45,65,0.01,30,nil,10,nil},nil,nil,30},{45,nil,45,46,nil,0,0,47,48,{0,100,1,44,nil,11,nil},nil,nil,44},{49,nil,49,50,nil,0,0,47,51,{0,100,1,44,nil,12,nil},nil,nil,44},{52,nil,52,53,nil,0,0,47,54,{0,100,1,44,nil,13,nil},nil,nil,44},{55,nil,55,56,nil,0,0,47,57,{0,100,1,44,nil,14,nil},nil,nil,44},{59,nil,59,60,nil,0,0,61,62,{0,999999,1,58,nil,15,nil},nil,nil,58},{63,nil,63,64,nil,nil,nil,65,66,{3,60,1,1,nil,16,nil},nil,nil,1},{67,nil,67,68,nil,nil,nil,65,69,{3,60,1,1,nil,17,nil},nil,nil,1},{70,nil,70,71,nil,nil,nil,65,72,{5,3600,1,1,nil,18,nil},nil,nil,1},{73,nil,73,74,nil,0,0,28,75,{0,999999,0.01,26,nil,19,nil},nil,nil,26},{76,nil,76,74,nil,0,0,28,77,{0,999999,0.01,26,nil,20,nil},nil,nil,26},{78,nil,78,74,nil,0,0,28,79,{0,999999,0.01,26,nil,21,nil},nil,nil,26},{80,nil,80,81,nil,0,0,33,82,{0,100,0.01,30,nil,22,nil},nil,nil,30},{83,nil,83,84,nil,0,0,47,85,{0,100,1,44,nil,23,nil},nil,nil,44},{86,nil,86,74,nil,0,0,28,87,{0,999999,0.01,26,nil,24,nil},nil,nil,26},{88,nil,88,81,nil,0,0,33,89,{0,100,0.01,30,nil,25,nil},nil,nil,30},{90,nil,90,84,nil,0,0,47,91,{0,100,1,44,nil,26,nil},nil,nil,44},{92,nil,92,74,nil,0,0,28,93,{0,999999,0.01,26,nil,27,nil},nil,nil,26},{94,nil,94,81,nil,0,0,33,95,{0,100,0.01,30,nil,28,nil},nil,nil,30},{96,nil,96,84,nil,0,0,47,97,{0,100,1,44,nil,29,nil},nil,nil,44},{98,nil,98,74,nil,0,0,28,99,{0,999999,0.01,26,nil,30,nil},nil,nil,26},{100,nil,100,81,nil,0,0,33,101,{0,100,0.01,30,nil,31,nil},nil,nil,30},{102,nil,102,84,nil,0,0,47,103,{0,100,1,44,nil,32,nil},nil,nil,44},{104,nil,104,105,nil,nil,nil,65,106,{5,3600,1,1,nil,33,nil},nil,nil,1},{107,nil,107,74,nil,0,0,28,108,{0,999999,0.01,26,nil,34,nil},nil,nil,26},{109,nil,109,81,nil,0,0,33,110,{0,100,0.01,30,nil,35,nil},nil,nil,30},{111,nil,111,84,nil,0,0,47,112,{0,100,1,44,nil,36,nil},nil,nil,44},{113,nil,113,105,nil,nil,nil,65,114,{30,3600,1,1,nil,37,nil},nil,nil,1},{115,nil,115,74,nil,0,0,28,116,{0,999999,0.01,26,nil,38,nil},nil,nil,26},{117,nil,117,81,nil,0,0,33,118,{0,100,0.01,30,nil,39,nil},nil,nil,30},{119,nil,119,84,nil,0,0,47,120,{0,100,1,44,nil,40,nil},nil,nil,44},{121,nil,121,105,nil,nil,nil,65,122,{5,3600,1,1,nil,41,nil},nil,nil,1},{123,nil,123,74,nil,0,0,28,124,{0,999999,0.01,26,nil,42,nil},nil,nil,26},{125,nil,125,81,nil,0,0,33,126,{0,100,0.01,30,nil,43,nil},nil,nil,30},{127,nil,127,84,nil,0,0,47,128,{0,100,1,44,nil,44,nil},nil,nil,44},{129,nil,129,105,nil,nil,nil,65,130,{5,3600,1,1,nil,45,nil},nil,nil,1},{131,nil,131,74,nil,0,0,28,132,{0,999999,0.01,26,nil,46,nil},nil,nil,26},{133,nil,133,74,nil,0,0,28,134,{0,999999,0.01,26,nil,47,nil},nil,nil,26},{135,nil,135,81,nil,0,0,33,136,{0,100,0.01,30,nil,48,nil},nil,nil,30},{137,nil,137,84,nil,0,0,47,138,{0,100,1,44,nil,49,nil},nil,nil,44},{139,nil,139,74,nil,0,0,28,140,{0,999999,0.01,26,nil,50,nil},nil,nil,26},{141,nil,141,81,nil,0,0,33,142,{0,100,0.01,30,nil,51,nil},nil,nil,30},{143,nil,143,84,nil,0,0,47,144,{0,100,1,44,nil,52,nil},nil,nil,44},{145,nil,145,74,nil,0,0,28,146,{0,999999,0.01,26,nil,53,nil},nil,nil,26},{147,nil,147,81,nil,0,0,33,148,{0,100,0.01,30,nil,54,nil},nil,nil,30},{149,nil,149,84,nil,0,0,47,150,{0,100,1,44,nil,55,nil},nil,nil,44},{151,nil,151,105,nil,nil,nil,65,152,{5,3600,1,1,nil,56,nil},nil,nil,1},{153,nil,153,74,nil,0,0,28,154,{0,999999,0.01,26,nil,57,nil},nil,nil,26},{155,nil,155,81,nil,0,0,33,156,{0,100,0.01,30,nil,58,nil},nil,nil,30},{157,nil,157,84,nil,0,0,47,158,{0,100,1,44,nil,59,nil},nil,nil,44},{159,nil,159,105,nil,nil,nil,65,160,{5,3600,1,1,nil,60,nil},nil,nil,1},{161,nil,161,81,nil,0,0,33,162,{0,100,0.01,30,nil,61,nil},nil,nil,30},{163,nil,163,84,nil,0,0,47,164,{0,100,1,44,nil,62,nil},nil,nil,44},{165,nil,165,14,nil,nil,nil,13,166,{1,50,1,12,nil,63,nil},nil,nil,12},{167,nil,167,19,nil,nil,nil,18,168,{240,295,1,17,nil,64,nil},nil,nil,17},{169,nil,169,23,nil,nil,nil,22,170,{90,220,1,17,nil,65,nil},nil,nil,17},{171,nil,171,9,nil,nil,nil,8,172,{-25,80,1,7,nil,66,nil},nil,nil,7},{174,nil,174,175,nil,nil,nil,176,177,{1000,26000,1,173,nil,67,nil},nil,nil,173},{178,nil,178,74,nil,0,0,28,179,{0,999999,0.01,26,nil,68,nil},nil,nil,26},{180,nil,180,181,nil,0,0,182,183,{0,999999,0.01,26,nil,69,nil},nil,nil,26},{184,nil,184,84,nil,0,0,47,185,{0,100,1,44,nil,70,nil},nil,nil,44},{186,nil,186,187,nil,nil,nil,188,189,{0.5,1.5,0.01,nil,nil,71,nil},nil,nil,nil},{190,nil,190,191,nil,nil,nil,192,193,{0.5,1.5,0.01,nil,nil,72,nil},nil,nil,nil},{194,nil,194,195,nil,nil,nil,196,197,{0.5,1.5,0.01,nil,nil,73,nil},nil,nil,nil},{198,nil,198,199,nil,nil,nil,200,201,{0.5,1.5,0.01,nil,nil,74,nil},nil,nil,nil},{202,nil,202,195,nil,nil,nil,196,203,{0.5,1.5,0.01,nil,nil,75,nil},nil,nil,nil},{204,nil,204,199,nil,nil,nil,200,205,{0.5,1.5,0.01,nil,nil,76,nil},nil,nil,nil},{206,nil,206,81,nil,0,0,33,207,{0,100,0.01,30,nil,77,nil},nil,nil,30},{208,nil,208,84,nil,0,0,47,209,{0,100,1,44,nil,78,nil},nil,nil,44},{210,nil,210,74,nil,0,0,28,211,{0,999999,0.01,26,nil,79,nil},nil,nil,26},{212,nil,212,74,nil,0,0,28,213,{0,999999,0.01,26,nil,80,nil},nil,nil,26},{214,nil,214,215,nil,0,0,216,217,{0,100,0.01,30,nil,81,nil},nil,nil,30}},numeric)
custom_capabilities.enum=build({{218,nil,218,219,nil,nil,nil,220,221,{222,223},{222,223},82,83,82},{224,nil,224,225,nil,nil,nil,226,227,{222,223},{222,223},84,85,84},{228,nil,228,225,nil,nil,nil,226,229,{222,223},{222,223},86,87,86},{230,nil,230,225,nil,nil,nil,226,231,{222,223},{222,223},88,89,88},{232,nil,232,225,nil,nil,nil,226,233,{222,223},{222,223},90,91,90},{234,nil,234,235,nil,nil,nil,236,237,{238,239},{238,239},92,93,92},{240,nil,240,241,nil,nil,nil,242,243,{238,239},{238,239},94,95,94},{244,nil,244,245,nil,nil,nil,246,247,{238,239},{238,239},96,97,96},{248,nil,248,249,nil,nil,nil,250,251,{238,239},{238,239},98,99,98},{252,nil,252,253,nil,nil,nil,254,255,{238,239},{238,239},100,101,100},{256,nil,256,257,nil,0,0,257,258,{259,260,261,262,263,264,265,266,267,268,269,270,271,272,273,274,275,276,277,278,279,280,281},{259,260,261,262,263,264,265,266,267,268,269,270,271,272,273,274,275,276,277,278,279,280,281},102,103,102}},enum)
custom_capabilities.text=build({{282,283,283,0,0,nil,284,64},{285,285,286,0,0,286,287,256}},text)
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

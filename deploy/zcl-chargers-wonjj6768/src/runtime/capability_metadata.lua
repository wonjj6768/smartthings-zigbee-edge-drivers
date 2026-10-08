local custom_capabilities={}local strings={"A","fhChargeSetpointChargingCurrent","setpointChargingCurrent","fh_charge_setpoint_charging_current","Fh Charge Setpoint Charging Current","fhChargeChargingCurrentLimit","chargingCurrentLimit","fh_charge_charging_current_limit","Fh Charge Charging Current Limit","kWh","fhChargeSessionEnergy","sessionEnergy","fh_charge_session_energy","Fh Charge Session Energy","fhChargeEnergyMeterStart","energyMeterStart","fh_charge_energy_meter_start","Fh Charge Energy Meter Start","fhChargeEnergyMeterNow","energyMeterNow","fh_charge_energy_meter_now","Fh Charge Energy Meter Now","s","fhChargeChargingDuration","chargingDuration","fh_charge_charging_duration","Fh Charge Charging Duration","V","fhChargeVoltagePhaseB","voltagePhaseB","fh_charge_voltage_phase_b","Fh Charge Voltage pHase B","fhChargeVoltagePhaseC","voltagePhaseC","fh_charge_voltage_phase_c","Fh Charge Voltage pHase C","fhChargeCurrentPhaseB","currentPhaseB","fh_charge_current_phase_b","Fh Charge Current pHase B","fhChargeCurrentPhaseC","currentPhaseC","fh_charge_current_phase_c","Fh Charge Current pHase C","fhChargeStatus","status","fh_charge_status","Fh Charge Status","plugged_out","off","plugged_in_charging","plugged_in_paused","plugged_in","stopped","fhChargeChargingStart","chargingStart","fh_charge_charging_start","Fh Charge Charging Start","start","fhChargeChargingStop","chargingStop","fh_charge_charging_stop","Fh Charge Charging Stop","stop","fhChargeChargingPause","chargingPause","fh_charge_charging_pause","Fh Charge Charging Pause","pause","fhChargeAutoCharge","autoCharge","fh_charge_auto_charge","Fh Charge Auto Charge","ON","OFF","fhChargePlugLockedPermanently","plugLockedPermanently","fh_charge_plug_locked_permanently","Fh Charge Plug Locked Permanently","LOCK","UNLOCK","fhChargeForceUnlock","forceUnlock","fh_charge_force_unlock","Fh Charge Force Unlock","fhChargePlugLockState","plugLockState","fh_charge_plug_lock_state","Fh Charge Plug Lock State","locked","unlocked","fhChargeIsCharging","isCharging","fh_charge_is_charging","Fh Charge Is Charging","true","false","fhChargeIsPlugConnected","isPlugConnected","fh_charge_is_plug_connected","Fh Charge Is Plug Connected","last_power_response_time","lastPowerResponseTime","Last power response time","fhChargeChargingStartDatetime","chargingStartDatetime","fh_charge_charging_start_datetime","Fh Charge Charging Start Datetime","fhChargeChargingEndDatetime","chargingEndDatetime","fh_charge_charging_end_datetime","Fh Charge Charging End Datetime","fhChargeConnectedStartDatetime","connectedStartDatetime","fh_charge_connected_start_datetime","Fh Charge Connected Start Datetime","fhChargeConnectedEndDatetime","connectedEndDatetime","fh_charge_connected_end_datetime","Fh Charge Connected End Datetime"}
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
local out={}table_groups[group_id]=out
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
local out=grouped_table(value[6])out.minimum=value[1]out.maximum=value[2]out.step=value[3]out.unit=string_value(value[4])out.allowed_values=string_list(value[5],value[7])return out
end
local function allowed_range(allowed_values,group_id)
if allowed_values==nil and group_id==nil then return nil end
local out=grouped_table(group_id)out.allowed_values=allowed_values
return out
end
local function numeric(row)
local attribute_name=string_value(row[4])return{kind="numeric",emit_name=string_value(row[1]),range_key=string_value(row[2]),capability_id=capability_id(row[3]),attribute_name=attribute_name,range_attribute_name=string_value(row[5]),command_name=optional_string(row[6],command_default(attribute_name)),argument_name=optional_string(row[7],attribute_name),mapping_name=string_value(row[8]),label=string_value(row[9]),default_range=range(row[10]),event_minimum=row[11],event_maximum=row[12],event_unit=string_value(row[13])}
end
local function enum(row)
local attribute_name=string_value(row[4])local supported_values=string_list(row[10],row[12])local default_allowed_values=string_list(row[11],row[14])local default_range=allowed_range(default_allowed_values,row[13])return{kind="enum",emit_name=string_value(row[1]),range_key=string_value(row[2]),capability_id=capability_id(row[3]),attribute_name=attribute_name,supported_attribute_name=string_value(row[5]),command_name=optional_string(row[6],command_default(attribute_name)),argument_name=optional_string(row[7],attribute_name),mapping_name=string_value(row[8]),label=string_value(row[9]),supported_values=supported_values,default_range=default_range}
end
local function text(row)
local attribute_name=string_value(row[3])return{kind="text",emit_name=string_value(row[1]),capability_id=capability_id(row[2]),attribute_name=attribute_name,command_name=optional_string(row[4],command_default(attribute_name)),argument_name=optional_string(row[5],attribute_name),mapping_name=string_value(row[6]),label=string_value(row[7]),maximum_length=row[8]}
end
local function build(rows,factory)
local out={}
for _,row in ipairs(rows)do out[#out+1]=factory(row)end
return out
end
custom_capabilities.numeric=build({{2,nil,2,3,nil,nil,nil,4,5,{0,32,nil,1,nil,1,nil},nil,nil,1},{6,nil,6,7,nil,nil,nil,8,9,{6,32,nil,1,nil,2,nil},nil,nil,1},{11,nil,11,12,nil,0,0,13,14,{nil,nil,nil,10,nil,3,nil},nil,nil,10},{15,nil,15,16,nil,0,0,17,18,{nil,nil,nil,10,nil,4,nil},nil,nil,10},{19,nil,19,20,nil,0,0,21,22,{nil,nil,nil,10,nil,5,nil},nil,nil,10},{24,nil,24,25,nil,0,0,26,27,{nil,nil,nil,23,nil,6,nil},nil,nil,23},{29,nil,29,30,nil,0,0,31,32,{nil,nil,nil,28,nil,7,nil},nil,nil,28},{33,nil,33,34,nil,0,0,35,36,{nil,nil,nil,28,nil,8,nil},nil,nil,28},{37,nil,37,38,nil,0,0,39,40,{nil,nil,nil,1,nil,9,nil},nil,nil,1},{41,nil,41,42,nil,0,0,43,44,{nil,nil,nil,1,nil,10,nil},nil,nil,1}},numeric)custom_capabilities.enum=build({{45,nil,45,46,nil,0,0,47,48,{49,50,51,52,53,54},{49,50,51,52,53,54},11,12,11},{55,nil,55,56,nil,nil,nil,57,58,{59},{59},13,14,13},{60,nil,60,61,nil,nil,nil,62,63,{64},{64},15,16,15},{65,nil,65,66,nil,nil,nil,67,68,{69},{69},17,18,17},{70,nil,70,71,nil,nil,nil,72,73,{74,75},{74,75},19,20,19},{76,nil,76,77,nil,nil,nil,78,79,{80,81},{80,81},21,22,21},{82,nil,82,83,nil,nil,nil,84,85,{81},{81},23,24,23},{86,nil,86,87,nil,0,0,88,89,{90,91},{90,91},25,26,25},{92,nil,92,93,nil,0,0,94,95,{96,97},{96,97},27,28,27},{98,nil,98,99,nil,0,0,100,101,{96,97},{96,97},29,30,29}},enum)custom_capabilities.text=build({{102,103,103,0,0,nil,104,64},{105,105,106,0,0,107,108,25},{109,109,110,0,0,111,112,25},{113,113,114,0,0,115,116,25},{117,117,118,0,0,119,120,25}},text)custom_capabilities.driver_message={["attribute_name"]="driverMessage",["capability_id"]="concertmirror08464.driverMessage",["emit_name"]="driver_message",["label"]="Driver message",["maximum_length"]=512}custom_capabilities.by_range_key={}custom_capabilities.by_emit_name={}custom_capabilities.by_capability_id={}
local function index_metadata(definitions)
for _,metadata in ipairs(definitions)do
custom_capabilities.by_emit_name[metadata.emit_name]=metadata
if type(metadata.capability_id)=="string"and metadata.capability_id~=""then custom_capabilities.by_capability_id[metadata.capability_id]=metadata end
if type(metadata.range_key)=="string"and metadata.range_key~=""then custom_capabilities.by_range_key[metadata.range_key]=metadata end
end
end
index_metadata(custom_capabilities.numeric)index_metadata(custom_capabilities.enum)index_metadata(custom_capabilities.text)custom_capabilities.by_emit_name[custom_capabilities.driver_message.emit_name]=custom_capabilities.driver_message
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
minimum=type(resolved.minimum)=="number"and resolved.minimum or(default_range and default_range.minimum or nil),maximum=type(resolved.maximum)=="number"and resolved.maximum or(default_range and default_range.maximum or nil),step=type(resolved.step)=="number"and resolved.step or(default_range and default_range.step or nil),unit=type(resolved.unit)=="string"and resolved.unit or(default_range and default_range.unit or nil),allowed_values=type(resolved.allowed_values)=="table"and clone_allowed_values(resolved.allowed_values)or clone_allowed_values(default_range and default_range.allowed_values or nil),}
end
return custom_capabilities

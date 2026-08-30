local custom_capabilities={}
local strings={"C","easyiotIr01AcTemperature","acTemperature","easyiot_ir01_ac_temperature","Easyiot Ir01Ac Temperature","easyiotIr01AcKfid","acKfid","easyiot_ir01_ac_kfid","Easyiot Ir01Ac Kfid","easyiotZl01TempUser","temporaryUser","easyiot_zl01_temp_user","Easyiot Zl01Temp User","easyiotZl01TempValid","temporaryValidTimes","easyiot_zl01_temp_valid","Easyiot Zl01Temp Valid","easyiotZl01TempClearUser","temporaryClearUser","easyiot_zl01_temp_clear_user","Easyiot Zl01Temp Clear User","easyiot24gDetectionRange","detectionRange","easyiot_24g_detection_range","Easyiot24g Detection Range","easyiot24gPirDelay","pirDelay","easyiot_24g_pir_delay","Easyiot24g Pir Delay","easyiot24gUltrasonicOccupiedDelay","ultrasonicOccupiedDelay","easyiot_24g_ultrasonic_occupied_delay","Easyiot24g Ultrasonic Occupied Delay","easyiot24gUsUnoccupiedDelay","ultrasonicUnoccupiedDelay","easyiot_24g_ultrasonic_unoccupied_delay","Easyiot24g Us Unoccupied Delay","easyiot24gMotionCoefficient","motionCoefficient","easyiot_24g_motion_coefficient","Easyiot24g Motion Coefficient","easyiot24gHoldCoefficient","holdCoefficient","easyiot_24g_hold_coefficient","Easyiot24g Hold Coefficient","easyiot24gMicroCoefficient","microCoefficient","easyiot_24g_micro_coefficient","Easyiot24g Micro Coefficient","easyiot24gAutoCalibrationProgress","autoCalibrationProgress","easyiot_24g_auto_calibration_progress","Easyiot24g Auto Calibration Progress","easyiotIr01AcMode","acMode","easyiot_ir01_ac_mode","Easyiot Ir01Ac Mode","auto","cooling","dehumidification","air_supply","heating","easyiotIr01AcWindSpeed","acWindSpeed","easyiot_ir01_ac_wind_speed","Easyiot Ir01Ac Wind Speed","low","medium","high","strong","easyiotRs485BaudRate","baudRate","easyiot_rs485_baud_rate","Easyiot Rs485Baud Rate","1200","2400","4800","9600","19200","38400","57600","115200","230400","460800","921600","easyiotRs485Parity","parity","easyiot_rs485_parity","Easyiot Rs485Parity","none","even","odd","easyiotRs485StopBits","stopBits","easyiot_rs485_stop_bits","Easyiot Rs485Stop Bits","1","1.5","2","easyiotRs232BaudRate","easyiot_rs232_baud_rate","Easyiot Rs232Baud Rate","easyiotRs232Parity","easyiot_rs232_parity","Easyiot Rs232Parity","easyiotRs232StopBits","easyiot_rs232_stop_bits","Easyiot Rs232Stop Bits","easyiot24gWorkMode","workMode","easyiot_24g_work_mode","Easyiot24g Work Mode","pirOnly","radarOnly","pirRadarAnd","occupied_first","unoccupied_first","last_power_response_time","lastPowerResponseTime","Last power response time","easyiotIr01LastReceivedCommand","lastReceivedCommand","easyiot_ir01_last_received_command","Easyiot Ir01Last Received Command","easyiotTts01LastReceivedStatus","lastReceivedStatus","easyiot_tts01_last_received_status","Easyiot Tts01Last Received Status","easyiotRs485LastReceivedCommand","easyiot_rs485_last_received_command","Easyiot Rs485Last Received Command","easyiotRs232LastReceivedCommand","easyiot_rs232_last_received_command","Easyiot Rs232Last Received Command"}
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
custom_capabilities.numeric=build({{2,nil,2,3,nil,nil,nil,4,5,{16,32,1,1,nil,1,nil},nil,nil,1},{6,nil,6,7,nil,nil,nil,8,9,{0,1354,1,nil,nil,2,nil},nil,nil,nil},{10,nil,10,11,nil,nil,nil,12,13,{1,20,1,nil,nil,3,nil},nil,nil,nil},{14,nil,14,15,nil,nil,nil,16,17,{0,255,1,nil,nil,4,nil},nil,nil,nil},{18,nil,18,19,nil,nil,nil,20,21,{1,20,1,nil,nil,5,nil},nil,nil,nil},{22,nil,22,23,nil,nil,nil,24,25,{0.7,10,0.1,nil,nil,6,nil},nil,nil,nil},{26,nil,26,27,nil,nil,nil,28,29,{0,65534,1,nil,nil,7,nil},nil,nil,nil},{30,nil,30,31,nil,nil,nil,32,33,{0,65534,1,nil,nil,8,nil},nil,nil,nil},{34,nil,34,35,nil,nil,nil,36,37,{0,65534,1,nil,nil,9,nil},nil,nil,nil},{38,nil,38,39,nil,nil,nil,40,41,{10,200,1,nil,nil,10,nil},nil,nil,nil},{42,nil,42,43,nil,nil,nil,44,45,{10,200,1,nil,nil,11,nil},nil,nil,nil},{46,nil,46,47,nil,nil,nil,48,49,{10,200,1,nil,nil,12,nil},nil,nil,nil},{50,nil,50,51,nil,0,0,52,53,{0,100,1,nil,nil,13,nil},nil,nil,nil}},numeric)
custom_capabilities.enum=build({{54,nil,54,55,nil,nil,nil,56,57,{58,59,60,61,62},{58,59,60,61,62},14,15,14},{63,nil,63,64,nil,nil,nil,65,66,{58,67,68,69,70},{58,67,68,69,70},16,17,16},{71,nil,71,72,nil,nil,nil,73,74,{75,76,77,78,79,80,81,82,83,84,85},{75,76,77,78,79,80,81,82,83,84,85},18,19,18},{86,nil,86,87,nil,nil,nil,88,89,{90,91,92},{90,91,92},20,21,20},{93,nil,93,94,nil,nil,nil,95,96,{97,98,99},{97,98,99},22,23,22},{100,nil,100,72,nil,nil,nil,101,102,{75,76,77,78,79,80,81,82,83,84,85},{75,76,77,78,79,80,81,82,83,84,85},24,25,24},{103,nil,103,87,nil,nil,nil,104,105,{90,91,92},{90,91,92},26,27,26},{106,nil,106,94,nil,nil,nil,107,108,{97,98,99},{97,98,99},28,29,28},{109,nil,109,110,nil,nil,nil,111,112,{113,114,115,116,117},{113,114,115,116,117},30,31,30}},enum)
custom_capabilities.text=build({{118,119,119,0,0,nil,120,64},{121,121,122,0,0,123,124,2048},{125,125,126,0,0,127,128,2048},{129,129,122,0,0,130,131,2048},{132,132,122,0,0,133,134,2048}},text)
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

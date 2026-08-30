local custom_capabilities={}
local strings={"min","nasThreeCountdown","countdown","naswv03b_countdown","Nas Three Countdown","nasThreeOnWithCountdown","onWithCountdown","naswv03b_on_with_countdown","Nas Three On With Countdown","nasThreeCountdownLeft","countdownLeft","naswv03b_countdown_left","Nas Three Countdown Left","s","nasThreeSingleWateringDuration","singleWateringDuration","naswv03b_single_watering_duration","Nas Three Single Watering Duration","L","nasThreeQuantitativeLiters","quantitativeWatering","naswv03b_quantitative_watering","Nas Three Quantitative Liters","nasThreeSingleAmountLiters","singleWateringAmount","naswv03b_single_watering_amount","Nas Three Single Amount Liters","nasThreeSurplusLiters","surplusFlow","naswv03b_surplus_flow","Nas Three Surplus Liters","L/min","nasThreeCurrentLiters","waterCurrent","naswv03b_water_current","Nas Three Current Liters","nasThreeTotalLiters","waterTotal","naswv03b_water_total","Nas Three Total Liters","gal","nasThreeQuantitativeGallons","Nas Three Quantitative Gallons","nasThreeSingleAmountGallons","Nas Three Single Amount Gallons","nasThreeSurplusGallons","Nas Three Surplus Gallons","gal/min","nasThreeCurrentGallons","Nas Three Current Gallons","nasThreeTotalGallons","Nas Three Total Gallons","V","batteryVoltage","battery_voltage","Battery Voltage","%","valvePositionHbnfokum","position","Valve Position Hbnfokum","valveCurrentPositionHbnfokum","position_current","Valve Current Position Hbnfokum","fkv02Threshold","threshold","Fkv02Threshold","fkv02Timer","timer","Fkv02Timer","zvg1WaterConsumed","waterConsumed","water_consumed","Zvg1Water Consumed","zvg1Timer","Zvg1Timer","zvg1TimerTimeLeft","timerTimeLeft","timer_time_left","Zvg1Timer Time Left","zvg1LastValveDuration","lastValveOpenDuration","last_valve_open_duration","Zvg1Last Valve Duration","zvlProCountdown","Zvl Pro Countdown","zvlProWaterOnce","waterOnce","water_once","Zvl Pro Water Once","gx03Timer","Gx03Timer","gx03LastDuration","lastDuration","last_duration","Gx03Last Duration","waterSwitchCountdown","Water Switch Countdown","waterSwitchDuration","valveDuration","valve_duration","Water Switch Duration","vuwtqx0tWaterConsumed","Vuwtqx0t Water Consumed","vuwtqx0tReverseConsumed","reverseWaterConsumed","reverse_water_consumed","Vuwtqx0t Reverse Consumed","vuwtqx0tMonthConsumption","monthConsumption","month_consumption","Vuwtqx0t Month Consumption","vuwtqx0tDailyConsumption","dailyConsumption","daily_consumption","Vuwtqx0t Daily Consumption","L/h","vuwtqx0tFlowRate","flowRate","flow_rate","Vuwtqx0t Flow Rate","nasThreeStatus","status","naswv03b_status","Nas Three Status","off","on_auto","button_locked","on_manual_app","on_manual_button","nasThreeRefresh","refreshStatus","naswv03b_refresh","Nas Three Refresh","refresh","nasThreeFlowSwitch","flowSwitch","naswv03b_flow_switch","Nas Three Flow Switch","on","nasThreeWaterTotalReset","waterTotalReset","naswv03b_water_total_reset","Nas Three Water Total Reset","reset","nasThreeFault","fault","naswv03b_fault","Nas Three Fault","normal","nasThreeChildLock","childLock","naswv03b_child_lock","Nas Three Child Lock","zpv01ValveState","valveState","valve_state","Zpv01Valve State","unknown","open","closed","zvg1WeatherDelay","weatherDelay","weather_delay","Zvg1Weather Delay","disabled","24h","48h","72h","zvg1TimerState","timerState","timer_state","Zvg1Timer State","active","enabled","zvlProWorkState","workState","work_state","Zvl Pro Work State","auto","manual","idle","gx03ValveState","Gx03Valve State","vuwtqx0tReportPeriod","reportPeriod","report_period","Vuwtqx0t Report Period","1h","2h","3h","4h","6h","8h","12h","autoCleanUltrasonicValve","auto_clean","Auto Clean Ultrasonic Valve","valveStatusDualIrrigationMode","valve_status","Valve Status Dual Irrigation Mode","last_power_response_time","lastPowerResponseTime","Last power response time","vuwtqx0tFaults","faults","Vuwtqx0t Faults","vuwtqx0tMeterId","meterId","meter_id","Vuwtqx0t Meter Id"}
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
custom_capabilities.numeric=build({{2,nil,2,3,nil,nil,nil,4,5,{1,240,1,1,nil,1,nil},nil,nil,1},{6,nil,6,7,nil,nil,nil,8,9,{1,240,1,1,nil,2,nil},nil,nil,1},{10,nil,10,11,nil,0,0,12,13,{0,240,1,1,nil,3,nil},nil,nil,1},{15,nil,15,16,nil,0,0,17,18,{0,2147483647,1,14,nil,4,nil},nil,nil,14},{20,nil,20,21,nil,nil,nil,22,23,{1,10000,1,19,nil,5,nil},nil,nil,19},{24,nil,24,25,nil,0,0,26,27,{0,2147483647,1,19,nil,6,nil},nil,nil,19},{28,nil,28,29,nil,0,0,30,31,{0,2147483647,1,19,nil,7,nil},nil,nil,19},{33,nil,33,34,nil,0,0,35,36,{0,4294967.295,0.001,32,nil,8,nil},nil,nil,32},{37,nil,37,38,nil,0,0,39,40,{0,4294967.295,0.001,19,nil,9,nil},nil,nil,19},{42,nil,42,21,nil,nil,nil,22,43,{1,10000,1,41,nil,10,nil},nil,nil,41},{44,nil,44,25,nil,0,0,26,45,{0,2147483647,1,41,nil,11,nil},nil,nil,41},{46,nil,46,29,nil,0,0,30,47,{0,2147483647,1,41,nil,12,nil},nil,nil,41},{49,nil,49,34,nil,0,0,35,50,{0,4294967.295,0.001,48,nil,13,nil},nil,nil,48},{51,nil,51,38,nil,0,0,39,52,{0,4294967.295,0.001,41,nil,14,nil},nil,nil,41},{54,nil,54,54,nil,0,0,55,56,{0,10,0.001,53,nil,15,nil},nil,nil,53},{58,nil,58,58,nil,nil,nil,59,60,{0,100,10,57,nil,16,nil},nil,nil,57},{61,nil,61,61,nil,0,0,62,63,{0,100,10,57,nil,17,nil},nil,nil,57},{64,nil,64,65,nil,nil,nil,65,66,{0,100,10,57,nil,18,nil},nil,nil,57},{67,nil,67,68,nil,nil,nil,68,69,{0,600,1,1,nil,19,nil},nil,nil,1},{70,nil,70,71,nil,0,0,72,73,{0,999999,0.01,19,nil,20,nil},nil,nil,19},{74,nil,74,68,nil,nil,nil,68,75,{0,60,1,1,nil,21,nil},nil,nil,1},{76,nil,76,77,nil,0,0,78,79,{0,600,1,1,nil,22,nil},nil,nil,1},{80,nil,80,81,nil,0,0,82,83,{0,999999,1,1,nil,23,nil},nil,nil,1},{84,nil,84,3,nil,nil,nil,3,85,{0,86400,1,14,nil,24,nil},nil,nil,14},{86,nil,86,87,nil,0,0,88,89,{0,999999,1,19,nil,25,nil},nil,nil,19},{90,nil,90,68,nil,nil,nil,68,91,{1,1440,1,1,nil,26,nil},nil,nil,1},{92,nil,92,93,nil,0,0,94,95,{0,999999,1,14,nil,27,nil},nil,nil,14},{96,nil,96,3,nil,nil,nil,3,97,{0,1440,1,1,nil,28,nil},nil,nil,1},{98,nil,98,99,nil,0,0,100,101,{0,999999,1,14,nil,29,nil},nil,nil,14},{102,nil,102,71,nil,0,0,72,103,{0,999999,0.001,19,nil,30,nil},nil,nil,19},{104,nil,104,105,nil,0,0,106,107,{0,999999,0.001,19,nil,31,nil},nil,nil,19},{108,nil,108,109,nil,0,0,110,111,{0,999999,0.001,19,nil,32,nil},nil,nil,19},{112,nil,112,113,nil,0,0,114,115,{0,999999,0.001,19,nil,33,nil},nil,nil,19},{117,nil,117,118,nil,0,0,119,120,{0,999999,1,116,nil,34,nil},nil,nil,116}},numeric)
custom_capabilities.enum=build({{121,nil,121,122,nil,0,0,123,124,{125,126,127,128,129},{125,126,127,128,129},35,36,35},{130,nil,130,131,nil,nil,nil,132,133,{134},{134},37,38,37},{135,nil,135,136,nil,nil,nil,137,138,{125,139},{125,139},39,40,39},{140,nil,140,141,nil,nil,nil,142,143,{144},{144},41,42,41},{145,nil,145,146,nil,0,0,147,148,{149,146},{149,146},43,44,43},{150,nil,150,151,nil,nil,nil,152,153,{125,139},{125,139},45,46,45},{154,nil,154,155,nil,0,0,156,157,{158,159,160},{158,159,160},47,48,47},{161,nil,161,162,nil,nil,nil,163,164,{165,166,167,168},{165,166,167,168},49,50,49},{169,nil,169,170,nil,0,0,171,172,{165,173,174},{165,173,174},51,52,51},{175,nil,175,176,nil,0,0,177,178,{179,180,181},{179,180,181},53,54,53},{182,nil,182,155,nil,0,0,156,183,{180,179,160},{180,179,160},55,56,55},{184,nil,184,185,nil,nil,nil,186,187,{188,189,190,191,192,193,194,166},{188,189,190,191,192,193,194,166},57,58,57},{195,nil,195,195,nil,nil,nil,196,197,{125,139},{125,139},59,60,59},{198,nil,198,198,nil,0,0,199,200,{180,179,181},{180,179,181},61,62,61}},enum)
custom_capabilities.text=build({{201,202,202,0,0,nil,203,64},{204,204,205,0,0,205,206,256},{207,207,208,0,0,209,210,256}},text)
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

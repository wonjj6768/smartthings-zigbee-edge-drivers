local a,H={},{"L","min","s","off","gal","on","countdown","%","auto","manual","timer","closed","disabled","24h","idle","batteryVoltage","valvePositionHbnfokum","valveCurrentPositionHbnfokum","fault","autoCleanUltrasonicValve","valveStatusDualIrrigationMode","nasThreeCountdown","nasThreeOnWithCountdown","nasThreeCountdownLeft","nasThreeSingleWateringDuration","nasThreeQuantitativeLiters","quantitativeWatering","naswv03b_quantitative_watering","nasThreeSingleAmountLiters","singleWateringAmount","naswv03b_single_watering_amount","nasThreeSurplusLiters","surplusFlow","naswv03b_surplus_flow","L/min","nasThreeCurrentLiters","waterCurrent","naswv03b_water_current","nasThreeTotalLiters","waterTotal","naswv03b_water_total","nasThreeQuantitativeGallons","nasThreeSingleAmountGallons","nasThreeSurplusGallons","gal/min","nasThreeCurrentGallons","nasThreeTotalGallons","fkv02Threshold","threshold","zvg1WaterConsumed","waterConsumed","water_consumed","zvg1Timer","zvg1TimerTimeLeft","zvg1LastValveDuration","zvlProCountdown","zvlProWaterOnce","gx03Timer","gx03LastDuration","waterSwitchCountdown","waterSwitchDuration","vuwtqx0tWaterConsumed","vuwtqx0tReverseConsumed","vuwtqx0tMonthConsumption","vuwtqx0tDailyConsumption","vuwtqx0tFlowRate","fkv02Countdown","nasThreeStatus","on_auto","button_locked","on_manual_app","on_manual_button","nasThreeRefresh","refresh","nasThreeFlowSwitch","nasThreeWaterTotalReset","reset","nasThreeFault","normal","nasThreeChildLock","zpv01ValveState","valveState","valve_state","unknown","open","zvg1WeatherDelay","zvg1TimerState","active","enabled","zvlProWorkState","gx03ValveState","vuwtqx0tReportPeriod","fkv02PowerOffState","maintain","lastPowerResponseTime","vuwtqx0tFaults","faults","vuwtqx0tMeterId"}
local function b(g)
if type(g)=="number"then return H[g]end
return g
end
local function p(g)local suffix=b(g);if suffix==nil then return nil end;return"concertmirror08464."..suffix end
local t={}
local function q(k)
if type(k)~="number"then return{}end
local x=t[k]if x~=nil then return x end
local n={}t[k]=n
return n
end
local function s(D,k)
if type(D)~="table"then return nil end
local n=q(k)for A,g in ipairs(D)do n[A]=b(g)end
return n
end
local function i(g,E)
if g==nil then return E end
if g==0 then return nil end
return b(g)
end
local function m(attribute_name)
if type(attribute_name)~="string"or attribute_name==""then return nil end
return"set"..attribute_name:sub(1,1):upper()..attribute_name:sub(2)
end
local function J(g)
if type(g)~="table"then return nil end
local n=q(g[6])n.minimum=g[1]n.maximum=g[2]n.step=g[3]n.unit=b(g[4])n.allowed_values=s(g[5],g[7])return n
end
local function w(j,k)
if j==nil and k==nil then return nil end
local n=q(k)n.allowed_values=j
return n
end
local function G(f)
local attribute_name=b(f[4])return{kind="numeric",emit_name=b(f[1]),range_key=b(f[2]),capability_id=p(f[3]),attribute_name=attribute_name,range_attribute_name=b(f[5]),command_name=i(f[6],m(attribute_name)),argument_name=i(f[7],attribute_name),mapping_name=b(f[8]),label=b(f[9]),default_range=J(f[10]),event_minimum=f[11],event_maximum=f[12],event_unit=b(f[13])}
end
local function K(f)
local attribute_name,u,r=b(f[4]),s(f[10],f[12]),s(f[11],f[14])local d=w(r,f[13])return{kind="enum",emit_name=b(f[1]),range_key=b(f[2]),capability_id=p(f[3]),attribute_name=attribute_name,supported_attribute_name=b(f[5]),command_name=i(f[6],m(attribute_name)),argument_name=i(f[7],attribute_name),mapping_name=b(f[8]),label=b(f[9]),supported_values=u,default_range=d}
end
local function M(f)
local attribute_name=b(f[3])return{kind="text",emit_name=b(f[1]),capability_id=p(f[2]),attribute_name=attribute_name,command_name=i(f[4],m(attribute_name)),argument_name=i(f[5],attribute_name),mapping_name=b(f[6]),label=b(f[7]),maximum_length=f[8]}
end
local function z(L,F)
local n={}for _,f in ipairs(L)do n[#n+1]=F(f)end
return n
end
a.numeric=z({{22,nil,22,7,nil,nil,nil,"naswv03b_countdown","Nas Three Countdown",{1,240,1,2,nil,1},nil,nil,2},{23,nil,23,"onWithCountdown",nil,nil,nil,"naswv03b_on_with_countdown","Nas Three On With Countdown",{1,240,1,2,nil,2},nil,nil,2},{24,nil,24,"countdownLeft",nil,0,0,"naswv03b_countdown_left","Nas Three Countdown Left",{0,240,1,2,nil,3},nil,nil,2},{25,nil,25,"singleWateringDuration",nil,0,0,"naswv03b_single_watering_duration","Nas Three Single Watering Duration",{0,2147483647,1,3,nil,4},nil,nil,3},{26,nil,26,27,nil,nil,nil,28,"Nas Three Quantitative Liters",{1,10000,1,1,nil,5},nil,nil,1},{29,nil,29,30,nil,0,0,31,"Nas Three Single Amount Liters",{0,2147483647,1,1,nil,6},nil,nil,1},{32,nil,32,33,nil,0,0,34,"Nas Three Surplus Liters",{0,2147483647,1,1,nil,7},nil,nil,1},{36,nil,36,37,nil,0,0,38,"Nas Three Current Liters",{0,4294967.295,0.001,35,nil,8},nil,nil,35},{39,nil,39,40,nil,0,0,41,"Nas Three Total Liters",{0,4294967.295,0.001,1,nil,9},nil,nil,1},{42,nil,42,27,nil,nil,nil,28,"Nas Three Quantitative Gallons",{1,10000,1,5,nil,10},nil,nil,5},{43,nil,43,30,nil,0,0,31,"Nas Three Single Amount Gallons",{0,2147483647,1,5,nil,11},nil,nil,5},{44,nil,44,33,nil,0,0,34,"Nas Three Surplus Gallons",{0,2147483647,1,5,nil,12},nil,nil,5},{46,nil,46,37,nil,0,0,38,"Nas Three Current Gallons",{0,4294967.295,0.001,45,nil,13},nil,nil,45},{47,nil,47,40,nil,0,0,41,"Nas Three Total Gallons",{0,4294967.295,0.001,5,nil,14},nil,nil,5},{16,nil,16,16,nil,0,0,"battery_voltage","Battery Voltage",{0,10,0.001,"V",nil,15},nil,nil,"V"},{17,nil,17,17,nil,nil,nil,"position","Valve Position Hbnfokum",{0,100,10,8,nil,16},nil,nil,8},{18,nil,18,18,nil,0,0,"position_current","Valve Current Position Hbnfokum",{0,100,10,8,nil,17},nil,nil,8},{48,nil,48,49,nil,nil,nil,49,"Fkv02Threshold",{0,100,10,8,nil,18},nil,nil,8},{50,nil,50,51,nil,0,0,52,"Zvg1Water Consumed",{0,999999,0.01,1,nil,19},nil,nil,1},{53,nil,53,11,nil,nil,nil,11,"Zvg1Timer",{0,60,1,2,nil,20},nil,nil,2},{54,nil,54,"timerTimeLeft",nil,0,0,"timer_time_left","Zvg1Timer Time Left",{0,600,1,2,nil,21},nil,nil,2},{55,nil,55,"lastValveOpenDuration",nil,0,0,"last_valve_open_duration","Zvg1Last Valve Duration",{0,999999,1,2,nil,22},nil,nil,2},{56,nil,56,7,nil,nil,nil,7,"Zvl Pro Countdown",{0,86400,1,3,nil,23},nil,nil,3},{57,nil,57,"waterOnce",nil,0,0,"water_once","Zvl Pro Water Once",{0,999999,1,1,nil,24},nil,nil,1},{58,nil,58,11,nil,nil,nil,11,"Gx03Timer",{1,1440,1,2,nil,25},nil,nil,2},{59,nil,59,"lastDuration",nil,0,0,"last_duration","Gx03Last Duration",{0,999999,1,3,nil,26},nil,nil,3},{60,nil,60,7,nil,nil,nil,7,"Water Switch Countdown",{0,1440,1,2,nil,27},nil,nil,2},{61,nil,61,"valveDuration",nil,0,0,"valve_duration","Water Switch Duration",{0,999999,1,3,nil,28},nil,nil,3},{62,nil,62,51,nil,0,0,52,"Vuwtqx0t Water Consumed",{0,999999,0.001,1,nil,29},nil,nil,1},{63,nil,63,"reverseWaterConsumed",nil,0,0,"reverse_water_consumed","Vuwtqx0t Reverse Consumed",{0,999999,0.001,1,nil,30},nil,nil,1},{64,nil,64,"monthConsumption",nil,0,0,"month_consumption","Vuwtqx0t Month Consumption",{0,999999,0.001,1,nil,31},nil,nil,1},{65,nil,65,"dailyConsumption",nil,0,0,"daily_consumption","Vuwtqx0t Daily Consumption",{0,999999,0.001,1,nil,32},nil,nil,1},{66,nil,66,"flowRate",nil,0,0,"flow_rate","Vuwtqx0t Flow Rate",{0,999999,1,"L/h",nil,33},nil,nil,"L/h"},{67,nil,67,7,nil,nil,nil,"fkv02_countdown","Fkv02Countdown",{0,43200,1,3,nil,34},nil,nil,3}},G)a.enum=z({{68,nil,68,"status",nil,0,0,"naswv03b_status","Nas Three Status",{4,69,70,71,72},{4,69,70,71,72},35,36,35},{73,nil,73,"refreshStatus",nil,nil,nil,"naswv03b_refresh","Nas Three Refresh",{74},{74},37,38,37},{75,nil,75,"flowSwitch",nil,nil,nil,"naswv03b_flow_switch","Nas Three Flow Switch",{4,6},{4,6},39,40,39},{76,nil,76,"waterTotalReset",nil,nil,nil,"naswv03b_water_total_reset","Nas Three Water Total Reset",{77},{77},41,42,41},{78,nil,78,19,nil,0,0,"naswv03b_fault","Nas Three Fault",{79,19},{79,19},43,44,43},{80,nil,80,"childLock",nil,nil,nil,"naswv03b_child_lock","Nas Three Child Lock",{4,6},{4,6},45,46,45},{81,nil,81,82,nil,0,0,83,"Zpv01Valve State",{84,85,12},{84,85,12},47,48,47},{86,nil,86,"weatherDelay",nil,nil,nil,"weather_delay","Zvg1Weather Delay",{13,14,"48h","72h"},{13,14,"48h","72h"},49,50,49},{87,nil,87,"timerState",nil,0,0,"timer_state","Zvg1Timer State",{13,88,89},{13,88,89},51,52,51},{90,nil,90,"workState",nil,0,0,"work_state","Zvl Pro Work State",{9,10,15},{9,10,15},53,54,53},{91,nil,91,82,nil,0,0,83,"Gx03Valve State",{10,9,12},{10,9,12},55,56,55},{92,nil,92,"reportPeriod",nil,nil,nil,"report_period","Vuwtqx0t Report Period",{"1h","2h","3h","4h","6h","8h","12h",14},{"1h","2h","3h","4h","6h","8h","12h",14},57,58,57},{20,nil,20,20,nil,nil,nil,"auto_clean","Auto Clean Ultrasonic Valve",{4,6},{4,6},59,60,59},{21,nil,21,21,nil,0,0,"valve_status","Valve Status Dual Irrigation Mode",{10,9,15},{10,9,15},61,62,61},{93,nil,93,"powerOffState",nil,nil,nil,"fkv02_power_off_state","Fkv02Power Off State",{4,6,94},{4,6,94},63,64,63}},K)a.text=z({{"last_power_response_time",95,95,0,0,nil,"Last power response time",64},{96,96,97,0,0,97,"Vuwtqx0t Faults",256},{98,98,"meterId",0,0,"meter_id","Vuwtqx0t Meter Id",256}},M)a.driver_message={attribute_name="driverMessage",capability_id="concertmirror08464.driverMessage",emit_name="driver_message",label="Driver message",maximum_length=512}a.by_range_key={}a.by_emit_name={}a.by_capability_id={}
local function o(y)
for _,e in ipairs(y)do
a.by_emit_name[e.emit_name]=e
if type(e.capability_id)=="string"and e.capability_id~=""then a.by_capability_id[e.capability_id]=e end
if type(e.range_key)=="string"and e.range_key~=""then a.by_range_key[e.range_key]=e end
end
end
o(a.numeric)o(a.enum)o(a.text)a.by_emit_name[a.driver_message.emit_name]=a.driver_message
a.by_capability_id[a.driver_message.capability_id]=a.driver_message
local function l(j)
if type(j)~="table"then return nil end
local B={}for A,g in ipairs(j)do B[A]=g end
return B
end
function a.resolve_range(v,e)
if type(e)~="table"then return nil end
local d,C=type(e.default_range)=="table"and e.default_range or nil,type(v)=="table"and v.presence_capability_ranges or nil

local h=type(C)=="table"and C[e.range_key]or nil
if type(h)~="table"then h=d end
if type(h)~="table"then return nil end
return{minimum=type(h.minimum)=="number"and h.minimum or(d and d.minimum or nil),maximum=type(h.maximum)=="number"and h.maximum or(d and d.maximum or nil),step=type(h.step)=="number"and h.step or(d and d.step or nil),unit=type(h.unit)=="string"and h.unit or(d and d.unit or nil),allowed_values=type(h.allowed_values)=="table"and l(h.allowed_values)or l(d and d.allowed_values or nil)}
end
return a

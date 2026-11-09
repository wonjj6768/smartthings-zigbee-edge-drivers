local a,H={},{"s","low","high","sensitivity","ON","OFF","keep_time","keepTime","min","medium","10","30","60","120","presence_time","presence_delay","presenceTime","presenceDelay","zg204zlIlluminanceInterval","tre6haifAlarmTime","auin8mzrVacancyDelay","auin8mzrVacantConfirmTime","auin8mzrReferenceLuminance","auin8mzrLightOnLuminance","auin8mzrLightOffLuminance","auin8mzrLuminanceLevel","seq9cm6uIntervalTime","szlm04uFadingTime","zg204zlSensitivity","zg204zlKeepTime","tre6haifPirSensitivity","tre6haifAlarmMode","silent","disarm","auin8mzrVSensitivity","speed_priority","normal_priority","accuracy_priority","auin8mzrOSensitivity","sensitive","normal","cautious","auin8mzrMode","mode","general_model","temporaty_stay","basic_detection","sensor_test","auin8mzrLedStatus","seq9cm6uSensitivity","middle","seq9cm6uWorkState","presence","none","presence_5min","presence_30min","none_5min","none_30min","szlm04uUsbPower","szlm04uSensorSwitch","ay204zSensitivity","ay204zKeepTime","lastPowerResponseTime"}
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
a.numeric=z({{7,7,8,8,"keepTimeRange",nil,nil,7,"Keep time",{0,3600,1,1,nil,1},nil,3600},{15,15,17,17,"presenceTimeRange",nil,nil,15,"Presence time",{0,3600,1,1,nil,2},nil,3600},{16,16,18,18,"presenceDelayRange",nil,nil,16,"Presence delay",{0,3600,1,1,nil,3},nil,3600},{19,nil,19,"illuminanceInterval",nil,nil,nil,"illuminance_interval","Zg204zl Illuminance Interval",{1,720,1,9,nil,4},nil,nil,9},{20,nil,20,"alarmTime",nil,nil,nil,"alarm_time","Tre6haif Alarm Time",{1,180,1,1,nil,5},nil,nil,1},{21,nil,21,"vacancyDelay",nil,nil,nil,"vacancy_delay","Auin8mzr Vacancy Delay",{0,1000,1,1,nil,6},nil,nil,1},{22,nil,22,"vacantConfirmTime",nil,0,0,"vacant_confirm_time","Auin8mzr Vacant Confirm Time",{nil,nil,nil,nil,nil,7}},{23,nil,23,"referenceLuminance",nil,0,0,"reference_luminance","Auin8mzr Reference Luminance",{nil,nil,nil,nil,nil,8}},{24,nil,24,"lightOnLuminance",nil,nil,nil,"light_on_luminance_prefer","Auin8mzr Light On Luminance",{0,10000,1,nil,nil,9}},{25,nil,25,"lightOffLuminance",nil,nil,nil,"light_off_luminance_prefer","Auin8mzr Light Off Luminance",{0,10000,1,nil,nil,10}},{26,nil,26,"luminanceLevel",nil,0,0,"luminance_level","Auin8mzr Luminance Level",{nil,nil,nil,nil,nil,11}},{27,nil,27,"intervalTime",nil,nil,nil,"interval_time","Seq9cm6u Interval Time",{5,720,5,9,nil,12},nil,nil,9},{28,nil,28,"fadingTime",nil,nil,nil,"fading_time","Szlm04u Fading Time",{5,300,1,1,nil,13},nil,nil,1}},G)a.enum=z({{29,nil,29,4,nil,nil,nil,4,"Zg204zl Sensitivity",{2,10,3},{2,10,3},14,15,14},{30,nil,30,8,nil,nil,nil,7,"Zg204zl Keep Time",{11,12,13,14},{11,12,13,14},16,17,16},{31,nil,31,"pirSensitivity",nil,nil,nil,"pir_sensitivity","Tre6haif Pir Sensitivity",{3,2},{3,2},18,19,18},{32,nil,32,"alarmMode",nil,nil,nil,"alarm_mode","Tre6haif Alarm Mode",{"arm",33,34},{"arm",33,34},20,21,20},{35,nil,35,"vSensitivity",nil,nil,nil,"v_sensitivity","Auin8mzr VSensitivity",{36,37,38},{36,37,38},22,23,22},{39,nil,39,"oSensitivity",nil,nil,nil,"o_sensitivity","Auin8mzr OSensitivity",{40,41,42},{40,41,42},24,25,24},{43,nil,43,44,nil,nil,nil,44,"Auin8mzr Mode",{45,46,47,48},{45,46,47,48},26,27,26},{49,nil,49,"ledStatus",nil,nil,nil,"led_status","Auin8mzr Led Status",{5,6},{5,6},28,29,28},{50,nil,50,4,nil,nil,nil,4,"Seq9cm6u Sensitivity",{2,51,3},{2,51,3},30,31,30},{52,nil,52,"workState",nil,0,0,"work_state","Seq9cm6u Work State",{53,54,55,56,57,58},{53,54,55,56,57,58},32,33,32},{59,nil,59,"usbPower",nil,0,0,"usb_power","Szlm04u Usb Power",{5,6},{5,6},34,35,34},{60,nil,60,"sensorSwitch",nil,0,0,"switch","Szlm04u Sensor Switch",{5,6},{5,6},36,37,36},{61,nil,61,4,nil,nil,nil,4,"Ay204z Sensitivity",{2,10,3},{2,10,3},38,39,38},{62,nil,62,8,nil,nil,nil,7,"Ay204z Keep Time",{11,12,13,14},{11,12,13,14},40,41,40}},K)a.text=z({{"last_power_response_time",63,63,0,0,nil,"Last power response time",64}},M)a.driver_message={attribute_name="driverMessage",capability_id="concertmirror08464.driverMessage",emit_name="driver_message",label="Driver message",maximum_length=512}a.by_range_key={}a.by_emit_name={}a.by_capability_id={}
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

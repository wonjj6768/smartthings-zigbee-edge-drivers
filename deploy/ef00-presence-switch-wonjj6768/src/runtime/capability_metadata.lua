local a,H={},{"off","ON","OFF","all","ch2","ch3","sensitivity","s","on","restore","ch1","power_outage_memory","powerOutageMemory","backlight","ch1_and_ch2","ch2_and_ch3","ch1_and_ch3","ch1_2","ch2_3","ch1_3","zg302zlSensitivity","zg302zlTriggerHold","triggerHold","trigger_hold","zis03DetectionRange","zis03FadingTime","zis03Compensation","zis04DetectionDistance","zg302zmSensitivity","zg302zmDistance","distance","zg302zmTriggerHold","zg302zlBacklight","zg302zlPowerOutage","zg302zlAutoOn","autoOn","auto_on","zg302zlAutoOff","autoOff","auto_off","zis03Sensitivity","medium","high","zis03DetectionArea","left","right","zis03Indicator","indicator","zis03Radar","radar","zis03StateReversal","zg302zmBacklight","zg302zmPowerOutage","zg302zmAutoOnV2","zg302zmAutoOffV2","zg302zmTriggerSwitch","lastPowerResponseTime"}
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
a.numeric=z({{21,nil,21,7,nil,nil,nil,7,"Zg302zl Sensitivity",{0,19,1,nil,nil,1}},{22,nil,22,23,nil,nil,nil,24,"Zg302zl Trigger Hold",{5,28800,1,8,nil,2},nil,nil,8},{25,nil,25,"detectionRange",nil,nil,nil,"detection_range","Zis03Detection Range",{1,7,1,nil,nil,3}},{26,nil,26,"fadingTime",nil,nil,nil,"fading_time","Zis03Fading Time",{2,3600,1,8,nil,4},nil,nil,8},{27,nil,27,"compensationCoefficient",nil,nil,nil,"compensation_coefficient","Zis03Compensation",{1,10,1,nil,nil,5}},{28,nil,28,"detectionDistance",nil,0,0,"detection_distance","Zis04Detection Distance",{0,10,0.01,"m",nil,6},nil,nil,"m"},{29,nil,29,7,nil,nil,nil,7,"Zg302zm Sensitivity",{0,19,1,nil,nil,7}},{30,nil,30,31,nil,nil,nil,31,"Zg302zm Distance",{0,6,0.1,"m",nil,8},nil,nil,"m"},{32,nil,32,23,nil,nil,nil,24,"Zg302zm Trigger Hold",{5,28800,1,8,nil,9},nil,nil,8}},G)a.enum=z({{12,12,13,13,"supportedPowerOutageMemories",nil,nil,12,"Power outage memory",{1,9,10},{1,9,10},10,11,10},{33,nil,33,14,nil,nil,nil,14,"Zg302zl Backlight",{2,3},{2,3},12,13,12},{34,nil,34,13,nil,nil,nil,12,"Zg302zl Power Outage",{1,9,10},{1,9,10},14,15,14},{35,nil,35,36,nil,nil,nil,37,"Zg302zl Auto On",{1,4,5,6,15,16,17},{1,4,5,6,15,16,17},16,17,16},{38,nil,38,39,nil,nil,nil,40,"Zg302zl Auto Off",{1,4,5,6,15,16,17},{1,4,5,6,15,16,17},18,19,18},{41,nil,41,7,nil,nil,nil,7,"Zis03Sensitivity",{"low",42,43,"max"},{"low",42,43,"max"},20,21,20},{44,nil,44,"detectionArea",nil,nil,nil,"detection_area","Zis03Detection Area",{4,45,46},{4,45,46},22,23,22},{47,nil,47,48,nil,nil,nil,48,"Zis03Indicator",{2,3},{2,3},24,25,24},{49,nil,49,50,nil,nil,nil,50,"Zis03Radar",{2,3},{2,3},26,27,26},{51,nil,51,"stateReversal",nil,nil,nil,"state_reversal","Zis03State Reversal",{2,3},{2,3},28,29,28},{52,nil,52,14,nil,nil,nil,14,"Zg302zm Backlight",{2,3},{2,3},30,31,30},{53,nil,53,13,nil,nil,nil,12,"Zg302zm Power Outage",{1,9,10},{1,9,10},32,33,32},{54,nil,54,36,nil,nil,nil,37,"Zg302zm Auto On V2",{1,4,11,5,6,18,19,20},{1,4,11,5,6,18,19,20},34,35,34},{55,nil,55,39,nil,nil,nil,40,"Zg302zm Auto Off V2",{1,4,11,5,6,18,19,20},{1,4,11,5,6,18,19,20},36,37,36},{56,nil,56,"triggerSwitch",nil,nil,nil,"trigger_switch","Zg302zm Trigger Switch",{11,5,6},{11,5,6},38,39,38}},K)a.text=z({{"last_power_response_time",57,57,0,0,nil,"Last power response time",64}},M)a.driver_message={attribute_name="driverMessage",capability_id="concertmirror08464.driverMessage",emit_name="driver_message",label="Driver message",maximum_length=512}a.by_range_key={}a.by_emit_name={}a.by_capability_id={}
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

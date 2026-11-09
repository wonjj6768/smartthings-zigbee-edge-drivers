local a,H={},{"off","on","s","restore","off_on","on_off","childLock","release","press","countdown","indicatorMode","power_poll_interval","countdownTimerZclTwelveHours","indicator_mode","power_outage_memory","powerOutageMemory","identify","ts011fPlug1Countdown","bacchusPumpDuration","nousA11zCountdown","hg06620Countdown","nousA6zCountdown","off/on","on/off","ts011fPlug1PowerOutageMemory","ts011fPlug1IndicatorMode","ts011fPlug1ChildLock","ts011fPlug1SwitchTypeButton","bacchusBeeperOnLeak","bacchusTankFull","normal","full","nousA11zPowerBehavior","previous","nousA11zIndicatorMode","nousA11zChildLock","nousA11zSwitchType","nousA11zIdentify","nousA6zPowerMemory","nousA6zIndicator","nousA6zChildLock","nousA6zButtonType","lastPowerResponseTime"}
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
a.numeric=z({{12,12,"powerPollIntervalV2","powerPollInterval","powerPollIntervalRange",nil,nil,12,"Power poll interval",{5,3600,5,3,nil,1},5,3600,3},{18,nil,18,10,nil,nil,nil,"ts011f_plug1_countdown","Ts011f Plug1Countdown",{0,43200,1,3,nil,2},nil,nil,3},{19,nil,19,"pumpDuration",nil,nil,nil,"bacchus_pump_duration","Bacchus Pump Duration",{0,600,1,3,nil,3},nil,nil,3},{20,nil,20,10,nil,nil,nil,"nous_a11z_countdown","Nous A11z Countdown",{0,43200,1,3,nil,4},nil,nil,3},{13,nil,13,13,nil,nil,nil,"countdown_timer","Countdown Timer Zcl Twelve Hours",{0,43200,1,3,nil,5},nil,nil,3},{21,nil,21,10,nil,nil,nil,"hg06620_countdown","Hg06620Countdown",{nil,nil,nil,3,nil,6},nil,nil,3},{22,nil,22,10,nil,nil,nil,"nous_a6z_countdown","Nous A6z Countdown",{0,43200,1,3,nil,7},nil,nil,3}},G)a.enum=z({{14,14,11,11,"supportedIndicatorModes",nil,nil,14,"Indicator mode",{1,23,24,2},{1,23,24,2},8,9,8},{15,15,16,16,"supportedPowerOutageMemories",nil,nil,15,"Power outage memory",{1,2,4},{1,2,4},10,11,10},{25,nil,25,16,nil,nil,nil,"ts011f_plug1_power_outage_memory","Ts011f Plug1Power Outage Memory",{1,2,4},{1,2,4},12,13,12},{26,nil,26,11,nil,nil,nil,"ts011f_plug1_indicator_mode","Ts011f Plug1Indicator Mode",{1,5,6,2},{1,5,6,2},14,15,14},{27,nil,27,7,nil,nil,nil,"ts011f_plug1_child_lock","Ts011f Plug1Child Lock",{1,2},{1,2},16,17,16},{28,nil,28,"switchTypeButton",nil,nil,nil,"ts011f_plug1_switch_type_button","Ts011f Plug1Switch Type Button",{8,9},{8,9},18,19,18},{29,nil,29,"beeperOnLeak",nil,nil,nil,"bacchus_beeper_on_leak","Bacchus Beeper On Leak",{1,2},{1,2},20,21,20},{30,nil,30,"tankFull",nil,0,0,"bacchus_tank_full","Bacchus Tank Full",{31,32},{31,32},22,23,22},{33,nil,33,"powerOnBehavior",nil,nil,nil,"nous_a11z_power_on_behavior","Nous A11z Power Behavior",{1,2,34},{1,2,34},24,25,24},{35,nil,35,11,nil,nil,nil,"nous_a11z_indicator_mode","Nous A11z Indicator Mode",{1,5,6,2},{1,5,6,2},26,27,26},{36,nil,36,7,nil,nil,nil,"nous_a11z_child_lock","Nous A11z Child Lock",{1,2},{1,2},28,29,28},{37,nil,37,"switchType",nil,nil,nil,"nous_a11z_switch_type","Nous A11z Switch Type",{8,9},{8,9},30,31,30},{38,nil,38,17,nil,nil,nil,"nous_a11z_identify","Nous A11z Identify",{17},{17},32,33,32},{7,nil,7,7,nil,nil,nil,"child_lock","Child Lock",{1,2},{1,2},34,35,34},{39,nil,39,"powerMemory",nil,nil,nil,"nous_a6z_power_memory","Nous A6z Power Memory",{1,2,4},{1,2,4},36,37,36},{40,nil,40,"indicator",nil,nil,nil,"nous_a6z_indicator","Nous A6z Indicator",{1,5,6,2},{1,5,6,2},38,39,38},{41,nil,41,7,nil,nil,nil,"nous_a6z_child_lock","Nous A6z Child Lock",{1,2},{1,2},40,41,40},{42,nil,42,"buttonType",nil,nil,nil,"nous_a6z_button_type","Nous A6z Button Type",{8,9},{8,9},42,43,42}},K)a.text=z({{"last_power_response_time",43,43,0,0,nil,"Last power response time",64}},M)a.driver_message={attribute_name="driverMessage",capability_id="concertmirror08464.driverMessage",emit_name="driver_message",label="Driver message",maximum_length=512}a.by_range_key={}a.by_emit_name={}a.by_capability_id={}
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

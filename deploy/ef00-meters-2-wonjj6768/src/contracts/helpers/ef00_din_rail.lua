local C,x=require"protocol.tuya",require"capabilities.events.all"local v,p,o,t=C.converter,x.voltage(),x.current(),x.power()

local function i(b,g)
return type(b)=="string"and
(b==g or b:sub(1,#g+1)==g .."_")
end
local function h(d,g,a)
local r=type(a)=="table"and a.mapping or nil
local w=type(r)=="table"and r.fields or nil
if type(w)=="table"then
for b,m in pairs(w)do
local z=m==true and b or m
if type(z)=="string"and
(i(b,g)or i(z,g))and
d[z]~=nil then
return d[z]end
end
end
return d[g]
end
local function l(j)
j=j or{}
return function(_,d,_,a)
if type(d)~="table"then
return nil
end
local e,s,q,A={},h(d,"voltage",a),h(d,"current",a),h(d,"power",a)if j.voltage and s~=nil then
e[#e+1]=p(nil,s)end
if j.current and q~=nil then
e[#e+1]=o(nil,q)end
if j.power and A~=nil then
e[#e+1]=t(nil,A)end
if #e==0 then
return nil
end
return e
end
end
local f={"short_circuit","surge","overload","leakage_current","temperature","fire","high_power","self_test","over_current","unbalance","over_voltage","under_voltage","miss_phase","outage","magnetism","credit","no_balance"}
local c=v.from_only(function(d)
local u=tonumber(d)if u==nil then
return nil
end
local n={}for y,B in ipairs(f)do
if u%(2 ^ y)>=2 ^(y-1)then
n[#n+1]=B
end
end
if #n==0 then
return"none"end
return table.concat(n,",")
end)
local k={[0]="normal",[1]="over_current_trip",[2]="over_power_trip",[3]="high_temp_trip",[4]="over_voltage_trip",[5]="under_voltage_trip",[6]="over_current_alarm",[7]="over_power_alarm",[8]="high_temp_alarm",[9]="over_voltage_alarm",[10]="under_voltage_alarm",[11]="remote_on",[12]="remote_off",[13]="manual_on",[14]="manual_off",[15]="leakage_trip",[16]="leakage_alarm",[17]="restore_default",[18]="automatic_closing",[19]="electricity_shortage",[20]="electricity_shortage_alarm",[21]="timing_switch_on",[22]="timing_switch_off"}return{emit_metric_bundle=l,circuit_breaker_faults_converter=c,BREAKER_EVENT_LOOKUP=k}

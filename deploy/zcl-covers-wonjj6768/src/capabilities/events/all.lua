local c,j,W,ab,Q,ak,k=require"st.capabilities",require"runtime.capability_metadata",require"runtime.battery_refresh",require"runtime.energy_reset",require"runtime.utf8_text",require"log",{}local u,q,w,p=j.by_emit_name.last_power_response_time,"_tuya_last_power_response_at","waiting",require"runtime.capability_support".is_callable

local function h(v,L)
local f=c[v]local m=f and f[L]or nil
if not p(m)and f and type(f.attributes)=="table"then
m=f.attributes[L]end
return f,m
end
local function s(m,ah)
if type(m)~="table"or type(m.schema)~="table"then
return nil
end
local ac=m.schema
if type(ac.properties)~="table"or type(ac.properties.value)~="table"then
return nil
end
local R,Z=ac.properties.value,ah or"maximum"
if type(R[Z])=="number"then
return R[Z]end
return nil
end
local function P(e,v)
if type(e)~="table"or type(v)~="string"then
return false
end
local X=e.profile and e.profile.components or nil
local aj=type(X)=="table"and X.main or nil
local I=type(aj)=="table"and aj.capabilities or nil
if type(I)~="table"then
return false
end
for _,f in ipairs(I)do
if type(f)=="table"and f.id==v then
return true
end
end
return false
end
local function D(S)
if type(S)~="number"or S<=0 then
return w
end
return os.date("!%Y-%m-%d %H:%M:%S UTC",S)
end
local function E(e)
local a=u
if type(a)~="table"or not P(e,a.capability_id)then
return nil
end
local _,m=h(a.capability_id,a.attribute_name)if not p(m)then
return nil
end
local S=os.time()if type(S)=="number"then
e:set_field(q,S,{persist=false})end
return m{value=D(e:get_field(q))}
end
local function d(e,a,ag)
if type(e)~="table"or type(a)~="table"then
return
end
local ah=string.format("__custom_emit_missing__:%s:%s",a.capability_id or"unknown",ag or"unknown")if e.get_field~=nil and e.set_field~=nil and e:get_field(ah)then
return
end
if e.set_field~=nil then
e:set_field(ah,true,{persist=false})end
ak.error(string.format("[%s] Custom capability emit binding missing (%s): %s.%s",e.label or e.id or"device",ag or"unknown",a.capability_id or"unknown",a.attribute_name or"unknown"))
end
function k.switch()
return function(_,b)
if b then
return c.switch.switch.on()else
return c.switch.switch.off()end
end
end
function k.valve()
return function(_,b)
if b~=nil then
return c.valve.valve(b)end
end
end
function k.occupancy()
return function(_,b)
if b then
return c.occupancySensor.occupancy.occupied()else
return c.occupancySensor.occupancy.unoccupied()end
end
end
function k.alarm()
return function(_,b)
if b=="strobe"then
return c.alarm.alarm.strobe()elseif b=="both"then
return c.alarm.alarm.both()elseif b=="off"then
return c.alarm.alarm.off()elseif b=="siren"or b then
return c.alarm.alarm.siren()else
return c.alarm.alarm.off()end
end
end
function k.temperature(N)
N=N or"C"
return function(_,b)
if b~=nil then
return c.temperatureMeasurement.temperature{value=b,unit=N}end
end
end
function k.humidity()
return function(_,b)
if type(b)=="number"and b>=0 and b<=100 then
return c.relativeHumidityMeasurement.humidity{value=b}end
end
end
function k.battery()
return function(e,b)
if b~=nil then
W.note_report(e)local i=b<0 and 0 or(b>100 and 100 or b)local ai=math.floor(i+0.5)return c.battery.battery(ai)end
end
end
function k.illuminance()
return function(_,b)
if b~=nil then
return c.illuminanceMeasurement.illuminance{value=b}end
end
end
local function l(n)
if type(n)~="table"then
return nil
end
if type(n.component_id)=="string"and n.component_id~=""then
return n.component_id
end
if type(n.component)=="table"and type(n.component.id)=="string"and n.component.id~=""then
return n.component.id
end
return nil
end
local function o(n)
if type(n)=="table"and type(n.component)=="string"and n.component~=""then
return n.component
end
return nil
end
function k.power()
return function(e,b,t,r)
if b~=nil then
local K,A=c.powerMeter.power{value=b,unit="W"},E(e)if A~=nil then
local x=l(r)or l(t)or o(r)or o(t)if x~=nil and x~="main"then
e:emit_event(A)return K
end
return{K,A}end
return K
end
end
end
function k.energy()
return function(e,b,t,r)
if b~=nil then
local x=l(r)or l(t)or o(r)or o(t)return c.energyMeter.energy{value=ab.apply_report(e,b,x),unit="kWh"}end
end
end
function k.voltage()
return function(_,b)
if b~=nil then
return c.voltageMeasurement.voltage{value=b,unit="V"}end
end
end
function k.current()
return function(_,b)
if b~=nil then
return c.currentMeasurement.current{value=b,unit="A"}end
end
end
function k.level()
return function(_,b)
if b~=nil then
local i=b<0 and 0 or(b>100 and 100 or b)return c.switchLevel.level(math.floor(i+0.5))end
end
end
function k.shade_level()
return function(_,b)
if b~=nil then
return c.windowShadeLevel.shadeLevel(b)end
end
end
local function O(a)
return function(e,b)
if b==nil then
return
end
local i,G,F=b,a.event_minimum or(a.default_range and a.default_range.minimum or nil),a.event_maximum or(a.default_range and a.default_range.maximum or nil)
local _,g=h(a.capability_id,a.attribute_name)local C,B=s(g,"minimum"),s(g)if type(C)=="number"then
if type(G)~="number"or C>G then
G=C
end
end
if type(B)=="number"then
if type(F)~="number"or B<F then
F=B
end
end
if type(G)=="number"and i<G then
i=G
end
if type(F)=="number"and i>F then
i=F
end
local f=c[a.capability_id]if not p(g)and f and type(f.attributes)=="table"then
g=f.attributes[a.attribute_name]end
if not p(g)then
if f==nil then
d(e,a,"capability")else
d(e,a,"attribute")end
return
end
local N=a.event_unit or(a.default_range and a.default_range.unit or nil)if N~=nil then
return g{value=i,unit=N}end
return g{value=i}
end
end
local function U(a)
return function(e,b)
if type(b)=="boolean"and type(a.supported_values)=="table"then
local af,ae,Y,ad,y=false,false,false,false,0




for _,J in ipairs(a.supported_values)do
y=y+1
if J=="on"then
af=true
elseif J=="off"then
ae=true
elseif J=="normal"then
Y=true
elseif J=="low"then
ad=true
end
end
if af and ae then
b=b and"on"or"off"elseif y==2 and Y and ad then
b=b and"low"or"normal"end
end
if type(b)~="string"or b==""then
return
end
local f,g=h(a.capability_id,a.attribute_name)if not p(g)then
if f==nil then
d(e,a,"capability")else
d(e,a,"attribute")end
return
end
return g{value=b}
end
end
local function V(a,T)
return function(e,b)
if type(b)~="string"or(b==""and not(T and T.allow_empty))then
return
end
local f,g=h(a.capability_id,a.attribute_name)if not p(g)then
if f==nil then
d(e,a,"capability")else
d(e,a,"attribute")end
return
end
local z=a.maximum_length or Q.length(b)local M=Q.truncate(b,z)if M==nil then
return
end
return g{value=M}
end
end
for _,a in ipairs(j.numeric)do
k[a.emit_name]=function()
return O(a)
end
end
for _,a in ipairs(j.enum)do
k[a.emit_name]=function()
return U(a)
end
end
for _,a in ipairs(j.text)do
k[a.emit_name]=function(T)
return V(a,T)
end
end
function k.driver_message()
return function(e,b)
if type(b)=="string"and b~=""then
local a=j.driver_message
local f,g=h(a.capability_id,a.attribute_name)if not p(g)then
if f==nil then
d(e,a,"capability")else
d(e,a,"attribute")end
return
end
local z=a.maximum_length or 512
local M=Q.truncate(b,z)if M==nil then
return
end
return g{value=M}end
end
end
function k.thermostat_operating_state()
return function(_,b)
if b~=nil then
return c.thermostatOperatingState.thermostatOperatingState(b)end
end
end
function k.fan_mode()
return function(_,b)
if b~=nil then
return c.fanMode.fanMode(b)end
end
end
function k.color_temperature()
return function(_,b)
if b~=nil then
local i=b<1 and 1 or(b>30000 and 30000 or b)return c.colorTemperature.colorTemperature(i)end
end
end
function k.color_hue()
return function(_,b)
if b~=nil then
local i=b<0 and 0 or(b>100 and 100 or b)return c.colorControl.hue(i)end
end
end
function k.color_saturation()
return function(_,b)
if b~=nil then
local i=b<0 and 0 or(b>100 and 100 or b)return c.colorControl.saturation(i)end
end
end
function k.shade_state()
return function(_,b)
if b~=nil then
return c.windowShade.windowShade(b)end
end
end
function k.value(H,N)
return function(_,b)
if b~=nil then
if N then
return H{value=b,unit=N}else
return H(b)end
end
end
end
return k

local b,k,X,ab,Q,ak,i=require"st.capabilities",require"runtime.capability_metadata",require"runtime.battery_refresh",require"runtime.energy_reset",require"runtime.utf8_text",require"log",{}local v,q,x,p=k.by_emit_name.last_power_response_time,"_tuya_last_power_response_at","waiting",require"runtime.capability_support".is_callable

local function h(w,M)
local f=b[w]local m=f and f[M]or nil
if not p(m)and f and type(f.attributes)=="table"then
m=f.attributes[M]end
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
local R,aa=ac.properties.value,ah or"maximum"
if type(R[aa])=="number"then
return R[aa]end
return nil
end
local function P(e,w)
if type(e)~="table"or type(w)~="string"then
return false
end
local Y=e.profile and e.profile.components or nil
local aj=type(Y)=="table"and Y.main or nil
local J=type(aj)=="table"and aj.capabilities or nil
if type(J)~="table"then
return false
end
for _,f in ipairs(J)do
if type(f)=="table"and f.id==w then
return true
end
end
return false
end
local function E(S)
if type(S)~="number"or S<=0 then
return x
end
return os.date("!%Y-%m-%d %H:%M:%S UTC",S)
end
local function F(e)
local c=v
if type(c)~="table"or not P(e,c.capability_id)then
return nil
end
local _,m=h(c.capability_id,c.attribute_name)if not p(m)then
return nil
end
local S=os.time()if type(S)=="number"then
e:set_field(q,S,{persist=false})end
return m{value=E(e:get_field(q))}
end
local function d(e,c,ag)
if type(e)~="table"or type(c)~="table"then
return
end
local ah=string.format("__custom_emit_missing__:%s:%s",c.capability_id or"unknown",ag or"unknown")if e.get_field~=nil and e.set_field~=nil and e:get_field(ah)then
return
end
if e.set_field~=nil then
e:set_field(ah,true,{persist=false})end
ak.error(string.format("[%s] Custom capability emit binding missing (%s): %s.%s",e.label or e.id or"device",ag or"unknown",c.capability_id or"unknown",c.attribute_name or"unknown"))
end
function i.switch()
return function(_,a)
if a then
return b.switch.switch.on()else
return b.switch.switch.off()end
end
end
function i.contact()
return function(_,a)
if a then
return b.contactSensor.contact.open()else
return b.contactSensor.contact.closed()end
end
end
function i.motion()
return function(_,a)
if a then
return b.motionSensor.motion.active()else
return b.motionSensor.motion.inactive()end
end
end
function i.smoke()
return function(_,a)
if a then
return b.smokeDetector.smoke.detected()else
return b.smokeDetector.smoke.clear()end
end
end
function i.carbon_monoxide()
return function(_,a)
if a then
return b.carbonMonoxideDetector.carbonMonoxide.detected()else
return b.carbonMonoxideDetector.carbonMonoxide.clear()end
end
end
function i.tamper()
return function(_,a)
if a then
return b.tamperAlert.tamper.detected()else
return b.tamperAlert.tamper.clear()end
end
end
function i.presence()
return function(_,a)
if a then
return b.presenceSensor.presence.present()else
return b.presenceSensor.presence.not_present()end
end
end
function i.gas()
return function(_,a)
if a then
return b.gasDetector.gas.detected()else
return b.gasDetector.gas.clear()end
end
end
function i.valve()
return function(_,a)
if a~=nil then
return b.valve.valve(a)end
end
end
function i.occupancy()
return function(_,a)
if a then
return b.occupancySensor.occupancy.occupied()else
return b.occupancySensor.occupancy.unoccupied()end
end
end
function i.alarm()
return function(_,a)
if a=="strobe"then
return b.alarm.alarm.strobe()elseif a=="both"then
return b.alarm.alarm.both()elseif a=="off"then
return b.alarm.alarm.off()elseif a=="siren"or a then
return b.alarm.alarm.siren()else
return b.alarm.alarm.off()end
end
end
function i.temperature(u)
u=u or"C"
return function(_,a)
if a~=nil then
return b.temperatureMeasurement.temperature{value=a,unit=u}end
end
end
function i.humidity()
return function(_,a)
if type(a)=="number"and a>=0 and a<=100 then
return b.relativeHumidityMeasurement.humidity{value=a}end
end
end
function i.battery()
return function(e,a)
if a~=nil then
X.note_report(e)local j=a<0 and 0 or(a>100 and 100 or a)local ai=math.floor(j+0.5)return b.battery.battery(ai)end
end
end
function i.illuminance()
return function(_,a)
if a~=nil then
return b.illuminanceMeasurement.illuminance{value=a}end
end
end
function i.co2()
return function(_,a)
if a~=nil then
return b.carbonDioxideMeasurement.carbonDioxide{value=a,unit="ppm"}end
end
end
function i.voc(u)
u=u or"ppb"
return function(_,a)
if a~=nil then
return b.tvocMeasurement.tvocLevel{value=a,unit=u}end
end
end
function i.formaldehyde(u)
u=u or"mg/m^3"
return function(_,a)
if a~=nil then
return b.formaldehydeMeasurement.formaldehydeLevel{value=a,unit=u}end
end
end
function i.pm25()
return function(_,a)
if a~=nil then
return b.fineDustSensor.fineDustLevel{value=a}end
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
function i.power()
return function(e,a,t,r)
if a~=nil then
local L,B=b.powerMeter.power{value=a,unit="W"},F(e)if B~=nil then
local y=l(r)or l(t)or o(r)or o(t)if y~=nil and y~="main"then
e:emit_event(B)return L
end
return{L,B}end
return L
end
end
end
function i.energy()
return function(e,a,t,r)
if a~=nil then
local y=l(r)or l(t)or o(r)or o(t)return b.energyMeter.energy{value=ab.apply_report(e,a,y),unit="kWh"}end
end
end
function i.voltage()
return function(_,a)
if a~=nil then
return b.voltageMeasurement.voltage{value=a,unit="V"}end
end
end
function i.current()
return function(_,a)
if a~=nil then
return b.currentMeasurement.current{value=a,unit="A"}end
end
end
function i.level()
return function(_,a)
if a~=nil then
local j=a<0 and 0 or(a>100 and 100 or a)return b.switchLevel.level(math.floor(j+0.5))end
end
end
function i.soil_moisture()
return function(_,a)
if a~=nil then
local j=a<0 and 0 or(a>100 and 100 or a)return b["concertmirror08464.soilMoisture"].soilMoisture{value=j,unit="%"}end
end
end
local function O(c)
return function(e,a)
if a==nil then
return
end
local j,H,G=a,c.event_minimum or(c.default_range and c.default_range.minimum or nil),c.event_maximum or(c.default_range and c.default_range.maximum or nil)
local _,g=h(c.capability_id,c.attribute_name)local D,C=s(g,"minimum"),s(g)if type(D)=="number"then
if type(H)~="number"or D>H then
H=D
end
end
if type(C)=="number"then
if type(G)~="number"or C<G then
G=C
end
end
if type(H)=="number"and j<H then
j=H
end
if type(G)=="number"and j>G then
j=G
end
local f=b[c.capability_id]if not p(g)and f and type(f.attributes)=="table"then
g=f.attributes[c.attribute_name]end
if not p(g)then
if f==nil then
d(e,c,"capability")else
d(e,c,"attribute")end
return
end
local u=c.event_unit or(c.default_range and c.default_range.unit or nil)if u~=nil then
return g{value=j,unit=u}end
return g{value=j}
end
end
local function V(c)
return function(e,a)
if type(a)=="boolean"and type(c.supported_values)=="table"then
local af,ae,Z,ad,z=false,false,false,false,0




for _,K in ipairs(c.supported_values)do
z=z+1
if K=="on"then
af=true
elseif K=="off"then
ae=true
elseif K=="normal"then
Z=true
elseif K=="low"then
ad=true
end
end
if af and ae then
a=a and"on"or"off"elseif z==2 and Z and ad then
a=a and"low"or"normal"end
end
if type(a)~="string"or a==""then
return
end
local f,g=h(c.capability_id,c.attribute_name)if not p(g)then
if f==nil then
d(e,c,"capability")else
d(e,c,"attribute")end
return
end
return g{value=a}
end
end
local function W(c,T)
return function(e,a)
if type(a)~="string"or(a==""and not(T and T.allow_empty))then
return
end
local f,g=h(c.capability_id,c.attribute_name)if not p(g)then
if f==nil then
d(e,c,"capability")else
d(e,c,"attribute")end
return
end
local A=c.maximum_length or Q.length(a)local N=Q.truncate(a,A)if N==nil then
return
end
return g{value=N}
end
end
for _,c in ipairs(k.numeric)do
i[c.emit_name]=function()
return O(c)
end
end
for _,c in ipairs(k.enum)do
i[c.emit_name]=function()
return V(c)
end
end
for _,c in ipairs(k.text)do
i[c.emit_name]=function(T)
return W(c,T)
end
end
function i.driver_message()
return function(e,a)
if type(a)=="string"and a~=""then
local c=k.driver_message
local f,g=h(c.capability_id,c.attribute_name)if not p(g)then
if f==nil then
d(e,c,"capability")else
d(e,c,"attribute")end
return
end
local A=c.maximum_length or 512
local N=Q.truncate(a,A)if N==nil then
return
end
return g{value=N}end
end
end
function i.fan_mode()
return function(_,a)
if a~=nil then
return b.fanMode.fanMode(a)end
end
end
function i.color_temperature()
return function(_,a)
if a~=nil then
local j=a<1 and 1 or(a>30000 and 30000 or a)return b.colorTemperature.colorTemperature(j)end
end
end
function i.color_hue()
return function(_,a)
if a~=nil then
local j=a<0 and 0 or(a>100 and 100 or a)return b.colorControl.hue(j)end
end
end
function i.color_saturation()
return function(_,a)
if a~=nil then
local j=a<0 and 0 or(a>100 and 100 or a)return b.colorControl.saturation(j)end
end
end
function i.value(I,u)
return function(_,a)
if a~=nil then
if u then
return I{value=a,unit=u}else
return I(a)end
end
end
end
return i

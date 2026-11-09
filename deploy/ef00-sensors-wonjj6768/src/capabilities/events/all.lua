local b,k,Y,ae,S,ar,i=require"st.capabilities",require"runtime.capability_metadata",require"runtime.battery_refresh",require"runtime.energy_reset",require"runtime.utf8_text",require"log",{}local v,r,x,p=k.by_emit_name.last_power_response_time,"_tuya_last_power_response_at","waiting",require"runtime.capability_support".is_callable

local function h(w,M)
local f=b[w]local m=f and f[M]or nil
if not p(m)and f and type(f.attributes)=="table"then
m=f.attributes[M]end
return f,m
end
local function t(m,am)
if type(m)~="table"or type(m.schema)~="table"then
return nil
end
local af=m.schema
if type(af.properties)~="table"or type(af.properties.value)~="table"then
return nil
end
local T,ad=af.properties.value,am or"maximum"
if type(T[ad])=="number"then
return T[ad]end
return nil
end
local function R(e,w)
if type(e)~="table"or type(w)~="string"then
return false
end
local Z=e.profile and e.profile.components or nil
local ap=type(Z)=="table"and Z.main or nil
local J=type(ap)=="table"and ap.capabilities or nil
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
local function E(U)
if type(U)~="number"or U<=0 then
return x
end
return os.date("!%Y-%m-%d %H:%M:%S UTC",U)
end
local function F(e)
local c=v
if type(c)~="table"or not R(e,c.capability_id)then
return nil
end
local _,m=h(c.capability_id,c.attribute_name)if not p(m)then
return nil
end
local U=os.time()if type(U)=="number"then
e:set_field(r,U,{persist=false})end
return m{value=E(e:get_field(r))}
end
local function d(e,c,ak)
if type(e)~="table"or type(c)~="table"then
return
end
local am=string.format("__custom_emit_missing__:%s:%s",c.capability_id or"unknown",ak or"unknown")if e.get_field~=nil and e.set_field~=nil and e:get_field(am)then
return
end
if e.set_field~=nil then
e:set_field(am,true,{persist=false})end
ar.error(string.format("[%s] Custom capability emit binding missing (%s): %s.%s",e.label or e.id or"device",ak or"unknown",c.capability_id or"unknown",c.attribute_name or"unknown"))
end
function i.all(...)
local al={...}
return function(e,a,an,ac)
local N={}for _,ag in ipairs(al)do
if type(ag)=="function"then
local aa=ag(e,a,an,ac)if type(aa)=="table"and aa[1]~=nil then
for _,aq in ipairs(aa)do
N[#N+1]=aq
end
elseif aa~=nil then
N[#N+1]=aa
end
end
end
if #N>0 then
return N
end
end
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
function i.temperature(q)
q=q or"C"
return function(_,a)
if a~=nil then
return b.temperatureMeasurement.temperature{value=a,unit=q}end
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
Y.note_report(e)local j=a<0 and 0 or(a>100 and 100 or a)local ao=math.floor(j+0.5)return b.battery.battery(ao)end
end
end
function i.illuminance()
return function(_,a)
if a~=nil then
return b.illuminanceMeasurement.illuminance{value=a}end
end
end
function i.atmospheric_pressure()
return function(_,a)
if a~=nil then
return b.atmosphericPressureMeasurement.atmosphericPressure{value=a,unit="kPa"}end
end
end
function i.co2()
return function(_,a)
if a~=nil then
return b.carbonDioxideMeasurement.carbonDioxide{value=a,unit="ppm"}end
end
end
function i.voc(q)
q=q or"ppb"
return function(_,a)
if a~=nil then
return b.tvocMeasurement.tvocLevel{value=a,unit=q}end
end
end
function i.formaldehyde(q)
q=q or"mg/m^3"
return function(_,a)
if a~=nil then
return b.formaldehydeMeasurement.formaldehydeLevel{value=a,unit=q}end
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
return function(e,a,u,s)
if a~=nil then
local L,B=b.powerMeter.power{value=a,unit="W"},F(e)if B~=nil then
local y=l(s)or l(u)or o(s)or o(u)if y~=nil and y~="main"then
e:emit_event(B)return L
end
return{L,B}end
return L
end
end
end
function i.energy()
return function(e,a,u,s)
if a~=nil then
local y=l(s)or l(u)or o(s)or o(u)return b.energyMeter.energy{value=ae.apply_report(e,a,y),unit="kWh"}end
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
function i.probe_temperature(q)
q=q or"C"
return function(_,a)
if a~=nil then
return b["connectamber53538.probeTemperature"].temperature{value=a,unit=q}end
end
end
function i.soil_ec()
return function(_,a)
if a~=nil then
return b["concertmirror08464.soilEc"].soilEc{value=a,unit="uS/cm"}end
end
end
local function Q(c)
return function(e,a)
if a==nil then
return
end
local j,H,G=a,c.event_minimum or(c.default_range and c.default_range.minimum or nil),c.event_maximum or(c.default_range and c.default_range.maximum or nil)
local _,g=h(c.capability_id,c.attribute_name)local D,C=t(g,"minimum"),t(g)if type(D)=="number"then
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
local q=c.event_unit or(c.default_range and c.default_range.unit or nil)if q~=nil then
return g{value=j,unit=q}end
return g{value=j}
end
end
local function W(c)
return function(e,a)
if type(a)=="boolean"and type(c.supported_values)=="table"then
local aj,ai,ab,ah,z=false,false,false,false,0




for _,K in ipairs(c.supported_values)do
z=z+1
if K=="on"then
aj=true
elseif K=="off"then
ai=true
elseif K=="normal"then
ab=true
elseif K=="low"then
ah=true
end
end
if aj and ai then
a=a and"on"or"off"elseif z==2 and ab and ah then
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
local function X(c,V)
return function(e,a)
if type(a)~="string"or(a==""and not(V and V.allow_empty))then
return
end
local f,g=h(c.capability_id,c.attribute_name)if not p(g)then
if f==nil then
d(e,c,"capability")else
d(e,c,"attribute")end
return
end
local A=c.maximum_length or S.length(a)local O=S.truncate(a,A)if O==nil then
return
end
return g{value=O}
end
end
for _,c in ipairs(k.numeric)do
i[c.emit_name]=function()
return Q(c)
end
end
for _,c in ipairs(k.enum)do
i[c.emit_name]=function()
return W(c)
end
end
for _,c in ipairs(k.text)do
i[c.emit_name]=function(V)
return X(c,V)
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
local O=S.truncate(a,A)if O==nil then
return
end
return g{value=O}end
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
function i.value(I,q)
return function(_,a)
if a~=nil then
if q then
return I{value=a,unit=q}else
return I(a)end
end
end
end
return i

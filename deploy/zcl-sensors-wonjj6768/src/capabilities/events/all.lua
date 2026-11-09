local b,k,X,ab,R,ak,h=require"st.capabilities",require"runtime.capability_metadata",require"runtime.battery_refresh",require"runtime.energy_reset",require"runtime.utf8_text",require"log",{}local v,r,x,q=k.by_emit_name.last_power_response_time,"_tuya_last_power_response_at","waiting",require"runtime.capability_support".is_callable

local function i(w,M)
local f=b[w]local n=f and f[M]or nil
if not q(n)and f and type(f.attributes)=="table"then
n=f.attributes[M]end
return f,n
end
local function t(n,ah)
if type(n)~="table"or type(n.schema)~="table"then
return nil
end
local ac=n.schema
if type(ac.properties)~="table"or type(ac.properties.value)~="table"then
return nil
end
local S,aa=ac.properties.value,ah or"maximum"
if type(S[aa])=="number"then
return S[aa]end
return nil
end
local function Q(e,w)
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
local function E(T)
if type(T)~="number"or T<=0 then
return x
end
return os.date("!%Y-%m-%d %H:%M:%S UTC",T)
end
local function F(e)
local c=v
if type(c)~="table"or not Q(e,c.capability_id)then
return nil
end
local _,n=i(c.capability_id,c.attribute_name)if not q(n)then
return nil
end
local T=os.time()if type(T)=="number"then
e:set_field(r,T,{persist=false})end
return n{value=E(e:get_field(r))}
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
function h.switch()
return function(_,a)
if a then
return b.switch.switch.on()else
return b.switch.switch.off()end
end
end
function h.contact()
return function(_,a)
if a then
return b.contactSensor.contact.open()else
return b.contactSensor.contact.closed()end
end
end
function h.motion()
return function(_,a)
if a then
return b.motionSensor.motion.active()else
return b.motionSensor.motion.inactive()end
end
end
function h.water()
return function(_,a)
if a then
return b.waterSensor.water.wet()else
return b.waterSensor.water.dry()end
end
end
function h.smoke()
return function(_,a)
if a then
return b.smokeDetector.smoke.detected()else
return b.smokeDetector.smoke.clear()end
end
end
function h.carbon_monoxide()
return function(_,a)
if a then
return b.carbonMonoxideDetector.carbonMonoxide.detected()else
return b.carbonMonoxideDetector.carbonMonoxide.clear()end
end
end
function h.tamper()
return function(_,a)
if a then
return b.tamperAlert.tamper.detected()else
return b.tamperAlert.tamper.clear()end
end
end
function h.gas()
return function(_,a)
if a then
return b.gasDetector.gas.detected()else
return b.gasDetector.gas.clear()end
end
end
function h.hardware_fault()
return function(_,a)
if a then
return b.hardwareFault.hardwareFault.detected()end
return b.hardwareFault.hardwareFault.clear()
end
end
function h.valve()
return function(_,a)
if a~=nil then
return b.valve.valve(a)end
end
end
function h.occupancy()
return function(_,a)
if a then
return b.occupancySensor.occupancy.occupied()else
return b.occupancySensor.occupancy.unoccupied()end
end
end
function h.acceleration()
return function(_,a)
if a then
return b.accelerationSensor.acceleration.active()else
return b.accelerationSensor.acceleration.inactive()end
end
end
function h.alarm()
return function(_,a)
if a=="strobe"then
return b.alarm.alarm.strobe()elseif a=="both"then
return b.alarm.alarm.both()elseif a=="off"then
return b.alarm.alarm.off()elseif a=="siren"or a then
return b.alarm.alarm.siren()else
return b.alarm.alarm.off()end
end
end
function h.temperature(m)
m=m or"C"
return function(_,a)
if a~=nil then
return b.temperatureMeasurement.temperature{value=a,unit=m}end
end
end
function h.humidity()
return function(_,a)
if type(a)=="number"and a>=0 and a<=100 then
return b.relativeHumidityMeasurement.humidity{value=a}end
end
end
function h.battery()
return function(e,a)
if a~=nil then
X.note_report(e)local j=a<0 and 0 or(a>100 and 100 or a)local ai=math.floor(j+0.5)return b.battery.battery(ai)end
end
end
function h.illuminance()
return function(_,a)
if a~=nil then
return b.illuminanceMeasurement.illuminance{value=a}end
end
end
function h.atmospheric_pressure()
return function(_,a)
if a~=nil then
return b.atmosphericPressureMeasurement.atmosphericPressure{value=a,unit="kPa"}end
end
end
function h.voc(m)
m=m or"ppb"
return function(_,a)
if a~=nil then
return b.tvocMeasurement.tvocLevel{value=a,unit=m}end
end
end
function h.formaldehyde(m)
m=m or"mg/m^3"
return function(_,a)
if a~=nil then
return b.formaldehydeMeasurement.formaldehydeLevel{value=a,unit=m}end
end
end
function h.pm25()
return function(_,a)
if a~=nil then
return b.fineDustSensor.fineDustLevel{value=a}end
end
end
local function l(o)
if type(o)~="table"then
return nil
end
if type(o.component_id)=="string"and o.component_id~=""then
return o.component_id
end
if type(o.component)=="table"and type(o.component.id)=="string"and o.component.id~=""then
return o.component.id
end
return nil
end
local function p(o)
if type(o)=="table"and type(o.component)=="string"and o.component~=""then
return o.component
end
return nil
end
function h.power()
return function(e,a,u,s)
if a~=nil then
local L,B=b.powerMeter.power{value=a,unit="W"},F(e)if B~=nil then
local y=l(s)or l(u)or p(s)or p(u)if y~=nil and y~="main"then
e:emit_event(B)return L
end
return{L,B}end
return L
end
end
end
function h.energy()
return function(e,a,u,s)
if a~=nil then
local y=l(s)or l(u)or p(s)or p(u)return b.energyMeter.energy{value=ab.apply_report(e,a,y),unit="kWh"}end
end
end
function h.voltage()
return function(_,a)
if a~=nil then
return b.voltageMeasurement.voltage{value=a,unit="V"}end
end
end
function h.current()
return function(_,a)
if a~=nil then
return b.currentMeasurement.current{value=a,unit="A"}end
end
end
function h.audio_volume()
return function(_,a)
if a~=nil then
local j=a<0 and 0 or(a>100 and 100 or a)return b.audioVolume.volume(math.floor(j+0.5))end
end
end
function h.level()
return function(_,a)
if a~=nil then
local j=a<0 and 0 or(a>100 and 100 or a)return b.switchLevel.level(math.floor(j+0.5))end
end
end
function h.heating_setpoint(m)
m=m or"C"
return function(_,a)
if a~=nil then
return b.thermostatHeatingSetpoint.heatingSetpoint{value=a,unit=m}end
end
end
function h.cooling_setpoint(m)
m=m or"C"
return function(_,a)
if a~=nil then
return b.thermostatCoolingSetpoint.coolingSetpoint{value=a,unit=m}end
end
end
local function P(c)
return function(e,a)
if a==nil then
return
end
local j,H,G=a,c.event_minimum or(c.default_range and c.default_range.minimum or nil),c.event_maximum or(c.default_range and c.default_range.maximum or nil)
local _,g=i(c.capability_id,c.attribute_name)local D,C=t(g,"minimum"),t(g)if type(D)=="number"then
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
local f=b[c.capability_id]if not q(g)and f and type(f.attributes)=="table"then
g=f.attributes[c.attribute_name]end
if not q(g)then
if f==nil then
d(e,c,"capability")else
d(e,c,"attribute")end
return
end
local m=c.event_unit or(c.default_range and c.default_range.unit or nil)if m~=nil then
return g{value=j,unit=m}end
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
local f,g=i(c.capability_id,c.attribute_name)if not q(g)then
if f==nil then
d(e,c,"capability")else
d(e,c,"attribute")end
return
end
return g{value=a}
end
end
local function W(c,U)
return function(e,a)
if type(a)~="string"or(a==""and not(U and U.allow_empty))then
return
end
local f,g=i(c.capability_id,c.attribute_name)if not q(g)then
if f==nil then
d(e,c,"capability")else
d(e,c,"attribute")end
return
end
local A=c.maximum_length or R.length(a)local N=R.truncate(a,A)if N==nil then
return
end
return g{value=N}
end
end
for _,c in ipairs(k.numeric)do
h[c.emit_name]=function()
return P(c)
end
end
for _,c in ipairs(k.enum)do
h[c.emit_name]=function()
return V(c)
end
end
for _,c in ipairs(k.text)do
h[c.emit_name]=function(U)
return W(c,U)
end
end
function h.driver_message()
return function(e,a)
if type(a)=="string"and a~=""then
local c=k.driver_message
local f,g=i(c.capability_id,c.attribute_name)if not q(g)then
if f==nil then
d(e,c,"capability")else
d(e,c,"attribute")end
return
end
local A=c.maximum_length or 512
local N=R.truncate(a,A)if N==nil then
return
end
return g{value=N}end
end
end
function h.thermostat_mode()
return function(_,a)
if a~=nil then
return b.thermostatMode.thermostatMode(a)end
end
end
function h.thermostat_operating_state()
return function(_,a)
if a~=nil then
return b.thermostatOperatingState.thermostatOperatingState(a)end
end
end
function h.fan_mode()
return function(_,a)
if a~=nil then
return b.fanMode.fanMode(a)end
end
end
function h.color_temperature()
return function(_,a)
if a~=nil then
local j=a<1 and 1 or(a>30000 and 30000 or a)return b.colorTemperature.colorTemperature(j)end
end
end
function h.color_hue()
return function(_,a)
if a~=nil then
local j=a<0 and 0 or(a>100 and 100 or a)return b.colorControl.hue(j)end
end
end
function h.color_saturation()
return function(_,a)
if a~=nil then
local j=a<0 and 0 or(a>100 and 100 or a)return b.colorControl.saturation(j)end
end
end
function h.value(I,m)
return function(_,a)
if a~=nil then
if m then
return I{value=a,unit=m}else
return I(a)end
end
end
end
return h

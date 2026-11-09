local function q(o)
local n,F,A,D=require"capabilities.events.all",require"st.zigbee.data_types",require"st.zigbee.constants",require"st.utils.safe_xy_to_hsv"
local function p(i,z)
if type(i)~="table"then
i={}end
if type(z)~="table"then
return i
end
for B,l in pairs(z)do
i[B]=l
end
return i
end
local function m(i,f)
if type(i)~="table"or type(f)~="table"then
return i
end
for B,l in pairs(f)do
if i[B]==nil then
i[B]=l
end
end
return i
end
local function h(d,k)
local e={}if type(d)=="string"then
e.name=d
else
p(e,d)end
p(e,k)return e
end
local function E(l,w,v)
if l<w then
return w
end
if l>v then
return v
end
return l
end
local function j()
return{
from=function(l)
if type(l)~="number"then
return l
end
local x=E(l,0,100)if x<=0 then
return"closed"end
if x>=100 then
return"open"end
return"partially open"
end
}
end
local function a(u,t,r)
return{minimum_interval=u,maximum_interval=t,reportable_change=r,read_on_configure=true}
end
local function c(...)
local y={}for _,f in ipairs{...}do
m(y,f)end
return y
end
local function b(G,C,s)
o[G]=function(d,k)
local e=h(d,k)local g,f=e.configure_reporting,s(e)
e.configure_reporting=nil
if g==false then
f.minimum_interval=nil
f.maximum_interval=nil
f.reportable_change=nil
f.physical_reportable_change=nil
f.reporting_defaults=nil
end
m(e,f)return C(e)
end
end
b("battery",o.power_configuration_battery,function()
return c({emit=n.battery(),scale=2},a(300,21600,2))
end)
b("switch",o.on_off,function(k)
local g=k.configure_reporting
k.configure_reporting=nil
if g==false then
return{emit=n.switch()}end
return c({emit=n.switch()},a(0,300,nil))
end)
o.tuya_magic_packet=function(d,k)
local e=h(d,k)m(e,{name="tuya_magic_packet",read_only=true,read_on_configure=true})return o.cluster_attribute(0,65534,e)
end
b("power",o.electrical_measurement_power,function()
return c({emit=n.power(),metering_kind="power",poll_interval=300},a(5,300,1))
end)
b("current",o.electrical_measurement_current,function()
return c({emit=n.current(),scale=1000,metering_kind="current",poll_interval=300},a(5,300,1))
end)
b("voltage",o.electrical_measurement_voltage,function()
return c({emit=n.voltage(),metering_kind="voltage",poll_interval=300},a(5,300,1))
end)
b("energy",o.simple_metering,function()
return{emit=n.energy(),read_on_configure=true,metering_kind="energy",poll_interval=900}
end)
b("cover_position",o.window_covering_position,function()
return c({emit=n.shade_level()},a(0,600,1))
end)
b("cover_state",o.window_covering_position,function()
return{name="cover_state",write_only=true}
end)
b("cover_tilt",o.window_covering_tilt,function()
return c({name="cover_tilt",emit=n.shade_tilt_level(),tx_command_id=8},a(0,600,1))
end)
b("window_shade_state",o.window_covering_position,function()
return c({name="window_shade_state",emit=n.shade_state(),converter=j()},a(0,600,1))
end)
end
return q

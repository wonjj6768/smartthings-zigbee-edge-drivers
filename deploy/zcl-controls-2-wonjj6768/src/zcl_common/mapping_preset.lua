local function q(n)
local o,H,D,G=require"capabilities.events.all",require"st.zigbee.data_types",require"st.zigbee.constants",require"st.utils.safe_xy_to_hsv"
local function p(l,C)
if type(l)~="table"then
l={}end
if type(C)~="table"then
return l
end
for E,d in pairs(C)do
l[E]=d
end
return l
end
local function m(l,c)
if type(l)~="table"or type(c)~="table"then
return l
end
for E,d in pairs(c)do
if l[E]==nil then
l[E]=d
end
end
return l
end
local function k(h,i)
local g={}if type(h)=="string"then
g.name=h
else
p(g,h)end
p(g,i)return g
end
local function A(d,z,y)
if d<z then
return z
end
if d>y then
return y
end
return d
end
local function r()
return{
from=function(d)
if type(d)~="number"then
return d
end
return math.floor(A(d,0,254)*100/254+0.5)
end,
to=function(d)
if type(d)~="number"then
return d
end
return math.floor(A(d,0,100)*254/100+0.5)
end
}
end
local function j()
return{
from=function(d)
if type(d)~="number"then
return d
end
return math.floor(A(d,0,254)*100/254+0.5)
end,
to=function(d)
if type(d)~="number"then
return d
end
return math.floor(A(d,0,100)*254/100+0.5)
end
}
end
local function a(v,u,s)
return{minimum_interval=v,maximum_interval=u,reportable_change=s,read_on_configure=true}
end
local function f(...)
local B={}for _,c in ipairs{...}do
m(B,c)end
return B
end
local function e(J,F,t)
n[J]=function(h,i)
local g=k(h,i)local b,c=g.configure_reporting,t(g)
g.configure_reporting=nil
if b==false then
c.minimum_interval=nil
c.maximum_interval=nil
c.reportable_change=nil
c.physical_reportable_change=nil
c.reporting_defaults=nil
end
m(g,c)return F(g)
end
end
e("temperature",n.temperature_measurement,function()
return f({emit=o.temperature"C",scale=100},a(30,300,50))
end)
e("battery",n.power_configuration_battery,function()
return f({emit=o.battery(),scale=2},a(300,21600,2))
end)
e("battery_voltage",n.power_configuration_battery_voltage,function()
return f({emit=o.voltage(),scale=10},a(300,21600,1))
end)
e("switch",n.on_off,function(i)
local b=i.configure_reporting
i.configure_reporting=nil
if b==false then
return{emit=o.switch()}end
return f({emit=o.switch()},a(0,300,nil))
end)
n.tuya_magic_packet=function(h,i)
local g=k(h,i)m(g,{name="tuya_magic_packet",read_only=true,read_on_configure=true})return n.cluster_attribute(0,65534,g)
end
e("level",n.level_control,function(i)
local b=i.configure_reporting
i.configure_reporting=nil
local c={name="brightness",emit=o.level(),converter=r()}if b==false then return c end
return f(c,a(1,3600,1))
end)
e("power",n.electrical_measurement_power,function()
return f({emit=o.power(),metering_kind="power",poll_interval=300},a(5,300,1))
end)
e("current",n.electrical_measurement_current,function()
return f({emit=o.current(),scale=1000,metering_kind="current",poll_interval=300},a(5,300,1))
end)
e("voltage",n.electrical_measurement_voltage,function()
return f({emit=o.voltage(),metering_kind="voltage",poll_interval=300},a(5,300,1))
end)
e("energy",n.simple_metering,function()
return{emit=o.energy(),read_on_configure=true,metering_kind="energy",poll_interval=900}
end)
e("color_hue",n.color_control_hue,function(i)
local b=i.configure_reporting
i.configure_reporting=nil
local c={name="color_hue",emit=o.color_hue(),converter=j(),tx_command_id=0,
to_device=function(d)
local x=j().to(d)return{x,0,0,0,0}
end
}if b==false then return c end
return f(c,a(1,300,1))
end)
e("color_saturation",n.color_control_saturation,function(i)
local b=i.configure_reporting
i.configure_reporting=nil
local c={name="color_saturation",emit=o.color_saturation(),converter=j(),tx_command_id=3,
to_device=function(d)
local x=j().to(d)return{x,0,0,0}
end
}if b==false then return c end
return f(c,a(1,300,1))
end)
n.color=function(h,i)
local g=k(h,i)m(g,{name="color",cluster_id=n.CLUSTER_COLOR_CONTROL,attribute_id=n.ATTR_CURRENT_HUE,write_only=true,tx_command_id=6,
to_device=function(d)
if type(d)~="table"then
return d
end
local I,w=j().to(d.hue),j().to(d.saturation)if type(I)~="number"or type(w)~="number"then
return nil
end
return{I,w,0,0,0}
end
})return n.cluster_attribute(g.cluster_id,g.attribute_id,g)
end
end
return q

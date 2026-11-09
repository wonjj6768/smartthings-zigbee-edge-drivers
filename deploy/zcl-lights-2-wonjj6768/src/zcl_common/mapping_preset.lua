local function v(m)
local q,F,U,J=require"capabilities.events.all",require"st.zigbee.data_types",require"st.zigbee.constants",require"st.utils.safe_xy_to_hsv"
local function r(n,S)
if type(n)~="table"then
n={}end
if type(S)~="table"then
return n
end
for W,value in pairs(S)do
n[W]=value
end
return n
end
local function o(n,d)
if type(n)~="table"or type(d)~="table"then
return n
end
for W,value in pairs(d)do
if n[W]==nil then
n[W]=value
end
end
return n
end
local function l(g,e)
local c={}if type(g)=="string"then
c.name=g
else
r(c,g)end
r(c,e)return c
end
local function N(value,M,L)
if value<M then
return M
end
if value>L then
return L
end
return value
end
local function w()
return{
from=function(value)
if type(value)~="number"then
return value
end
return math.floor(N(value,0,254)*100/254+0.5)
end,
to=function(value)
if type(value)~="number"then
return value
end
return math.floor(N(value,0,100)*254/100+0.5)
end
}
end
local function j()
return{
from=function(value)
if type(value)~="number"then
return value
end
return math.floor(N(value,0,254)*100/254+0.5)
end,
to=function(value)
if type(value)~="number"then
return value
end
return math.floor(N(value,0,100)*254/100+0.5)
end
}
end
local function u()
local p=1000000
return{
from=function(value)
if type(value)~="number"or value<=0 then
return value
end
return math.floor(p/value+0.5)
end,
to=function(value)
if type(value)~="number"or value<=0 then
return value
end
return math.floor(p/value+0.5)
end
}
end
local function f(E,D,z)
return{minimum_interval=E,maximum_interval=D,reportable_change=z,read_on_configure=true}
end
local function i(...)
local R={}for _,d in ipairs{...}do
o(R,d)end
return R
end
local function h(ac,Y,A)
m[ac]=function(g,e)
local c=l(g,e)local b,d=c.configure_reporting,A(c)
c.configure_reporting=nil
if b==false then
d.minimum_interval=nil
d.maximum_interval=nil
d.reportable_change=nil
d.physical_reportable_change=nil
d.reporting_defaults=nil
end
o(c,d)return Y(c)
end
end
h("switch",m.on_off,function(e)
local b=e.configure_reporting
e.configure_reporting=nil
if b==false then
return{emit=q.switch()}end
return i({emit=q.switch()},f(0,300,nil))
end)
m.tuya_magic_packet=function(g,e)
local c=l(g,e)o(c,{name="tuya_magic_packet",read_only=true,read_on_configure=true})return m.cluster_attribute(0,65534,c)
end
h("level",m.level_control,function(e)
local b=e.configure_reporting
e.configure_reporting=nil
local d={name="brightness",emit=q.level(),converter=w()}if b==false then return d end
return i(d,f(1,3600,1))
end)
h("power",m.electrical_measurement_power,function()
return i({emit=q.power(),metering_kind="power",poll_interval=300},f(5,300,1))
end)
h("current",m.electrical_measurement_current,function()
return i({emit=q.current(),scale=1000,metering_kind="current",poll_interval=300},f(5,300,1))
end)
h("voltage",m.electrical_measurement_voltage,function()
return i({emit=q.voltage(),metering_kind="voltage",poll_interval=300},f(5,300,1))
end)
h("energy",m.simple_metering,function()
return{emit=q.energy(),read_on_configure=true,metering_kind="energy",poll_interval=900}
end)
h("color_temperature",m.color_control_temperature,function(e)
local b=e.configure_reporting
e.configure_reporting=nil
local d={name="color_temperature",emit=q.color_temperature(),converter=u(),tx_command_id=10}if b==false then return d end
return i(d,f(1,300,1))
end)
h("color_hue",m.color_control_hue,function(e)
local b=e.configure_reporting
e.configure_reporting=nil
local d={name="color_hue",emit=q.color_hue(),converter=j(),tx_command_id=0,
to_device=function(value)
local H=j().to(value)return{H,0,0,0,0}
end
}if b==false then return d end
return i(d,f(1,300,1))
end)
h("color_saturation",m.color_control_saturation,function(e)
local b=e.configure_reporting
e.configure_reporting=nil
local d={name="color_saturation",emit=q.color_saturation(),converter=j(),tx_command_id=3,
to_device=function(value)
local H=j().to(value)return{H,0,0,0}
end
}if b==false then return d end
return i(d,f(1,300,1))
end)
m.color=function(g,e)
local c=l(g,e)o(c,{name="color",cluster_id=m.CLUSTER_COLOR_CONTROL,attribute_id=m.ATTR_CURRENT_HUE,write_only=true,tx_command_id=6,
to_device=function(value)
if type(value)~="table"then
return value
end
local V,s=j().to(value.hue),j().to(value.saturation)if type(V)~="number"or type(s)~="number"then
return nil
end
return{V,s,0,0,0}
end
})return m.cluster_attribute(c.cluster_id,c.attribute_id,c)
end
function m.color_xy(e)
local function Z(value,k,t,mapping)
value=type(value)=="table"and value.value or value
local G="_zcl_color_xy_"..tostring(t.endpoint or 1).."_"k:set_field(G..mapping.name,value)local x,y,aa=k:get_field(G.."color_x"),k:get_field(G.."color_y"),k:get_field(G.."color_mode")if x~=nil and y~=nil and(aa==nil or aa==0)then
local V,s=J(x,y)local K=t.component or{id=t.component_id or"main"}k:emit_component_event(K,q.color_hue()(k,V))k:emit_component_event(K,q.color_saturation()(k,s))end
end
local C={}for _,T in ipairs{{"color_x",3},{"color_y",4},{"color_mode",8}}do
local c=r({},e)c.name,c.read_only,c.from_device=T[1],true,Z
c.data_type=T[2]==8 and F.Enum8 or F.Uint16
C[#C+1]=m.cluster_attribute(m.CLUSTER_COLOR_CONTROL,T[2],c)end
return C
end
function m.send_light_effect(k,mapping,value,t)
local B,O,command,I=t.endpoint or 1,3,64,nil

if value=="colorloop"or value=="stop_colorloop"then
O,command=768,1
I=string.char(value=="colorloop"and 1 or 0,value=="colorloop"and 17 or 1,0,0)else
local Q=({blink=0,breathe=1,okay=2,channel_change=11,finish_effect=254,stop_effect=255})[value]if Q==nil then return false end
I=string.char(Q,0)end
local ab=m.send_raw_cluster_command(k,O,command,I,B)if ab~=false then
k:emit_component_event({id=t.component_id or"main"},mapping.emit(k,value))if value=="stop_colorloop"then
k.thread:call_with_delay(0.1,function()
m.read_mapping(k,m.cluster_attribute(768,0,{endpoint=B}))m.read_mapping(k,m.cluster_attribute(768,8,{endpoint=B}))
end,"light colorloop stopped")
end
end
return ab
end
end
return v

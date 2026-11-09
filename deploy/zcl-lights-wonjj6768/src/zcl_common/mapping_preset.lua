local function G(k)
local t,j,aq,Z=require"capabilities.events.all",require"st.zigbee.data_types",require"st.zigbee.constants",require"st.utils.safe_xy_to_hsv"
local function w(q,an)
if type(q)~="table"then
q={}end
if type(an)~="table"then
return q
end
for ai,value in pairs(an)do
q[ai]=value
end
return q
end
local function h(q,f)
if type(q)~="table"or type(f)~="table"then
return q
end
for ai,value in pairs(f)do
if q[ai]==nil then
q[ai]=value
end
end
return q
end
local function o(ap,...)
local K=t[ap]if type(K)=="function"then
return K(...)end
return nil
end
local function d(c,e)
local b={}if type(c)=="string"then
b.name=c
else
w(b,c)end
w(b,e)return b
end
local function r(az,H,T,ag)
local F={}for ai,value in pairs(az)do
F[value]=ai
end
if type(ag)=="table"then
for ay,q in pairs(ag)do
if F[q]~=nil then
F[ay]=F[q]end
end
end
return{
from=function(value)
local J=az[value]if J~=nil then
return J
end
if H~=nil then
return H
end
return value
end,
to=function(value)
local J=F[value]if J~=nil then
return J
end
if T~=nil then
return T
end
return value
end
}
end
local function v(value,ad,ac)
if value<ad then
return ad
end
if value>ac then
return ac
end
return value
end
local function I()
return{
from=function(value)
if type(value)~="number"then
return value
end
return math.floor(v(value,0,254)*100/254+0.5)
end,
to=function(value)
if type(value)~="number"then
return value
end
return math.floor(v(value,0,100)*254/100+0.5)
end
}
end
local function n()
return{
from=function(value)
if type(value)~="number"then
return value
end
return math.floor(v(value,0,254)*100/254+0.5)
end,
to=function(value)
if type(value)~="number"then
return value
end
return math.floor(v(value,0,100)*254/100+0.5)
end
}
end
local function ae()
return r{[0]="off",[1]="low",[2]="medium",[3]="high",[4]="on",[5]="auto",[6]="turbo"}
end
local function D()
return r({[0]="off",[1]="on",[2]="previous"},nil,nil,{restore="previous"})
end
local function B()
return r{[0]="momentary",[1]="toggle",[2]="state"}
end
local function U()
return r{[0]="led",[1]="incandescent",[2]="halogen"}
end
local function O(value)
local L=math.floor(v(tonumber(value)or 0,0,0xFFFFFFFF)+0.5)return string.char(L&255,(L>>8)&255,(L>>16)&255,(L>>24)&255)
end
local function s()
return{
from=function(value)
if type(value)~="number"then
return value
end
return math.floor(v(value,0,1000)*254/1000+1+0.5)
end,
to=function(value)
if type(value)~="number"then
return value
end
return math.floor((v(value,1,255)-1)*1000/254+0.5)
end
}
end
local function E(ak,af,f)
return function(c,e)
local b,ab=d(c,e),f.converter_factory()h(b,{name=f.name,emit=f.emit,converter=ab,
to_device=function(value)
return ab.to(value)
end,
data_type=j.Enum8,write_type=j.Enum8,attribute_name=f.attribute_name,mfg_code=f.mfg_code,read_on_configure=true})return k.cluster_attribute(ak,af,b)
end
end
local function C()
local u=1000000
return{
from=function(value)
if type(value)~="number"or value<=0 then
return value
end
return math.floor(u/value+0.5)
end,
to=function(value)
if type(value)~="number"or value<=0 then
return value
end
return math.floor(u/value+0.5)
end
}
end
local function i(S,R,M)
return{minimum_interval=S,maximum_interval=R,reportable_change=M,read_on_configure=true}
end
local function m(...)
local am={}for _,f in ipairs{...}do
h(am,f)end
return am
end
local function l(ap,K,N)
k[ap]=function(c,e)
local b=d(c,e)local g,f=b.configure_reporting,N(b)
b.configure_reporting=nil
if g==false then
f.minimum_interval=nil
f.maximum_interval=nil
f.reportable_change=nil
f.physical_reportable_change=nil
f.reporting_defaults=nil
end
h(b,f)return K(b)
end
end
l("switch",k.on_off,function(e)
local g=e.configure_reporting
e.configure_reporting=nil
if g==false then
return{emit=t.switch()}end
return m({emit=t.switch()},i(0,300,nil))
end)
k.power_on_behavior=E(k.CLUSTER_ON_OFF,32770,{name="power_on_behavior",emit=o"power_on_behavior",attribute_name="tuyaPowerOnBehavior",converter_factory=D})
k.tuya_magic_packet=function(c,e)
local b=d(c,e)h(b,{name="tuya_magic_packet",read_only=true,read_on_configure=true})return k.cluster_attribute(0,65534,b)
end
k.ts110e_countdown_timer=function(c,e)
local b=d(c,e)local W=b.emit or o("countdownTsOneTenHours","s")h(b,{name="countdown_timer",emit=W,data_type=j.Uint32,tx_command_id=240,
to_device=function(value)
return O(v(tonumber(value)or 0,0,43200))
end,
numeric_range={minimum=0,maximum=43200,step=1,unit="s"},attribute_name="tuyaCountdown",read_on_configure=true})return k.cluster_attribute(k.CLUSTER_ON_OFF,16385,b)
end
l("level",k.level_control,function(e)
local g=e.configure_reporting
e.configure_reporting=nil
local f={name="brightness",emit=t.level(),converter=I()}if g==false then return f end
return m(f,i(1,3600,1))
end)
k.tuya_dimmer_level=function(c,e)
local b=d(c,e)h(b,{name="brightness",emit=t.level(),data_type=j.Uint16,write_type=j.Uint16,attribute_name="tuyaCurrentLevel",
from_device=function(value)
if type(value)~="number"then
return value
end
local as=v(value,10,1000)return math.floor((as-10)*100/990+0.5)
end,
to_device=function(value)
if type(value)~="number"then
return value
end
local au=v(value,0,100)return math.floor(10+au*990/100+0.5)
end,
read_on_configure=true})return k.cluster_attribute(k.CLUSTER_LEVEL_CONTROL,61440,b)
end
l("power",k.electrical_measurement_power,function()
return m({emit=t.power(),metering_kind="power",poll_interval=300},i(5,300,1))
end)
l("current",k.electrical_measurement_current,function()
return m({emit=t.current(),scale=1000,metering_kind="current",poll_interval=300},i(5,300,1))
end)
l("voltage",k.electrical_measurement_voltage,function()
return m({emit=t.voltage(),metering_kind="voltage",poll_interval=300},i(5,300,1))
end)
l("energy",k.simple_metering,function()
return{emit=t.energy(),read_on_configure=true,metering_kind="energy",poll_interval=900}
end)
l("fan_mode",k.fan_control_mode,function()
return m({name="fan_mode",emit=t.fan_mode(),converter=ae()},i(1,300,nil))
end)
l("color_temperature",k.color_control_temperature,function(e)
local g=e.configure_reporting
e.configure_reporting=nil
local f={name="color_temperature",emit=t.color_temperature(),converter=C(),tx_command_id=10}if g==false then return f end
return m(f,i(1,300,1))
end)
k.min_brightness=function(c,e)
local b=d(c,e)h(b,{name="min_brightness",emit=o"minBrightnessZclThousand",data_type=j.Uint16,write_type=j.Uint16,attribute_name="tuyaMinBrightness",read_on_configure=true})return k.cluster_attribute(k.CLUSTER_LEVEL_CONTROL,64515,b)
end
k.ts110e_min_brightness=function(c,e)
local b=d(c,e)h(b,{name="min_brightness",emit=o"minimumBrightnessTsOneTenMax",converter=s(),data_type=j.Uint16,write_type=j.Uint16,attribute_name="tuyaMinBrightness",read_on_configure=true})return k.cluster_attribute(k.CLUSTER_LEVEL_CONTROL,64515,b)
end
k.ts110e_max_brightness=function(c,e)
local b=d(c,e)h(b,{name="max_brightness",emit=o"maxBrightnessTsOneTenMax",converter=s(),data_type=j.Uint16,write_type=j.Uint16,attribute_name="tuyaMaxBrightness",read_on_configure=true})return k.cluster_attribute(k.CLUSTER_LEVEL_CONTROL,64516,b)
end
k.ts110e_switch_type=function(c,e)
local b=d(c,e)h(b,{name="switch_type",emit=o"switch_type",converter=B(),data_type=j.Enum8,write_type=j.Enum8,attribute_name="tuyaSwitchType",read_on_configure=true})return k.cluster_attribute(k.CLUSTER_LEVEL_CONTROL,64514,b)
end
k.light_type=function(c,e)
local b=d(c,e)h(b,{name="light_type",emit=o"light_type",converter=U(),data_type=j.Enum8,attribute_name="tuyaLightType",read_on_configure=true})return k.cluster_attribute(k.CLUSTER_LEVEL_CONTROL,64514,b)
end
l("color_hue",k.color_control_hue,function(e)
local g=e.configure_reporting
e.configure_reporting=nil
local f={name="color_hue",emit=t.color_hue(),converter=n(),tx_command_id=0,
to_device=function(value)
local X=n().to(value)return{X,0,0,0,0}
end
}if g==false then return f end
return m(f,i(1,300,1))
end)
l("color_saturation",k.color_control_saturation,function(e)
local g=e.configure_reporting
e.configure_reporting=nil
local f={name="color_saturation",emit=t.color_saturation(),converter=n(),tx_command_id=3,
to_device=function(value)
local X=n().to(value)return{X,0,0,0}
end
}if g==false then return f end
return m(f,i(1,300,1))
end)
k.color=function(c,e)
local b=d(c,e)h(b,{name="color",cluster_id=k.CLUSTER_COLOR_CONTROL,attribute_id=k.ATTR_CURRENT_HUE,write_only=true,tx_command_id=6,
to_device=function(value)
if type(value)~="table"then
return value
end
local ar,z=n().to(value.hue),n().to(value.saturation)if type(ar)~="number"or type(z)~="number"then
return nil
end
return{ar,z,0,0,0}
end
})return k.cluster_attribute(b.cluster_id,b.attribute_id,b)
end
function k.color_xy(e)
local function av(value,p,A,mapping)
value=type(value)=="table"and value.value or value
local V="_zcl_color_xy_"..tostring(A.endpoint or 1).."_"p:set_field(V..mapping.name,value)local x,y,aw=p:get_field(V.."color_x"),p:get_field(V.."color_y"),p:get_field(V.."color_mode")if x~=nil and y~=nil and(aw==nil or aw==0)then
local ar,z=Z(x,y)local aa=A.component or{id=A.component_id or"main"}p:emit_component_event(aa,t.color_hue()(p,ar))p:emit_component_event(aa,t.color_saturation()(p,z))end
end
local Q={}for _,ao in ipairs{{"color_x",3},{"color_y",4},{"color_mode",8}}do
local b=w({},e)b.name,b.read_only,b.from_device=ao[1],true,av
b.data_type=ao[2]==8 and j.Enum8 or j.Uint16
Q[#Q+1]=k.cluster_attribute(k.CLUSTER_COLOR_CONTROL,ao[2],b)end
return Q
end
function k.send_light_effect(p,mapping,value,A)
local P,ah,command,Y=A.endpoint or 1,3,64,nil

if value=="colorloop"or value=="stop_colorloop"then
ah,command=768,1
Y=string.char(value=="colorloop"and 1 or 0,value=="colorloop"and 17 or 1,0,0)else
local al=({blink=0,breathe=1,okay=2,channel_change=11,finish_effect=254,stop_effect=255})[value]if al==nil then return false end
Y=string.char(al,0)end
local ax=k.send_raw_cluster_command(p,ah,command,Y,P)if ax~=false then
p:emit_component_event({id=A.component_id or"main"},mapping.emit(p,value))if value=="stop_colorloop"then
p.thread:call_with_delay(0.1,function()
k.read_mapping(p,k.cluster_attribute(768,0,{endpoint=P}))k.read_mapping(p,k.cluster_attribute(768,8,{endpoint=P}))
end,"light colorloop stopped")
end
end
return ax
end
end
return G

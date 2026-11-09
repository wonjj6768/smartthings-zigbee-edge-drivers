local k,aa,y=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family"local K,d,D,V=y.create_fingerprint,require"st.zigbee.data_types",require"st.capabilities",require"st.zigbee.zcl.clusters"
local r,n=y.definition_registry()
local function q(c,_,p)
if p and p.raw_value==255 then return nil end
return c
end
local function O(h)
h.from_device=h.from_device or q
return k.battery(h)
end
local function P(h)
h.from_device=h.from_device or q
return k.battery_voltage(h)
end
local function x(U,Y)
return function(_,c)
if c==255 then return end
return{D.battery.battery(math.floor(math.max(0,math.min(100,(c-U)*100/(Y-U)))+0.5)),D.voltageMeasurement.voltage{value=c/10,unit="V"}}
end
end
local g=x(25,30)
local function i(_,c)
return(c&0xF03C0F)~=0 and D.batteryLevel.battery.critical()or D.batteryLevel.battery.normal()
end
local function s(_,c)
return c and D.batteryLevel.battery.critical()or D.batteryLevel.battery.normal()
end
local function o(a,J)
a.minimum_interval=nil
a.maximum_interval=nil
a.reportable_change=nil
a.read_on_configure=false
a.emit=function(f,c,p)
if p.command_id==0 then return J(f,c)end
end
return a
end
local function G(c)
if c==255 then return nil end
local j,v=c*100,100

if j<2100 then v=0
elseif j<2440 then v=6-(2440-j)*6/340
elseif j<2740 then v=18-(2740-j)*12/300
elseif j<2900 then v=42-(2900-j)*24/160
elseif j<3000 then v=100-(3000-j)*58/100 end
return math.floor(v+0.5)
end
local function C(_,c)
if c==255 then return end
return{D.battery.battery(G(c)),D.voltageMeasurement.voltage{value=c/10,unit="V"}}
end
do
local S={profile="safety-water-iris-3315l",zcl_clusters={o(k.water{endpoint=1,read_only=true,read_on_refresh=false,ias_configure_method=0},aa.water()),o(k.tamper{endpoint=1,read_only=true,read_on_refresh=false,ias_configure_method=0},aa.tamper()),o(k.battery_low{endpoint=1,read_only=true,read_on_refresh=false,ias_configure_method=0},s),k.temperature{endpoint=1,read_only=true,read_on_configure=false,read_on_refresh=false,minimum_interval=10,maximum_interval=3600,reportable_change=100},k.cluster_attribute(1,32,{name="iris3315_voltage",endpoint=1,data_type=d.Uint8,read_only=true,read_on_configure=true,read_on_refresh=false,minimum_interval=3600,maximum_interval=65000,reportable_change=0,emit=g}),k.cluster_attribute(1,62,{name="iris3315_alarm",endpoint=1,data_type=d.Bitmap32,read_only=true,read_on_configure=false,read_on_refresh=false,emit=i})}}n(S,{K("CentraLite","3315-L"),K("CentraLite","3315-S"),K("CentraLite","3315-Seu"),K("CentraLite","3315-G")})end
local function m(b,W,I)
return function(Z,f)
for _,a in ipairs(b)do
if a.reporting_defaults then k.bind_cluster(f,a.cluster_id,Z.environment_info.hub_zigbee_eui,1)end
end
for _,a in ipairs(b)do
local B=a.reporting_defaults
if B then k.configure_reporting(f,{cluster=a.cluster_id,attribute=a.attribute_id,data_type=a.data_type,minimum_interval=B.minimum_interval,maximum_interval=B.maximum_interval,reportable_change=B.reportable_change},1)end
end
if W then k.read_attribute(f,1,W,1)end
if I then I(f)end
end
end
local function z(X,h,l)
local b={X(h),k.tamper(h),k.battery_low(h)}b[3].emit=s
if not l then
for ab,a in ipairs(b)do b[ab]=o(a,a.emit)end
end
return b
end
local function e(L,l,T,I,R)
local b=z(k.contact,{endpoint=1,read_only=true,read_on_configure=false,read_on_refresh=false,configure_reporting=false,ias_configure_method=0},l)b[#b+1]=k.temperature{endpoint=1,data_type=d.Int16,read_only=true,configure_reporting=false,read_on_configure=false,read_on_refresh=false,reporting_defaults={minimum_interval=10,maximum_interval=3600,reportable_change=100}}if T then
b[#b+1]=k.cluster_attribute(1,32,{name="centralite_contact_voltage",endpoint=1,data_type=d.Uint8,read_only=true,read_on_configure=false,read_on_refresh=false,emit=R or g,reporting_defaults={minimum_interval=3600,maximum_interval=65000,reportable_change=0}})b[#b+1]=k.cluster_attribute(1,62,{name="centralite_contact_alarm",endpoint=1,data_type=d.Bitmap32,read_only=true,read_on_configure=false,read_on_refresh=false,emit=i})end
return{profile=L,zcl_clusters=b,configure=m(b,T and 32,I),announce_handler=I}
end
do
local E,F=e("safety-contact-centralite-3300s",true,true),e("safety-contact-centralite-3323g",false,false)n(E,{K("CentraLite","3300-S")})n(F,{K("CentraLite","3323-G"),K("Ecolink","4655BC0-R")})end
do
local function t(L,u)
local b=z(k.water,{endpoint=1,read_only=true,read_on_configure=false,read_on_refresh=false,configure_reporting=false,ias_configure_method=0},u)if u then
for _,a in ipairs(b)do
local J=a.emit
a.emit=function(f,c,p)
if p.command_id==0 or p.zb_rx.body.zcl_header.cmd.value==10 then return J(f,c)end
end
end
end
local H=k.temperature{endpoint=1,data_type=d.Int16,read_only=true,configure_reporting=false,read_on_configure=false,read_on_refresh=false,reporting_defaults={minimum_interval=10,maximum_interval=3600,reportable_change=100}}if u then
b[#b+1]=H
b[#b+1]=O{endpoint=1,data_type=d.Uint8,read_only=true,configure_reporting=false,read_on_configure=false,read_on_refresh=false,reporting_defaults={minimum_interval=3600,maximum_interval=65000,reportable_change=0}}b[#b+1]=P{endpoint=1,read_only=true,configure_reporting=false,read_on_configure=false,read_on_refresh=false}else
b[#b+1]=k.cluster_attribute(1,32,{name="smartthings_water_voltage",endpoint=1,data_type=d.Uint8,read_only=true,read_on_configure=false,read_on_refresh=false,emit=g,reporting_defaults={minimum_interval=3600,maximum_interval=65000,reportable_change=0}})b[#b+1]=H
end
b[#b+1]=k.cluster_attribute(1,62,{name="smartthings_water_alarm",endpoint=1,data_type=d.Bitmap32,read_only=true,read_on_configure=false,read_on_refresh=false,emit=i})return{profile=L,zcl_clusters=b,configure=m(b,u and 33 or 32)}
end
local Q,w=t("safety-water-samjin",true),t("safety-water-smartthings-v4",false)n(Q,{K("Samjin","water")})n(w,{K("SmartThings","moisturev4")})end
do
local function A(f)
if not f.zigbee_endpoints[1]then return false end
return pcall(f.send,f,V.PollControl.commands.SetLongPollInterval(f,1200):to_endpoint(1))
end
local N=e("safety-contact-visonic-mct350",false,false,A)n(N,{K("Visonic","MCT-350 SMA")})local M=e("safety-contact-visonic-mct340",false,true,nil,C)n(M,{K("Visonic","MCT-340 E"),K("Visonic","MCT-340 SMA"),K("Sercomm Corp.","SZ-DWS04")})end
k.attach_reporting_capabilities(r,{{1,"rpt-zum"},{2,"rpt-zlb"},{3,"rpt-zpf"},{4,"rpt-wpn"},{5,"rpt-mdi"},{6,"rpt-zpf"},{7,"rpt-zlb"}})return{id="zcl.sensors.contact_water_additions",registrations=r}

local e,ag,G=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family"local Q,i,u,L=G.create_fingerprint,require"st.zigbee.data_types",require"st.capabilities",require"st.zigbee.device_management"
local z,l=G.definition_registry()
local function y(d,_,g)
if g and g.raw_value==255 then return nil end
return d
end
local function B(d,_,g)
local ac=g.zb_rx.body.zcl_body
local q=type(ac.get_attribute_data)=="function"and ac:get_attribute_data(32)if type(q)=="table"then q=q.value end
if type(q)=="number"and q<255 then return end
if g.raw_value~=255 then return d end
end
local function r(h)
h.from_device=h.from_device or y
return e.battery(h)
end
local function C(h)
h.from_device=h.from_device or y
return e.battery_voltage(h)
end
local function F(U,aa)
return function(_,d)
if d==255 then return end
return{u.battery.battery(math.floor(math.max(0,math.min(100,(d-U)*100/(aa-U)))+0.5)),u.voltageMeasurement.voltage{value=d/10,unit="V"}}
end
end
local function x(_,d)
return(d&0xF03C0F)~=0 and u.batteryLevel.battery.critical()or u.batteryLevel.battery.normal()
end
local function f(_,d)
return d and u.batteryLevel.battery.critical()or u.batteryLevel.battery.normal()
end
local function R(c,Z)
c.minimum_interval=nil
c.maximum_interval=nil
c.reportable_change=nil
c.read_on_configure=false
c.emit=function(a,d,g)
if g.command_id==0 then return Z(a,d)end
end
return c
end
local function b(c)
c.minimum_interval=nil
c.maximum_interval=nil
c.reportable_change=nil
return c
end
local function H(v,h,K)
local E={v(h),e.tamper(h),e.battery_low(h)}E[3].emit=f
if not K then
for ae,c in ipairs(E)do E[ae]=R(c,c.emit)end
end
return E
end
local function k(a)
for _,D in ipairs{33,32}do
pcall(e.read_attribute,a,1,D,a:get_endpoint(1))end
end
do
local function p(a,_,g)
return g and g.zb_rx and g.endpoint or a:get_endpoint(1)
end
local function n(A,a)
local j=a:get_endpoint(1)for _,D in ipairs{33,32}do
e.bind_cluster(a,1,A.environment_info.hub_zigbee_eui,j)e.configure_reporting(a,{cluster=1,attribute=D,data_type=i.Uint8,minimum_interval=3600,maximum_interval=65000,reportable_change=10},j,{auto_endpoint=true})pcall(e.read_attribute,a,1,D,j)end
end
local function o(A,a)
for _,j in pairs(a.zigbee_endpoints)do
if a:supports_server_cluster(1026,j.id)then
e.bind_cluster(a,1026,A.environment_info.hub_zigbee_eui,j.id)e.configure_reporting(a,{cluster=1026,attribute=0,data_type=i.Int16,minimum_interval=10,maximum_interval=3600,reportable_change=100},j.id,{auto_endpoint=true})pcall(e.read_attribute,a,1026,0,j.id)end
end
end
do
local s={profile="safety-contact-sengled-g73",magic_packet=false,parent_refresh=k,configure=n,zcl_clusters={b(e.contact{component="main",read_on_configure=false,read_on_refresh=false,ias_configure_method=0}),b(e.tamper{component="main",read_on_configure=false,read_on_refresh=false,ias_configure_method=0}),b(e.battery_low{component="main",read_on_configure=false,read_on_refresh=false,ias_configure_method=0,emit=f})}}for _,v in ipairs{r,C}do
s.zcl_clusters[#s.zcl_clusters+1]=b(v{endpoint=p,component="main",read_on_configure=false,read_on_refresh=false,reporting_defaults={minimum_interval=3600,maximum_interval=65000,reportable_change=10}})end
l(s,{Q("sengled","E1D-G73"),Q("sengled","E2D-G73")})end
do
local O={profile="safety-sound-ecolink-ffzb1",magic_packet=false,
parent_refresh=function(a)
pcall(e.read_attribute,a,1026,0,a:get_endpoint(1026))k(a)
end,
configure=o,zcl_clusters={b(e.alarm{component="main",read_only=true,read_on_configure=false,read_on_refresh=false,ias_configure_method=0,
emit=function(_,d)return d and u.soundSensor.sound.detected()or u.soundSensor.sound.not_detected()end}),
b(e.tamper{component="main",read_only=true,read_on_configure=false,read_on_refresh=false,ias_configure_method=0}),b(e.battery_low{component="main",read_only=true,read_on_configure=false,read_on_refresh=false,ias_configure_method=0,emit=f}),b(e.temperature{component="main",data_type=i.Int16,read_only=true,read_on_configure=false,read_on_refresh=false,reporting_defaults={minimum_interval=10,maximum_interval=3600,reportable_change=100,all_endpoints=true}}),b(r{component="main",read_only=true,read_on_configure=false,read_on_refresh=false,from_device=B}),e.cluster_attribute(1,32,{name="ecolink_sound_voltage",component="main",data_type=i.Uint8,read_only=true,read_on_configure=false,read_on_refresh=false,emit=F(22,30)})}}l(O,{Q("Ecolink","FFZB1-SM-ECO")})end
do
local function I(P,a)
local W,af=false,false
for _,ad in ipairs(P.body.zcl_body.alert_structure_list or{})do
local d=ad.value
if(d&12288)~=0 then
if(d&255)==130 then af=true else W=true end
end
end
a:emit_event(W and u.waterSensor.water.wet()or u.waterSensor.water.dry())a:emit_event(f(nil,af))
end
local t={profile="safety-water-waxman-8840100h",magic_packet=false,
parent_refresh=function(a)
pcall(e.send_raw_cluster_command,a,2818,0,"",1)k(a)pcall(e.read_attribute,a,1026,0,a:get_endpoint(1026))
end,
configure=function(A,a)
if a:supports_server_cluster(1280)then L.configure_ias_zone(a,1,A.environment_info.hub_zigbee_eui)end
e.bind_cluster(a,2818,A.environment_info.hub_zigbee_eui,1)n(A,a)o(A,a)
end,
zcl_clusters={{cluster_id=2818,command_id=0,command_extractor=I,read_only=true},{cluster_id=2818,command_id=1,command_extractor=I,read_only=true},b(e.temperature{component="main",data_type=i.Int16,read_only=true,read_on_configure=false,read_on_refresh=false,reporting_defaults={minimum_interval=10,maximum_interval=3600,reportable_change=100,all_endpoints=true}}),e.cluster_attribute(1,62,{name="waxman_battery_alarm",component="main",data_type=i.Bitmap32,read_only=true,read_on_configure=false,read_on_refresh=false,emit=x})}}for _,v in ipairs{r,C}do
t.zcl_clusters[#t.zcl_clusters+1]=b(v{endpoint=p,component="main",read_on_configure=false,read_on_refresh=false,reporting_defaults={minimum_interval=3600,maximum_interval=65000,reportable_change=10}})end
l(t,{Q("WAXMAN","leakSMART Water Sensor V2")})end
end
do
local function w(ab,v,Y)
local E=H(v,{component="main",read_only=true,read_on_configure=false,read_on_refresh=false,configure_reporting=false,ias_configure_method=1})if Y then
for _,c in ipairs{r,C}do
E[#E+1]=b(c{component="main",read_only=true,read_on_configure=false,read_on_refresh=false})end
E[#E+1]=e.cluster_attribute(1,62,{name="battery_alarm",component="main",data_type=i.Bitmap32,read_only=true,read_on_configure=false,read_on_refresh=false,emit=x})end
return{profile=ab,magic_packet=false,zcl_clusters=E}
end
local N=w("safety-contact-aurora-window",e.contact,true)l(N,{Q("Aurora","WindowSensor51AU")})local J=w("safety-contact-livingwise-lvs",e.contact)l(J,{Q("ORVIBO","e70f96b3773a4c9283c6862dbafb6a99")})local S=w("safety-water-orvibo-sw21",e.water)l(S,{Q("HEIMAN","da2edf1ded0d44e1815d06f45ce02029"),Q("Heiman","2f077707a13f4120846e0775df7e2efe")})local V=w("safety-co-climax-co8",e.carbon_monoxide,true)l(V,{Q("ClimaxTechnology","CO_00.00.00.15TC"),Q("ClimaxTechnology","CO_00.00.00.22TC")})end
do
local T,M,m={[16]=1,[17]=15,[18]=30,[19]=30,[20]=50,[21]=50,[22]=70,[23]=70,[24]=90,[25]=90,[26]=100,[27]=100,[28]=100},ag.battery(),{profile="safety-motion-smartthings-pgc314",magic_packet=false,additional_zcl_profiles={64513},zcl_clusters=H(e.motion,{component="main",read_only=true,read_on_configure=false,read_on_refresh=false,configure_reporting=false,ias_configure_method=1})}m.zcl_clusters[#m.zcl_clusters+1]={cluster_id=64516,command_id=0,mfg_code=4362,profile_id=64513,read_only=true,
command_extractor=function(P,a)
if P.address_header.profile.value~=64513 then return end
local d=P.body.zcl_body.body_bytes:byte()if(d&1)==0 then
local q=d>>2
a:emit_event(M(a,T[math.min(28,q)]or 0))a:emit_event(u.voltageMeasurement.voltage{value=q/10,unit="V"})end
a:emit_event((d&2)~=0 and u.motionSensor.motion.active()or u.motionSensor.motion.inactive())
end
}l(m,{Q("SmartThings","PGC314")})end
e.attach_reporting_capabilities(z,{{1,"rpt-edw"},{2,"rpt-fws"},{3,"rpt-ldr"}})return{id="zcl.sensors.passive_alarm_additions",registrations=z}

local f,ae,y=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family"local n,k,c,W=y.create_fingerprint,require"st.zigbee.data_types",require"st.capabilities",require"st.zigbee.cluster_base"
local F,g=y.definition_registry()
local function ad(a)
if type(a)=="table"then
if type(a.is_alarm1_set)=="function"then
return a:is_alarm1_set()end
a=a.value
end
if type(a)~="number"then return nil end
return a%2==1
end
local function e(a,_,T)
local I=type(T)=="table"and T.raw_value or a
if type(I)~="number"or I>=255 then return nil end
if type(T)=="table"then return a end
return I/2
end
local function d()
local b=f.smoke{endpoint=1,read_only=true,from_device=ad}b.minimum_interval=nil
b.maximum_interval=nil
b.reportable_change=nil
return b
end
local X={profile="safety-wave19-ewelink-7035",zcl_clusters={d(),f.battery{endpoint=1,read_only=true,minimum_interval=3600,maximum_interval=65000,reportable_change=10,from_device=e},f.cluster_attribute(64529,8192,{name="ewelink_7035_tamper",endpoint=1,mfg_code=4742,data_type=k.Uint8,read_only=true,read_on_configure=true,
from_device=function(a)
if a==1 then return true end
if a==0 then return false end
return nil
end,
emit=ae.tamper()})},
configure=function(_,t)
for _,V in ipairs{0,16,17}do
f.read_attribute(t,f.CLUSTER_IAS_ZONE,V,1)end
end
}g(X,{n("eWeLink","CK-TLSR8656-Z123SE22DY-01(7035)")})
local function D(_,a)
if a==255 then return nil end
local af=math.floor(math.max(0,math.min(100,(a-25)*20))+0.5)return{c.battery.battery(af),c.voltageMeasurement.voltage{value=a/10,unit="V"}}
end
local p={profile="safety-smoke-smszb120-core",zcl_clusters={f.smoke{endpoint=35,read_only=true,from_device=ad,minimum_interval=0,maximum_interval=65000,reportable_change=0},f.battery_low{endpoint=35,read_on_configure=true,minimum_interval=0,maximum_interval=65000,reportable_change=0,
emit=function(_,a)
return a and c.batteryLevel.battery.critical()or c.batteryLevel.battery.normal()
end},
f.temperature{endpoint=38,minimum_interval=10,maximum_interval=3600,reportable_change=100},f.cluster_attribute(1,32,{name="smszb_battery_voltage",endpoint=35,data_type=k.Uint8,read_only=true,minimum_interval=3600,maximum_interval=65000,reportable_change=10,emit=D})}}for _,b in ipairs(p.zcl_clusters)do
if b.cluster_id==1280 then
b.minimum_interval=nil
b.maximum_interval=nil
b.reportable_change=nil
end
end
g(p,{n("Develco Products A/S","SMSZB-120"),n("Develco Products A/S","GWA1512_SmokeSensor"),n("frient A/S","SMSZB-120")})
local function C()
local b=f.smoke{endpoint=1,read_only=true,from_device=function(a)
if type(a)=="table"then a=a.value end
return(a&3)~=0
end}
b.minimum_interval=nil
b.maximum_interval=nil
b.reportable_change=nil
return b
end
local K={profile="safety-smoke-multir-sm100-core",zcl_clusters={C(),f.battery{endpoint=1,read_only=true,minimum_interval=3600,maximum_interval=65000,reportable_change=10,from_device=e}}}g(K,{n("MultIR","MIR-SM100-E")})
local function q(S,s)
s=s or 2475
return{c.battery.battery(math.floor(math.max(0,math.min(100,(S-s)*100/(3000-s)))+0.5)),c.voltageMeasurement.voltage{value=S/1000,unit="V"}}
end
local function v(s,U)
return function(_,a)
local h=type(a)=="table"and a.value or a
if h==nil then h=a end
if type(h)=="string"then
local aa,u={},1
while u+1<=#h do
local ah,Y=h:byte(u,u+1)local width=Y>=32 and Y<=47 and((Y%8)+1)or Y==16 and 1
if not width or u+1+width>#h then break end
aa[ah]=string.unpack("<"..(Y>=40 and"i"or"I")..width,h,u+2)u=u+2+width
end
h=aa
end
if type(h)~="table"then return nil end
local A=h[1]or h["1"]local Q,l=type(A)=="number"and q(A,s)or{},h[160]or h["160"]if U and l~=nil then
Q[#Q+1]=c.smokeDetector.smoke(l==1 and"detected"or"clear")end
return #Q>0 and Q or nil
end
end
local m,o=v(2475,true),d()o.read_on_configure=false
o.ias_configure_method=0
local w={profile="safety-smoke-aqara-acn03-core",zcl_clusters={o,f.cluster_attribute(64704,314,{name="aqara_smoke",endpoint=1,mfg_code=4447,data_type=k.Uint8,
read_only=true,read_on_configure=true,from_device=function(a)return a==1 end,
emit=ae.smoke()}),f.cluster_attribute(64704,247,{name="aqara_smoke_heartbeat",endpoint=1,read_only=true,read_on_configure=false,emit=m}),f.cluster_attribute(0,65281,{name="aqara_smoke_basic_heartbeat",endpoint=1,read_only=true,read_on_configure=false,emit=m}),f.cluster_attribute(1,32,{name="aqara_smoke_battery_voltage",endpoint=1,data_type=k.Uint8,
read_only=true,read_on_configure=true,emit=function(_,a)
if a==255 then return nil end
return q(a*100)
end
}),f.power_configuration_battery{endpoint=1,read_only=true,scale=2,emit=ae.battery(),read_on_configure=false,from_device=e}},
configure=function(_,t)
t:send(W.write_manufacturer_specific_attribute(t,64704,331,4447,k.Uint8,1):to_endpoint(1))
end
}g(w,{n("LUMI","lumi.sensor_smoke.acn03")})
local function G()
local b=d()b.read_on_configure=false
b.ias_configure_method=0
return b
end
local O={profile="safety-smoke-mijia-core",zcl_clusters={G(),f.cluster_attribute(0,65281,{name="mijia_smoke_battery",endpoint=1,read_only=true,read_on_configure=false,emit=v(2850,false)}),f.cluster_attribute(0,65282,{name="mijia_smoke_struct_battery",endpoint=1,read_only=true,read_on_configure=false,
emit=function(_,a)
local M=a.elements
local ag=M and M[2]and M[2].data
local A=type(ag)=="table"and ag.value or ag
if type(A)=="number"then return q(A,2850)end
end
})}}g(O,{n("LUMI","lumi.sensor_smoke")})
local function i(H)
local l=d()l.read_on_configure=false
local L=f.battery_low{endpoint=1,read_on_configure=false,
emit=function(_,a)
return a and c.batteryLevel.battery.critical()or c.batteryLevel.battery.normal()
end}
L.minimum_interval,L.maximum_interval,L.reportable_change=nil,nil,nil
local N={l,L,f.battery{endpoint=1,read_only=true,minimum_interval=3600,maximum_interval=65000,reportable_change=0,from_device=e},f.cluster_attribute(1,32,{name="smoke_core_voltage",endpoint=1,data_type=k.Uint8,read_only=true,read_on_configure=false,
emit=function(_,a)
if type(a)=="table"then a=a.value end
if a~=255 then return c.voltageMeasurement.voltage{value=a/10,unit="V"}end
end
}),f.cluster_attribute(1,62,{name="smoke_core_battery_alarm",endpoint=1,data_type=k.Bitmap32,read_only=true,read_on_configure=H==true,minimum_interval=H and 3600 or nil,maximum_interval=H and 65000 or nil,reportable_change=H and 0 or nil,
emit=function(_,a)
return(a&0xF03C0F)~=0 and c.batteryLevel.battery.critical()or c.batteryLevel.battery.normal()
end
})}if H then
local j=f.tamper{endpoint=1,read_on_configure=false}j.minimum_interval,j.maximum_interval,j.reportable_change=nil,nil,nil
N[#N+1]=j
end
return N
end
local J={profile="safety-smoke-feibit-ssa01-core",magic_packet=false,zcl_clusters=i(true)}g(J,{n("feibit","FNB56-SMF06FB1.6"),n("Feibit Inc co.","FNB56-SMF06FB1.6"),n("Feibit Inc co.","FNB56-SMF06FB2.0")})local B={profile="safety-smoke-heimgard-htsmo2-core",magic_packet=false,zcl_clusters=i(false)}g(B,{n("Heimgard","HT-SMO-2")})
local function E()
local l=d()l.read_on_configure=false
local j,Z=f.tamper{endpoint=1,read_on_configure=false},f.battery{endpoint=1,read_on_configure=false,from_device=e}for _,b in ipairs{j,Z}do
b.minimum_interval,b.maximum_interval,b.reportable_change=nil,nil,nil
end
return{l,j,Z}
end
local P={profile="safety-smoke-tuya-ts0205-core",magic_packet=false,zcl_clusters=E(),
parent_refresh=function(t)
f.read_attribute(t,1,33,1)f.read_attribute(t,1,32,1)
end
}g(P,{n("_TYZB01_dsjszp0x","TS0205"),n("_TZ3000_hl7yraue","TS0205"),n("_TYZB01_hr7c7xlf","TS0205"),n("_TYZB01_yt1wd5db","TS0205"),n("_TZ3210_4c6b5m1e","TS0205"),n("_TZ3000_2szo322m","TS0205")})
local function z()
local l=d()l.read_on_configure=false
local j=f.tamper{endpoint=1,read_on_configure=false}local L=f.battery_low{endpoint=1,read_on_configure=false,
emit=function(_,a)
return a and c.batteryLevel.battery.critical()or c.batteryLevel.battery.normal()
end}
for _,b in ipairs{j,L}do
b.minimum_interval,b.maximum_interval,b.reportable_change=nil,nil,nil
end
return{l,j,L,f.battery{endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10,from_device=e}}
end
local R={profile="safety-smoke-gs-sshm-i1-core",magic_packet=false,zcl_clusters=z()}g(R,{n("GS","SSHM-I1")})
local function r()
local l=d()l.read_on_configure=false
local j=f.tamper{endpoint=1,read_on_configure=false}local L=f.battery_low{endpoint=1,read_on_configure=false,
emit=function(_,a)
return a and c.batteryLevel.battery.critical()or c.batteryLevel.battery.normal()
end}
for _,b in ipairs{j,L}do
b.minimum_interval,b.maximum_interval,b.reportable_change=nil,nil,nil
end
return{l,j,L}
end
local x={profile="safety-smoke-bitron-av2010-24-core",magic_packet=false,zcl_clusters=r()}g(x,{n("SMaBiT","902010/24"),n("SMaBiT","AV2010/24"),n("Bitron Home","902010/24"),n("Bitron Home","AV2010/24"),n("Bitron Video","902010/24"),n("Bitron Video","AV2010/24"),n("SMaBiT","902010/24A"),n("SMaBiT","AV2010/24A"),n("Bitron Home","902010/24A"),n("Bitron Home","AV2010/24A"),n("Bitron Video","902010/24A"),n("Bitron Video","AV2010/24A")})f.attach_reporting_capabilities(F,{{1,"rpt-cdi"},{2,"rpt-soa"},{3,"rpt-mam"},{6,"rpt-fil"},{7,"rpt-hne"},{9,"rpt-ska"}})return{id="zcl.sensors.wave19_smoke",registrations=F}

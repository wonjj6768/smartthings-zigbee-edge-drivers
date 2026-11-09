local i,u,bh=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family"local g,d,B,z,ak,dK,dO=bh.create_fingerprint,require"st.zigbee.data_types",require"st.capabilities",require"st.zigbee.device_management",require"st.zigbee.cluster_base",require"st.zigbee.zcl.clusters",require"st.buf"
local ay,b=bh.definition_registry()local S,bV,dl,bo,G=1,10,1066,1067,64641




local function r(ab,af,dp,s,w)
return i.temperature{endpoint=s,minimum_interval=ab,maximum_interval=af,reportable_change=dp,read_on_configure=w}
end
local function K(ab,af,dp,s,w)
return i.humidity{endpoint=s,minimum_interval=ab,maximum_interval=af,reportable_change=dp,read_on_configure=w}
end
local function j(s,w)
return i.temperature{endpoint=s or 1,minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=w}
end
local function v(s,w)
return i.humidity{endpoint=s,minimum_interval=10,maximum_interval=3600,reportable_change=100,read_on_configure=w}
end
local function dq(capability_id)
return assert(u[capability_id],"missing Wave19 environment emitter: "..capability_id)()
end
local function bj(dJ)
local cQ,dr=os.date("*t",dJ),os.date("!*t",dJ)cQ.isdst=false
dr.isdst=false
return math.floor(os.difftime(os.time(cQ),os.time(dr)))
end
local function ao(e,dm,ds)
local ac=ak.write_attribute(e,d.ClusterId(bV),d.AttributeId(dm),ds)if type(ac.to_endpoint)=="function"then ac=ac:to_endpoint(1)end
e:send(ac)
end
local function cw(V,e)
e:send(z.build_bind_request(e,bV,V.environment_info.hub_zigbee_eui,1))local dg=os.time()local dt=math.max(0,dg-946684800)ao(e,1,d.Bitmap8(3))ao(e,0,d.Uint32(dt))ao(e,2,d.Int32(bj(dg)))
end
local dE={profile="sensors-wave19-heiman-hs2aq-ef-three",package_group="wave19-environment",zcl_clusters={r(10,3600,100,nil,nil),K(10,3600,100,nil,nil),i.battery{minimum_interval=3600,maximum_interval=65000,reportable_change=10},i.cluster_attribute(dl,0,{name="pm25",emit=u.pm25(),data_type=d.Uint16,minimum_interval=0,maximum_interval=3600,reportable_change=1,read_on_configure=true,read_only=true}),i.cluster_attribute(bo,0,{name="formaldehyde",emit=u.formaldehyde(),data_type=d.Uint16,scale=1000,minimum_interval=0,maximum_interval=3600,reportable_change=1,read_on_configure=true,read_only=true}),i.cluster_attribute(G,61442,{name="heiman_ef_three_charging_status",emit=dq"heimanEfThreeChargingStatus",data_type=d.Uint8,
from_device=function(a)
return({[0]="NotCharged",[1]="Charging",[2]="FullyCharged"})[tonumber(a)]
end,
minimum_interval=0,maximum_interval=3600,reportable_change=1,read_on_configure=true,read_only=true}),i.cluster_attribute(G,61443,{name="heiman_ef_three_pm_ten",emit=dq"heimanEfThreePmTen",data_type=d.Uint16,minimum_interval=0,maximum_interval=3600,reportable_change=1,read_on_configure=true,read_only=true}),i.cluster_attribute(G,61445,{name="heiman_ef_three_aqi",emit=dq"heimanEfThreeAqi",data_type=d.Uint16,minimum_interval=0,maximum_interval=3600,reportable_change=1,read_on_configure=true,read_only=true})},configure=cw}b(dE,{g("HEIMAN","HS2AQ-EF-3.0")})
local function dG(a,ab,af)
if a<ab then return ab end
if a>af then return af end
return a
end
local function bC(_,a)
local bE=tonumber(a)if bE==nil then return nil end
local U=math.floor((((dG(bE,2500,3000)-2500)/500)*100)+0.5)return{B.battery.battery(U),B.voltageMeasurement.voltage{value=bE/1000,unit="V"}}
end
local function cK(V,e)
e:send(z.build_bind_request(e,S,V.environment_info.hub_zigbee_eui,1))
end
local dH={profile="sensors-wave19-plaid-spruce",package_group="wave19-environment",zcl_clusters={r(10,3600,100,nil,nil),K(10,3600,100,nil,nil),i.cluster_attribute(S,0,{name="plaid_mains_voltage_battery",emit=bC,data_type=d.Uint16,read_only=true})},configure=cK}b(dH,{g("PLAID SYSTEMS","PS-SPRZMS-SLP3")})
local function P(a,_,k)
if k and k.raw_value==255 then return nil end
return a
end
local function Z(a,_,k)
local ai=k.zb_rx.body.zcl_body
local p=type(ai.get_attribute_data)=="function"and ai:get_attribute_data(32)if type(p)=="table"then p=p.value end
if type(p)=="number"and p<255 then return end
if k.raw_value~=255 then return a end
end
local function h(au)
au.from_device=au.from_device or P
return i.battery(au)
end
local function q(au)
au.from_device=au.from_device or P
return i.battery_voltage(au)
end
local function D(ci,cP)
return{i.temperature{minimum_interval=10,maximum_interval=3600,reportable_change=ci},i.humidity{minimum_interval=10,maximum_interval=3600,reportable_change=cP},h{minimum_interval=3600,maximum_interval=65000,reportable_change=10},i.power_configuration_battery_voltage{name="battery_voltage",emit=u.voltage(),scale=10,read_only=true,read_on_configure=false,from_device=P}}
end
local bU={profile="sensors-zigbeetlc-th05-core",zcl_clusters=D(10,100)}b(bU,{g("Tuya","TH05-z"),g("Xiaomi","LYWSD03MMC-z"),g("Xiaomi","MJWSD06MMC-z"),g("MiaoMiaoCe","MHO-C122-z"),g("MiaoMiaoCe","MHO-C401-z"),g("MiaoMiaoCe","MHO-C401N-z"),g("Qingping","CGG1-z"),g("Qingping","CGG1N-z"),g("Xiaomi","LYWSD03MMC-bz"),g("Xiaomi","MJWSD06MMC-bz"),g("MiaoMiaoCe","MHO-C122-bz"),g("MiaoMiaoCe","MHO-C401-bz"),g("MiaoMiaoCe","MHO-C401N-bz"),g("Qingping","CGG1-bz"),g("Qingping","CGG1N-bz")})local aY={profile="sensors-zigbeetlc-display-core",zcl_clusters=D(10,100)}b(aY,{g("Qingping","CGDK2-z"),g("Qingping","CGDK2-bz"),g("Tuya","LKTMZL02-z")})local bF={profile="sensors-zigbeetlc-basic-core",zcl_clusters=D(10,100)}b(bF,{g("Tuya","TS0201-z"),g("Wing","TS0201-z"),g("Tuya","TH03Z-z"),g("Tuya","ZTH01-z"),g("Tuya","ZTH02-z"),g("Tuya","ZY-ZTH02-z"),g("Tuya","TS0201-bz"),g("Tuya","TH03Z-bz"),g("Tuya","ZTH01-bz"),g("Tuya","ZTH02-bz")})local bG={profile="sensors-zigbeetlc-zg227-core",zcl_clusters=D(100,100)}b(bG,{g("Tuya","ZG-227Z-z")})local aZ={profile="sensors-zigbeetlc-zbeacon-core",zcl_clusters=D(10,50)}b(aZ,{g("ZBeacon","MC-z"),g("ZBeacon","TH01-z"),g("ZBeacon","TH01-2-z")})local aS={profile="safety-motion-battery-voltage",zcl_clusters={i.occupancy{emit=u.motion(),minimum_interval=0,maximum_interval=3600,reportable_change=0,
from_device=function(a)
if type(a)=="table"then a=a.value end
return(a&1)~=0
end},
h{minimum_interval=3600,maximum_interval=65000,reportable_change=10},i.power_configuration_battery_voltage{name="battery_voltage",emit=u.voltage(),scale=10,read_only=true,read_on_configure=true,from_device=P}}}b(aS,{g("Tuya","TS202PIR1-z")})
local function W(a)
if a==255 then return nil end
return math.floor(math.max(0,math.min(100,(a-25)*20))+0.5)
end
local function t(dM,s,w)
return i.cluster_attribute(1,32,{name=dM or"battery_voltage_percent",endpoint=s or 1,data_type=d.Uint8,read_only=true,minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=w,from_device=W,emit=u.battery()})
end
local function Q(ab,af)
return function(_,a)
if a==255 then return end
return{B.battery.battery(math.floor(math.max(0,math.min(100,(a-ab)*100/(af-ab)))+0.5)),B.voltageMeasurement.voltage{value=a/10,unit="V"}}
end
end
local C=Q(25,30)
local function o(_,a)
return(a&0xF03C0F)~=0 and B.batteryLevel.battery.critical()or B.batteryLevel.battery.normal()
end
local function R(_,a)
return a and B.batteryLevel.battery.critical()or B.batteryLevel.battery.normal()
end
local function x(y,dC)
y.minimum_interval=nil
y.maximum_interval=nil
y.reportable_change=nil
y.read_on_configure=false
y.emit=function(e,a,k)
if k.command_id==0 then return dC(e,a)end
end
return y
end
local function aU()
return{
x(i.motion{endpoint=1,from_device=function(a)
if type(a)=="table"then a=a.value end
return(a&1)~=0
end},u.motion()),
x(i.tamper{endpoint=1},u.tamper()),x(i.battery_low{endpoint=1},R),j(1,false),i.illuminance{endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=5,read_on_configure=true},i.cluster_attribute(1,32,{name="radion_voltage",endpoint=1,data_type=d.Uint8,read_only=true,minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true,emit=C}),i.cluster_attribute(1,62,{name="radion_battery_alarm",endpoint=1,data_type=d.Bitmap32,read_only=true,read_on_configure=false,emit=o})}
end
local function bk(e)i.read_attribute(e,1024,0,1)end
local cm={profile="safety-motion-bosch-radion-core",parent_refresh=bk,zcl_clusters=aU()}b(cm,{g("BOSCH","RFDL-ZB-MS"),g("BOSCH","RFDL-ZB"),g("BOSCH","RFDL-ZB-EU"),g("BOSCH","RFDL-ZB-H"),g("BOSCH","RFDL-ZB-K"),g("BOSCH","RFDL-ZB-CHI"),g("BOSCH","RFDL-ZB-ES"),g("BOSCH","RFPR-ZB"),g("BOSCH","RFPR-ZB-EU"),g("BOSCH","RFPR-ZB-CHI"),g("BOSCH","RFPR-ZB-ES"),g("BOSCH","RFPR-ZB-MS")})local bA=Q(25,32)local bX={profile="sensors-hmszb-core",zcl_clusters={j(38),v(38,nil),i.cluster_attribute(1,32,{name="hmszb_battery_voltage",endpoint=38,data_type=d.Uint8,read_only=true,minimum_interval=3600,maximum_interval=65000,reportable_change=10,emit=bA})}}b(bX,{g("Develco Products A/S","HMSZB-110"),g("Develco Products A/S","HMSZB-120"),g("frient A/S","HMSZB-110"),g("frient A/S","HMSZB-120")})
local function an()
local y=i.occupancy{ias_zone=true,endpoint=35,read_only=true,emit=u.motion()}y.minimum_interval=nil
y.maximum_interval=nil
y.reportable_change=nil
return y
end
local function L(_,a)
if type(a)=="table"then a=a.value end
return C(nil,a)
end
local be={profile="safety-motion-moszb130-core",zcl_clusters={an()}}b(be,{g("Develco Products A/S","MOSZB-130")})local bg={profile="safety-motion-moszb141-core",zcl_clusters={an()}}b(bg,{g("Develco Products A/S","MOSZB-141"),g("frient A/S","MOSZB-141")})local bf={profile="safety-motion-moszb140-core",
parent_refresh=function(e)
i.read_attribute(e,1026,0,38)i.read_attribute(e,1024,0,39)i.read_attribute(e,1,32,35)
end,
zcl_clusters={x(i.motion{endpoint=35},u.motion()),x(i.tamper{endpoint=35},u.tamper()),x(i.battery_low{endpoint=35},R),r(60,3600,100,38,true),i.illuminance{endpoint=39,minimum_interval=300,maximum_interval=3600,reportable_change=100,read_on_configure=true},i.cluster_attribute(1,32,{name="moszb_battery_voltage",endpoint=35,data_type=d.Uint8,read_only=true,minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true,emit=L})}}b(bf,{g("Develco Products A/S","MOSZB-140"),g("frient A/S","MOSZB-140"),g("Develco Products A/S","GWA1511_MotionSensor")})local bz={profile="safety-motion-moszb153-core",zcl_clusters={i.occupancy{endpoint=35,ias_zone=true,emit=u.motion(),read_on_configure=true,minimum_interval=0,maximum_interval=65000,reportable_change=0},j(38),i.illuminance{endpoint=39,component="main",minimum_interval=60,maximum_interval=3600,reportable_change=500,read_on_configure=true},i.cluster_attribute(1,32,{name="moszb_battery_voltage",endpoint=35,data_type=d.Uint8,read_only=true,minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true,emit=L}),i.cluster_attribute(1,33,{name="moszb153_battery_percentage",endpoint=35,data_type=d.Uint8,read_only=true,read_on_configure=false,scale=2,from_device=Z,emit=u.battery()})}}b(bz,{g("frient A/S","MOSZB-153"),g("Develco Products A/S","MOSZB-153")})
local function X()
local y=i.occupancy{ias_zone=true,endpoint=1,read_only=true,emit=u.motion(),
from_device=function(a)
if type(a)=="table"then a=a.value end
return(a&2)~=0
end}
y.minimum_interval=nil
y.maximum_interval=nil
y.reportable_change=nil
return y
end
local aD=Q(21,30)local aI={profile="safety-motion-centralite-a-core",zcl_clusters={X(),j(),i.cluster_attribute(1,32,{name="centralite_battery_voltage",endpoint=1,data_type=d.Uint8,read_only=true,minimum_interval=3600,maximum_interval=65000,reportable_change=0,emit=aD})}}b(aI,{g("CentraLite","Motion Sensor-A")})
local function T(e)
return e.zigbee_endpoints and e.zigbee_endpoints[3]and 3 or 1
end
local function av(a,_,k)
local df=k and k.raw_value or a
if df>=32767 then return nil end
return k and a or df/100
end
local function aL(a,_,k)
local df=k and k.raw_value or a
if df>=255 then return nil end
return k and a or df/2
end
local function aM(a,_,k)
local df=k and k.raw_value or a
if df>=255 then return nil end
return k and a or df/10
end
local de={profile="sensors-owon-ths317-et",zcl_clusters={i.temperature{endpoint=T,minimum_interval=10,maximum_interval=3600,reportable_change=100,from_device=av},h{endpoint=T,minimum_interval=3600,maximum_interval=65000,reportable_change=0,from_device=aL},q{endpoint=T,minimum_interval=3600,maximum_interval=65000,reportable_change=0,from_device=aM}}}b(de,{g("OWON","THS317-ET")})local aV={profile="sensors-devbis-lywsd03mmc-core",
configure=function(V,e)
for _,aw in ipairs{{1026,0,d.Int16,10,300,10},{1029,0,d.Uint16,10,300,50},{1,33,d.Uint8,3600,65000,10}}do
if not e:supports_server_cluster(aw[1],1)then
e:send(z.build_bind_request(e,aw[1],V.environment_info.hub_zigbee_eui,1):to_endpoint(1))e:send(z.attr_config(e,{cluster=aw[1],attribute=aw[2],data_type=aw[3],minimum_interval=aw[4],maximum_interval=aw[5],reportable_change=aw[3](aw[6])}):to_endpoint(1))end
end
end,
zcl_clusters={r(10,300,10,1,nil),K(10,300,50,1,nil),h{endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10}}}b(aV,{g("Xiaomi","LYWSD03MMC")})local ba={profile="safety-motion-zg204zl-z-core",zcl_clusters={i.occupancy{endpoint=1,emit=u.motion(),minimum_interval=0,maximum_interval=3600,
reportable_change=0,from_device=function(a)
if type(a)=="table"then a=a.value end
return(a&1)~=0
end},
i.illuminance{endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=5},h{endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10}}}b(ba,{g("Sonoff","ZG-204ZL-z")})local cS={profile="sensors-nodon-stph-core",zcl_clusters={j(),v(1,nil),h{endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10}}}b(cS,{g("NodOn","STPH-4-1-00")})
local function c(y)
y.minimum_interval=nil
y.maximum_interval=nil
y.reportable_change=nil
return y
end
local function A(s)
return c(h{endpoint=s,read_on_configure=false})
end
local function n(s)
return c(q{endpoint=s,read_on_configure=false})
end
local function at(e,a)
if type(a)=="table"then a=a.value end
return o(e,a)
end
local function ah(e)
local s=e:get_endpoint(1)i.read_attribute(e,1,33,s)i.read_attribute(e,1,0,s)
end
local bO={profile="sensors-namron-4512765-core",zcl_clusters={c(i.temperature{endpoint=1}),c(i.humidity{endpoint=1}),c(h{endpoint=1})}}b(bO,{g("Namron AS","4512765")})local bN={profile="safety-motion-namron-4512763-core",zcl_clusters={x(i.motion{endpoint=1},u.motion()),x(i.tamper{endpoint=1},u.tamper()),x(i.battery_low{endpoint=1},R),h{endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10},c(q{endpoint=1})}}b(bN,{g("Namron AS","4512763")})local ae={profile="sensors-openlumi-router-temperature-core",magic_packet=false,zcl_clusters={i.cluster_attribute(2,0,{name="openlumi_device_temperature",endpoint=1,data_type=d.Int16,read_only=true,read_on_configure=true,minimum_interval=300,maximum_interval=3600,reportable_change=1,emit=u.temperature"C"})}}b(ae,{g("OpenLumi","openlumi.gw_router.dgnwg05lm"),g("OpenLumi","openlumi.gw_router.zhwg11lm")})local cd={profile="sensors-salus-ss909zb-core",zcl_clusters={j(9,false),t("ss909zb_battery",9,true)}}b(cd,{g("Computime","SS909ZB"),g("Computime","PS600")})do
local br={profile="sensors-centralite-3310-core",
parent_refresh=function()end,
zcl_clusters={j(1,false),i.cluster_attribute(64581,0,{name="centralite_humidity",endpoint=1,mfg_code=4174,data_type=d.Uint16,read_only=true,read_on_configure=false,scale=100,emit=u.humidity(),minimum_interval=10,maximum_interval=3600,reportable_change=10}),i.cluster_attribute(1,32,{name="centralite_3310_voltage",endpoint=1,data_type=d.Uint8,read_only=true,minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true,emit=C}),i.cluster_attribute(1,62,{name="centralite_3310_alarm",endpoint=1,data_type=d.Bitmap32,read_only=true,read_on_configure=false,emit=o})}}b(br,{g("CentraLite","3310-G"),g("CentraLite","3310-S"),g("SmartThings","3310-S")})local bi=c(t())bi.read_on_configure=false
local co={profile="sensors-feibit-sth01-core",magic_packet=false,zcl_clusters={c(i.temperature{endpoint=1,read_on_configure=false}),c(i.humidity{endpoint=1,read_on_configure=false}),bi}}b(co,{g("fei","FNB54-THM17ML1.1"),g("Feibit Inc co.","FNB54-THM17ML1.1"),g("Feibit Inc co.","FB56-THM12HM1.2"),g("Feibit Inc co.","FNB56-THM14FB2.4"),g("Feibit Inc co.","FNB56-THM14FB2.5")})local bt={profile="safety-motion-centralite-3328-core",zcl_clusters={X(),j()}}b(bt,{g("CentraLite","3328-G")})end
local function I(a)
if a==255 then return nil end
local p,ag=a*100,100

if p<2100 then ag=0
elseif p<2440 then ag=6-(2440-p)*6/340
elseif p<2740 then ag=18-(2740-p)*12/300
elseif p<2900 then ag=42-(2900-p)*24/160
elseif p<3000 then ag=100-(3000-p)*58/100 end
return math.floor(ag+0.5)
end
local function as(_,a)
if a==255 then return end
return{B.battery.battery(I(a)),B.voltageMeasurement.voltage{value=a/10,unit="V"}}
end
local function am(dn,dv)
return{
x(i.motion{endpoint=1,from_device=function(a)
if type(a)=="table"then a=a.value end
return(a&2)~=0
end},u.motion()),
x(i.tamper{endpoint=1},u.tamper()),x(i.battery_low{endpoint=1},R),j(1,false),i.cluster_attribute(1,32,{name=dn,endpoint=1,data_type=d.Uint8,read_only=true,minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true,emit=as}),i.cluster_attribute(1,62,{name=dv,endpoint=1,data_type=d.Bitmap32,read_only=true,read_on_configure=false,emit=o})}
end
local da={profile="safety-motion-iris-3326-core",
parent_refresh=function()end,
zcl_clusters=am("iris_battery","iris_alarm")}b(da,{g("CentraLite","3326-L"),g("iMagic by GreatStar","3326-L")})local cr={profile="sensors-sihas-tsm300-core",magic_packet=false,zcl_clusters={r(30,300,30,1,false),K(30,3600,50,1,false),i.cluster_attribute(1,32,{name="sihas_tsm_battery_voltage",endpoint=1,data_type=d.Uint8,read_only=true,read_on_configure=true,minimum_interval=30,maximum_interval=21600,reportable_change=1,emit=as})}}b(cr,{g("ShinaSystem","TSM-300Z")})local dj={profile="sensors-konke-th-core",zcl_clusters={j(),c(i.humidity{endpoint=1}),t()}}b(dj,{g("Konke","3AFE140103020000"),g("Konke","3AFE220103020000")})local bZ={profile="safety-motion-ikea-vallhorn-core",zcl_clusters={i.occupancy{endpoint=2,emit=u.motion(),minimum_interval=0,maximum_interval=3600,
reportable_change=0,from_device=function(a)
if type(a)=="table"then a=a.value end
return(a&1)~=0
end},
i.illuminance{endpoint=3,minimum_interval=10,maximum_interval=3600,reportable_change=5},h{endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10},q{endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10}}}b(bZ,{g("IKEA of Sweden","VALLHORN Wireless Motion Sensor")})
local function f(s,dI,dL)
return c(i.occupancy{endpoint=s,ias_zone=true,read_only=true,
read_on_configure=false,from_device=function(a,_,k)
if not k or k.command_id~=0 then return nil end
if type(a)=="table"then a=a.value end
return(a&(dL or 1))~=0
end,emit=function(e,dD)
if dI then
local aN=e:get_field"__core_ias_motion_timer"if aN then aN:cancel()end
e:set_field("__core_ias_motion_timer",e.thread:call_with_delay(90,function()
e:set_field("__core_ias_motion_timer",nil)e:emit_event(B.motionSensor.motion.inactive())
end,"Motion reset"))
end
return B.motionSensor.motion(dD and"active"or"inactive")
end
})
end
local function l(s,aH)
return c(i.battery_low{endpoint=not aH and(s or 1)or nil,read_on_configure=false,
emit=function(_,a,k)
if k.command_id==0 then
return a and B.batteryLevel.battery.critical()or B.batteryLevel.battery.normal()end
end
})
end
local cH={profile="safety-motion-tuya-sm0202-core",magic_packet=false,zcl_clusters={f(1,true),l(),h{endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true},n(1)}}b(cH,{g("_TYZB01_u6uejz21","SM0202")})local bc={profile="safety-motion-bitron-av2010-22-core",magic_packet=false,zcl_clusters={f(1,true),c(i.tamper{endpoint=1,read_on_configure=false,
emit=function(e,dB,k)
if k.command_id==0 then return u.tamper()(e,dB)end
end
}),l()}}b(bc,{g("SMaBiT","902010/22"),g("SMaBiT","AV2010/22"),g("Bitron Home","902010/22"),g("Bitron Home","AV2010/22"),g("Bitron Video","902010/22"),g("Bitron Video","AV2010/22"),g("Bitron Video","IR_00.00.03.12TC"),g("SMaBiT","902010/22B"),g("SMaBiT","AV2010/22B"),g("Bitron Home","902010/22B"),g("Bitron Home","AV2010/22B"),g("Bitron Video","902010/22B"),g("Bitron Video","AV2010/22B")})local bb={profile="safety-motion-bitron-av2010-14-core",magic_packet=false,zcl_clusters={f(1,true),l()}}b(bb,{g("SMaBiT","902010/14"),g("SMaBiT","AV2010/14"),g("Bitron Home","902010/14"),g("Bitron Home","AV2010/14"),g("Bitron Video","902010/14"),g("Bitron Video","AV2010/14"),g("SMaBiT","902010/22A"),g("SMaBiT","AV2010/22A"),g("Bitron Home","902010/22A"),g("Bitron Home","AV2010/22A"),g("Bitron Video","902010/22A"),g("Bitron Video","AV2010/22A")})local aE={profile="safety-motion-smartthings-v4-core",magic_packet=false,zcl_clusters={c(i.occupancy{endpoint=1,ias_zone=true,read_on_configure=false,emit=u.motion(),
from_device=function(a)
if type(a)=="table"then a=a.value end
return(a&3)~=0
end
}),c(i.tamper{endpoint=1,read_on_configure=false}),j(1,false),i.cluster_attribute(1,32,{name="smartthings_v4_battery",endpoint=1,data_type=d.Uint8,read_only=true,read_on_configure=true,minimum_interval=3600,maximum_interval=65000,reportable_change=0,
from_device=function(a)
if a==255 then return nil end
return math.floor(math.max(0,math.min(100,235-370000/(a*100+1)))+0.5)
end,
emit=u.battery()})}}b(aE,{g("SmartThings","motionv4")})
local function m(s,aH)
return c(i.tamper{endpoint=not aH and(s or 1)or nil,read_on_configure=false,
emit=function(e,a,k)
if k.command_id==0 then return u.tamper()(e,a)end
end
})
end
local cf={profile="safety-motion-sercomm-pir02-core",magic_packet=false,zcl_clusters={f(1,false),m(),l(),h{endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true,
from_device=function()return nil end
},i.cluster_attribute(1,32,{name="sercomm_pir02_battery",endpoint=1,data_type=d.Uint8,read_only=true,read_on_configure=false,from_device=I,emit=u.battery()}),i.cluster_attribute(1,62,{name="sercomm_pir02_battery_alarm",endpoint=1,data_type=d.Bitmap32,read_only=true,read_on_configure=false,emit=o})}}b(cf,{g("Sercomm Corp.","SZ-PIR02"),g("Sercomm Corp.","SZ-PIR02_SF")})local cg={profile="safety-motion-sercomm-pir04-core",magic_packet=false,zcl_clusters={f(1,false),m(),j(1,false),i.illuminance{endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=5,read_on_configure=true},i.cluster_attribute(1,32,{name="sercomm_pir04_battery_voltage",endpoint=1,data_type=d.Uint8,read_only=true,read_on_configure=true,minimum_interval=3600,maximum_interval=65000,reportable_change=0,
emit=function(_,a)
if a==255 then return nil end
local ag=math.floor(math.max(0,math.min(100,(a-25)*100/7))+0.5)return{B.battery.battery(ag),B.voltageMeasurement.voltage{value=a/10,unit="V"}}
end
})}}b(cg,{g("Sercomm Corp.","SZ-PIR04N"),g("Sercomm Corp.","SZ-PIR04N_EU")})local cX={profile="safety-motion-bosch-isw-core",zcl_clusters={f(5,false),m(5),l(5),j(5,false),t("isw_battery",5,true)}}b(cX,{g("Bosch","ISW-ZPR1-WP13"),g("BOSCH","ISW-ZPR1-WP13")})local cA={profile="safety-motion-hive-mot003-core",zcl_clusters={f(6,true),j(6),h{endpoint=6,minimum_interval=3600,maximum_interval=65000,reportable_change=0}}}b(cA,{g("HiveHome.com","MOT003")})local cq={profile="safety-motion-konke-core",zcl_clusters={f(1,true),c(t())}}b(cq,{g("Konke","3AFE14010402000D"),g("Konke","3AFE27010402000D"),g("Konke","3AFE28010402000D")})local bq={profile="safety-motion-centralite-3305-core",
parent_refresh=function()end,
zcl_clusters={f(1,false,2),m(),l(),j(1,false),i.cluster_attribute(1,32,{name="centralite_3305_voltage",endpoint=1,data_type=d.Uint8,read_only=true,minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true,emit=C}),i.cluster_attribute(1,62,{name="centralite_3305_alarm",endpoint=1,data_type=d.Bitmap32,read_only=true,read_on_configure=false,emit=o})}}b(bq,{g("CentraLite","3305-S"),g("CentraLite","3305"),g("SmartThings","3305-S"),g("SmartThings","3305")})local bs={profile="safety-motion-centralite-3325-core",
parent_refresh=function()end,
zcl_clusters=am("centralite_3325_battery","centralite_3325_alarm")}b(bs,{g("CentraLite","3325-S"),g("SmartThings","3325-S")})local aF={profile="safety-motion-smartthings-v5-core",zcl_clusters={f(1,false),j(),t()}}b(aF,{g("SmartThings","motionv5")})local cp={profile="sensors-keen-home-th-core",zcl_clusters={
c(i.temperature{endpoint=1,read_on_configure=false,from_device=function(a)
if a>-65 and a<65 then return a end
end}),
c(i.humidity{endpoint=1,read_on_configure=false}),i.cluster_attribute(1,32,{name="keen_battery",endpoint=1,data_type=d.Uint8,read_only=true,read_on_configure=false,from_device=I,emit=u.battery()}),n(1),i.cluster_attribute(1,62,{name="keen_battery_alarm",endpoint=1,data_type=d.Bitmap32,read_only=true,read_on_configure=false,emit=o})}}b(cp,{g("LUMI","RS-THP-MP-1.0"),g("Keen Home Inc","RS-THP-MP-1.0")})local bM={profile="safety-motion-linkind-core",zcl_clusters={f(1,false),h{endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=0}}}b(bM,{g("lk","ZB-MotionSensor-D0003")})local cU={profile="safety-motion-trust-zpir-core",zcl_clusters={f(1,false,2),m(),l(),h{endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true}}}b(cU,{g("ADUROLIGHT","VMS_ADUROLIGHT"),g("Trust International B.V.","VMS_ADUROLIGHT"),g("Trust International B.V.\0","VMS_ADUROLIGHT"),g("AduroSmart Eria","VMS_ADUROLIGHT")})local aW={profile="safety-motion-livingwise-core",zcl_clusters={f(1,true),A(1),n(1)}}b(aW,{g("ORVIBO","895a2d80097f4ae2b2d40500d5e03dcc"),g("中性","700ae5aab3414ec09c1872efe7b8755a")})
local function N()
return{i.occupancy{endpoint=2,emit=u.motion(),minimum_interval=0,maximum_interval=3600,
reportable_change=0,from_device=function(a)
if type(a)=="table"then a=a.value end
return(a&1)~=0
end},
j(2),i.illuminance{endpoint=2,minimum_interval=10,maximum_interval=3600,reportable_change=5},h{endpoint=2,minimum_interval=3600,maximum_interval=65000,reportable_change=0}}
end
local cL={profile="safety-motion-hue-sml001-core",zcl_clusters=N()}b(cL,{g("Philips","SML001")})local cM={profile="safety-motion-hue-sml002-core",zcl_clusters=N()}b(cM,{g("Philips","SML002")})
local function al()
local cF=N()cF[1].read_on_configure=false
cF[2].read_on_configure=false
cF[3].read_on_configure=true
cF[4].read_on_configure=true
cF[5]=n(2)cF[6]=i.cluster_attribute(1,62,{name="hue_battery_alarm",endpoint=2,data_type=d.Bitmap32,read_only=true,read_on_configure=false,emit=o})return cF
end
local function ar(e)i.read_attribute(e,1024,0,2)end
local cN={profile="safety-motion-hue-sml003-core",parent_refresh=ar,zcl_clusters=al()}b(cN,{g("Signify Netherlands B.V.","SML003"),g("Philips","SML003")})local cO={profile="safety-motion-hue-sml004-core",parent_refresh=ar,zcl_clusters=al()}b(cO,{g("Signify Netherlands B.V.","SML004"),g("Philips","SML004")})local bW={profile="safety-motion-adeo-ldsenk10-core",zcl_clusters={f(1,false)}}b(bW,{g("ADEO","LDSENK10")})
local function O(aq)
local J,bL=aq==false and{configure_reporting=false,read_on_configure=true}or{minimum_interval=0,maximum_interval=3600,reportable_change=0},aq==false and{endpoint=1,configure_reporting=false,read_on_configure=true}or{endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=5}return{i.occupancy{endpoint=1,emit=u.presence(),configure_reporting=J.configure_reporting,read_on_configure=J.read_on_configure,minimum_interval=J.minimum_interval,maximum_interval=J.maximum_interval,reportable_change=J.reportable_change,
from_device=function(a)
if type(a)=="table"then a=a.value end
return(a&1)~=0
end},
i.illuminance(bL)}
end
local bm={profile="safety-presence-sonoff-snzb06p24-core",zcl_clusters=O(false),
configure=function(V,e)
for _,cY in ipairs{1,1280}do
e:send(z.build_bind_request(e,cY,V.environment_info.hub_zigbee_eui,1):to_endpoint(1))end
end
}b(bm,{g("SONOFF","SNZB-06P24")})local bn={profile="safety-presence-third-reality-r3-core",zcl_clusters=O()}b(bn,{g("Third Reality, Inc","3RPL01084Z")})
local function ad()
return{j(1,false),v(2,false),t(nil,2,true),h{endpoint=2,minimum_interval=3600,maximum_interval=65000,reportable_change=0,
read_on_configure=true,from_device=function()return nil end}
}
end
local cD={profile="sensors-orvibo-st20-core",zcl_clusters=ad()}b(cD,{g("Heiman","b467083cfc864f5e826459e5d8ea6079"),g("ORVIBO","b467083cfc864f5e826459e5d8ea6079")})local cE={profile="sensors-orvibo-st21-core",zcl_clusters=ad()}b(cE,{g("HEIMAN","888a434f3cfc47f29ec4a3a03e9fc442"),g("ORVIBO","888a434f3cfc47f29ec4a3a03e9fc442")})local cB={profile="safety-motion-imagic-1117-core",zcl_clusters={f(1,false,2),j(),v(1,nil),i.cluster_attribute(1,32,{name="imagic_battery",endpoint=1,data_type=d.Uint8,read_only=true,minimum_interval=3600,maximum_interval=65000,reportable_change=10,from_device=I,emit=u.battery()}),q{endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10},h{endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10}}}b(cB,{g("iMagic by GreatStar","1117-S")})local bp={profile="safety-motion-aurora-51-core",zcl_clusters={f(1,false),i.illuminance{minimum_interval=10,maximum_interval=3600,reportable_change=5}}}b(bp,{g("Aurora","MotionSensor51AU")})local cG={profile="safety-motion-sengled-e1m-core",zcl_clusters={c(i.occupancy{endpoint=1,ias_zone=true,emit=u.motion(),
from_device=function(a)
if type(a)=="table"then a=a.value end
return(a&1)~=0
end}),
h{endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10}}}b(cG,{g("sengled","E1M-G7H")})local ce={profile="safety-motion-samjin-core",
parent_refresh=function()end,
zcl_clusters={f(1,false),m(),l(),j(1,false),i.cluster_attribute(1,32,{name="samjin_motion_voltage",endpoint=1,data_type=d.Uint8,read_only=true,minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true,emit=C}),i.cluster_attribute(1,62,{name="samjin_motion_alarm",endpoint=1,data_type=d.Bitmap32,read_only=true,read_on_configure=false,emit=o})}}b(ce,{g("Samjin","motion"),g("SmartThings","motion")})local aX={profile="safety-motion-thirdreality-3rms-core",zcl_clusters={f(1,false),c(h{endpoint=1,read_on_configure=true}),n(1)}}b(aX,{g("THIRDREALITY","3RMS16BZ")})
local function H()
return{r(30,1800,10,nil,false),K(30,1800,10,nil,false),h{minimum_interval=3600,maximum_interval=21600,reportable_change=1,read_on_configure=true},q{minimum_interval=3600,maximum_interval=21600,reportable_change=1,read_on_configure=true}}
end
local bx={profile="sensors-efekta-th-v1-lr-core",magic_packet=false,zcl_clusters=H()}b(bx,{g("EfektaLab","EFEKTA_TH_v1_LR")})local by={profile="sensors-efekta-th-v2-lr-core",magic_packet=false,zcl_clusters=H()}b(by,{g("EfektaLab","EFEKTA_TH_v2_LR"),g("EfektaLab_for_Zigbee-Shop.ru","EFEKTA_TH_v2_LR")})local bw={profile="sensors-efekta-th-pow-r-core",magic_packet=false,parent_refresh=ah,zcl_clusters={r(0,300,0,nil,false),K(0,300,0,nil,false),h{minimum_interval=10,maximum_interval=600,reportable_change=1,read_on_configure=true},i.cluster_attribute(1,0,{name="efekta_th_pow_mains_voltage",data_type=d.Uint16,scale=10,read_only=true,read_on_configure=true,emit=u.voltage()}),i.cluster_attribute(1,62,{name="efekta_th_pow_battery_alarm",data_type=d.Bitmap32,read_only=true,read_on_configure=false,emit=o})}}b(bw,{g("EfektaLab_for_Zigbee-Shop.ru","EFEKTA_TH_POW_R"),g("EfektaLab","EFEKTA_TH_POW_R"),g("EfektaLab","EFEKTA_TH_POW_E"),g("EfektaLab_for_Zigbee-Shop.ru","EFEKTA_TH_POW_E")})local bv={profile="sensors-efekta-t1-v2-lr-core",magic_packet=false,zcl_clusters={r(30,1800,10,nil,false),h{minimum_interval=3600,maximum_interval=21600,reportable_change=1,read_on_configure=true},q{minimum_interval=3600,maximum_interval=21600,reportable_change=1,read_on_configure=true}}}b(bv,{g("EfektaLab","EFEKTA_T1_v2_LR"),g("EfektaLab_for_Zigbee-Shop.ru","EFEKTA_T1_v2_LR")})local bu={profile="sensors-efekta-t1-max-e-core",magic_packet=false,parent_refresh=ah,zcl_clusters={r(0,300,0,nil,false),h{minimum_interval=10,maximum_interval=600,reportable_change=1,read_on_configure=true},i.cluster_attribute(1,0,{name="efekta_t1_max_mains_voltage",data_type=d.Uint16,scale=10,read_only=true,read_on_configure=true,emit=u.voltage()}),i.cluster_attribute(1,62,{name="efekta_t1_max_battery_alarm",data_type=d.Bitmap32,read_only=true,read_on_configure=false,emit=o})}}b(bu,{g("EfektaLab","EFEKTA_T1_MAX_E"),g("EfektaLab","EFEKTA_T1_MAX_R")})local bJ={profile="sensors-efekta-eth102z-core",magic_packet=false,zcl_clusters=H()}b(bJ,{g("efektalab.com","EFEKTA_eTH102z")})local bI={profile="sensors-efekta-eon29wz-core",magic_packet=false,zcl_clusters={r(0,21600,0,nil,true),K(0,21600,0,nil,true),i.illuminance{minimum_interval=0,maximum_interval=21600,reportable_change=0,read_on_configure=true},h{minimum_interval=0,maximum_interval=21600,reportable_change=0,read_on_configure=true},n()}}b(bI,{g("EfektaLab","EFEKTA_eON29wz")})local bB={profile="sensors-ikea-vindstyrka-core",magic_packet=false,zcl_clusters={r(10,3600,100,nil,true),v(nil,true),i.cluster_attribute(1066,0,{name="ikea_vindstyrka_pm25",data_type=d.SinglePrecisionFloat,minimum_interval=60,maximum_interval=120,reportable_change=d.SinglePrecisionFloat(0,1,0),read_only=true,read_on_configure=true,
from_device=function(a)
if type(a)=="table"then a=a.value end
return math.floor(math.max(0,a)+0.5)
end,
emit=u.pm25()})}}b(bB,{g("IKEA of Sweden","VINDSTYRKA")})local aJ={profile="sensors-miamiaoce-mho-c401n-core",magic_packet=false,zcl_clusters={r(10,300,10,1,true),K(10,300,50,1,true),h{endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true}}}b(aJ,{g("MiaMiaoCe","MHO-C401N")})local aR={profile="sensors-zigbeetlc-mho-c401n-core",magic_packet=false,zcl_clusters={r(10,3600,10,1,true),v(1,true),h{endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true},n(1)}}b(aR,{g("MiaMiaoCe","MHO-C401N-z")})local bl={profile="sensors-sonoff-snzb02dr2-core",magic_packet=false,zcl_clusters={r(10,3600,100,nil,true),v(nil,true),h{minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true},q{minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true}},
configure=function(V,e)
local s=e:get_endpoint(32)e:send(z.build_bind_request(e,32,V.environment_info.hub_zigbee_eui,s):to_endpoint(s))
end
}b(bl,{g("SONOFF","SNZB-02DR2")})local bY={profile="sensors-efekta-th-duo-core",magic_packet=false,
parent_refresh=function(e)
i.read_attribute(e,1,33,1)i.read_attribute(e,1,32,1)
end,
zcl_clusters={i.temperature{endpoint=1,component="main",minimum_interval=30,maximum_interval=1800,reportable_change=10,read_on_configure=false},i.humidity{endpoint=1,component="main",minimum_interval=30,maximum_interval=1800,reportable_change=10,read_on_configure=false},i.temperature{endpoint=2,component="external",minimum_interval=30,maximum_interval=1800,reportable_change=10,read_on_configure=false},i.humidity{endpoint=2,component="external",minimum_interval=30,maximum_interval=1800,reportable_change=10,read_on_configure=false},h{endpoint=1,component="main",minimum_interval=3600,maximum_interval=21600,reportable_change=1,read_on_configure=true},q{endpoint=1,component="main",minimum_interval=3600,maximum_interval=21600,reportable_change=1,read_on_configure=true},i.cluster_attribute(1,62,{name="efekta_th_duo_battery_alarm",endpoint=1,component="main",data_type=d.Bitmap32,read_only=true,read_on_configure=false,emit=at})}}b(bY,{g("EfektaLab","EFEKTA_TH_DUO_LR")})local cy={profile="sensors-efekta-t1-y-core",magic_packet=false,
parent_refresh=function(e)
i.read_attribute(e,1,33,e:get_endpoint(1))i.read_attribute(e,1,32,e:get_endpoint(1))
end,
zcl_clusters={c(i.temperature{read_on_configure=false}),A(),n(),i.cluster_attribute(1,62,{name="efekta_t1_y_battery_alarm",data_type=d.Bitmap32,read_only=true,read_on_configure=false,emit=at})}}b(cy,{g("EfektaLab","EFEKTA_T1_Y"),g("EfektaLab","EFEKTA_T1_Y_LR")})local cn={profile="sensors-efekta-t1-v2-core",magic_packet=false,
parent_refresh=function(e)
i.read_attribute(e,1,33,1)i.read_attribute(e,1,32,1)
end,
zcl_clusters={r(30,1800,10,1,false),h{endpoint=1,minimum_interval=3600,maximum_interval=21600,reportable_change=1,read_on_configure=true},q{endpoint=1,minimum_interval=3600,maximum_interval=21600,reportable_change=1,read_on_configure=true},i.cluster_attribute(1,62,{name="efekta_t1_v2_battery_alarm",endpoint=1,data_type=d.Bitmap32,read_only=true,read_on_configure=false,emit=o})}}b(cn,{g("EfektaLab","EFEKTA_T1_v2")})local cz={profile="sensors-gs-sthm-i1h-core",magic_packet=false,zcl_clusters={r(10,3600,100,nil,true),v(nil,true),h{minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true,from_device=Z},i.cluster_attribute(1,32,{name="gs_sthm_battery_voltage",data_type=d.Uint8,read_only=true,read_on_configure=false,emit=L})}}b(cz,{g("GS","STHM-I1H")})local cc={profile="sensors-pushok-pok005-core",magic_packet=false,zcl_clusters={c(i.temperature{}),c(i.humidity{}),A(),n()}}b(cc,{g("PushOk Hardware","POK005")})local ch={profile="sensors-slacky-ts0201-core",magic_packet=false,zcl_clusters={r(10,3600,10,nil,true),K(10,3600,10,nil,true),h{minimum_interval=3600,maximum_interval=21600,reportable_change=0,read_on_configure=true},q{minimum_interval=3600,maximum_interval=21600,reportable_change=0,read_on_configure=true}}}b(ch,{g("Slacky-DIY","TS0201-z-SlD"),g("Slacky-DIY","TS0201-z21-SlD"),g("Slacky-DIY","TS0201-z22-SlD"),g("Slacky-DIY","TS0201-z23-SlD"),g("Slacky-DIY","TS0201-z24-SlD"),g("Slacky-DIY","TS0201-z28-SlD")})local ct={profile="safety-motion-yandex-00528-core",magic_packet=false,zcl_clusters={i.occupancy{emit=u.motion(),minimum_interval=0,maximum_interval=3600,
reportable_change=0,read_on_configure=true,from_device=function(a)
if type(a)=="table"then a=a.value end
return(a&1)~=0
end},
i.illuminance{minimum_interval=10,maximum_interval=3600,reportable_change=5,read_on_configure=true},h{minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true},n()}}b(ct,{g("Yandex","YNDX-00528")})local cu={profile="sensors-yandex-00529-core",magic_packet=false,zcl_clusters={r(10,3600,100,nil,true),v(nil,true),h{minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true},n()}}b(cu,{g("Yandex","YNDX-00529")})
local function aA(a,_,k)
local ai=k and k.zb_rx and k.zb_rx.body and k.zb_rx.body.zcl_body
if ai and type(ai.get_attribute_data)=="function"then
local az=ai:get_attribute_data(61441)if az~=nil then
if type(az)=="table"then az=az.value end
a=a+az/10
end
end
return a
end
local aB={profile="sensors-pushok-extended-probe-core",magic_packet=false,zcl_clusters={c(i.temperature{read_on_configure=false,from_device=aA}),A(),n()}}b(aB,{g("PushOk Hardware","POK014"),g("PushOk Hardware","POK015")})local ca={profile="sensors-kmpcil-res005-core",magic_packet=false,zcl_clusters={j(8,false),v(8,false),h{endpoint=8,minimum_interval=1,maximum_interval=120,reportable_change=1,read_on_configure=false},c(q{endpoint=8,read_on_configure=false}),i.cluster_attribute(15,85,{name="kmpcil_res005_motion",endpoint=8,data_type=d.Boolean,read_only=true,read_on_configure=false,minimum_interval=0,maximum_interval=30,reportable_change=true,
from_device=function(a)
if type(a)=="table"then a=a.value end
return a==1 or a==true
end,
emit=u.motion()}),i.illuminance{minimum_interval=10,maximum_interval=3600,reportable_change=5}},
configure=function(_,e)
for _,aw in ipairs{{81,d.Boolean,true},{257,d.Uint32,25}}do
local ac=ak.write_attribute(e,d.ClusterId(15),d.AttributeId(aw[1]),aw[2](aw[3]))ac.body.zcl_header.frame_ctrl:set_disable_default_response()e:send(ac:to_endpoint(8))end
end
}b(ca,{g("KMPCIL","RES005")})local aP={profile="sensors-schneider-cct593011-core",magic_packet=false,zcl_clusters={j(1,false),v(1,false),h{endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true},n(1)}}b(aP,{g("Schneider Electric","CCT593011_AS")})local aQ={profile="safety-motion-schneider-cct595011-core",magic_packet=false,zcl_clusters={c(i.occupancy{ias_zone=true,read_on_configure=false,emit=u.motion(),
from_device=function(a)
if type(a)=="table"then a=a.value end
return(a&2)~=0
end}),
c(i.battery_low{read_on_configure=false,
emit=function(_,dy)
return dy and B.batteryLevel.battery.critical()or B.batteryLevel.battery.normal()
end}),
h{minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true},i.illuminance{minimum_interval=10,maximum_interval=3600,reportable_change=5}}}b(aQ,{g("Schneider Electric","CCT595011_AS")})local bK={profile="safety-motion-hobeian-zg204z-core",magic_packet=false,zcl_clusters={c(i.occupancy{endpoint=1,ias_zone=true,read_on_configure=false,emit=u.motion(),
from_device=function(a)
if type(a)=="table"then a=a.value end
return(a&1)~=0
end}),
c(i.battery_low{endpoint=1,read_on_configure=false,
emit=function(_,dy)
return dy and B.batteryLevel.battery.critical()or B.batteryLevel.battery.normal()
end}),
h{endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true},q{endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true}}}b(bK,{g("HOBEIAN","ZG-204Z")})local cJ={profile="safety-presence-aqara-fp1e-core",magic_packet=false,zcl_clusters={i.cluster_attribute(64704,322,{name="aqara_fp1e_presence",endpoint=1,mfg_code=4447,data_type=d.Uint8,read_only=true,read_on_configure=true,
from_device=function(a)
if type(a)=="table"then a=a.value end
return a==1
end,
emit=u.presence()})}}b(cJ,{g("aqara","lumi.sensor_occupy.agl1")})local dk={profile="safety-motion-tcl-ms01-core",magic_packet=false,zcl_clusters={c(i.occupancy{endpoint=1,ias_zone=true,read_on_configure=false,emit=u.motion(),
from_device=function(a)
if type(a)=="table"then a=a.value end
return(a&1)~=0
end}),
c(i.battery_low{endpoint=1,read_on_configure=false,
emit=function(_,dy)
return dy and B.batteryLevel.battery.critical()or B.batteryLevel.battery.normal()
end}),
h{endpoint=1,minimum_interval=3600,maximum_interval=7200,reportable_change=2,read_on_configure=true},q{endpoint=1,minimum_interval=3600,maximum_interval=7200,reportable_change=100,read_on_configure=true}}}b(dk,{g("TCL","MS01")})local cb={profile="safety-motion-orvibo-sn10zw-core",magic_packet=false,zcl_clusters={f(nil,true),m(nil,true),l(nil,true),A(),n(),i.cluster_attribute(1,62,{name="orvibo_sn10_battery_alarm",data_type=d.Bitmap32,read_only=true,read_on_configure=false,emit=o})}}b(cb,{g("欧瑞","585fdfb8c2304119a2432e9845cf2623"),g("ORVIBO","131c854783bc45c9b2ac58088d09571c"),g("ORVIBO","b2e57a0f606546cd879a1a54790827d6")})
local function Y(a,_,k)
if k and k.raw_value==255 then return nil end
local rx=k and k.zb_rx
local ai=rx and rx.body and rx.body.zcl_body
if ai and type(ai.get_attribute_data)=="function"then
local U,p=ai:get_attribute_data(33),ai:get_attribute_data(32)U=type(U)=="table"and U.value or U
p=type(p)=="table"and p.value or p
if U==200 and type(p)=="number"and p<30 then return nil end
end
return a
end
local function ap(cZ)
return{i.tuya_magic_packet{endpoint=1},c(i.temperature{read_on_configure=false}),c(i.humidity{scale=cZ,read_on_configure=false,
from_device=function(a)if a>=0 and a<=100 then return a end end}),
c(h{read_on_configure=false,from_device=Y}),c(q{read_on_configure=false,from_device=Y})}
end
local aG={profile="sensors-tuya-ts0201-standard-core",zcl_clusters=ap(100)}b(aG,{g("_TZ2000_a476raq2","TS0201"),g("_TZ3000_i8jfiezr","TS0201"),g("_TYZB01_a476raq2","TS0201"),g("_TZ3000_nau60otv","TS0201"),g("_TZ2000_hjsgdkfl","TS0201"),g("_TZ3000_kchagk8y","TS0201"),g("_TZ2000_lxvycln5","TS0201"),g("_TZ3210_qkj7rujp","TS0201"),g("_TZ3000_cx6atb9s","TS0201"),g("_TZ3000_1o6x1bl0","TS0201"),g("_TZ2000_zrl0mqre","TS0201"),g("xn0","TY0201"),g("_TZ3210_huzkzqyk","TS0201"),g("_TZ3000_acklt5lf","TS0201"),g("_TZ3000_vira43zx","TS0201"),g("_TZ3000_unw0hpdv","TS0201"),g("_TZ3000_fejbrqvb","TS0201"),g("_TZ3000_lfa05ajd","TS0201"),g("_TZ3000_8fwzalxx","TS0201"),g("_TZ3000_vfpt3wk4","TS0201"),g("_TZ2000_zsfvulde","TS0201"),g("Wing","TS0201"),g("AoYan  ","TS0201"),g("_TZ3000_utwgoauk","TS0201"),g("_TZ3000_qzvaivin","TS0201"),g("_TZ3000_z1jcca2g","TS0201"),g("_TZ3210_k3qngb7u","TS0201")})local bD={profile="sensors-tuya-ty0201-ncw-core",zcl_clusters=ap(10)}b(bD,{g("_TZ3210_ncw88jfq","TY0201")})local bR={profile="sensors-tuyatec-rh3052-core",magic_packet=false,zcl_clusters={c(i.temperature{read_on_configure=false}),c(i.humidity{read_on_configure=false}),A(),n()}}b(bR,{g("TUYATEC-prhs1rsd","RH3052"),g("TUYATEC-jigsujrv","RH3052"),g("TUYATEC-yg5dcbfu","RH3052"),g("TUYATEC-gqhxixyk","RH3052"),g("TUYATEC-4yn5mbem","RH3052"),g("TUYATEC-ef6iwyfl","RH3052"),g("TUYATEC-HaoiuWzy","RH3052"),g("TUYATEC-vmgh3fxd","RH3052"),g("TUYATEC-ehyenwmu","RH3052"),g("TUYATEC-lqyucvyd","RH3052")})local ck={profile="safety-motion-visonic-mp841-core",magic_packet=false,zcl_clusters={f(nil,false)}}b(ck,{g("Visonic","MP-841")})local cx={profile="sensors-dawon-th110-core",magic_packet=false,zcl_clusters={j(1,true),v(1,true),h{endpoint=1,scale=1,minimum_interval=30,maximum_interval=21600,reportable_change=1,read_on_configure=true},q{endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true,
from_device=function()return nil end}
}}b(cx,{g("DAWON_DNS","ZB30C2")})local cs={profile="safety-motion-swann-core",magic_packet=false,zcl_clusters={f(1,false),m(),l()}}b(cs,{g("SWANN","SWO-MOS1PA")})local cj={profile="safety-motion-visonic-mp840-core",magic_packet=false,zcl_clusters={f(1,false),m(),l(),c(i.temperature{endpoint=1,read_on_configure=false}),i.cluster_attribute(1,32,{name="visonic_mp840_battery_voltage",endpoint=1,data_type=d.Uint8,read_only=true,read_on_configure=false,emit=L}),i.cluster_attribute(1,62,{name="visonic_mp840_battery_alarm",endpoint=1,data_type=d.Bitmap32,read_only=true,read_on_configure=false,emit=o})}}b(cj,{g("Visonic","MP-840")})
local function aa(_,a)
if type(a)=="table"then a=a.value end
if a==255 then return end
return{B.battery.battery(I(a)),B.voltageMeasurement.voltage{value=a/10,unit="V"}}
end
local bS={profile="safety-motion-universal-xhs1-core",magic_packet=false,zcl_clusters={f(1,false),m(),l(),j(),i.cluster_attribute(1,32,{name="universal_xhs1_battery",endpoint=1,data_type=d.Uint8,read_only=true,minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true,emit=aa})}}b(bS,{g("Universal Electronics Inc","URC4470BC0-X-R")})
local function dz(a)
return string.char(a&255,(a>>8)&255,(a>>16)&255,(a>>24)&255)
end
local function F(e)
i.send_raw_cluster_command(e,32,2,dz(24),1)local ac=ak.write_attribute(e,d.ClusterId(32),d.AttributeId(0),d.Uint32(13200))e:send(ac:to_endpoint(1))return true
end
local bT={profile="safety-contact-universal-xhs2-core",magic_packet=false,announce_handler=F,
configure=function(_,e)
F(e)
end,
zcl_clusters={c(i.contact{endpoint=1,read_on_configure=false,
emit=function(e,a,k)
if k.command_id==0 then return u.contact()(e,a)end
end
}),m(),l(),j(),i.cluster_attribute(1,32,{name="universal_xhs2_battery",endpoint=1,data_type=d.Uint8,read_only=true,minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true,emit=aa})}}b(bT,{g("Universal Electronics Inc","URC4460BC0-X-R")})local bP={profile="safety-motion-namron-4512770-core",magic_packet=false,zcl_clusters={f(nil,false),c(i.temperature{endpoint=3,read_on_configure=false}),c(i.humidity{endpoint=4,read_on_configure=false}),A(),n(),i.illuminance{minimum_interval=10,maximum_interval=3600,reportable_change=5}},
configure=function(V,e)
e:send(z.build_bind_request(e,1026,V.environment_info.hub_zigbee_eui,3))e:send(z.build_bind_request(e,1029,V.environment_info.hub_zigbee_eui,4))
end
}b(bP,{g("NAMRON AS","4512770"),g("NAMRON AS","4512771"),g("Namron AS","4512770"),g("Namron AS","4512771")})local cI={profile="safety-motion-tuya-ts0202-core",magic_packet=false,zcl_clusters={c(i.occupancy{endpoint=1,ias_zone=true,read_on_configure=false,emit=u.motion(),
from_device=function(a)
if type(a)=="table"then a=a.value end
return(a&1)~=0
end}),
h{endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true},q{endpoint=1,minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=true}}}b(cI,{g("_TZ3000_mmtwjmaq","TS0202"),g("_TZ3000_kmh5qpmb","TS0202"),g("_TZ3000_0b0c7d6h","TS0202"),g("_TZ3000_hgu1dlak","TS0202"),g("_TZ3000_tiwq83wk","TS0202"),g("_TZ3000_y56pgpgs","TS0202"),g("_TZ3000_k5wwrk7a","TS0202"),g("_TZ3000_c8ozah8n","TS0202"),g("_TYZB01_hqbdru35","TS0202"),g("_TYZB01_dl7cejts","TS0202")})local bQ={profile="safety-motion-tuyatec-rh3040-core",magic_packet=false,zcl_clusters={f(nil,false),A(),n()}}b(bQ,{g("TUYATEC-zn9wyqtr","RH3040"),g("TUYATEC-bd5faf9p","RH3040"),g("TUYATEC-b3ov3nor","RH3040"),g("TUYATEC-2gn2zf9e","RH3040"),g("TUYATEC-b5g40alm","RH3040"),g("TUYATEC-kpz6r4qx","RH3040"),g("TUYATEC-dxnohkpd","RH3040"),g("TUYATEC-zw6hxafz","RH3040"),g("TUYATEC-deetibst","RH3040"),g("TUYATEC-kmfarmcu","RH3040"),g("TUYATEC-53o41joc","RH3040")})
local function M(dh)
local du=A()du.scale=dh
return{f(nil,false,2),c(i.occupancy{read_on_configure=false,emit=u.motion(),
from_device=function(a)
if type(a)=="table"then a=a.value end
return(a&1)~=0
end}),
c(i.temperature{read_on_configure=false}),c(i.humidity{read_on_configure=false}),du,n()}
end
local db={profile="safety-motion-nyce-3041-core",magic_packet=false,zcl_clusters=M(1)}b(db,{g("NYCE","3041")})local dc={profile="safety-motion-nyce-3043-core",magic_packet=false,zcl_clusters=M(2)}b(dc,{g("NYCE","3043")})local dd={profile="safety-motion-nyce-3045-core",magic_packet=false,zcl_clusters=M(1)}b(dd,{g("NYCE","3045")})local aj={profile="safety-motion-bosch-radion-notification-core",parent_refresh=bk,zcl_clusters=aU()}b(aj,{g("Bosch","RFPR-ZB"),g("Bosch","RFDL-ZB-MS"),g("Bosch","RFPR-ZB-MS")})
local function E(_,cR)
return{B.battery.battery(math.max(0,math.min(100,math.floor((cR-2850)*100/150+0.5)))),B.voltageMeasurement.voltage{value=cR/1000,unit="V"}}
end
local aC={profile="safety-motion-aqara-high-precision-core",magic_packet=false,zcl_clusters={i.cluster_attribute(1030,0,{name="aqara_high_precision_motion",endpoint=1,read_only=true,read_on_configure=false,
emit=function(e,a)
if type(a)=="table"then a=a.value end
if a~=1 then return end
local aN=e:get_field"__aqara_high_precision_timer"if aN then aN:cancel()end
local dA=e:get_field"__aqara_high_precision_interval"or 60
e:set_field("__aqara_high_precision_timer",e.thread:call_with_delay(dA+2,function()
e:set_field("__aqara_high_precision_timer",nil)e:emit_event(B.motionSensor.motion.inactive())
end,"Aqara high precision motion reset"))
return B.motionSensor.motion.active()
end
}),i.cluster_attribute(64704,258,{name="aqara_high_precision_interval",endpoint=1,mfg_code=4447,read_only=true,read_on_configure=true,
handler=function(e,a)
if type(a)=="table"then a=a.value end
e:set_field("__aqara_high_precision_interval",a)
end
}),i.cluster_attribute(1,32,{name="aqara_high_precision_voltage",endpoint=1,data_type=d.Uint8,read_only=true,read_on_configure=true,
emit=function(e,a)
if type(a)=="table"then a=a.value end
if a~=255 then return E(e,a*100)end
end
}),i.cluster_attribute(64704,247,{name="aqara_high_precision_diagnostics",endpoint=1,read_only=true,read_on_configure=false,
emit=function(e,a)
if type(a)=="table"and a.value~=nil then a=a.value end
if type(a)=="string"then
local cl,aK={},1
while aK+1<=#a do
local dF,cC=a:byte(aK,aK+1)local width=cC>=32 and cC<=47 and((cC%8)+1)or cC==16 and 1
if not width or aK+1+width>#a then break end
cl[dF]=string.unpack("<"..(cC>=40 and"i"or"I")..width,a,aK+2)aK=aK+2+width
end
a=cl
end
if type(a)~="table"then return end
local p=a[1]or a["1"]if type(p)=="table"then p=p.value end
if type(p)=="number"then return E(e,p)end
end
})}}b(aC,{g("LUMI","lumi.motion.agl04")})local bd={profile="sensors-frient-aqszb110-core",magic_packet=false,zcl_clusters={j(38,true),v(38,true),i.cluster_attribute(1,32,{name="aqszb110_battery_voltage",endpoint=38,data_type=d.Uint8,read_only=true,minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true,
emit=function(_,a)
if type(a)=="table"then a=a.value end
if a==255 then return end
return{B.battery.battery(W(a)),B.voltageMeasurement.voltage{value=a/10,unit="V"},a<=25 and B.batteryLevel.battery.critical()or B.batteryLevel.battery.normal()}
end
}),c(h{endpoint=38,read_on_configure=false,
from_device=function(a,_,k)
local ai=k.zb_rx.body.zcl_body
local p=type(ai.get_attribute_data)=="function"and ai:get_attribute_data(32)if type(p)=="table"then p=p.value end
if type(p)=="number"and p<255 then return end
if type(a)=="table"then a=a.value end
if k.raw_value~=255 then return a end
end
})}}b(bd,{g("frient A/S","AQSZB-110")})
local function aT(a,dw)
if type(a)=="table"and a.value~=nil then a=a.value end
if type(a)=="string"then
local cT=dO.Reader(a)local aO
while cT:remain()>=2 do
local dF,cC=cT:read_u8(),cT:read_u8()local ok,cl=pcall(d.parse_data_type,cC,cT)if not ok then break end
if dF==dw then aO=cl.value end
end
return aO
end
if type(a)~="table"then return end
local aO=a[dw]or a[tostring(dw)]if type(aO)=="table"then aO=aO.value end
return aO
end
local function bH(e,a)
local p=aT(a,23)if type(p)=="number"then return E(e,p)end
end
local cv={profile="safety-presence-aqara-fp310-core",magic_packet=false,
parent_refresh=function(e)
i.read_attribute(e,64704,322,1,4447)for _,cY in ipairs{1026,1029,1024}do i.read_attribute(e,cY,0,1)end
end,
zcl_clusters={i.cluster_attribute(64704,322,{name="aqara_fp310_presence",endpoint=1,mfg_code=4447,data_type=d.Uint8,read_only=true,read_on_configure=true,minimum_interval=0,maximum_interval=3600,reportable_change=1,
from_device=function(a)
if type(a)=="table"then a=a.value end
return a==1
end,
emit=u.presence()}),j(1,true),v(1,true),i.illuminance{endpoint=1,minimum_interval=10,maximum_interval=3600,reportable_change=5,read_on_configure=true},i.cluster_attribute(64704,247,{name="aqara_fp310_battery",endpoint=1,mfg_code=4447,read_only=true,read_on_configure=false,emit=bH}),i.cluster_attribute(64704,252,{name="aqara_fp310_paired",endpoint=1,mfg_code=4447,data_type=d.Boolean,read_only=true,read_on_configure=false,
handler=function(e,a,k)
if type(a)=="table"then a=a.value end
if a==false and k.zb_rx.body.zcl_header.cmd.value==10 then
e:send(ak.write_manufacturer_specific_attribute(e,64704,252,4447,d.Boolean,true):to_endpoint(1))end
end
})}}b(cv,{g("Aqara","lumi.sensor_occupy.acn1")})
local function ax(a)
if type(a)=="table"then a=a.value end
if a==0 then return false end
if a==1 then return true end
end
local cW={profile="safety-presence-aqara-fp1-core",magic_packet=false,
parent_refresh=function(e)i.read_attribute(e,64704,322,1,4447)end,
zcl_clusters={i.cluster_attribute(64704,322,{name="aqara_fp1_presence",endpoint=1,mfg_code=4447,data_type=d.Uint8,read_only=true,read_on_configure=true,from_device=ax,emit=u.presence()}),i.cluster_attribute(64704,247,{name="aqara_fp1_heartbeat_presence",endpoint=1,mfg_code=4447,read_only=true,read_on_configure=false,
from_device=function(a)return ax(aT(a,101))end,
emit=u.presence()})}}b(cW,{g("aqara","lumi.motion.ac01")})i.attach_reporting_capabilities(ay,{{1,"rpt-hbj"},{2,"rpt-pha"},{3,"rpt-tjc"},{4,"rpt-tjc"},{5,"rpt-tjc"},{6,"rpt-tjc"},{7,"rpt-tjc"},{8,"rpt-tla"},{9,"rpt-rkp"},{10,"rpt-hew"},{13,"rpt-mos"},{14,"rpt-mnz"},{15,"rpt-min"},{16,"rpt-twu"},{17,"rpt-lrf"},{18,"rpt-zfm"},{19,"rpt-lrf"},{21,"rpt-zqa"},{22,"rpt-oyj"},{23,"rpt-scj"},{24,"rpt-zus"},{26,"rpt-zdq"},{27,"rpt-zif"},{28,"rpt-hew"},{29,"rpt-zun"},{30,"rpt-vaw"},{31,"rpt-slz"},{34,"rpt-mzh"},{35,"rpt-sfw"},{36,"rpt-slc"},{37,"rpt-ioq"},{38,"rpt-mgr"},{40,"rpt-zbp"},{41,"rpt-zbp"},{42,"rpt-mex"},{44,"rpt-zsl"},{45,"rpt-vjq"},{47,"rpt-sjc"},{48,"rpt-sjc"},{49,"rpt-skq"},{50,"rpt-skq"},{53,"rpt-zxi"},{54,"rpt-bbf"},{55,"rpt-bbf"},{56,"rpt-zth"},{57,"rpt-moz"},{58,"rpt-zsl"},{59,"rpt-zbp"},{61,"rpt-ejv"},{62,"rpt-ejv"},{63,"rpt-enq"},{64,"rpt-ekk"},{65,"rpt-els"},{66,"rpt-ejv"},{67,"rpt-eou"},{68,"rpt-vbu"},{69,"rpt-lrf"},{70,"rpt-tjc"},{71,"rpt-sxh"},{72,"rpt-eoa",{zr040200001="Temp",zr040200002="TempTwo",zr040500001="Humidity",zr040500002="HumidityTwo"}},{74,"rpt-esn"},{75,"rpt-tjc"},{77,"rpt-sxh"},{78,"rpt-ybf"},{79,"rpt-tjc"},{81,"rpt-rgu"},{82,"rpt-cfw"},{83,"rpt-csr"},{84,"rpt-znf"},{86,"rpt-znf"},{92,"rpt-zfz"},{95,"rpt-uis"},{96,"rpt-uti"},{97,"rpt-zim"},{98,"rpt-tue"},{103,"rpt-rkp"},{105,"rpt-ala"},{106,"rpt-lam"}})return{id="zcl.sensors.wave19_environment",registrations=ay}

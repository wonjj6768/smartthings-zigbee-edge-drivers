local j,w,an=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family"local o,s,k,I,z,bz=an.create_fingerprints,an.create_fingerprint,require"contracts.helpers.zcl",require"st.zigbee.device_management",require"st.zigbee.data_types",require"st.zigbee.cluster_base"

local ap,b=an.definition_registry()
local function c(bu)
return function(L,g)
for endpoint=1,bu do
g:send(I.build_bind_request(g,j.CLUSTER_ON_OFF,L.environment_info.hub_zigbee_eui,endpoint))end
end
end
local function i(t,ad,e)
if ad==1 then
return{profile=t,zcl_clusters={k.switch_cluster()}}end
return{profile=t,zcl_clusters=j.multi_switch(ad,e)}
end
local a=k.append_clusters
local function az(t,ad,e)
local h=i(t,ad,e).zcl_clusters
a(h,j.tuya_magic_packet(),j.tuya_power_outage_memory(),j.child_lock())return{profile=t,zcl_clusters=h,configure=c(ad)}
end
local function O(t,ad,e)
local h=i(t,ad,e).zcl_clusters
a(h,j.tuya_magic_packet(),j.switch_type(),j.countdown_timer())return{profile=t,zcl_clusters=h,configure=c(ad)}
end
local function Q()
return j.cluster_attribute(57345,53264,{name="power_on_behavior",emit=w.power_on_behavior(),
from_device=function(v)
return({[0]="off",[1]="on",[2]="previous"})[v]
end,
to_device=function(v)
return({off=0,on=1,previous=2})[v]
end,
data_type=z.Enum8,write_type=z.Enum8,read_on_configure=true})
end
local function l(bN,ac,by,bt,bA,bG,e)
e=e or{}return j.cluster_attribute(ac,by,{name=bN,endpoint=e.endpoint,component=e.component,emit=bt,
from_device=function(v)
if type(v)=="table"then v=v.value end
return bA[v]
end,
to_device=function(v)return bG[v]end,
data_type=e.data_type or z.Enum8,write_type=e.write_type or e.data_type or z.Enum8,mfg_code=e.mfg_code,read_on_configure=e.read_on_configure~=false})
end
local function bd(g,bv,bD,bK)
return g:get_latest_state("main",bv,bD)or bK
end
local bx,bn,E={[1]={enabled_capability="concertmirror08464.nfzb03InchingControlOne",enabled_attribute="inchingControlOne",time_capability="concertmirror08464.nfzb03InchingTimeOne",time_attribute="inchingTimeOne"},[2]={enabled_capability="concertmirror08464.nfzb03InchingControlTwo",enabled_attribute="inchingControlTwo",time_capability="concertmirror08464.nfzb03InchingTimeTwo",time_attribute="inchingTimeTwo"},[3]={enabled_capability="concertmirror08464.nfzb03InchingControlThree",enabled_attribute="inchingControlThree",time_capability="concertmirror08464.nfzb03InchingTimeThree",time_attribute="inchingTimeThree"}},{[1]={countdown=w.nfzb03CountdownOne(),control=w.nfzb03InchingControlOne(),time=w.nfzb03InchingTimeOne()},[2]={countdown=w.nfzb03CountdownTwo(),control=w.nfzb03InchingControlTwo(),time=w.nfzb03InchingTimeTwo()},[3]={countdown=w.nfzb03CountdownThree(),control=w.nfzb03InchingControlThree(),time=w.nfzb03InchingTimeThree()}},"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local function aW(H)
local R={}for af=1,#H,3 do
local bo,aC,aR=H[af],H[af+1],H[af+2]local bj,be,bl,bc=math.floor(bo/4),((bo%4)*16)+math.floor((aC or 0)/16),(((aC or 0)%16)*4)+math.floor((aR or 0)/64),(aR or 0)%64
R[#R+1]=E:sub(bj+1,bj+1)R[#R+1]=E:sub(be+1,be+1)R[#R+1]=aC and E:sub(bl+1,bl+1)or"="R[#R+1]=aR and E:sub(bc+1,bc+1)or"="end
return table.concat(R)
end
local function aP(aG,aD,aI)
return aW{aG,aD,aI}
end
local function ab(bE)
local af=E:find(bE,1,true)return af and(af-1)or nil
end
local function aV(bf)
if type(bf)~="string"or #bf~=4 then return nil end
local bo,aC,aS,aH=ab(bf:sub(1,1)),ab(bf:sub(2,2)),bf:sub(3,3),bf:sub(4,4)local aR,bF=aS=="="and 0 or ab(aS),aH=="="and 0 or ab(aH)if bo==nil or aC==nil or aR==nil or bF==nil then return nil end
local H={(bo*4)+math.floor(aC/16)}if aS~="="then
H[#H+1]=((aC%16)*16)+math.floor(aR/4)end
if aH~="="then
H[#H+1]=((aR%4)*64)+bF
end
return H
end
local function aK(v)
if type(v)~="string"or(#v%4)~=0 then
return nil
end
local aL={}for af=1,#v,4 do
local H=aV(v:sub(af,af+3))if H==nil or #H~=3 then return nil end
local aG,x=H[1],1
local aA=aG
while aA>=2 do
x=x+1
aA=math.floor(aA/2)end
aL[x]={enabled=aG%2==1 and"enabled"or"disabled",time=(H[2]*256)+H[3]}end
return aL
end
local function aB(v,bP,bH,f)
local aL=aK(v)local x=aL and aL[f.inching_channel]or nil
if x==nil then return nil end
if f.inching_kind=="enabled"and f.inching_enabled_values~=nil then
return x.enabled=="enabled"and f.inching_enabled_values.enabled or
f.inching_enabled_values.disabled
end
return x[f.inching_kind]
end
local function aY(g,f,v)
local x=f.inching_channel
local aO,bs=f.inching_contract or bx[x],f.inching_enabled_values and f.inching_enabled_values.disabled or"disabled"local bB,ay=bd(g,aO.enabled_capability,aO.enabled_attribute,bs),tonumber(bd(g,aO.time_capability,aO.time_attribute,1))or 1
if f.inching_kind=="enabled"then bB=v end
if f.inching_kind=="time"then ay=tonumber(v)or ay end
ay=math.max(1,math.min(65535,math.floor(ay+0.5)))local bw=f.inching_enabled_values and f.inching_enabled_values.enabled or"enabled"local aG=bB==bw and 1 or 0
if x>1 then aG=aG+(2 ^(x-1))end
local aD,aI=math.floor(ay/256),ay%256
return j.send_raw_cluster_command(g,57344,251,aP(aG,aD,aI),1)
end
local function ae(x,bL,bt,e)
e=e or{}local bM={enabled=(e.name_prefix or"nfzb03").."_inching_enabled_"..({"one","two","three"})[x],time=(e.name_prefix or"nfzb03").."_inching_time_"..({"one","two","three"})[x]}local f=j.cluster_attribute(57344,53251,{name=bM[bL],emit=bt,from_device=aB,data_type=z.CharString,read_on_configure=false,sender=aY})f.inching_channel=x
f.inching_kind=bL
f.inching_contract=e.contracts and e.contracts[x]or nil
f.inching_enabled_values=e.enabled_values
return f
end
local U=w.lellkiWp33PowerOnBehavior()
local function ai()
local f=Q()f.name="lellki_wp33_power_on_behavior"f.emit=U
return f
end
local function d(t,e)
e=e or{}local h=i("switches-switch-1",1).zcl_clusters
a(h,j.tuya_magic_packet())if e.power_outage_memory then a(h,j.tuya_power_outage_memory())end
if e.power_on_behavior_2 then a(h,Q())end
if e.switch_type then a(h,j.switch_type())end
if e.gen_on_off_switch_type then a(h,j.gen_on_off_switch_type())end
if e.countdown then a(h,j.countdown_timer())end
if e.indicator_mode then a(h,j.indicator_mode())end
return{profile=t,zcl_clusters=h,configure=c(1)}
end
local function P(t,aX)
local h=k.metering_clusters{include_switch=true,include_current=true,energy_scale=100}a(h,j.power_outage_memory(),j.tuya_magic_packet())if aX~=false then a(h,j.switch_type())end
return{profile=t,zcl_clusters=h,
configure=function(L,g)
for _,ac in ipairs{j.CLUSTER_ON_OFF,2820,1794}do
g:send(I.build_bind_request(g,ac,L.environment_info.hub_zigbee_eui,1))end
end
}
end
local function ao(t,ad)
local h=i(t,ad).zcl_clusters
a(h,j.tuya_magic_packet(),j.power_outage_memory(),j.gen_on_off_switch_type())return{profile=t,zcl_clusters=h,configure=c(ad)}
end
local function aF(t)
local h={k.switch_cluster(1),k.switch_cluster(2,"switch2")}a(h,j.power{endpoint=1,component="main",minimum_interval=5,maximum_interval=3600,reportable_change=10,poll_interval=300},j.voltage{endpoint=1,component="main",minimum_interval=5,maximum_interval=3600,reportable_change=5,poll_interval=300},j.current{endpoint=1,component="main",scale=1000,ignore_reported_scaler=true,minimum_interval=5,maximum_interval=3600,reportable_change=50,poll_interval=300},j.energy{endpoint=1,component="main",scale=100,ignore_reported_scaler=true,minimum_interval=5,maximum_interval=3600,reportable_change=257,poll_interval=900},j.tuya_magic_packet(),j.tuya_power_outage_memory{endpoint=1,name="nous_b3z_power_behavior",emit=w.nousB3zPowerBehavior()},j.switch_type{endpoint=1,name="nous_b3z_switch_type",emit=w.nousB3zSwitchType(),
sender=function(g,f,v)
local bC=bz.write_attribute(g,z.ClusterId(57345),z.AttributeId(53296),z.Enum8(f.converter.to(v)))bC.body.zcl_header.frame_ctrl:set_disable_default_response()g:send(bC:to_endpoint(1));return true
end},
j.countdown_timer{endpoint=1,component="main",name="nous_b3z_countdown1",emit=w.nousB3zCountdown1()},j.countdown_timer{endpoint=2,component="switch2",name="nous_b3z_countdown2",emit=w.nousB3zCountdown2()})return{profile=t,zcl_clusters=h,component_to_endpoint_map={main=1,switch2=2},
configure=function(L,g)
for _,bI in ipairs{6,2820,1794}do
j.bind_cluster(g,bI,L.environment_info.hub_zigbee_eui,1)end
j.bind_cluster(g,6,L.environment_info.hub_zigbee_eui,2)
end
}
end
local av={profile="plugs-switch-2-power-energy-voltage",zcl_clusters={k.switch_cluster(1),k.switch_cluster(2,"switch2")}}a(av.zcl_clusters,k.metering_clusters{endpoint=1,include_switch=false,include_current=false})
local function X(L,g)
for _,ac in ipairs{j.CLUSTER_ON_OFF,2820,1794}do
g:send(I.build_bind_request(g,ac,L.environment_info.hub_zigbee_eui,1))end
g:send(I.build_bind_request(g,j.CLUSTER_ON_OFF,L.environment_info.hub_zigbee_eui,2))
end
local function m(t,e)
e=e or{}local h={k.switch_cluster(1),k.switch_cluster(2,"switch2")}a(h,k.metering_clusters{endpoint=1,include_switch=false,include_current=true,energy_scale=100,energy_ignore_reported_scaler=e.energy_ignore_reported_scaler,use_reported_unity_scaler=e.use_reported_unity_scaler},j.tuya_magic_packet())if e.outage_memory then a(h,j.tuya_power_outage_memory())end
if e.indicator_mode then a(h,j.indicator_mode())end
if e.child_lock then a(h,j.child_lock())end
if e.countdown then a(h,j.countdown_timer())end
return{profile=t,zcl_clusters=h,configure=X}
end
local bi,aE,bh,bp,V,M,ag,J=m("plugs-dual-metered",{use_reported_unity_scaler=true}),m("plugs-dual-metered-outage",{outage_memory=true}),m("plugs-mercator-spp02gip",{outage_memory=true,energy_ignore_reported_scaler=true}),{profile="plugs-mercator-spp04g",component_to_endpoint_map={main=1,switch2=2},zcl_clusters={j.switch{endpoint=1,component="main",maximum_interval=3600},j.switch{endpoint=2,component="switch2",maximum_interval=3600},j.power{endpoint=1,minimum_interval=5,maximum_interval=3600,reportable_change=1,poll_interval=300},j.voltage{endpoint=1,minimum_interval=5,maximum_interval=3600,reportable_change=5,poll_interval=300},j.current{endpoint=1,scale=1000,ignore_reported_scaler=true,minimum_interval=5,maximum_interval=3600,reportable_change=50,poll_interval=300},j.energy{endpoint=1,scale=100,ignore_reported_scaler=true,poll_interval=900},j.tuya_magic_packet(),j.tuya_power_outage_memory{endpoint=1,name="spp04_power_behavior",emit=w.spp04PowerBehavior()}},configure=X},m("plugs-dual-metered-outage-indicator",{outage_memory=true,indicator_mode=true,use_reported_unity_scaler=true}),m("plugs-dual-metered-outage-indicator-lock",{outage_memory=true,indicator_mode=true,child_lock=true}),m("plugs-dual-metered-full-options",{outage_memory=true,indicator_mode=true,child_lock=true,countdown=true}),i("plugs-dual-outage",2)a(J.zcl_clusters,j.tuya_magic_packet(),j.tuya_power_outage_memory())J.configure=c(2)local C=i("switches-switch-1",1)
local function B(g,bq)
return g:get_manufacturer()=="LUMI"and g:get_model()==bq
end
C.component_to_endpoint=function(g)
if B(g,"lumi.ctrl_neutral1")then return 2 end
end
C.zcl_clusters[1].endpoint=function(g)
if B(g,"lumi.ctrl_neutral1")then return 2 end
end
local Z=C.zcl_clusters[1].from_device
or(C.zcl_clusters[1].converter or{}).from
C.zcl_clusters[1].from_device=function(v,g,ax,f)
local bq=g:get_model()if g:get_manufacturer()=="LUMI"and
(bq=="lumi.ctrl_ln1"or bq=="lumi.ctrl_ln1.aq1"or bq=="lumi.ctrl_neutral1")and
(ax.endpoint==4 or ax.endpoint==5 or ax.endpoint==6)then
return nil
end
if Z then return Z(v,g,ax,f)end
return v
end
local q=i("switches-switch-1",1)a(q.zcl_clusters,j.tuya_magic_packet())q.configure=c(1)local am,at,r=P"switches-switch-1-power-options",P("switches-switch-1-power-outage",false),i("switches-switch-2",2)
r.component_to_endpoint=function(g,ba)
if B(g,"lumi.ctrl_neutral2")then return ba=="main"and 2 or 3 end
end
r.endpoint_to_component=function(g,endpoint)
if B(g,"lumi.ctrl_neutral2")then
if endpoint==2 then return"main"end
if endpoint==3 then return"switch2"end
end
end
for _,f in ipairs(r.zcl_clusters)do
local endpoint,ba=f.endpoint,f.component
f.reporting_defaults={key=string.format("zr%04x%04x%d",f.cluster_id,f.attribute_id,endpoint),minimum_interval=f.minimum_interval,maximum_interval=f.maximum_interval,reportable_change=f.reportable_change}
f.endpoint=function(g)
return B(g,"lumi.ctrl_neutral2")and endpoint+1 or endpoint
end
f.component=function(g,bJ,ax)
if B(g,"lumi.ctrl_neutral2")then return endpoint==1 and"main"or"switch2"end
return ba(g,bJ,ax)
end
end
local aN=c(2)
r.configure=function(L,g)
if not B(g,"lumi.ctrl_neutral2")then return aN(L,g)end
for endpoint=2,3 do j.bind_cluster(g,j.CLUSTER_ON_OFF,L.environment_info.hub_zigbee_eui,endpoint)end
end
local p=i("switches-switch-2",2,{index_offset=1})p.time_start="off"a(p.zcl_clusters,j.tuya_magic_packet())p.configure=c(2)local aU=i("switches-ts0002-rux",2,{index_offset=1})a(aU.zcl_clusters,j.tuya_magic_packet(),l("ts0002_rux_power_outage_memory",j.CLUSTER_ON_OFF,32770,w.ts0002RuxPowerOutageMemory(),{[0]="off",[1]="on",[2]="restore"},{off=0,on=1,restore=2}),l("ts0002_rux_switch_type",57345,53296,w.ts0002RuxSwitchType(),{[0]="toggle",[1]="state",[2]="momentary"},{toggle=0,state=1,momentary=2}))aU.configure=c(2)local bg,al=aF"switches-nous-b3z",i("switches-switch-3",3,{index_offset=1})al.configure=c(3)local A=i("switches-switch-3",3,{index_offset=1})a(A.zcl_clusters,j.tuya_magic_packet())A.configure=c(3)local bk=i("switches-switch-4",4,{index_offset=1})bk.configure=c(4)local u=i("switches-switch-4",4,{index_offset=1})a(u.zcl_clusters,j.tuya_magic_packet())u.configure=c(4)local N={profile="switches-switch-4",zcl_clusters=j.multi_switch(4,{configure_reporting=false,index_offset=1}),configure=c(4)}a(N.zcl_clusters,j.tuya_magic_packet())local K={profile="switches-switch-4",zcl_clusters=j.multi_switch(4,{configure_reporting=false,index_offset=1})}a(K.zcl_clusters,j.tuya_magic_packet())local aw,aq=az("switches-switch-5-tuya-options",5,{index_offset=1}),i("switches-lellki-wp33-5",5,{index_offset=1})a(aq.zcl_clusters,j.tuya_magic_packet(),ai())local aQ=i("switches-switch-6-basic",6,{index_offset=1})a(aQ.zcl_clusters,j.tuya_magic_packet())aQ.configure=c(6)local F,bb,aT,ar,as,y=O("switches-switch-1-countdown-switch-type",1),O("switches-switch-2-countdown-switch-type",2),O("switches-switch-3-countdown-switch-type",3,{index_offset=1}),ao("switches-switch-1-poweron-switch-type",1),ao("switches-switch-2-poweron-switch-type",2),i("switches-switch-1",1)y.configure=c(1)local aM,T,ah,W,au,G,aa,ak,aZ,aj,D,aJ=d("switches-switch-1-countdown",{countdown=true}),d("switches-switch-1-switch-type",{switch_type=true}),d("switches-switch-1-outage-switch-type",{power_outage_memory=true,switch_type=true}),d("switches-switch-1-outage-switch-type",{power_outage_memory=true,gen_on_off_switch_type=true}),d("switches-switch-1-module-options",{power_outage_memory=true,switch_type=true,countdown=true,indicator_mode=true}),d("switches-switch-1-countdown-switch-type-indicator",{switch_type=true,countdown=true,indicator_mode=true}),d("switches-switch-1-countdown-indicator",{countdown=true,indicator_mode=true}),d("switches-switch-1-poweron-indicator",{power_on_behavior_2=true,indicator_mode=true}),d("switches-switch-1-poweron",{power_on_behavior_2=true}),d("switches-switch-1-poweron-countdown",{power_on_behavior_2=true,countdown=true}),d("switches-switch-1-poweron-countdown-switch-type-indicator",{power_on_behavior_2=true,switch_type=true,countdown=true,indicator_mode=true}),i("switches-switch-1-ts0001-bbeb",1)a(aJ.zcl_clusters,j.tuya_magic_packet(),l("ts0001_bbeb_power_on_behavior",57345,53264,w.ts0001BbebPowerOnBehavior(),{[0]="off",[1]="on",[2]="previous"},{off=0,on=1,previous=2}),l("ts0001_bbeb_backlight_mode",j.CLUSTER_ON_OFF,20480,w.ts0001BbebBacklightMode(),{[0]="off",[1]="on",[false]="off",[true]="on"},{off=false,on=true},{data_type=z.Boolean}),l("ts0001_bbeb_indicator_mode",j.CLUSTER_ON_OFF,32769,w.ts0001BbebIndicatorPattern(),{[0]="off",[1]="off/on",[2]="on/off",[3]="on"},{off=0,["off/on"]=1,["on/off"]=2,on=3}))aJ.configure=c(1)local S,Y=i("switches-switch-3-ts0003-module2",3,{index_offset=1}),{w.ts0003Module2CountdownOne(),w.ts0003Module2CountdownTwo(),w.ts0003Module2CountdownThree()}a(S.zcl_clusters,j.tuya_magic_packet(),l("ts0003_module2_switch_type",57345,53296,w.ts0003Module2SwitchType(),{[0]="toggle",[1]="state",[2]="momentary"},{toggle=0,state=1,momentary=2},{mfg_code=4417}),l("ts0003_module2_indicator_mode",j.CLUSTER_ON_OFF,32769,w.ts0003Module2IndicatorMode(),{[0]="off",[1]="off_on",[2]="on_off",[3]="on"},{off=0,off_on=1,on_off=2,on=3}))for endpoint=1,3 do
local word=({"One","Two","Three"})[endpoint]a(S.zcl_clusters,j.countdown_timer{name="ts0003_module2_countdown_"..word:lower(),endpoint=endpoint,component=endpoint==1 and"main"or("switch"..endpoint),emit=Y[endpoint]})end
S.configure=c(3)local br=i("switches-switch-3-nfzb03",3,{index_offset=1})a(br.zcl_clusters,j.tuya_magic_packet(),l("nfzb03_power_outage_memory",j.CLUSTER_ON_OFF,32770,w.nfzb03PowerOutageMemory(),{[0]="off",[1]="on",[2]="restore"},{off=0,on=1,restore=2}),l("nfzb03_switch_type",57345,53296,w.nfzb03SwitchType(),{[0]="toggle",[1]="state",[2]="momentary"},{toggle=0,state=1,momentary=2},{mfg_code=4417}),l("nfzb03_indicator_mode",j.CLUSTER_ON_OFF,32769,w.nfzb03IndicatorMode(),{[0]="off",[1]="off_on",[2]="on_off",[3]="on"},{off=0,off_on=1,on_off=2,on=3}),l("nfzb03_backlight_mode",j.CLUSTER_ON_OFF,20480,w.nfzb03BacklightMode(),{[0]="off",[1]="on",[false]="off",[true]="on"},{off=false,on=true},{data_type=z.Boolean}))for endpoint=1,3 do
local word,bm=({"One","Two","Three"})[endpoint],bn[endpoint]a(br.zcl_clusters,j.countdown_timer{name="nfzb03_countdown_"..word:lower(),endpoint=endpoint,component=endpoint==1 and"main"or("switch"..endpoint),emit=bm.countdown},ae(endpoint,"enabled",bm.control,{enabled_values={enabled="ENABLE",disabled="DISABLE"}}),ae(endpoint,"time",bm.time,{enabled_values={enabled="ENABLE",disabled="DISABLE"}}))end
br.configure=c(3)b(aJ,o("TS0001",{"_TZ3000_bbebkwjk"}))b(S,o("TS0003",{"_TZ3000_bu47m8pv"}))b(br,o("TS0003",{"_TZ3000_fawk5xjv","_TZ3000_bvij6kod","_TZ3000_aracgljk","_TZ3210_fawk5xjv"}))b(am,o("TS0001",{"_TZ3000_xkap8wtb","_TZ3000_qnejhcsu","_TZ3000_x3ewpzyr","_TZ3000_mkhkxx1p","_TZ3000_tgddllx4","_TZ3000_kqvb5akv","_TZ3000_q8r0bbvy","_TZ3000_g92baclx","_TZ3000_qlai3277","_TZ3000_qaabwu5c","_TZ3000_qorepo2x","_TZ3000_ikuxinvo","_TZ3000_hzlsaltw","_TZ3000_jsfzkftc","_TZ3000_0ghwhypc","_TZ3000_1adss9de","_TZ3000_x8mbwtsz","_TZ3000_iktiy8ue","_TZ3000_zojh9vz7","_TZ3000_gsat0axs","_TZ3000_olo5jhjk"}))b(bg,o("TS0002",{"_TZ3000_aaifmpuq","_TZ3000_irrmjcgi","_TZ3000_huvxrx4i","_TZ3000_pxfjrzyj","_TZ3000_hopb2kjm"}))b(am,o("TS000F",{"_TZ3000_xkap8wtb"}))b(q,o("SM0001",{"_TZ3000_jcqs2mrv"}))b(y,o("TS0001",{"_TZ3000_bezfthwc"}))b(F,o("TS0001",{"_TZ3000_hktqahrq","_TZ3000_q6a3tepg","_TZ3000_skueekg3","_TZ3000_npzfdcof","_TZ3000_5ng23zjs","_TZ3000_rmjr4ufz","_TZ3000_v7gnj3ad","_TZ3000_3a9beq8a","_TZ3000_ark8nv4y","_TZ3000_mx3vgyea","_TZ3000_fdxihpp7","_TZ3000_qsp2pwtf","_TZ3000_kycczpw8","_TZ3000_46t1rvdu","_TZ3000_bhcpnvud","_TZ3000_i9oy2rdq"}))b(q,o("TS0001",{"_TZ3000_8n7lqbm0","_TZ3000_cb3aangp","_TZ3000_ctftgjwb","_TZ3000_g8n1n7lg","_TZ3000_udl7uyd2"}))b(aZ,o("TS0001",{"_TZ3000_bmqxalil","_TZ3000_w1tcofu8","_TZ3000_ma3mhpx2","_TZ3000_wijoqjk1"}))b(D,o("TS0001",{"_TZ3000_5rpu3r0d"}))b(au,o("TS0001",{"_TZ3000_tqlv4ug4","_TZ3210_tqlv4ug4","_TZ3000_gjrubzje","_TZ3000_tygpxwqa","_TZ3000_4rbqgcuv","_TZ3000_veu2v775","_TZ3000_prits6g4","_TZ3210_9hbau615","_TZ3000_afgzktgb","_TZ3000_qamj2vnn","_TZ3000_n6fqajob"}))b(ah,o("TS0001",{"_TZ3000_xfxpoxe0"}))b(aa,o("TS0001",{"_TZ3000_myaaknbq","_TZ3000_cpozgbrx","_TZ3000_drc9tuqb"}))b(ak,o("TS0001",{"_TZ3000_gbshwgag","_TZ3000_blhvsaqf","_TZ3000_65ajyxua","_TZ3000_qq9ahj6z"}))b(G,o("TS0001",{"_TZ3000_pgq7ormg"}))b(aj,o("TS0001",{"_TZ3000_qvmiyxuk"}))b(aM,o("TS0001",{"_TZ3210_fhx7lk3d"}))b(y,o("TS0001",{"_TYZB01_4vgantdz","_TYZB01_reyozfcg","_TZ3000_wrhhi5h2"}))b(T,o("TS0001",{"_TZ3000_6axxqqi2","_TZ3000_gtdswg8k","_TZ3000_majwnphg","_TZ3000_qh6qjuan","_TZ3000_zw7yf6yk"}))b(q,o("TS0001",{"_TZ3000_dov0a3p1","_TZ3000_t3s9qmmg","_TZ3000_ehgouyvu"}))b(q,o("TS0011",{"_TZ3000_uaa34g7v","_TZ3000_l8fsgo6p","_TZ3000_abjodzas","_TZ3000_hhiodade"}))b(F,o("TS0011",{"_TZ3000_hbxsdd6k"}))b(F,o("TS0011",{"_TZ3000_qmi1cfuq","_TZ3000_txpirhfq","_TZ3000_ji4araar","_TZ3000_tw4ztbp4"}))b(y,o("TS011F",{"_TZ3000_twqctvna"}))b(q,{s("_TYZB01_iuepbmpv","TS0121"),s("_TZ3000_bkfe0bab","TS011F"),s("_TZ3000_zmy1waw6","TS011F")})b(at,o("TS011F",{"_TZ3000_z6fgd73r"}))b(F,o("TS000F",{"_TZ3000_hktqahrq","_TZ3000_m9af2l6g","_TZ3000_mx3vgyea","_TZ3000_skueekg3","_TZ3000_dlhhrhs8","_TZ3000_fdxihpp7"}))b(q,o("TS000F",{"_TZ3210_a2erlvb8"}))b(C,{{manufacturer="_TZ3210_hjxqqofs"..string.char(0),model="TS000F"}})b(T,o("TS000F",{"_TZ3000_hdc8bbha"}))b(W,o("TS000F",{"_TZ3218_hdc8bbha"}))b(ar,o("TS000F",{"_TZ3218_n0jsuogs"}))b(bi,o("TS011F",{"_TZ3000_bep7ccew"}))b(bh,o("TS011F",{"_TZ3210_7jnk7l3k"}))b(aE,o("TS011F",{"_TZ3210_raqjcxo5","_TZ3210_pfbzs1an"}))b(bp,{s("_TZ3210_yvxjawlt","TS011F")})b(V,o("TS011F",{"_TZ3000_dd8wwzcy"}))b(M,o("TS011F",{"_TZ3000_jak16dll","_TZ3000_rqbjepe8","_TZ3000_uwkja6z1"}))b(ag,o("TS011F",{"_TZ3210_bep7ccew","_TZ3210_qlmnxmac"}))b(J,o("TS011F",{"_TZ3000_gazjngjl"}))b(av,{s("LUMI","lumi.plug.acn005"),s("LUMI","lumi.plug.sacn03")})b(C,{s("Aqara","lumi.switch.acn048"),s("LUMI","lumi.ctrl_ln1"),s("LUMI","lumi.ctrl_ln1.aq1"),s("LUMI","lumi.ctrl_neutral1"),s("LUMI","lumi.switch.acn029"),s("LUMI","lumi.switch.acn048"),s("LUMI","lumi.switch.acn056"),s("LUMI","lumi.switch.acn061"),s("LUMI","lumi.switch.b1laus01"),s("LUMI","lumi.switch.b1lacn01"),s("LUMI","lumi.switch.b1nacn01"),s("LUMI","lumi.switch.b1nacn02"),s("LUMI","lumi.switch.b1naus01"),s("LUMI","lumi.switch.b1lc04"),s("LUMI","lumi.switch.b1nc01"),s("LUMI","lumi.switch.l0acn1"),s("LUMI","lumi.switch.l0agl1"),s("LUMI","lumi.switch.l1acn1"),s("LUMI","lumi.switch.l1aeu1"),s("LUMI","lumi.switch.n0acn2"),s("LUMI","lumi.switch.n0agl1"),s("LUMI","lumi.switch.n1acn1"),s("LUMI","lumi.switch.n1aeu1")})b(r,{s("Aqara","lumi.switch.acn047"),s("Aqara","lumi.switch.acn049"),s("Aqara","lumi.switch.acn057"),s("LUMI","lumi.ctrl_ln2"),s("LUMI","lumi.ctrl_ln2.aq1"),s("LUMI","lumi.ctrl_neutral2"),s("LUMI","lumi.relay.c2acn01"),s("LUMI","lumi.switch.acn030"),s("LUMI","lumi.switch.acn047"),s("LUMI","lumi.switch.acn049"),s("LUMI","lumi.switch.acn057"),s("LUMI","lumi.switch.b2laus01"),s("LUMI","lumi.switch.b2lacn01"),s("LUMI","lumi.switch.b2nacn01"),s("LUMI","lumi.switch.b2nacn02"),s("LUMI","lumi.switch.b2naus01"),s("LUMI","lumi.switch.b2lc04"),s("LUMI","lumi.switch.b2nc01"),s("LUMI","lumi.switch.l2acn1"),s("LUMI","lumi.switch.l2aeu1"),s("LUMI","lumi.switch.n2acn1"),s("LUMI","lumi.switch.n2aeu1")})b(al,{s("Aqara","lumi.switch.acn055"),s("Aqara","lumi.switch.acn059"),s("LUMI","lumi.switch.acn031"),s("LUMI","lumi.switch.acn040"),s("LUMI","lumi.switch.acn054"),s("LUMI","lumi.switch.acn055"),s("LUMI","lumi.switch.acn058"),s("LUMI","lumi.switch.acn059"),s("LUMI","lumi.switch.b3l01"),s("LUMI","lumi.switch.b3n01"),s("LUMI","lumi.switch.l3acn1"),s("LUMI","lumi.switch.l3acn3"),s("LUMI","lumi.switch.n3acn1"),s("LUMI","lumi.switch.n3acn3"),s("LUMI","lumi.switch.n4acn4")})b(p,o("TS011F",{"_TZ3000_46vasa5h","_TZ3000_mvn6jl7x","_TZ3000_raviyuvk","_TYZB01_hlla45kx","_TZ3000_92qd4sqa","_TZ3000_zwaadvus","_TZ3000_k6fvknrr","_TZ3000_6s5dc9lx","_TZ3000_helyqdvs","_TZ3000_rgpqqmbj","_TZ3000_8nyaanzb","_TZ3000_iy2c3n6p","_TZ3000_qlmnxmac","_TZ3000_sgb0xhwn","_TZ3210_ph1joc22","_TZ3210_sgb0xhwn","_TZ3000_iv6ph5tr","_TZ3000_pmz6mjyu","_TZ3000_rul9yxcc","_TZ3000_mlswgkc3","_TZ3000_v4mevirn","_TZ3000_zigisuyh","_TZ3000_xeumnff9","_TZ3000_2xlvlnez","_TZ3000_cymsnfvf","_TZ3210_2uk4z8ce"}))b(p,{s("HOBEIAN","ZG-305Z")})b(p,o("TS000F",{"_TZ3000_m8f3z8ju"}))b(as,o("TS000F",{"_TZ3218_sgbsg6mr"}))b(aU,o("TS0002",{"_TZ3000_ruxexjfz"}))b(p,o("TS0002",{"_TZ3000_01gpyda5","_TZ3000_bvrlqyj7","_TZ3000_7ed9cqgi","_TZ3000_zmy4lslw","_TZ3000_4xfqlgqo","_TZ3000_hojntt34","_TZ3000_eei0ubpy","_TZ3000_qaa59zqd","_TZ3000_lmlsduws","_TZ3000_fbjdkph9","_TZ3000_zbfya6h0","_TZ3000_hznzbl0x","_TZ3000_fisb3ajo","_TZ3000_5gey1ohx","_TZ3000_mtnpt6ws","_TZ3000_mufwv0ry","_TZ3000_54hjn4vs","_TZ3000_aa5t61rh","_TZ3000_in5qxhtt","_TZ3000_ogpla3lh","_TZ3000_i9w5mehz","_TZ3000_dershnvx","_TZ3000_ywubfuvt","_TZ3000_wnzoyohq","_TZ3000_5ksufhqi","_TZ3210_nuenzetq","_TZ3000_zxrfobzw","_TZ3000_criiahcg","_TZ3000_lugaswf8","_TZ3000_nuenzetq","_TZ3000_ruldv5dt","_TZ3000_gkesadus","_TZ3000_rfjctviq","_TZ3000_yxmafzmd","_TZ3210_a2erlvb8","_TZ3210_pdnwpnz5"}))b(p,{s("HOBEIAN","ZG-301Z-2CH")})b(p,o("TS0012",{"_TZ3000_biakwrag","_TZ3000_18ejxno0"}))b(r,o("TS0003",{"_TYZB01_digziiav","_TYZB01_zsl6z0pw","_TYZB01_uqkphoed"}))b(r,o("TS0002",{"_TYZB01_digziiav","_TYZB01_zsl6z0pw","_TYZB01_uqkphoed","_TZ3000_iwtv2jwo","_TZ3000_h1ipgkwn","_TZ3000_tas0zemd"}))b(p,o("TS0002",{"_TZ3210_6smingw0"}))b(r,{s("Somfy","ON/OFF (2CH)"),s("Sunricher","ON/OFF (2CH)")})b(bb,o("TS0012",{"_TZ3000_jl7qyupf","_TZ3000_nPGIPl5D","_TZ3000_kpatq5pq","_TZ3000_ljhbw1c9","_TZ3000_4zf0crgo"}))b(A,o("TS0003",{"_TZ3000_vjhcenzo","_TZ3000_f09j9qjb","_TZ3000_rhkfbfcv","_TZ3000_empogkya","_TZ3000_lubfc1t5","_TZ3000_lsunm46z","_TZ3000_v4l4b0lp","_TZ3000_uilitwsy","_TZ3000_66fekqhh","_TZ3000_ok0ggpk7","_TZ3210_ok0ggpk7","_TZ3000_aknpkt02","_TZ3210_aksyshpw","_TZ3000_nwidmc4n","_TZ3000_pfc7i3kt","_TZ3000_dyzkbcip","_TZ3000_ouwfc1qj","_TZ3000_eqsair32","_TZ3000_4o16jdca","_TZ3000_odzoiovu","_TZ3000_hbic3ka3","_TZ3000_lvhy15ix","_TZ3000_mhhxxjrs","_TZ3000_iv4eq7eh","_TZ3000_mzcp0of6","_TZ3000_pf7swkqp","_TZ3000_ju82pu2b","_TZ3000_vsasbzkf","_TZ3000_nnwehhst","_TZ3000_mw1pqqqt","_TZ3000_pv4puuxi","_TZ3000_avky2mvc","_TZ3000_785olaiq","_TZ3000_qxcnwv26","_TZ3000_g9chy2ib","_TZ3000_0q5fjqgw","_TZ3000_pmsxmttq","_TZ3000_zeuulson","_TZ33000_d9yfgzur"}))b(aT,o("TS0013",{"_TZ3000_ypgri8yz","_TZ3000_sznawwyw","_TZ3000_avotanj3","_TZ3000_t7ugva7q"}))b(A,{s("HOBEIAN","ZG-301Z-3CH")})b(y,o("TS0003",{"_TYZB01_aneiicmq","_TYZB01_ncutbjdi","_TYZB01_u9kkqh5o"}))b(N,o("TS0004",{"_TZ3000_ltt60asa","_TZ3000_mmkbptmx","_TZ3000_liygxtcq","_TZ3000_mdj7kra9","_TZ3000_u3oupgdy","_TZ3000_imaccztn","_TZ3000_iymfxdis","_TZ3000_nivavasg","_TZ3000_gexniqbq","_TZ3000_r9e2w7dn","_TZ3000_5ajpkyq6","_TZ3000_knoj8lpk","_TZ3000_3n2minvf","_TZ3000_tyg4yiat","_TZ3210_imaccztn","_TZ3210_wts1g2oh"}))b(u,{s("_TZ3210_iymfxdis","TS0004")})b(K,o("TS0004",{"_TZ3000_a37eix1s","_TZ3000_nsa76jai","_TZ3000_wwtnshol"}))b(aQ,o("TS0006",{"_TZ3000_cvis4qmw"}))b(u,o("TS011F",{"_TZ3000_3zofvcaa","_TZ3000_pvlvoxvt","_TZ3000_lqb7lcq9","_TZ3210_lqb7lcq9","_TZ3210_urjf5u18","_TZ3210_8n4dn1ne"}))b(bk,{s("_TZ3000_qiutut5y","TS011F")})b(A,o("TS011F",{"_TZ3000_wzauvbcs","_TZ3000_oznonj5q","_TZ3000_1obwwnmq","_TZ3000_4uf3d0ax","_TZ3000_vzopcetz","_TZ3000_vmpbygs5","_TZ3000_dlug3kbc","_TZ3000_9tg32trw"}))b(aq,o("TS011F",{"_TZ3000_air9m6af","_TZ3000_9djocypn","_TZ3000_bppxj3sf"}))b(aw,o("TS011F",{"_TZ3000_in5s3wn1","_TZ3000_wbloefbf"}))b(aw,o("TS011F",{"_TZ3000_cfnprab5","_TZ3000_o005nuxx","_TZ3000_gdyjfvgm","_TZ3000_pl5v1yyy","_TZ3000_djgzdba9"}))j.attach_reporting_capabilities(ap,{{1,"rpt-tuj"},{2,"rpt-tkg",{zr000600001="Switch",zr000600002="SwitchTwo",zr000600003="SwitchThree"}},{3,"rpt-tcm",{zr000600001="Switch",zr000600002="SwitchTwo",zr000600003="SwitchThree"}},{4,"rpt-tzt"},{5,"rpt-tkp",{zr000600001="Switch",zr000600002="SwitchTwo"}},{6,"rpt-tzt"},{7,"rpt-sit"},{8,"rpt-sit"},{9,"rpt-tss"},{10,"rpt-sit"},{11,"rpt-tbx"},{12,"rpt-tpl"},{13,"rpt-tmp"},{14,"rpt-tks"},{15,"rpt-tet"},{16,"rpt-tlp"},{17,"rpt-tma"},{18,"rpt-tce"},{19,"rpt-twp"},{20,"rpt-sit"},{21,"rpt-tlc"},{22,"rpt-sit"},{23,"rpt-sit"},{24,"rpt-tss"},{25,"rpt-tss"},{26,"rpt-sit"},{27,"rpt-sit"},{28,"rpt-txu"},{29,"rpt-tss"},{30,"rpt-sit"},{31,"rpt-sit"},{32,"rpt-tlc"},{33,"rpt-tks"},{34,"rpt-tpe"},{35,"rpt-tye",{zr000600001="Switch",zr000600002="SwitchTwo"}},{36,"rpt-too",{zr000600001="Switch",zr000600002="SwitchTwo"}},{37,"rpt-too",{zr000600001="Switch",zr000600002="SwitchTwo"}},{38,"rpt-tve",{zr000600001="Switch",zr000600002="SwitchTwo"}},{39,"rpt-tfo",{zr000600001="Switch",zr000600002="SwitchTwo"}},{40,"rpt-tzz",{zr000600001="Switch",zr000600002="SwitchTwo"}},{41,"rpt-tum",{zr000600001="Switch",zr000600002="SwitchTwo"}},{42,"rpt-tev",{zr000600001="Switch",zr000600002="SwitchTwo"}},{43,"rpt-lvk",{zr000600001="Switch",zr000600002="SwitchTwo"}},{44,"rpt-sit"},{45,"rpt-lpm",{zr000600001="Switch",zr000600002="SwitchTwo"}},{46,"rpt-lek",{zr000600001="Switch",zr000600002="SwitchTwo",zr000600003="SwitchThree"}},{47,"rpt-lpm",{zr000600001="Switch",zr000600002="SwitchTwo"}},{48,"rpt-lpm",{zr000600001="Switch",zr000600002="SwitchTwo"}},{49,"rpt-lpm",{zr000600001="Switch",zr000600002="SwitchTwo"}},{50,"rpt-tsl",{zr000600001="Switch",zr000600002="SwitchTwo"}},{51,"rpt-tqv",{zr000600001="Switch",zr000600002="SwitchTwo"}},{52,"rpt-lpm",{zr000600001="Switch",zr000600002="SwitchTwo"}},{53,"rpt-lpm",{zr000600001="Switch",zr000600002="SwitchTwo"}},{54,"rpt-lpm",{zr000600001="Switch",zr000600002="SwitchTwo"}},{55,"rpt-lpm",{zr000600001="Switch",zr000600002="SwitchTwo"}},{56,"rpt-lpm",{zr000600001="Switch",zr000600002="SwitchTwo"}},{57,"rpt-lpm",{zr000600001="Switch",zr000600002="SwitchTwo"}},{58,"rpt-lpm",{zr000600001="Switch",zr000600002="SwitchTwo"}},{59,"rpt-tkw",{zr000600001="Switch",zr000600002="SwitchTwo"}},{60,"rpt-lek",{zr000600001="Switch",zr000600002="SwitchTwo",zr000600003="SwitchThree"}},{61,"rpt-tiu",{zr000600001="Switch",zr000600002="SwitchTwo",zr000600003="SwitchThree"}},{62,"rpt-lek",{zr000600001="Switch",zr000600002="SwitchTwo",zr000600003="SwitchThree"}},{63,"rpt-sit"},{65,"rpt-tmr",{zr000600001="Switch",zr000600002="SwitchTwo",zr000600003="SwitchThree",zr000600004="SwitchFour"}},{67,"rpt-tqvv",{zr000600001="Switch",zr000600002="SwitchTwo",zr000600003="SwitchThree",zr000600004="SwitchFour",zr000600005="SwitchFive",zr000600006="SwitchSix"}},{68,"rpt-tmr",{zr000600001="Switch",zr000600002="SwitchTwo",zr000600003="SwitchThree",zr000600004="SwitchFour"}},{69,"rpt-tmr",{zr000600001="Switch",zr000600002="SwitchTwo",zr000600003="SwitchThree",zr000600004="SwitchFour"}},{70,"rpt-lek",{zr000600001="Switch",zr000600002="SwitchTwo",zr000600003="SwitchThree"}},{71,"rpt-tsh",{zr000600001="Switch",zr000600002="SwitchTwo",zr000600003="SwitchThree",zr000600004="SwitchFour",zr000600005="SwitchFive"}},{72,"rpt-tfx",{zr000600001="Switch",zr000600002="SwitchTwo",zr000600003="SwitchThree",zr000600004="SwitchFour",zr000600005="SwitchFive"}},{73,"rpt-tfx",{zr000600001="Switch",zr000600002="SwitchTwo",zr000600003="SwitchThree",zr000600004="SwitchFour",zr000600005="SwitchFive"}}})return{id="zcl.switches.switches",registrations=ap}

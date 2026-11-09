local i,f,c,A,S,n,aK=require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family",require"contracts.helpers.zcl",require"st.zigbee.device_management",require"st.zigbee.data_types",require"st.zigbee.cluster_base"local O,a=c.definition_registry()
local function d(aB)
return function(aL,e)
for endpoint=1,aB do
e:send(S.build_bind_request(e,i.CLUSTER_ON_OFF,aL.environment_info.hub_zigbee_eui,endpoint))end
end
end
local function v(at,bf)
if bf==1 then
return{profile=at,zcl_clusters={A.switch_cluster()}}end
return{profile=at,zcl_clusters=i.multi_switch(bf)}
end
local k=A.append_clusters
local function C(g,bn)
g.metering_kind=nil
g.scale=bn
return g
end
local function b(bo,aX,aJ,aA,aU,bb,m)
m=m or{}return i.cluster_attribute(aX,aJ,{name=bo,endpoint=m.endpoint,component=m.component,emit=aA,
from_device=function(j)return aU[type(j)=="table"and j.value or j]end,
to_device=function(j)return bb[j]end,
data_type=m.data_type or n.Enum8,write_type=m.write_type or m.data_type or n.Enum8,mfg_code=m.mfg_code,prefer_plain_attribute_write=m.prefer_plain_attribute_write==true,read_on_configure=m.read_on_configure~=false})
end
local function aq(e,aE,aY,bi)
return e:get_latest_state("main",aE,aY)or bi
end
local aI,V,t={[1]={enabled_capability="concertmirror08464.nfzb03InchingControlOne",enabled_attribute="inchingControlOne",time_capability="concertmirror08464.nfzb03InchingTimeOne",time_attribute="inchingTimeOne"},[2]={enabled_capability="concertmirror08464.nfzb03InchingControlTwo",enabled_attribute="inchingControlTwo",time_capability="concertmirror08464.nfzb03InchingTimeTwo",time_attribute="inchingTimeTwo"},[3]={enabled_capability="concertmirror08464.nfzb03InchingControlThree",enabled_attribute="inchingControlThree",time_capability="concertmirror08464.nfzb03InchingTimeThree",time_attribute="inchingTimeThree"}},{[1]={enabled_capability="concertmirror08464.nfzbTwoInchingEnabledOne",enabled_attribute="nfzbTwoInchingEnabledOne",time_capability="concertmirror08464.nfzbTwoInchingTimeOne",time_attribute="nfzbTwoInchingTimeOne"},[2]={enabled_capability="concertmirror08464.nfzbTwoInchingEnabledTwo",enabled_attribute="nfzbTwoInchingEnabledTwo",time_capability="concertmirror08464.nfzbTwoInchingTimeTwo",time_attribute="nfzbTwoInchingTimeTwo"}},"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local function al(r)
local B={}for l=1,#r,3 do
local u,p,G=r[l],r[l+1],r[l+2]local au,ar,av,ao=math.floor(u/4),((u%4)*16)+math.floor((p or 0)/16),(((p or 0)%16)*4)+math.floor((G or 0)/64),(G or 0)%64
B[#B+1]=t:sub(au+1,au+1)B[#B+1]=t:sub(ar+1,ar+1)B[#B+1]=p and t:sub(av+1,av+1)or"="B[#B+1]=G and t:sub(ao+1,ao+1)or"="end
return table.concat(B)
end
local function ai(T,Y,ad)
local y={}for _,Z in ipairs{T,Y,ad}do
if Z<128 then
y[#y+1]=Z
else
y[#y+1]=192+math.floor(Z/64)y[#y+1]=128+(Z%64)end
end
return al(y)
end
local function I(aZ)
local l=t:find(aZ,1,true)return l and(l-1)or nil
end
local function ak(as)
if type(as)~="string"or #as~=4 then return nil end
local u,p,aj,ac=I(as:sub(1,1)),I(as:sub(2,2)),as:sub(3,3),as:sub(4,4)local G,ba=aj=="="and 0 or I(aj),ac=="="and 0 or I(ac)if u==nil or p==nil or G==nil or ba==nil then return nil end
local r={(u*4)+math.floor(p/16)}if aj~="="then
r[#r+1]=((p%16)*16)+math.floor(G/4)end
if ac~="="then
r[#r+1]=((G%4)*64)+ba
end
return r
end
local function aa(r)
local h,l={},1
while l<=#r do
local u=r[l]if u<128 then
h[#h+1]=u
l=l+1
elseif u>=194 and u<=223 then
local p=r[l+1]if p~=nil and p>=128 and p<=191 then
h[#h+1]=((u-192)*64)+(p-128)l=l+2
else
h[#h+1]=65533
l=l+1
end
elseif u>=224 and u<=239 then
local p,G=r[l+1],r[l+2]local aS=p~=nil and p>=128 and p<=191 and
not(u==224 and p<160)and not(u==237 and p>159)if aS and G~=nil and G>=128 and G<=191 then
h[#h+1]=((u-224)*4096)+
((p-128)*64)+(G-128)l=l+3
else
h[#h+1]=65533
l=l+1
end
else
h[#h+1]=65533
l=l+1
end
end
return h
end
local function ae(j)
if type(j)~="string"or(#j%4)~=0 then
return nil
end
local af={}for l=1,#j,4 do
local r=ak(j:sub(l,l+3))if r==nil then return nil end
local h=aa(r)local T=h[1]if T==nil then return nil end
local q,W=1,T

while W>=2 do
q=q+1
W=math.floor(W/2)end
af[q]={enabled=T%2==1 and"enabled"or"disabled",time=h[3]==nil and(math.huge-math.huge)or
((h[2]or 0)*256)+h[3]}end
return af
end
local function X(j,bq,bc,g)
local af=ae(j)local q=af and af[g.inching_channel]or nil
if q==nil then return nil end
if g.inching_kind=="enabled"and g.inching_enabled_values~=nil then
return q.enabled=="enabled"and g.inching_enabled_values.enabled or
g.inching_enabled_values.disabled
end
return q[g.inching_kind]
end
local function am(e,g,j)
local q=g.inching_channel
local ah,az=g.inching_contract or aI[q],g.inching_enabled_values and g.inching_enabled_values.disabled or"disabled"local aV,U=aq(e,ah.enabled_capability,ah.enabled_attribute,az),tonumber(aq(e,ah.time_capability,ah.time_attribute,1))or 1
if g.inching_kind=="enabled"then aV=j end
if g.inching_kind=="time"then U=tonumber(j)or U end
U=math.max(1,math.min(65535,math.floor(U+0.5)))local aF=g.inching_enabled_values and g.inching_enabled_values.enabled or"enabled"local T=aV==aF and 1 or 0
if q>1 then T=T+(2 ^(q-1))end
local Y,ad=math.floor(U/256),U%256
return i.send_raw_cluster_command(e,57344,251,ai(T,Y,ad),1)
end
local function K(q,bj,aA,m)
m=m or{}local bm={enabled=(m.name_prefix or"nfzb03").."_inching_enabled_"..({"one","two","three"})[q],time=(m.name_prefix or"nfzb03").."_inching_time_"..({"one","two","three"})[q]}local g=i.cluster_attribute(57344,53251,{name=bm[bj],emit=aA,from_device=X,data_type=n.CharString,read_on_configure=false,sender=am})g.inching_channel=q
g.inching_kind=bj
g.inching_contract=m.contracts and m.contracts[q]or nil
g.inching_enabled_values=m.enabled_values
return g
end
local H=v("switches-switch-2-ay301z-two",2)k(H.zcl_clusters,i.tuya_magic_packet(),i.switch_type{name="ay301z_two_switch_type",endpoint=1,component="main",emit=f.ay301zTwoSwitchType()},i.countdown_timer{name="ay301z_two_countdown_one",endpoint=1,component="main",emit=f.ay301zTwoCountdownOne"s"},i.countdown_timer{name="ay301z_two_countdown_two",endpoint=2,component="switch2",emit=f.ay301zTwoCountdownTwo"s"})H.configure=d(2)local x=v("switches-switch-1-mli-tint",1)k(x.zcl_clusters,i.cluster_attribute(i.CLUSTER_ON_OFF,16387,{name="mli_tint_power_on_behavior",emit=f.mliTintPowerOnBehavior(),
from_device=function(j)
return({[0]="off",[1]="on",[2]="toggle",[255]="previous"})[j]
end,
to_device=function(j)
return({off=0,on=1,toggle=2,previous=255})[j]
end,
data_type=n.Enum8,write_type=n.Enum8,read_on_configure=true}))x.configure=d(1)local J=v("switches-switch-3-ssw03g",3)k(J.zcl_clusters,i.tuya_magic_packet(),b("ssw03g_power_on_behavior",i.CLUSTER_ON_OFF,32770,f.sswThreePowerOnBehavior(),{[0]="off",[1]="on",[2]="previous"},{off=0,on=1,previous=2}),b("ssw03g_backlight_mode",i.CLUSTER_ON_OFF,32769,f.sswThreeBacklightMode(),{[0]="low",[1]="medium",[2]="high"},{low=0,medium=1,high=2}))J.configure=d(3)local aH,aC=v("switches-switch-2-nfzb2",2),{[1]={countdown=f.nfzbTwoCountdownOne(),enabled=f.nfzbTwoInchingEnabledOne(),time=f.nfzbTwoInchingTimeOne()},[2]={countdown=f.nfzbTwoCountdownTwo(),enabled=f.nfzbTwoInchingEnabledTwo(),time=f.nfzbTwoInchingTimeTwo()}}k(aH.zcl_clusters,i.tuya_magic_packet(),b("nfzb2_power_outage_memory",i.CLUSTER_ON_OFF,32770,f.nfzbTwoPowerOutageMemory(),{[0]="off",[1]="on",[2]="restore"},{off=0,on=1,restore=2}),b("nfzb2_indicator_mode",i.CLUSTER_ON_OFF,32769,f.nfzbTwoIndicatorMode(),{[0]="off",[1]="off/on",[2]="on/off",[3]="on"},{off=0,["off/on"]=1,["on/off"]=2,on=3}),b("nfzb2_backlight_mode",i.CLUSTER_ON_OFF,20480,f.nfzbTwoBacklightMode(),{[0]="OFF",[1]="ON"},{OFF=0,ON=1},{data_type=n.Enum8,write_type=n.Enum8}))for endpoint=1,2 do
local bp=({"One","Two"})[endpoint]local suffix,aw=bp:lower(),aC[endpoint]k(aH.zcl_clusters,i.countdown_timer{name="nfzb2_countdown_"..suffix,endpoint=endpoint,component=endpoint==1 and"main"or"switch2",emit=aw.countdown},K(endpoint,"enabled",aw.enabled,{name_prefix="nfzb2",contracts=V,enabled_values={enabled="ENABLE",disabled="DISABLE"}}),K(endpoint,"time",aw.time,{name_prefix="nfzb2",contracts=V,enabled_values={enabled="ENABLE",disabled="DISABLE"}}))end
aH.configure=d(2)local N,M=i.switch{endpoint=1,minimum_interval=0,maximum_interval=65535,reportable_change=1},i.switch{endpoint=1,minimum_interval=0,maximum_interval=65535,reportable_change=1}
M.sender=function(e,_,j,w)
local endpoint=w.endpoint or 1
local bl=i.send_named_command(e,{N},"switch",j,{component_id=w.component_id,endpoint=endpoint})if bl then
i.read_attribute(e,i.CLUSTER_ON_OFF,32768,endpoint)end
return bl
end
local aT={profile="switches-candeo-ssfs",zcl_clusters={M,C(i.power{endpoint=1,minimum_interval=5,maximum_interval=300,reportable_change=10},1),C(i.voltage{endpoint=1,minimum_interval=5,maximum_interval=600,reportable_change=5},1),C(i.current{endpoint=1,minimum_interval=5,maximum_interval=900,reportable_change=10},1000),C(i.energy{endpoint=1,minimum_interval=5,maximum_interval=1800,reportable_change=50},100),i.power_on_behavior{name="candeo_ssfs_power_on_behavior",endpoint=1,emit=f.candeoSsfsPowerBehavior(),read_on_configure=true},i.child_lock{name="candeo_ssfs_child_lock",endpoint=1,emit=f.candeoSsfsChildLock(),
from_device=function(j)
return(j==true or j==1)and"LOCK"or"UNLOCK"
end,
to_device=function(j)
return j=="LOCK"
end,
read_on_configure=true}}}local R=v("switches-moes-zsus1-ln",1)k(R.zcl_clusters,i.tuya_magic_packet(),b("moes_zsus1_power_on_behavior",57345,53264,f.moesZsus1PowerBehavior(),{[0]="off",[1]="on",[2]="previous"},{off=0,on=1,previous=2}),b("moes_zsus1_switch_type",57345,53296,f.moesZsus1SwitchType(),{[0]="toggle",[1]="state",[2]="momentary"},{toggle=0,state=1,momentary=2}),b("moes_zsus1_backlight_mode",i.CLUSTER_ON_OFF,20480,f.moesZsus1BacklightMode(),{[0]="off",[1]="on"},{off=0,on=1},{data_type=n.Enum8,write_type=n.Enum8,prefer_plain_attribute_write=true}))R.configure=d(1)a(J,c.create_fingerprints("TS0013",{"_TZ3000_khtlvdfc"}))a(aH,c.create_fingerprints("TS0002",{"_TZ3210_5ksufhqi"}))a(H,{c.create_fingerprint("AOYAN","AY301Z-2CH")})a(x,{c.create_fingerprint("MLI","tint Smart Switch"),c.create_fingerprint("MLI\0","switch01\0")})a(aT,{c.create_fingerprint("Candeo","C-ZB-SSFS")})a(R,{c.create_fingerprint("_TZ3000_bzzgvet0","TS0001")})local z=v("switches-zemismart-kes606",1)z.zcl_clusters[1].maximum_interval=65000
k(z.zcl_clusters,i.tuya_magic_packet{read_on_configure=false},b("kes606_power_on_behavior",57345,53264,f.kes606PowerBehavior(),{[0]="off",[1]="on",[2]="previous"},{off=0,on=1,previous=2},{read_on_configure=false}),b("kes606_indicator_mode",i.CLUSTER_ON_OFF,32769,f.kes606IndicatorMode(),{[0]="off",[1]="off/on",[2]="on/off",[3]="on"},{off=0,["off/on"]=1,["on/off"]=2,on=3},{read_on_configure=false}))z.configure=d(1)a(z,{c.create_fingerprint("_TZ3000_w5s3mbyn","TS0001")})local aM={profile="switches-ekaza-ts0003",zcl_clusters={i.switch{endpoint=1,component="main",configure_reporting=false,read_on_configure=false},i.switch{endpoint=2,component="switch2",configure_reporting=false,read_on_configure=false},i.switch{endpoint=3,component="switch3",configure_reporting=false,read_on_configure=false},i.tuya_magic_packet{read_on_configure=false},b("eka_ts0003_switch_type",57345,53296,f.ekaTs0003SwitchType(),{[0]="toggle",[1]="state",[2]="momentary"},{toggle=0,state=1,momentary=2},{mfg_code=4417,read_on_configure=false}),b("eka_ts0003_indicator_mode",6,32769,f.ekaTs0003IndicatorMode(),{[0]="off",[1]="off/on",[2]="on/off",[3]="on"},{off=0,["off/on"]=1,["on/off"]=2,on=3},{read_on_configure=false}),i.countdown_timer{name="eka_ts0003_countdown_one",endpoint=1,component="main",emit=f.ekaTs0003CountdownOne(),read_on_configure=false},i.countdown_timer{name="eka_ts0003_countdown_two",endpoint=2,component="switch2",emit=f.ekaTs0003CountdownTwo(),read_on_configure=false},i.countdown_timer{name="eka_ts0003_countdown_three",endpoint=3,component="switch3",emit=f.ekaTs0003CountdownThree(),read_on_configure=false}},configure=d(3)}a(aM,{c.create_fingerprint("_TZ3000_f6pgzqob","TS0003")})local s=b("nous_b2z_switch_type",57345,53296,f.nousB2zSwitchType(),{[0]="toggle",[1]="state",[2]="momentary"},{toggle=0,state=1,momentary=2},{read_on_configure=false})
s.sender=function(e,g,j,w)
local aW=aK.write_attribute(e,n.ClusterId(57345),n.AttributeId(53296),n.Enum8(g.to_device(j)))aW.body.zcl_header.frame_ctrl:set_disable_default_response()e:send(aW:to_endpoint(w.endpoint or 1))return true
end
local bd={profile="switches-nous-b2z",zcl_clusters={i.switch{endpoint=1,configure_reporting=false,read_on_configure=false},i.electrical_measurement_power{endpoint=1,emit=f.power(),read_only=true,minimum_interval=5,maximum_interval=3600,reportable_change=10,
from_device=function(j,e,w)
return i.scale_mapping_value(e,nil,j,{metering_kind="power",scale=1},w)
end
},i.electrical_measurement_voltage{endpoint=1,emit=f.voltage(),read_only=true,minimum_interval=5,maximum_interval=3600,reportable_change=5,
from_device=function(j,e,w)
return i.scale_mapping_value(e,nil,j,{metering_kind="voltage",scale=1},w)
end
},i.electrical_measurement_current{endpoint=1,emit=f.current(),scale=1000,read_only=true,minimum_interval=5,maximum_interval=3600,reportable_change=50},i.simple_metering{endpoint=1,emit=f.energy(),scale=100,read_only=true,minimum_interval=5,maximum_interval=3600,reportable_change=257},i.tuya_magic_packet{read_on_configure=false},s,b("nous_b2z_power_outage_memory",6,32770,f.nousB2zPowerOutageMemory(),{[0]="off",[1]="on",[2]="restore"},{off=0,on=1,restore=2},{read_on_configure=false})},
configure=function(aL,e)
for _,bg in ipairs{6,2820,1794}do
e:send(S.build_bind_request(e,bg,aL.environment_info.hub_zigbee_eui,1))end
end,
parent_refresh=function(e)
for _,ap in ipairs{{6,0},{6,32770},{57345,53296}}do
i.read_attribute(e,ap[1],ap[2],1)end
end
}a(bd,{c.create_fingerprint("_TZ3000_ahvrgyac","TS0001")})local L=b("tuya_p26_switch_type",57345,53296,f.tuyaP26SwitchType(),{[0]="toggle",[1]="state",[2]="momentary"},{toggle=0,state=1,momentary=2},{read_on_configure=false})L.sender=s.sender
local be={profile="switches-tuya-p26",zcl_clusters={i.switch{endpoint=1,configure_reporting=false,read_on_configure=false},i.tuya_magic_packet{read_on_configure=false},b("tuya_p26_power_behavior",57345,53264,f.tuyaP26PowerBehavior(),{[0]="off",[1]="on",[2]="previous"},{off=0,on=1,previous=2},{read_on_configure=false}),L,b("tuya_p26_backlight_mode",6,20480,f.tuyaP26BacklightMode(),{[0]="OFF",[1]="ON"},{OFF=0,ON=1},{read_on_configure=false,prefer_plain_attribute_write=true}),b("tuya_p26_indicator_mode",6,32769,f.tuyaP26IndicatorMode(),{[0]="off",[1]="off/on",[2]="on/off",[3]="on"},{off=0,["off/on"]=1,["on/off"]=2,on=3},{read_on_configure=false})},configure=d(1),
parent_refresh=function(e)
for _,ap in ipairs{{6,0},{57345,53264},{57345,53296},{6,20480},{6,32769}}do
i.read_attribute(e,ap[1],ap[2],1)end
end
}a(be,{c.create_fingerprint("_TZ3000_p26flek3","TS0001")})local P=b("qs_s10_switch_type",57345,53296,f.qsS10SwitchType(),{[0]="toggle",[1]="state",[2]="momentary"},{toggle=0,state=1,momentary=2},{read_on_configure=false})P.sender=s.sender
local aR={profile="switches-qs-s10-three",zcl_clusters={i.switch{endpoint=1,component="main",configure_reporting=false,read_on_configure=false},i.switch{endpoint=2,component="switch2",configure_reporting=false,read_on_configure=false},i.switch{endpoint=3,component="switch3",configure_reporting=false,read_on_configure=false},i.tuya_magic_packet{read_on_configure=false},P,b("qs_s10_power_memory",6,32770,f.qsS10PowerMemory(),{[0]="off",[1]="on",[2]="restore"},{off=0,on=1,restore=2},{read_on_configure=false})},configure=d(3)}a(aR,{c.create_fingerprint("_TZ3000_ly9apzky","TS0003")})local D={i.switch{endpoint=1,configure_reporting=false,read_on_configure=false,
suppress_optimistic_state=true,from_device=function(j,e,w)
local rx=w.zb_rx
if rx and A.duplicate_transaction(e,w.endpoint,rx.body.zcl_header.seqno.value,"__ewelink_switch_transactions")then return end
return j==true or j==1
end}
}local F={
ewelink_toggle=function(e)return i.send_raw_cluster_command(e,6,2,"",1)end
}local E={{capability_id="momentary",command_name="push",mapping_name="ewelink_toggle"}}local aN,aG={profile="switches-ewelink-sw01",zcl_clusters=D,protocol_writers=F,capability_commands=E},{profile="plugs-ewelink-sa003",zcl_clusters=D,protocol_writers=F,capability_commands=E,configure=d(1)}a(aN,{c.create_fingerprint("eWeLink","ZB-SW01")})a(aG,{c.create_fingerprint("eWeLink","SA-003-Zigbee")})local an,ax={[0]="off",[1]="on",[2]="toggle",[255]="previous"},{off=0,on=1,toggle=2,previous=255}local ag={
ewelink_multi_toggle=function(e,_,bh)
return i.send_raw_cluster_command(e,6,2,"",e:get_endpoint_for_component_id(bh.component))
end
}local ab={{capability_id="momentary",command_name="push",mapping_name="ewelink_multi_toggle"}}
local function Q(at,bk)
local ay={}for endpoint,ap in ipairs(bk)do
local aD=endpoint==1 and"main"or"switch"..endpoint
ay[#ay+1]=i.switch{endpoint=endpoint,component=aD,configure_reporting=false,read_on_configure=false,suppress_optimistic_state=true}ay[#ay+1]=b(ap[1],6,16387,ap[2],an,ax,{endpoint=endpoint,component=aD,read_on_configure=false,prefer_plain_attribute_write=true})ay[#ay].suppress_optimistic_state=true
end
return{profile=at,zcl_clusters=ay,protocol_writers=ag,capability_commands=ab}
end
local aO,aP,aQ=Q("switches-ewelink-sw02",{{"ewelink_sw02_power_one",f.ewelinkSw02PowerOne()},{"ewelink_sw02_power_two",f.ewelinkSw02PowerTwo()}}),Q("switches-ewelink-sw03",{{"ewelink_sw03_power_one",f.ewelinkSw03PowerOne()},{"ewelink_sw03_power_two",f.ewelinkSw03PowerTwo()},{"ewelink_sw03_power_three",f.ewelinkSw03PowerThree()}}),Q("switches-ewelink-sw04",{{"ewelink_sw04_power_one",f.ewelinkSw04PowerOne()},{"ewelink_sw04_power_two",f.ewelinkSw04PowerTwo()},{"ewelink_sw04_power_three",f.ewelinkSw04PowerThree()},{"ewelink_sw04_power_four",f.ewelinkSw04PowerFour()}})a(aO,{c.create_fingerprint("eWeLink","ZB-SW02")})a(aP,{c.create_fingerprint("eWeLink","ZB-SW03")})a(aQ,{c.create_fingerprint("eWeLink","ZB-SW04")})i.attach_reporting_capabilities(O,{{1,"rpt-tgv",{zr000600001="Switch",zr000600002="SwitchTwo",zr000600003="SwitchThree"}},{2,"rpt-tjh",{zr000600001="Switch",zr000600002="SwitchTwo"}},{3,"rpt-aft",{zr000600001="Switch",zr000600002="SwitchTwo"}},{4,"rpt-tqs"},{5,"rpt-cbp"},{6,"rpt-tgk"},{7,"rpt-tesc"},{9,"rpt-tjs"}})return{id="zcl.switches.z2m_absorption",registrations=O}

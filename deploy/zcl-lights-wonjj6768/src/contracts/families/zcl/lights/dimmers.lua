local k,c,U,J,L,w,E,A=require"protocol.zcl",require"contracts.helpers.family",require"capabilities.events.all",require"st.zigbee.device_management",require"st.zigbee.data_types",require"contracts.helpers.tuya_dimmer_brightness",require"contracts.helpers.tuya_dimmer_minimum",require"contracts.helpers.tuya_dimmer_settings"local h,a=c.definition_registry()
local function G(W)
local P={}for _,X in ipairs(W or{})do
P[#P+1]=X
end
return P
end
local function e(M)
return function(V,S)
for i=1,M do
for _,Q in ipairs{k.CLUSTER_ON_OFF,k.CLUSTER_LEVEL_CONTROL}do
S:send(J.build_bind_request(S,Q,V.environment_info.hub_zigbee_eui,i))end
end
end
end
local function d(l,f)
f=f or{}local g={k.tuya_magic_packet(),k.switch(),k.tuya_dimmer_level()}if f.power_on_behavior then g[#g+1]=k.power_on_behavior()end
if f.switch_type then g[#g+1]=k.ts110e_switch_type{write_only=true}end
if f.countdown then
g[#g+1]=f.countdown_step==30
and k.ts110e_countdown_timer{emit=U.countdownTsOneTenHalfMinute"s"}or k.ts110e_countdown_timer()end
if f.min_brightness then g[#g+1]=k.ts110e_min_brightness()end
if f.max_brightness then g[#g+1]=k.ts110e_max_brightness()end
if f.light_type then g[#g+1]=k.light_type()end
return{profile=l,zcl_clusters=g,configure=e(1)}
end
local function s(l)
return{profile=l,zcl_clusters={k.switch(),k.level()},configure=e(1)}
end
local function o(l)
return{profile=l,zcl_clusters={k.switch(),k.level(),k.min_brightness()},configure=e(1)}
end
local function n(l)
local b=G(k.multi_switch(2,{component_prefix="switch"}))for _,y in ipairs(k.multi_level(2,{component_prefix="switch"}))do
b[#b+1]=y
end
return{profile=l,zcl_clusters=b,configure=e(2)}
end
local function q(l)
local b=G(k.multi_switch(2,{component_prefix="switch"}))for _,y in ipairs(k.multi_level(2,{component_prefix="switch"}))do
b[#b+1]=y
end
for i=1,2 do
b[#b+1]=k.min_brightness{endpoint=i,component=i==1 and"main"or"switch2"}end
return{profile=l,zcl_clusters=b,configure=e(2)}
end
local function j(l,f)
f=f or{}local b=G(k.multi_switch(2,{component_prefix="switch"}))for _,y in ipairs(k.multi_level(2,{component_prefix="switch"}))do
b[#b+1]=y
end
table.insert(b,1,k.tuya_magic_packet())if f.power_on_behavior then b[#b+1]=k.power_on_behavior()end
for i=1,2 do
local F=i==1 and"main"or"switch2"if f.switch_type then
b[#b+1]=k.ts110e_switch_type{endpoint=i,component=F,write_only=true}end
if f.min_brightness then
b[#b+1]=k.ts110e_min_brightness{endpoint=i,component=F}end
if f.max_brightness then
b[#b+1]=k.ts110e_max_brightness{endpoint=i,component=F}end
end
return{profile=l,zcl_clusters=b,configure=e(2)}
end
local B,v,I,m=s"lights-dimmer",o"lights-dimmer-min",n"lights-dimmer-2-zcl-basic",n"lights-dimmer-2-lonsonho"for i,spec in ipairs{{"One",U.lonD2PowerOne()},{"Two",U.lonD2PowerTwo()}}do
m.zcl_clusters[#m.zcl_clusters+1]=k.cluster_attribute(6,16387,{name="lon_d_two_power_"..spec[1]:lower(),endpoint=i,component=i==1 and"main"or"switch2",data_type=L.Enum8,write_type=L.Enum8,read_on_configure=true,emit=spec[2],
from_device=function(H)
if type(H)=="table"then H=H.value end
return({[0]="off",[1]="on",[2]="toggle",[255]="previous"})[H]
end,
to_device=function(H)return({off=0,on=1,toggle=2,previous=255})[H]end
})end
local x,N,t,r,D,O,C,R,u,p,K,z,T=q"lights-dimmer-2-min",d("lights-dimmer-options-ts110",{power_on_behavior=true,switch_type=true,countdown=true,min_brightness=true,max_brightness=true,light_type=true}),d("lights-dimmer-options-ts110-countdown30",{power_on_behavior=true,switch_type=true,countdown=true,countdown_step=30,min_brightness=true,max_brightness=true,light_type=true}),d("lights-dimmer-ts110-power-switch-minmax",{power_on_behavior=true,switch_type=true,min_brightness=true,max_brightness=true}),d("lights-dimmer-ts110-power-switch",{power_on_behavior=true,switch_type=true}),d("lights-dimmer-ts110-minmax",{min_brightness=true,max_brightness=true}),d("lights-dimmer-ts110-power-minmax",{power_on_behavior=true,min_brightness=true,max_brightness=true}),d("lights-dimmer-ts110-min",{min_brightness=true}),j("lights-dimmer-2-options-ts110",{power_on_behavior=true,switch_type=true,min_brightness=true,max_brightness=true}),j("lights-ts110e-dual-f0",{power_on_behavior=true,switch_type=true,min_brightness=true,max_brightness=true}),j("lights-dimmer-2-ts110-power-switch",{power_on_behavior=true,switch_type=true}),j("lights-dimmer-2-ts110-power-switch-min",{power_on_behavior=true,switch_type=true,min_brightness=true}),j("lights-dimmer-2-ts110-min",{min_brightness=true})a(B,c.create_fingerprints("TS110F",{"_TZ3000_estfrmup","_TZ3000_ktuoyvt5","_TZ3210_lfbz816s","_TZ3210_ebbfkvoy"}))a(I,c.create_fingerprints("TS110F",{"_TZ3000_hexqj6ls"}))a(m,c.create_fingerprints("TS110F",{"_TZ3000_92chsky7"}))a(v,c.create_fingerprints("TS110F",{"_TYZB01_qezuin6k"}))a(x,c.create_fingerprints("TS110F",{"_TYZB01_v8gtiaed"}))a(r,c.create_fingerprints("TS110E",{"_TZ3210_zxbtub8r","_TZ3210_cyuyd5az"}))a(t,c.create_fingerprints("TS110E",{"_TZ3210_ngqk6jia"}))a(N,c.create_fingerprints("TS110E",{"_TZ3210_weaqkhab","_TZ3210_k1msuvg6","_TZ3210_o235agwx"}))a(D,c.create_fingerprints("TS110E",{"_TZ3210_hzdhb62z","_TZ3210_v5yquxma"}))a(C,c.create_fingerprints("TS110E",{"_TZ3210_ysfo0wla"}))a(O,c.create_fingerprints("TS110E",{"_TZ3210_guijtl8k","_TZ3210_hquixjeg"}))a(R,c.create_fingerprints("TS1101",{"_TZ3000_xfs39dbf"}))a(u,c.create_fingerprints("TS110E",{"_TZ3210_wdexaypg"}))a(p,c.create_fingerprints("TS110E",{"_TZ3210_pagajpog","_TZ3210_4ubylghk","_TZ3210_vfwhhldz","_TZ3210_3mpwqzuu","_TZ3210_mt5xjoy6"}))a(K,c.create_fingerprints("TS110E",{"_TZ3210_tkkb1ym8"}))a(T,c.create_fingerprints("TS1101",{"_TZ3000_7ysdnebc"}))a(z,c.create_fingerprints("TS0052",{"_TZ3000_zjtxnoft","_TZ3000_kvwrdf47","_TZ3000_sfibawtr"}))w.apply(h)E.apply(h)A.apply(h)k.attach_reporting_capabilities(h,{{1,"rpt-tmf"},{2,"rpt-tww",{zr000600001="Switch",zr000600002="SwitchTwo",zr000800001="Level",zr000800002="LevelTwo"}},{3,"rpt-tif",{zr000600001="Switch",zr000600002="SwitchTwo",zr000800001="Level",zr000800002="LevelTwo"}},{4,"rpt-tmjp"},{5,"rpt-tjg",{zr000600001="Switch",zr000600002="SwitchTwo",zr000800001="Level",zr000800002="LevelTwo"}},{6,"rpt-twd"},{7,"rpt-twk"},{8,"rpt-txs"},{9,"rpt-tln"},{10,"rpt-tvu"},{11,"rpt-tqn"},{12,"rpt-txw"},{13,"rpt-tcs",{zr000600001="Switch",zr000600002="SwitchTwo",zr000800001="Level",zr000800002="LevelTwo"}},{14,"rpt-taw",{zr000600001="Switch",zr000600002="SwitchTwo"}},{15,"rpt-tvt",{zr000600001="Switch",zr000600002="SwitchTwo",zr000800001="Level",zr000800002="LevelTwo"}},{16,"rpt-tjg",{zr000600001="Switch",zr000600002="SwitchTwo",zr000800001="Level",zr000800002="LevelTwo"}},{17,"rpt-tslv",{zr000600001="Switch",zr000600002="SwitchTwo",zr000800001="Level",zr000800002="LevelTwo"}}})return{id="zcl.lights.dimmers",registrations=h}

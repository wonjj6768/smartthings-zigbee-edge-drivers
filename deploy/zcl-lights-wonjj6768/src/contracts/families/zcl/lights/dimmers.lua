local i,c,Q,F,H=require"protocol.zcl",require"contracts.helpers.family",require"capabilities.events.all",require"st.zigbee.device_management",require"st.zigbee.data_types"local q,a=c.definition_registry()
local function C(S)
local L={}for _,T in ipairs(S or{})do
L[#L+1]=T
end
return L
end
local function e(I)
return function(R,O)
for h=1,I do
for _,M in ipairs{i.CLUSTER_ON_OFF,i.CLUSTER_LEVEL_CONTROL}do
O:send(F.build_bind_request(O,M,R.environment_info.hub_zigbee_eui,h))end
end
end
end
local function d(k,f)
f=f or{}local g={i.tuya_magic_packet(),i.switch(),i.tuya_dimmer_level()}if f.power_on_behavior then g[#g+1]=i.power_on_behavior()end
if f.switch_type then g[#g+1]=i.ts110e_switch_type{write_only=true}end
if f.countdown then
g[#g+1]=f.countdown_step==30
and i.ts110e_countdown_timer{emit=Q.countdownTsOneTenHalfMinute"s"}or i.ts110e_countdown_timer()end
if f.min_brightness then g[#g+1]=i.ts110e_min_brightness()end
if f.max_brightness then g[#g+1]=i.ts110e_max_brightness()end
if f.light_type then g[#g+1]=i.light_type()end
return{profile=k,zcl_clusters=g,configure=e(1)}
end
local function s(k)
return{profile=k,zcl_clusters={i.switch(),i.level()},configure=e(1)}
end
local function o(k)
return{profile=k,zcl_clusters={i.switch(),i.level(),i.min_brightness()},configure=e(1)}
end
local function n(k)
local b=C(i.multi_switch(2,{component_prefix="switch"}))for _,w in ipairs(i.multi_level(2,{component_prefix="switch"}))do
b[#b+1]=w
end
return{profile=k,zcl_clusters=b,configure=e(2)}
end
local function p(k)
local b=C(i.multi_switch(2,{component_prefix="switch"}))for _,w in ipairs(i.multi_level(2,{component_prefix="switch"}))do
b[#b+1]=w
end
for h=1,2 do
b[#b+1]=i.min_brightness{endpoint=h,component=h==1 and"main"or"switch2"}end
return{profile=k,zcl_clusters=b,configure=e(2)}
end
local function j(k,f)
f=f or{}local b=C(i.multi_switch(2,{component_prefix="switch"}))for _,w in ipairs(i.multi_level(2,{component_prefix="switch"}))do
b[#b+1]=w
end
table.insert(b,1,i.tuya_magic_packet())if f.power_on_behavior then b[#b+1]=i.power_on_behavior()end
for h=1,2 do
local B=h==1 and"main"or"switch2"if f.switch_type then
b[#b+1]=i.ts110e_switch_type{endpoint=h,component=B,write_only=true}end
if f.min_brightness then
b[#b+1]=i.ts110e_min_brightness{endpoint=h,component=B}end
if f.max_brightness then
b[#b+1]=i.ts110e_max_brightness{endpoint=h,component=B}end
end
return{profile=k,zcl_clusters=b,configure=e(2)}
end
local y,u,E,l=s"lights-dimmer",o"lights-dimmer-min",n"lights-dimmer-2-zcl-basic",n"lights-dimmer-2-lonsonho"for h,spec in ipairs{{"One",Q.lonD2PowerOne()},{"Two",Q.lonD2PowerTwo()}}do
l.zcl_clusters[#l.zcl_clusters+1]=i.cluster_attribute(6,16387,{name="lon_d_two_power_"..spec[1]:lower(),endpoint=h,component=h==1 and"main"or"switch2",data_type=H.Enum8,write_type=H.Enum8,read_on_configure=true,emit=spec[2],
from_device=function(D)
if type(D)=="table"then D=D.value end
return({[0]="off",[1]="on",[2]="toggle",[255]="previous"})[D]
end,
to_device=function(D)return({off=0,on=1,toggle=2,previous=255})[D]end
})end
local v,J,t,r,A,K,z,N,m,G,x,P=p"lights-dimmer-2-min",d("lights-dimmer-options-ts110",{power_on_behavior=true,switch_type=true,countdown=true,min_brightness=true,max_brightness=true,light_type=true}),d("lights-dimmer-options-ts110-countdown30",{power_on_behavior=true,switch_type=true,countdown=true,countdown_step=30,min_brightness=true,max_brightness=true,light_type=true}),d("lights-dimmer-ts110-power-switch-minmax",{power_on_behavior=true,switch_type=true,min_brightness=true,max_brightness=true}),d("lights-dimmer-ts110-power-switch",{power_on_behavior=true,switch_type=true}),d("lights-dimmer-ts110-minmax",{min_brightness=true,max_brightness=true}),d("lights-dimmer-ts110-power-minmax",{power_on_behavior=true,min_brightness=true,max_brightness=true}),d("lights-dimmer-ts110-min",{min_brightness=true}),j("lights-dimmer-2-options-ts110",{power_on_behavior=true,switch_type=true,min_brightness=true,max_brightness=true}),j("lights-dimmer-2-ts110-power-switch",{power_on_behavior=true,switch_type=true}),j("lights-dimmer-2-ts110-power-switch-min",{power_on_behavior=true,switch_type=true,min_brightness=true}),j("lights-dimmer-2-ts110-min",{min_brightness=true})a(y,c.create_fingerprints("TS110F",{"_TZ3000_estfrmup","_TZ3000_ktuoyvt5","_TZ3210_lfbz816s","_TZ3210_ebbfkvoy"}))a(E,c.create_fingerprints("TS110F",{"_TZ3000_hexqj6ls"}))a(l,c.create_fingerprints("TS110F",{"_TZ3000_92chsky7"}))a(u,c.create_fingerprints("TS110F",{"_TYZB01_qezuin6k"}))a(v,c.create_fingerprints("TS110F",{"_TYZB01_v8gtiaed"}))a(r,c.create_fingerprints("TS110E",{"_TZ3210_zxbtub8r","_TZ3210_cyuyd5az"}))a(t,c.create_fingerprints("TS110E",{"_TZ3210_ngqk6jia"}))a(J,c.create_fingerprints("TS110E",{"_TZ3210_weaqkhab","_TZ3210_k1msuvg6","_TZ3210_o235agwx"}))a(A,c.create_fingerprints("TS110E",{"_TZ3210_hzdhb62z","_TZ3210_v5yquxma"}))a(z,c.create_fingerprints("TS110E",{"_TZ3210_ysfo0wla"}))a(K,c.create_fingerprints("TS110E",{"_TZ3210_guijtl8k","_TZ3210_hquixjeg"}))a(N,c.create_fingerprints("TS1101",{"_TZ3000_xfs39dbf"}))a(m,c.create_fingerprints("TS110E",{"_TZ3210_wdexaypg"}))a(m,c.create_fingerprints("TS110E",{"_TZ3210_pagajpog","_TZ3210_4ubylghk","_TZ3210_vfwhhldz","_TZ3210_3mpwqzuu","_TZ3210_mt5xjoy6"}))a(G,c.create_fingerprints("TS110E",{"_TZ3210_tkkb1ym8"}))a(P,c.create_fingerprints("TS1101",{"_TZ3000_7ysdnebc"}))a(x,c.create_fingerprints("TS0052",{"_TZ3000_zjtxnoft","_TZ3000_kvwrdf47","_TZ3000_sfibawtr"}))i.attach_reporting_capabilities(q,{{1,"rpt-tmf"},{2,"rpt-tww",{zr000600001="Switch",zr000600002="SwitchTwo",zr000800001="Level",zr000800002="LevelTwo"}},{3,"rpt-tif",{zr000600001="Switch",zr000600002="SwitchTwo",zr000800001="Level",zr000800002="LevelTwo"}},{4,"rpt-tmj"},{5,"rpt-tzm",{zr000600001="Switch",zr000600002="SwitchTwo",zr000800001="Level",zr000800002="LevelTwo"}},{6,"rpt-twd"},{7,"rpt-twk"},{8,"rpt-txs"},{9,"rpt-tln"},{10,"rpt-tvu"},{11,"rpt-tqn"},{12,"rpt-txw"},{13,"rpt-tcs",{zr000600001="Switch",zr000600002="SwitchTwo",zr000800001="Level",zr000800002="LevelTwo"}},{14,"rpt-tcs",{zr000600001="Switch",zr000600002="SwitchTwo",zr000800001="Level",zr000800002="LevelTwo"}},{15,"rpt-tvt",{zr000600001="Switch",zr000600002="SwitchTwo",zr000800001="Level",zr000800002="LevelTwo"}},{16,"rpt-tjg",{zr000600001="Switch",zr000600002="SwitchTwo",zr000800001="Level",zr000800002="LevelTwo"}},{17,"rpt-tslv",{zr000600001="Switch",zr000600002="SwitchTwo",zr000800001="Level",zr000800002="LevelTwo"}}})return{id="zcl.lights.dimmers",registrations=q}

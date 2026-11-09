local y,b,B,C,Q,o=require"protocol.zcl",require"contracts.helpers.family",require"contracts.helpers.zcl",require"st.zigbee.device_management",require"capabilities.events.all",require"st.zigbee.data_types"local s,a=b.definition_registry()
local function P(V)
local M={}for _,W in ipairs(V or{})do
M[#M+1]=W
end
return M
end
local function k(j,q)
local R={}for F=1,j do
R[F]=F==1 and"main"or("switch"..tostring(F))end
for F=1,q do
local endpoint=j+F
R[endpoint]=endpoint==1 and"main"or("button"..tostring(endpoint))end
if j==0 then
R[1]="main"end
return R
end
local function n(I)
return function(T,A)
for endpoint=1,I do
A:send(C.build_bind_request(A,y.CLUSTER_ON_OFF,T.environment_info.hub_zigbee_eui,endpoint))end
end
end
local function c(S,j,q,U)
local v=P(y.multi_switch(j,{component_prefix="switch"}))table.insert(v,1,y.tuya_magic_packet())B.append_clusters(v,y.power_on_behavior(),y.switch_mode())local E={profile=S,scene_switch=true,button_actions={"pushed"},scene_component_map=k(j,q),zcl_clusters=v,configure=n(j+q)}for X,r in pairs(U or{})do
E[X]=r
end
return E
end
local N,O,H,J,x,u,w,p=c("scene-switches-1",1,0),c("scene-switches-2",2,0),c("scene-switches-3",3,0),c("scene-switches-4",4,0),c("scene-switches-1-advanced",1,0),c("scene-switches-3-advanced",3,0),c("scene-switches-4-advanced",4,0),c("scene-switches-4-plus-2",4,2)local d={profile="scene-switches-4-plus-4",scene_switch=true,button_actions={"pushed"},scene_component_map=k(4,4),zcl_clusters={y.tuya_magic_packet{read_on_configure=false}},configure=n(8),
parent_refresh=function(A)
for endpoint=1,4 do
y.read_attribute(A,6,0,endpoint)y.read_attribute(A,57345,53264,endpoint)end
return true
end
}for endpoint=1,4 do
local z=endpoint==1 and"main"or("switch"..endpoint)d.zcl_clusters[#d.zcl_clusters+1]=y.cluster_attribute(6,0,{name="switch",endpoint=endpoint,component=z,data_type=o.Boolean,emit=Q.switch()})d.zcl_clusters[#d.zcl_clusters+1]=y.cluster_attribute(57345,53264,{name="ts0726_four_scene_power_behavior",endpoint=endpoint,component=z,data_type=o.Enum8,write_type=o.Enum8,emit=Q.ts0726FourScenePowerBehavior(),converter={
from=function(r)
if type(r)=="table"then r=r.value end
return({[0]="off",[1]="on",[2]="previous"})[r]
end,
to=function(r)return({off=0,on=1,previous=2})[r]end
}})d.zcl_clusters[#d.zcl_clusters+1]=y.cluster_attribute(57345,53280,{name="ts0726_four_scene_switch_mode",endpoint=endpoint,component=z,data_type=o.Enum8,write_type=o.Enum8,write_only=true,
to_device=function(r)return({switch=0,scene=1})[r]end,
emit=Q.ts0726FourSceneSwitchMode()})end
local K,L,D,G,t,l,m,h,i,g,e=c("scene-switches-scene-1",1,0),c("scene-switches-scene-2",2,0),c("scene-switches-scene-3",3,0),c("scene-switches-scene-4",4,0),c("scene-switches-scene-6",4,2),c("scene-switches-1-advanced",1,0),c("scene-switches-2-advanced",2,0),c("scene-switches-3-advanced",3,0),c("scene-switches-3-advanced",3,0),{[1]=1,[2]=2,[3]=3,[4]=1,[5]=2,[6]=3},{[1]="1_down",[2]="2_down",[3]="3_down",[4]="1_up",[5]="2_up",[6]="3_up"}l.scene_action_map=g
l.scene_action_name_map=e
l.scene_component_map={[1]="main",[4]="main"}m.scene_action_map=g
m.scene_action_name_map=e
m.scene_component_map={[1]="main",[4]="main",[2]="switch2",[5]="switch2"}h.scene_action_map=g
h.scene_action_name_map=e
h.scene_component_map={[1]="main",[4]="main",[2]="switch2",[5]="switch2",[3]="switch3",[6]="switch3"}i.scene_action_map=g
i.scene_action_name_map=e
i.scene_component_map=h.scene_component_map
a(N,b.create_fingerprints("TS0726",{"_TZ3002_l8bfzlcd","_TZ3000_ovbvmhiq"}))a(O,b.create_fingerprints("TS0726",{"_TZ3002_1s0vfmtv","_TZ3002_gdwja9a7","_TZ3002_u7d3nes3","_TZ3000_icoxotza"}))a(x,b.create_fingerprints("TS0726",{"_TZ3002_9vcekkp1","_TZ3000_m4ah6bcz"}))a(l,{b.create_fingerprint("_TZ3000_wopf2sox","TS0726")})a(m,b.create_fingerprints("TS0726",{"_TZ3000_ssup6h68"}))a(u,b.create_fingerprints("TS0726",{"_TZ3000_m3pafcnk","_TZ3002_m3pafcnk"}))a(h,b.create_fingerprints("TS0726",{"_TZ3000_kt6xxa4o"}))a(i,b.create_fingerprints("TS0726",{"_TZ3002_vaq2bfcu"}))a(w,b.create_fingerprints("TS0726",{"_TZ3002_aewsvjcu","_TZ3002_phu8ygaw"}))a(p,b.create_fingerprints("TS0726",{"_TZ3000_qhyadm57","_TZ3000_cumqn2av","_TZ300A_fhbcipep"}))a(t,b.create_fingerprints("TS0726",{"_TZ3002_sal078g8","_TZ3002_sfh0jtz0"}))a(d,b.create_fingerprints("TS0726",{"_TZ300A_82iab0pn","_TZ300A_57kqwetw"}))a(H,b.create_fingerprints("TS0726",{"_TZ3000_lcjsewlo","_TZ3000_kfkqkjqe"}))a(J,b.create_fingerprints("TS0726",{"_TZ3000_wsspgtcd","_TZ3000_s678wazd","_TZ3002_uu4uircb","_TZ3002_yptomml1","_TZ3002_pw4ad2xa"}))a(K,b.create_fingerprints("TS0726",{"_TZ3000_5kxl9esg","_TZ3002_jn2x20tg","_TZ300A_rncj86af","_TZ3002_xkxgfxsg"}))a(L,b.create_fingerprints("TS0726",{"_TZ3000_ezqbvrqz","_TZ3002_ymv5vytn","_TZ3002_6ahhkwyh","_TZ3002_zjuvw9zf","_TZ3002_a4kvf6zd","_TZ300A_ohjmifiz","_TZ3002_tlsvxhxc"}))a(D,b.create_fingerprints("TS0726",{"_TZ3000_noru9tix","_TZ3002_rbnycsav","_TZ3002_kq3kqwjt","_TZ3002_ybtqbyk3","_TZ3002_iedhxgyi","_TZ3002_vsom92pp","_TZ300A_vqrs45nj","_TZ3000_cziew6eu","_TZ3000_r2fgo9ks"}))a(G,b.create_fingerprints("TS0726",{"_TZ3000_rsylfthg","_TZ3002_umdkr64x","_TZ3002_hkaktryd","_TZ3002_pzao9ls1","_TZ300A_vkflnsl0","_TZ3002_eda6eitk","_TZ3000_hurauima","_TZ3002_tdf2m4ch"}))a(N,b.create_fingerprints("TS0726_1_gang",{"_TZ3002_l8bfzlcd"}))a(O,b.create_fingerprints("TS0726_2_gang",{"_TZ3002_1s0vfmtv","_TZ3002_gdwja9a7","_TZ3002_u7d3nes3","_TZ3000_icoxotza"}))a(x,b.create_fingerprints("TS0726_multi_1_gang",{"_TZ3002_9vcekkp1","_TZ3000_m4ah6bcz"}))a(l,b.create_fingerprints("TS0726_multi_1_gang",{"_TZ3000_wopf2sox"}))a(m,b.create_fingerprints("TS0726_multi_2_gang",{"_TZ3000_ssup6h68"}))a(u,b.create_fingerprints("TS0726_multi_3_gang",{"_TZ3000_m3pafcnk","_TZ3002_m3pafcnk"}))a(h,b.create_fingerprints("TS0726_multi_3_gang",{"_TZ3000_kt6xxa4o"}))a(i,b.create_fingerprints("TS0726_multi_3_gang",{"_TZ3002_vaq2bfcu"}))a(w,b.create_fingerprints("TS0726_multi_4_gang",{"_TZ3002_aewsvjcu","_TZ3002_phu8ygaw"}))a(p,b.create_fingerprints("TS0726_4_gang_switch_and_2_scene",{"_TZ3000_qhyadm57","_TZ3000_cumqn2av","_TZ300A_fhbcipep"}))a(H,b.create_fingerprints("TS0726_3_gang",{"_TZ3000_lcjsewlo","_TZ3000_kfkqkjqe"}))a(J,b.create_fingerprints("TS0726_4_gang",{"_TZ3000_wsspgtcd","_TZ3000_s678wazd","_TZ3002_uu4uircb","_TZ3002_yptomml1","_TZ3002_pw4ad2xa"}))a(t,b.create_fingerprints("TS0726_switch_4g_2s",{"_TZ3002_sal078g8","_TZ3002_sfh0jtz0"}))a(K,b.create_fingerprints("TS0726_1_gang_scene_switch",{"_TZ3000_5kxl9esg","_TZ3002_jn2x20tg","_TZ300A_rncj86af","_TZ3002_xkxgfxsg"}))a(L,b.create_fingerprints("TS0726_2_gang_scene_switch",{"_TZ3000_ezqbvrqz","_TZ3002_ymv5vytn","_TZ3002_6ahhkwyh","_TZ3002_zjuvw9zf","_TZ3002_a4kvf6zd","_TZ300A_ohjmifiz","_TZ3002_tlsvxhxc"}))a(D,b.create_fingerprints("TS0726_3_gang_scene_switch",{"_TZ3000_noru9tix","_TZ3002_rbnycsav","_TZ3002_kq3kqwjt","_TZ3002_ybtqbyk3","_TZ3002_iedhxgyi","_TZ3002_vsom92pp","_TZ300A_vqrs45nj","_TZ3000_r2fgo9ks"}))a(G,b.create_fingerprints("TS0726_4_gang_scene_switch",{"_TZ3000_rsylfthg","_TZ3002_umdkr64x","_TZ3002_hkaktryd","_TZ3002_pzao9ls1","_TZ300A_vkflnsl0","_TZ3002_eda6eitk","_TZ3000_hurauima","_TZ3002_tdf2m4ch"}))y.attach_reporting_capabilities(s,{{1,"rpt-tmrj"},{2,"rpt-tnb",{zr000600001="Switch",zr000600002="SwitchTwo"}},{3,"rpt-tmrj"},{4,"rpt-tmrj"},{5,"rpt-tnb",{zr000600001="Switch",zr000600002="SwitchTwo"}},{6,"rpt-tyi",{zr000600001="Switch",zr000600002="SwitchTwo",zr000600003="SwitchThree"}},{7,"rpt-tyi",{zr000600001="Switch",zr000600002="SwitchTwo",zr000600003="SwitchThree"}},{8,"rpt-tyi",{zr000600001="Switch",zr000600002="SwitchTwo",zr000600003="SwitchThree"}},{9,"rpt-tql",{zr000600001="Switch",zr000600002="SwitchTwo",zr000600003="SwitchThree",zr000600004="SwitchFour"}},{10,"rpt-thq",{zr000600001="Switch",zr000600002="SwitchTwo",zr000600003="SwitchThree",zr000600004="SwitchFour"}},{11,"rpt-tbc",{zr000600001="Switch",zr000600002="SwitchTwo",zr000600003="SwitchThree",zr000600004="SwitchFour"}},{13,"rpt-tyi",{zr000600001="Switch",zr000600002="SwitchTwo",zr000600003="SwitchThree"}},{14,"rpt-tql",{zr000600001="Switch",zr000600002="SwitchTwo",zr000600003="SwitchThree",zr000600004="SwitchFour"}},{15,"rpt-tmrj"},{16,"rpt-tdp",{zr000600001="Switch",zr000600002="SwitchTwo"}},{17,"rpt-trv",{zr000600001="Switch",zr000600002="SwitchTwo",zr000600003="SwitchThree"}},{18,"rpt-tpu",{zr000600001="Switch",zr000600002="SwitchTwo",zr000600003="SwitchThree",zr000600004="SwitchFour"}},{19,"rpt-tmrj"},{20,"rpt-tnb",{zr000600001="Switch",zr000600002="SwitchTwo"}},{21,"rpt-tmrj"},{22,"rpt-tmrj"},{23,"rpt-tnb",{zr000600001="Switch",zr000600002="SwitchTwo"}},{24,"rpt-tyi",{zr000600001="Switch",zr000600002="SwitchTwo",zr000600003="SwitchThree"}},{25,"rpt-tyi",{zr000600001="Switch",zr000600002="SwitchTwo",zr000600003="SwitchThree"}},{26,"rpt-tyi",{zr000600001="Switch",zr000600002="SwitchTwo",zr000600003="SwitchThree"}},{27,"rpt-tql",{zr000600001="Switch",zr000600002="SwitchTwo",zr000600003="SwitchThree",zr000600004="SwitchFour"}},{28,"rpt-thq",{zr000600001="Switch",zr000600002="SwitchTwo",zr000600003="SwitchThree",zr000600004="SwitchFour"}},{29,"rpt-tyi",{zr000600001="Switch",zr000600002="SwitchTwo",zr000600003="SwitchThree"}},{30,"rpt-tql",{zr000600001="Switch",zr000600002="SwitchTwo",zr000600003="SwitchThree",zr000600004="SwitchFour"}},{31,"rpt-tbc",{zr000600001="Switch",zr000600002="SwitchTwo",zr000600003="SwitchThree",zr000600004="SwitchFour"}},{32,"rpt-tmrj"},{33,"rpt-tdp",{zr000600001="Switch",zr000600002="SwitchTwo"}},{34,"rpt-trv",{zr000600001="Switch",zr000600002="SwitchTwo",zr000600003="SwitchThree"}},{35,"rpt-tpu",{zr000600001="Switch",zr000600002="SwitchTwo",zr000600003="SwitchThree",zr000600004="SwitchFour"}}})return{id="zcl.controls.scene_switches",registrations=s}

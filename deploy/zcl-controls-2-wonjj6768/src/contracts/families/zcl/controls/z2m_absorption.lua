local g,e,J,h,k,cf,X,c,Q,cO,cL=require"protocol.zcl",require"contracts.helpers.family",require"contracts.helpers.zcl",require"capabilities.events.all",require"st.capabilities",require"runtime.capability_support".is_callable,require"st.zigbee.device_management",require"st.zigbee.data_types",require"st.zigbee.cluster_base",require"st.buf",require"st.json"
local au,d=e.definition_registry()local aX,O,bk,ag,bK,Z=5,18,85,{pushed=k.button.button.pushed,double=k.button.button.double,held=k.button.button.held,up=k.button.button.up,down=k.button.button.down,up_hold=k.button.button.up_hold,down_hold=k.button.button.down_hold},{[0]="hold",[1]="single",[2]="double",[3]="triple",[4]="quadruple",[5]="quintuple",[300]="N/A",[255]="release"},{single="pushed",double="double",hold="held"}



local function S(G)
if type(G)~="number"then return G end
local bb=math.floor((((G-2.0)/1.0)*100)+0.5)if bb<0 then return 0 end
if bb>100 then return 100 end
return bb
end
local by={profile="buttons-button-3-battery",button_actions={"pushed","double","held"},zcl_clusters={g.tuya_magic_packet(),g.cluster_attribute(g.CLUSTER_POWER_CONFIGURATION,g.ATTR_BATTERY_PERCENTAGE_REMAINING,{name="battery",endpoint=1,emit=h.battery(),scale=2}),g.cluster_attribute(g.CLUSTER_POWER_CONFIGURATION,g.ATTR_BATTERY_VOLTAGE,{name="battery",endpoint=1,emit=h.battery(),scale=10,from_device=S})}}d(by,{e.create_fingerprint("_TZ3000_9zc1ilmb","TS0043")})
local function ab(endpoint)
return endpoint==1 and"main"or("button"..tostring(endpoint))
end
local function bm(a,R,action)
local N=Z[action]local ch=N and ag[N]or nil
if not cf(ch)then
return
end
if type(a.supports_capability_by_id)=="function"and not a:supports_capability_by_id(k.button.ID,R)then
return
end
a:emit_component_event({id=R},ch{state_change=true})g.schedule_battery_refresh_after_button(a)
end
local function af(endpoint)
local R=ab(endpoint)return g.cluster_attribute(O,bk,{name="remote_action",endpoint=endpoint,component=R,emit=h.remote_action(),
from_device=function(value)
local action=bK[value]if action==nil then
return nil
end
return action.."_"..tostring(endpoint)
end,
handler=function(a,action)
if type(action)~="string"then
return
end
bm(a,R,action:match"^([^_]+)")
end
})
end
local function ap(aF,L)
for endpoint=1,L do
aF[#aF+1]=af(endpoint)end
end
local function aJ(aR,bM)
return function(r,a)
for endpoint=1,bM do
for _,v in ipairs(aR)do
a:send(X.build_bind_request(a,v,r.environment_info.hub_zigbee_eui,endpoint))end
end
end
end
local function j(B,...)
local cB=B and B.body and B.body.zcl_body or nil
if type(cB)~="table"then
return nil
end
for _,cD in ipairs{...}do
local value=cB[cD]if type(value)=="table"and value.value~=nil then
return value.value
end
if value~=nil then
return value
end
end
return nil
end
local bB={[0]={name="click",button_event="pushed"},[2]={name="double_click",button_event="double"},[4]={name="hold",button_event="held"}}
local function ay(x,L)
if type(x)=="table"and x.value~=nil then
x=x.value
end
if type(x)~="number"or x%1~=0 or
x<1 or x>(L*6)-1 then
return nil
end
local bH=(x-1)%6
local action=bB[bH]if action==nil then
return nil
end
local ax=math.floor((x-1)/6)+1
return{action="button_"..tostring(ax).."_"..action.name,button_event=action.button_event,component=ax==1 and"main"or("button"..tostring(ax))}
end
local function ac(L,ce)
return g.cluster_attribute(g.CLUSTER_IAS_ZONE,g.ATTR_ZONE_STATUS,{name="linxura_button_action_"..tostring(L),endpoint=1,read_only=true,command_id=0,
command_extractor=function(B)
return j(B,"zonestatus","zone_status")
end,
from_device=function(value)
return ay(value,L)
end,
handler=function(a,y)
if type(y)~="table"then
return
end
if type(a.supports_capability_by_id)=="function"and
not a:supports_capability_by_id(k.button.ID,y.component)then
return
end
a:emit_component_event({id=y.component},k.button.button(y.button_event,{state_change=true}))if ce then
g.schedule_battery_refresh_after_button(a)end
end
})
end
local function ah(r,a)
a:send(X.build_bind_request(a,g.CLUSTER_IAS_ZONE,r.environment_info.hub_zigbee_eui,1))
end
local bE,bF={profile="buttons-button-12-battery",button_actions={"pushed","double","held"},button_count=12,zcl_clusters={ac(12,true),g.battery{endpoint=1,minimum_interval=3600,maximum_interval=0,reportable_change=1,read_on_configure=true}},configure=ah},{profile="buttons-button-4",button_actions={"pushed","double","held"},button_count=4,zcl_clusters={ac(4,false)},configure=ah}d(bE,{e.create_fingerprint("Linxura","Aura Smart Button")})d(bF,{e.create_fingerprint("Linxura","Smart Controller")})
local function as(B,v,l,P)
if type(P)~="number"or P<1 or P>3 then
return nil,nil,true
end
local action
if v==g.CLUSTER_ON_OFF then
action=({[0]="off",[1]="on",[2]="toggle",[64]="off"})[l]elseif v==g.CLUSTER_LEVEL_CONTROL then
if l==0 or l==4 then
action="brightness_move_to_level"elseif l==1 or l==5 then
local az=j(B,"move_mode","movemode","mode")action=az==1 and"brightness_move_down"or"brightness_move_up"elseif l==2 or l==6 then
local az=j(B,"step_mode","stepmode","mode")action=az==1 and"brightness_step_down"or"brightness_step_up"elseif l==3 or l==7 then
action="brightness_stop"end
elseif v==g.CLUSTER_COLOR_CONTROL then
if l==75 then
action=({[0]="color_temperature_move_stop",[1]="color_temperature_move_up",[3]="color_temperature_move_down"})[j(B,"move_mode","movemode","mode")]elseif l==71 then
action="stop_move_step"elseif l==76 then
local az=j(B,"step_mode","stepmode","mode")action=az==1 and"color_temperature_step_up"or"color_temperature_step_down"elseif l==67 then
action="enhanced_move_to_hue_and_saturation"elseif l==6 then
action="move_to_hue_and_saturation"elseif l==2 then
local az=j(B,"step_mode","stepmode","mode")action=az==1 and"color_hue_step_up"or"color_hue_step_down"elseif l==5 then
local az=j(B,"step_mode","stepmode","mode")action=az==1 and"color_saturation_step_up"or"color_saturation_step_down"elseif l==68 then
action="color_loop_set"elseif l==10 then
action="color_temperature_move"elseif l==7 then
action="color_move"elseif l==1 then
action=({[1]="hue_move",[3]="hue_down"})[
j(B,"move_mode","movemode","mode")]or"hue_stop"elseif l==3 then
action="move_to_saturation"elseif l==0 then
action="move_to_hue"end
elseif v==aX then
local bi=j(B,"sceneid","scene_id")if l==0 then
action="add"elseif l==2 then
action="remove"elseif l==3 then
action="remove_all"elseif l==4 then
action=bi~=nil and("store_"..tostring(bi))or"store"elseif l==5 then
action=bi~=nil and("recall_"..tostring(bi))or"recall"end
end
return action,ab(P),true
end
local m={profile="buttons-button-3-battery-remote-action-slacky",button_actions={"pushed","double","held"},advanced_remote=true,button_count=3,standard_action_endpoint_suffix=true,standard_command_action_resolver=as,zcl_clusters={g.battery{endpoint=1,minimum_interval=3600,maximum_interval=14400,reportable_change=0,read_on_configure=true}}}ap(m.zcl_clusters,3)local aD,aL,V,ai={[0]="off",[1]="on",[2]="toggle"},{off=0,on=1,toggle=2},{[0]="toggle",[1]="momentary",[2]="multifunction",[3]="brightness_level",[4]="brightness_level_up",[5]="brightness_level_down",[6]="move_to_color_temperature",[7]="move_to_color_temperature_up",[8]="move_to_color_temperature_down",[9]="scene"},{}for cP,value in pairs(V)do ai[value]=cP end
local function av(bh,endpoint,p,v,aE,aq,cd,cv)
return g.cluster_attribute(v,aE,{name=bh,endpoint=endpoint,component=p,emit=aq,
from_device=function(value)return cd[value]end,
to_device=function(value)return cv[value]end,
data_type=c.Enum8,write_type=c.Enum8,read_on_configure=true})
end
local function D(bh,endpoint,p,v,aE,aq,aM)
return g.cluster_attribute(v,aE,{name=bh,endpoint=endpoint,component=p,emit=aq,data_type=aM,write_type=aM,read_on_configure=true})
end
local aZ={[1]={switch_action=h.slackyThreeSwitchActionOne(),switch_type=h.slackyThreeSwitchTypeOne(),scene_id=h.slackyThreeSceneIdOne(),group_id=h.slackyThreeGroupIdOne(),min_level=h.slackyThreeMinLevelOne(),max_level=h.slackyThreeMaxLevelOne()},[2]={switch_action=h.slackyThreeSwitchActionTwo(),switch_type=h.slackyThreeSwitchTypeTwo(),scene_id=h.slackyThreeSceneIdTwo(),group_id=h.slackyThreeGroupIdTwo(),min_level=h.slackyThreeMinLevelTwo(),max_level=h.slackyThreeMaxLevelTwo()},[3]={switch_action=h.slackyThreeSwitchActionThree(),switch_type=h.slackyThreeSwitchTypeThree(),scene_id=h.slackyThreeSceneIdThree(),group_id=h.slackyThreeGroupIdThree(),min_level=h.slackyThreeMinLevelThree(),max_level=h.slackyThreeMaxLevelThree()}}for endpoint=1,3 do
local cN=({"One","Two","Three"})[endpoint]local suffix,p,ar=cN:lower(),endpoint==1 and"main"or("button"..endpoint),aZ[endpoint]m.zcl_clusters[#m.zcl_clusters+1]=av("slacky3_switch_action_"..suffix,endpoint,p,7,16,ar.switch_action,aD,aL)m.zcl_clusters[#m.zcl_clusters+1]=av("slacky3_switch_type_"..suffix,endpoint,p,7,61440,ar.switch_type,V,ai)m.zcl_clusters[#m.zcl_clusters+1]=D("slacky3_scene_id_"..suffix,endpoint,p,5,61440,ar.scene_id,c.Uint8)m.zcl_clusters[#m.zcl_clusters+1]=D("slacky3_group_id_"..suffix,endpoint,p,5,61441,ar.group_id,c.Uint16)m.zcl_clusters[#m.zcl_clusters+1]=D("slacky3_min_level_"..suffix,endpoint,p,g.CLUSTER_LEVEL_CONTROL,2,ar.min_level,c.Uint8)m.zcl_clusters[#m.zcl_clusters+1]=D("slacky3_max_level_"..suffix,endpoint,p,g.CLUSTER_LEVEL_CONTROL,3,ar.max_level,c.Uint8)end
local aK={O,g.CLUSTER_ON_OFF,g.CLUSTER_LEVEL_CONTROL,g.CLUSTER_COLOR_CONTROL,aX}m.configure=aJ(aK,3)d(m,{e.create_fingerprint("Slacky-DIY","TS0043-z-SlD"),e.create_fingerprint("Slacky-DIY","TS0043-M007-SlD")})
local function bR(r,a,endpoint,aR)
for _,v in ipairs(aR)do
a:send(X.build_bind_request(a,v,r.environment_info.hub_zigbee_eui,endpoint))end
end
local bl={profile="controllers-candeo-rd1p-rem",advanced_remote=true,unprefixed_remote_actions=true,remote_action_emit_name="candeoRd1pRemAction",standard_command_action_resolver=J.resolve_rd1p_rotary_action,zcl_clusters={g.power{endpoint=1,minimum_interval=5,maximum_interval=300,reportable_change=10},g.voltage{endpoint=1,minimum_interval=5,maximum_interval=600,reportable_change=500},g.current{endpoint=1,minimum_interval=5,maximum_interval=900,reportable_change=10},g.energy{endpoint=1,minimum_interval=5,maximum_interval=1800,reportable_change=50}},
configure=function(r,a)
bR(r,a,2,{g.CLUSTER_ON_OFF,g.CLUSTER_LEVEL_CONTROL})
end
}d(bl,{e.create_fingerprint("Candeo","C-ZB-RD1Pv2-REM")})
local function Y(_,value)
if type(value)=="string"then
local bc=cO.Reader(value)while bc:remain()>1 do
local cD,bg=bc:read_u8(),bc:read_u8()local cs=bg==16 and 1 or
(bg>=32 and bg<=47 and((bg%8)+1))or
(bg==57 and 4)or(bg==58 and 8)if cs==nil or bc:remain()<cs then return nil end
if cD==1 then
value=c.parse_data_type(bg,bc).value
break
end
bc:seek(cs)end
elseif type(value)=="table"then
value=value[1]or value["1"]value=type(value)=="table"and value.value or value
end
if type(value)~="number"or value==0 then return nil end
local bb=math.max(0,math.min(100,((value-2850)*100)/150))return{k.battery.battery(math.floor(bb+0.5)),k.voltageMeasurement.voltage{value=value/1000,unit="V"}}
end
local br=h.aqH1Action()
local function aN(a,action)
local A=br(a,action)A.state_change=true
a:emit_component_event({id="main"},A)local N=Z[action]if N~=nil then
a:emit_component_event({id="main"},k.button.button(N,{state_change=true}))end
end
local function bs(value,_,U)
local cA=U.zb_rx.body.zcl_body.attr_records or{}for _,ad in ipairs(cA)do
if ad.attr_id.value==570 then
return type(value)=="table"and value.value or value
end
end
return nil
end
local aw={profile="controllers-aqara-h1",button_actions={"pushed","double","held"},zcl_clusters={g.cluster_attribute(18,85,{name="aq_h1_action",endpoint=1,read_only=true,handler=aN,
from_device=function(value)
return({[0]="hold",[1]="single",[2]="double",[255]="release"})[value]
end
}),g.cluster_attribute(64704,570,{name="aq_h1_action",endpoint=1,read_only=true,handler=aN,
from_device=function(value)
return({[1]="start_rotating",[2]="rotation",[3]="stop_rotating"})[value&~128]
end
}),g.cluster_attribute(64704,570,{name="aq_h1_rotation_button_state",endpoint=1,read_only=true,emit=h.aqH1RotationButtonState(),
from_device=function(value)return(value&128)==128 and"pressed"or"released"end
}),g.cluster_attribute(64704,1,{name="aq_h1_battery_voltage",endpoint=1,read_only=true,emit=Y}),g.cluster_attribute(64704,247,{name="aq_h1_battery_struct",endpoint=1,read_only=true,emit=Y}),g.cluster_attribute(64704,65281,{name="aq_h1_battery_nested",endpoint=1,read_only=true,emit=Y}),g.cluster_attribute(64704,9,{name="aq_h1_operation_mode",endpoint=1,write_only=true,mfg_code=4447,data_type=c.Uint8,write_type=c.Uint8,emit=h.aqH1OperationMode(),
to_device=function(value)return({event=1,command=0})[value]end
}),g.cluster_attribute(64704,564,{name="aq_h1_sensitivity",endpoint=1,data_type=c.Uint16,write_type=c.Uint16,emit=h.aqH1Sensitivity(),
from_device=function(value)return({[720]="low",[360]="medium",[180]="high"})[value]end,
to_device=function(value)return({low=720,medium=360,high=180})[value]end,
sender=function(a,z,value)
a:send(Q.write_manufacturer_specific_attribute(a,64704,564,4447,c.Uint16,z.to_device(value)):to_endpoint(1))
end
}),g.cluster_attribute(0,65520,{name="aq_h1_prevent_reset",endpoint=1,read_only=true,
handler=function(a,value,U)
if U.zb_rx.body.zcl_header.cmd.value==10 and
type(value)=="string"and value:sub(1,5)==string.char(170,16,5,65,135)then
a:send(Q.write_manufacturer_specific_attribute(a,0,65520,4447,c.OctetString,string.char(170,16,5,65,71,1,1,16,1)):to_endpoint(1))end
end
})},
configure=function(_,a)
a:send(Q.write_manufacturer_specific_attribute(a,64704,9,4447,c.Uint8,1):to_endpoint(1))g.read_attribute(a,64704,564,1)
end,
parent_refresh=function(a)
g.read_attribute(a,64704,9,1,4447)g.read_attribute(a,64704,564,1,4447)
end
}for _,cn in ipairs{{558,"aq_h1_rotation_angle",h.aqH1RotationAngle()},{560,"aq_h1_rotation_angle_speed",h.aqH1RotationAngleSpeed()},{563,"aq_h1_rotation_percent",h.aqH1RotationPercent()},{562,"aq_h1_rotation_percent_speed",h.aqH1RotationPercentSpeed()},{561,"aq_h1_rotation_time",h.aqH1RotationTime()}}do
aw.zcl_clusters[#aw.zcl_clusters+1]=g.cluster_attribute(64704,cn[1],{name=cn[2],endpoint=1,read_only=true,emit=cn[3],from_device=bs})end
d(aw,{e.create_fingerprint("LUMI","lumi.remote.rkba01")})local ba,aI={[1]="single_up",[2]="double_up",[3]="release_up",[4]="hold_up",[11]="single_down",[12]="double_down",[13]="release_down",[14]="hold_down"},{[1]="single_up",[2]="double_up",[3]="release_up",[4]="hold_up"}
local function E(endpoint,suffix,cH,cp,bh,aq)
local cg=cp and ba or aI
return g.cluster_attribute(18,85,{name=bh,endpoint=endpoint,read_only=true,
from_device=function(value)
return cg[value]and cg[value].."_"..suffix or nil
end,
handler=function(a,action)
local A=aq(a,action)A.state_change=true
a:emit_component_event({id="main"},A)local bg=action:match"^([^_]+)"local aa,p=({single="pushed",double="double",release="up",hold="held"})[bg],cp and action:find("_down_",1,true)and cp or cH
a:emit_component_event({id=p},ag[aa]{state_change=true})
end
})
end
local function w(a)
return a:get_endpoint(1)
end
local function W()
return{g.cluster_attribute(1,33,{name="battery",endpoint=w,component="main",read_only=true,data_type=c.Uint8,read_on_configure=true,minimum_interval=3600,maximum_interval=65000,reportable_change=10,
emit=function(a,value)
if value<255 then return h.battery()(a,value/2)end
end
}),g.cluster_attribute(1,32,{name="battery_voltage",endpoint=w,component="main",read_only=true,data_type=c.Uint8,
emit=function(a,value)
if value==255 then return nil end
local G,I=value*100,100

if G<2100 then I=0
elseif G<2440 then I=6-(2440-G)*6/340
elseif G<2740 then I=18-(2740-G)*12/300
elseif G<2900 then I=42-(2900-G)*24/160
elseif G<3000 then I=100-(3000-G)*58/100 end
return{h.battery()(a,math.floor(I+0.5)),h.voltage()(a,value/10)}
end
}),g.cluster_attribute(1,53,{name="battery_low",endpoint=w,component="main",read_only=true,data_type=c.Bitmap8,
emit=function(_,value)
return value==1 and k.batteryLevel.battery.critical()or k.batteryLevel.battery.normal()
end
})}
end
local function T(r,a)
g.bind_cluster(a,1,r.environment_info.hub_zigbee_eui,w(a))
end
local function ae(a)
for _,o in ipairs{33,32}do
g.read_attribute(a,1,o,w(a))end
end
local function u(cy)
local aF={}for _,aQ in ipairs(cy)do
local H={endpoint=aQ[1],component=aQ[2],configure_reporting=false}J.append_clusters(aF,g.switch(H),g.level{endpoint=aQ[1],component=aQ[2],configure_reporting=false},g.color_hue{endpoint=aQ[1],component=aQ[2],configure_reporting=false},g.color_saturation{endpoint=aQ[1],component=aQ[2],configure_reporting=false},g.color{endpoint=aQ[1],component=aQ[2]})end
return aF
end
local function C(q,cy,ca,cC)
q.auto_on_before_light_command=false
for _,bS in ipairs(ca)do
q.zcl_clusters[#q.zcl_clusters+1]=g.switch{endpoint=bS[1],component=bS[2],minimum_interval=0,maximum_interval=65000}end
q.configure=function(r,a)
for endpoint in pairs(a.zigbee_endpoints)do
if a:supports_server_cluster(768,endpoint)then
for _,o in ipairs{16394,16395,16396}do
g.read_attribute(a,768,o,endpoint)end
end
if #ca>0 and a:supports_server_cluster(6,endpoint)then
g.bind_cluster(a,6,r.environment_info.hub_zigbee_eui,endpoint)g.read_attribute(a,6,0,endpoint)end
end
end
q.parent_refresh=function(a)
for _,aQ in ipairs(cy)do
g.read_attribute(a,6,0,aQ[1])g.read_attribute(a,8,0,aQ[1])for _,o in ipairs{0,1,3,4,8}do
g.read_attribute(a,768,o,aQ[1])end
end
for _,bS in ipairs(ca)do g.read_attribute(a,6,0,bS[1])end
if cC then
g.read_attribute(a,6,0,3)for _,o in ipairs{0,16,18,19,17,16384,15}do
g.read_attribute(a,8,o,3)end
end
end
end
local aT={profile="controllers-streda-bn0s",button_actions={"pushed","double","held","up"},component_to_endpoint_map={main=3,button1Down=3},zcl_clusters=W(),configure=T,parent_refresh=ae}aT.zcl_clusters[#aT.zcl_clusters+1]=
E(3,"button_1","main","button1Down","streda_bn0s_action",h.stredaBn0sAction())d(aT,{e.create_fingerprint("TKHTechnology","BN0-S-03/PW")})local aU={profile="controllers-streda-bn0t",button_actions={"pushed","double","held","up"},component_to_endpoint_map={main=3,button1Down=3,button2Up=4,button2Down=4},zcl_clusters=W(),configure=T,parent_refresh=ae}for index,endpoint in ipairs{3,4}do
aU.zcl_clusters[#aU.zcl_clusters+1]=E(endpoint,"button_"..index,index==1 and"main"or"button2Up","button"..index.."Down","streda_bn0t_action",h.stredaBn0tAction())end
d(aU,{e.create_fingerprint("TKHTechnology","BN0-T-03/PW")})local bu={profile="controllers-streda-led1",zcl_clusters=u{{2,"main"}}}C(bu,{{2,"main"}},{})d(bu,{e.create_fingerprint("TKHTechnology","BN1-1-03/PW"),e.create_fingerprint("TKHTechnology","BN3-110-03/PW")})local bv={profile="controllers-streda-led2",zcl_clusters=u{{2,"main"},{4,"led2"}}}C(bv,{{2,"main"},{4,"led2"}},{})d(bv,{e.create_fingerprint("TKHTechnology","DF3-11R-03/PW")})local bd={profile="controllers-streda-ceiling",zcl_clusters=u{{2,"main"},{4,"led2"}}}C(bd,{{2,"main"},{4,"led2"}},{{3,"outlet"}})d(bd,{e.create_fingerprint("TKHTechnology","BN1-C-03/PW"),e.create_fingerprint("TKHTechnology","HN1-CW-4-03/PW")})local ao={profile="controllers-streda-sn2",zcl_clusters=u{{2,"main"},{4,"led2"}},capability_commands={{capability_id="concertmirror08464.stredaSn2OnLevel",command_name="usePreviousOnLevel",mapping_name="streda_sn2_on_level",value="previous"},{capability_id="concertmirror08464.stredaSn2StartupLevel",command_name="useMinimumStartupLevel",mapping_name="streda_sn2_startup_level",value="minimum"},{capability_id="concertmirror08464.stredaSn2StartupLevel",command_name="usePreviousStartupLevel",mapping_name="streda_sn2_startup_level",value="previous"},{capability_id="concertmirror08464.stredaSn2OnTransitionTime",command_name="disableOnTransitionTime",mapping_name="streda_sn2_on_transition_time",value="disabled"},{capability_id="concertmirror08464.stredaSn2OffTransitionTime",command_name="disableOffTransitionTime",mapping_name="streda_sn2_off_transition_time",value="disabled"}}}J.append_clusters(ao.zcl_clusters,g.switch{endpoint=3,component="dimmer",configure_reporting=false},g.level{endpoint=3,component="dimmer",configure_reporting=false})for _,bO in ipairs{{18,"streda_sn2_on_transition_time",h.stredaSn2OnTransitionTime()},{19,"streda_sn2_off_transition_time",h.stredaSn2OffTransitionTime()},{15,"streda_sn2_execute_if_off",h.stredaSn2ExecuteIfOff()},{17,"streda_sn2_on_level",h.stredaSn2OnLevel()},{16384,"streda_sn2_startup_level",h.stredaSn2StartupLevel()},{16,"streda_sn2_on_off_transition_time",h.stredaSn2OnOffTransitionTime()}}do
local o=bO[1]local bN=o==16 or o==18 or o==19
ao.zcl_clusters[#ao.zcl_clusters+1]=g.cluster_attribute(8,o,{name=bO[2],endpoint=3,component="dimmer",emit=bO[3],data_type=bN and c.Uint16 or o==15 and c.Bitmap8 or c.Uint8,prefer_plain_attribute_write=true,
from_device=function(value)
value=type(value)=="table"and value.value or value
if o==15 then return(value&1)==1 and"on"or"off"end
return bN and value/10 or value
end,
to_device=function(value)
if o==15 then return value=="on"and 1 or 0 end
if value=="disabled"then return 65535 end
if value=="previous"then return 255 end
if value=="minimum"then return 0 end
if bN then return math.max(0,math.min(65535,math.floor(value*10+0.5)))end
return math.max(o==17 and 1 or 0,math.min(255,math.floor(value+0.5)))
end
})end
C(ao,{{2,"main"},{4,"led2"}},{},true)d(ao,{e.create_fingerprint("TKHTechnology","SN2-E-03/PW")})local bI,aV={profile="controllers-streda-sn3",zcl_clusters=u{{2,"main"}},button_actions={"pushed","double","held","up"},component_to_endpoint_map={main=2,socket=3,light=7,button1Up=4,button1Down=4,button2Up=5,button2Down=5}},{profile="controllers-streda-sn3k",zcl_clusters=u{{2,"main"}},button_actions={"pushed","double","held","up"},component_to_endpoint_map={main=2,socket=3,light=7,button1Up=4,button1Down=4,button2Up=5,button2Down=5,doorbellButton=8}}for _,bD in ipairs{{bI,"streda_sn3",h.stredaSn3Action(),h.stredaSn3Doorbell()},{aV,"streda_sn3k",h.stredaSn3kButtonAction(),h.stredaSn3kDoorbell()}}do
local q,bZ,action=bD[1],bD[2],bD[3]for index,endpoint in ipairs{4,5}do
q.zcl_clusters[#q.zcl_clusters+1]=E(endpoint,"button_"..index,"button"..index.."Up","button"..index.."Down",bZ.."_action",action)end
if q==aV then
q.zcl_clusters[#q.zcl_clusters+1]=E(8,"doorbell_button","doorbellButton",nil,bZ.."_action",action)end
q.zcl_clusters[#q.zcl_clusters+1]=g.cluster_attribute(6,65535,{name=bZ.."_doorbell",component="main",write_only=true,suppress_optimistic_state=true,
emit=bD[4],sender=function(a)
local bq=g.get_generated_cluster(6).commands.On(a):to_endpoint(6)bq.body.zcl_header.frame_ctrl:set_disable_default_response()a:send(bq)
end
})C(q,{{2,"main"}},{{3,"socket"},{7,"light"}})end
d(bI,{e.create_fingerprint("TKHTechnology","SN3-1TB5-03/PW"),e.create_fingerprint("TKHTechnology","HNB-W-1TB5-03/PW")})d(aV,{e.create_fingerprint("TKHTechnology","SN3-1TB5K-03/PW"),e.create_fingerprint("TKHTechnology","HNB-W-1TB5K-03/PW")})local bw,aH={[0]="hold",[1]="single",[2]="double",[3]="triple",[4]="quadruple",[255]="release"},{hold="held",single="pushed",double="double",triple="pushed_3x",quadruple="pushed_4x",release="up"}local aW={profile="buttons-third-reality-3rsb22bz",button_actions={"pushed","double","held","pushed_3x","pushed_4x","up"},button_count=1,zcl_clusters={g.cluster_attribute(18,85,{name="r3sb22bz_action",endpoint=1,read_only=true,
from_device=function(value)
if value==nil then return nil end
return bw[value]or"many"
end,
handler=function(a,action)
local A=h.r3sb22bzAction()(a,action)A.state_change=true
a:emit_component_event({id="main"},A)local aa=aH[action]if aa then
a:emit_component_event({id="main"},k.button.button(aa,{state_change=true}))end
end
}),g.cluster_attribute(1,33,{name="battery",endpoint=1,read_only=true,data_type=c.Uint8,minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true,emit=h.battery(),
from_device=function(value)
if value<255 then return value/2 end
end
})},
configure=function(r,a)
g.bind_cluster(a,1,r.environment_info.hub_zigbee_eui,1)
end,
parent_refresh=function(a)
g.read_attribute(a,1,33,1)g.read_attribute(a,1,32,1)return true
end
}d(aW,{e.create_fingerprint("Third Reality, Inc","3RSB22BZ")})
local function be(B,a,z)
local t,command,cQ=z.cluster_id,z.command_id,B.body.zcl_header.seqno.value

local bX=tostring(t)..":"..tostring(command)..":"..tostring(cQ)if a:get_field"__sunricher_cct_last_command"==bX then return end
a:set_field("__sunricher_cct_last_command",bX)local action,p,aa=nil,"main","pushed"if t==6 then
action=({[0]="off",[1]="on",[2]="toggle",[64]="off"})[command]p=action=="off"and"offButton"or"main"elseif t==8 or t==768 then
local az=j(B,"step_mode","stepmode")local up=t==8 and az~=1 or t==768 and az==1
action=(t==8 and"brightness_step_"or"color_temperature_step_")..(up and"up"or"down")p=(t==8 and"brightness"or"temperature")..(up and"Up"or"Down")local cq=j(B,"step_size","stepsize")if cq~=nil then
a:emit_event(h.srCctStepSize()(a,cq))if t==768 then
a:emit_event(h.srCctTemperatureDelta()(a,up and cq or-cq))end
end
local bJ=j(B,"transition_time","transtime")if bJ~=nil then a:emit_event(h.srCctTransitionTime()(a,bJ/10))end
elseif t==5 then
local bT=j(B,"scene_id","sceneid")if bT==nil then return end
action=(command==4 and"store_"or"recall_")..tostring(bT)p=bT==1 and"sceneOne"or bT==2 and"sceneTwo"or nil
aa=command==4 and"held"or"pushed"end
local A=h.srCctAction()(a,action)A.state_change=true
a:emit_event(A)if p then
a:emit_component_event({id=p},k.button.button(aa,{state_change=true}))end
local bf=B.address_header.dest_addr.value
if bf>=1 and bf<=65527 then a:emit_event(h.srCctGroup()(a,bf))end
end
local aB={profile="buttons-sunricher-cct",button_actions={"pushed","held"},zcl_clusters={g.cluster_attribute(1,33,{name="battery",endpoint=1,read_only=true,data_type=c.Uint8,minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=true,
emit=h.battery(),from_device=function(value)if value<255 then return value/2 end end
})},
configure=function(r,a)
for _,t in ipairs{1,6,8,768,5}do
g.bind_cluster(a,t,r.environment_info.hub_zigbee_eui,1)end
end,
parent_refresh=function(a)g.read_attribute(a,1,33,1)end
}for _,item in ipairs{{6,0},{6,1},{6,2},{6,64},{8,2},{8,6},{768,76},{5,4},{5,5}}do
aB.zcl_clusters[#aB.zcl_clusters+1]=g.cluster_attribute(item[1],nil,{name="sr_cct_action",endpoint=1,read_only=true,command_id=item[2],command_extractor=be})end
d(aB,{e.create_fingerprint("Sunricher","ZGRC-KEY-008")})
local function aj(a)
local bq=Q.write_attribute(a,c.ClusterId(64512),c.AttributeId(16),c.Uint32(os.time()-946684800))a:send(bq:to_endpoint(10))return true
end
local K={{4200,200},{4180,196},{4160,192},{4140,188},{4120,184},{4100,180},{4080,176},{4060,171},{4040,166},{4020,160},{4000,154},{3980,148},{3960,142},{3940,135},{3920,128},{3900,120},{3880,112},{3860,104},{3840,96},{3820,88},{3800,80},{3780,72},{3760,64},{3740,56},{3720,48},{3700,40},{3680,32},{3660,25},{3640,19},{3620,14},{3600,10},{3580,7},{3560,5},{3540,3},{3520,2},{3500,1},{3400,0}}
local function bC(value)
if value<2500 or value>4400 then return nil end
if value>=4200 then return 100 end
for index=2,#K do
local cw,ci=K[index-1],K[index]if value>=ci[1]then
return(ci[2]+math.floor(((value-ci[1])*(cw[2]-ci[2])+math.floor((cw[1]-ci[1])/2))/(cw[1]-ci[1])))/2
end
end
return 0
end
local function at(value,a,U)
if value<=0 or value>=0xFFFFFFFF then return"—"end
local bH=a:get_field"airwick_timezone_minutes"or 180
for _,ad in ipairs(U.zb_rx.body.zcl_body.attr_records or{})do
if ad.attr_id.value==6 and ad.data then bH=ad.data.value end
end
return os.date("!%d.%m.%Y %H:%M",value+946684800+bH*60)
end
local function aC(value)
if value<0 or value>1439 then return"—"end
return string.format("%02d:%02d",math.floor(value/60),value%60)
end
local function ak(value)
local cx,cu=value:match"^%s*(%d%d?):(%d%d)%s*$"if cx==nil or tonumber(cx)>23 or tonumber(cu)>59 then return nil end
return tonumber(cx)*60+tonumber(cu)
end
local function n(o,bh,aq,aM,H)
H=H or{}H.name=bh;H.endpoint=10;H.emit=aq;H.data_type=aM
H.read_on_configure=not H.write_only
H.prefer_plain_attribute_write=true
return g.cluster_attribute(64512,o,H)
end
local bL={profile="controllers-airwick",magic_packet=false,component_to_endpoint_map={main=10},
configure=function(r,a)
g.bind_cluster(a,64512,r.environment_info.hub_zigbee_eui,10)aj(a)
end,
runtime_start=function(a)
a.thread:call_with_delay(0.8,function()aj(a)end)
end,
announce_handler=function(a)
a.thread:call_with_delay(1.2,function()aj(a)end)
end,
capability_commands={{capability_id="concertmirror08464.airwickSpray",command_name="spray",value=true,mapping_name="airwick_spray"},{capability_id="concertmirror08464.airwickResetCounter",command_name="reset",value=true,mapping_name="airwick_reset_counter"}},zcl_clusters={
n(0,"airwick_mode",function(a,value)
return{h.airwickMode()(a,value),h.airwickScheduleInfo()(a,"Mon–Fri 07:00–22:00; Sat–Sun 09:00–22:00; every 30 min; duration is configured separately")}
end,c.Enum8,{read_only=true,minimum_interval=0,maximum_interval=3600,
from_device=function(value)return({[0]="OFF","AUTO","SCHEDULE","PROGRAMMABLE"})[value]or"UNKNOWN"end}),
n(1,"airwick_auto_interval",h.airwickAutoInterval(),c.Uint16),n(6,"airwick_time_zone",h.airwickTimeZone(),c.Int16,{scale=60,
from_device=function(value,a)a:set_field("airwick_timezone_minutes",value*60,{persist=true});return value end}),
n(7,"airwick_spray_count",h.airwickSprayCount(),c.Uint32,{read_only=true,minimum_interval=0,maximum_interval=3600,reportable_change=1}),n(8,"airwick_last_reason",h.airwickLastReason(),c.Uint8,{read_only=true,minimum_interval=0,maximum_interval=3600,reportable_change=1,
from_device=function(value)return({[0]="None","Zigbee","Button","AUTO","SCHEDULE","PROGRAM"})[value]end}),
n(9,"airwick_last_spray",h.airwickLastSpray(),c.UtcTime,{read_only=true,minimum_interval=0,maximum_interval=3600,reportable_change=1,from_device=at}),n(10,"airwick_next_spray",h.airwickNextSpray(),c.UtcTime,{read_only=true,minimum_interval=0,maximum_interval=3600,reportable_change=1,from_device=at}),n(11,"airwick_time_valid",h.airwickTimeValid(),c.Boolean,
{read_only=true,minimum_interval=0,maximum_interval=3600,from_device=function(value,a)
if not value and os.time()-(a:get_field"airwick_last_sync_attempt"or 0)>=60 then
a:set_field("airwick_last_sync_attempt",os.time());aj(a)end
return value and"ON"or"OFF"
end}),
n(14,"airwick_reset_counter",nil,c.Boolean,{write_only=true,
sender=function(a)
a:send(Q.write_attribute(a,c.ClusterId(64512),c.AttributeId(14),c.Boolean(true)):to_endpoint(10))a:emit_component_event({id="main"},h.airwickSprayCount()(a,0))return true
end}),
n(17,"airwick_battery_level",function(a,value)
local bW,cz={h.voltage()(a,value/1000)},bC(value)if cz then bW[#bW+1]=h.airwickBatteryLevel()(a,cz)end
return bW
end,c.Uint16,{read_only=true,minimum_interval=30,maximum_interval=3600,reportable_change=10}),
n(18,"airwick_duration",h.airwickDuration(),c.Uint16),g.cluster_attribute(6,nil,{name="airwick_spray",endpoint=10,write_only=true,
sender=function(a)return g.send_raw_cluster_command(a,6,1,"",10)end})
}}for index,day in ipairs{"Mon","Tue","Wed","Thu","Fri","Sat","Sun"}do
local cJ=32+(index-1)*8
for _,item in ipairs{{0,"Enabled",c.Boolean,
function(value)return value and"ON"or"OFF"end,
function(value)return value=="ON"end},
{2,"Start",c.Uint16,aC,ak},{3,"End",c.Uint16,aC,ak},{4,"Interval",c.Uint16}}do
bL.zcl_clusters[#bL.zcl_clusters+1]=n(cJ+item[1],"airwick_"..day:lower().."_"..item[2]:lower(),h["airwick"..day..item[2]](),item[3],{from_device=item[4],to_device=item[5]})end
end
d(bL,{e.create_fingerprint("DIY","AirWick_nRF52840")})local bQ,bU={[0]="zigbee",[2]="keypad",[3]="fingerprintsensor",[4]="rfid",[5]="unattributed",[10]="self"},{LastLockUser=h.nimlyCodeLastLockUser(),LastUnlockUser=h.nimlyCodeLastUnlockUser(),LastLockSource=h.nimlyCodeLastLockSource(),LastUnlockSource=h.nimlyCodeLastUnlockSource(),Action=h.nimlyCodeAction(),ActionUser=h.nimlyCodeActionUser(),ActionSource=h.nimlyCodeActionSource(),EventSource=h.nimlyCodeEventSource(),Pin=h.nimlyCodePin()}
local function s(a,bh,value)
local A=bU[bh](a,value)if A then A.state_change=true;a:emit_component_event({id="main"},A)end
end
local function bY(value,a)
local bp,action=bQ[(value>>24)&255]or"unknown",({[1]="Lock",[2]="Unlock"})[(value>>16)&255]if not action then return end
local cc=value&65535
s(a,"Last"..action.."User",tostring(cc))s(a,"Last"..action.."Source",bp)s(a,"Action",action:lower());s(a,"ActionUser",cc)s(a,"ActionSource",bp)
end
local function bA(value,a,U)
local cj=a:get_field"nimly_min_pin_length"or 4
for _,ad in ipairs(U.zb_rx.body.zcl_body.attr_records or{})do
if ad.attr_id.value==24 and ad.data and ad.data.value>0 then cj=ad.data.value end
end
value=value:gsub("%z+$","")if #value>=cj and value:match"^%d+$"then return value end
local bV={}for index=1,#value do
local cm=value:byte(index)if cm>>4>9 or cm&15>9 then
return(value:gsub(".",function(ct)return string.format("%02x",ct:byte())end))
end
bV[#bV+1]=tostring(cm>>4)..tostring(cm&15)end
return table.concat(bV)
end
local function bG(a,_,value)
local y=cL.decode(value)if type(y)~="table"or type(y.user)~="number"or y.user%1~=0 or y.user<0 or y.user>=50 then return false end
local payload,command=string.pack("<I2",y.user),7
if y.pin_code~=nil then
local pin=tostring(y.pin_code)if not pin:match"^%d+$"then return false end
local bP=({unrestricted=0,year_day_schedule=1,week_day_schedule=2,master=3,non_access=4})[y.user_type or"unrestricted"]if not bP then return false end
command=5;payload=payload..string.char(y.user_enabled==false and 3 or 1,bP,#pin)..pin
end
a:set_field("nimly_pending_pin_user",y.user)a:set_field("nimly_pending_pin_value",value)return g.send_raw_cluster_command(a,257,command,payload,11)
end
local function bo(command)
return function(rx,a)
local cc,value=a:get_field"nimly_pending_pin_user",a:get_field"nimly_pending_pin_value"a:set_field("nimly_pending_pin_user",nil);a:set_field("nimly_pending_pin_value",nil)if j(rx,"status")~=0 then return end
s(a,"Action",command==5 and"pin_code_added"or"pin_code_deleted")if cc~=nil then s(a,"ActionUser",cc)end
if value then s(a,"Pin",value)end
end
end
local aG,aY={[0]="unknown","lock","unlock","lock_failure_invalid_pin_or_id","lock_failure_invalid_schedule","unlock_failure_invalid_pin_or_id","unlock_failure_invalid_schedule","one_touch_lock","key_lock","key_unlock","auto_lock","schedule_lock","schedule_unlock","manual_lock","manual_unlock","non_access_user_operational_event"},{[0]="unknown","master_code_changed","pin_code_added","pin_code_deleted","pin_code_changed","rfid_code_added","rfid_code_deleted"}
local function bn(aS)
return function(rx,a)
local bp,cK=j(rx,aS and"program_event_source"or"operation_event_source"),j(rx,aS and"program_event_code"or"operation_event_code")s(a,"Action",(aS and aY or aG)[cK])s(a,"ActionUser",j(rx,"user_id"))s(a,"EventSource",bp)s(a,"ActionSource",({[0]="keypad","rf","manual","rfid","fingerprint"})[bp])
end
end
local am={profile="locks-nimly-code-pro",magic_packet=false,component_to_endpoint_map={main=11},capability_commands={{capability_id="lock",command_name="lock",value=1,mapping_name="nimly_lock"},{capability_id="lock",command_name="unlock",value=0,mapping_name="nimly_lock"}},
configure=function(r,a)
for _,t in ipairs{257,1}do g.bind_cluster(a,t,r.environment_info.hub_zigbee_eui,11)end
end,
zcl_clusters={g.cluster_attribute(257,0,{name="nimly_lock_state",endpoint=11,read_only=true,data_type=c.Enum8,minimum_interval=0,maximum_interval=3600,reportable_change=0,read_on_configure=true,
from_device=function(value)
value=type(value)=="table"and value.value or value
return({[0]="not fully locked","locked","unlocked"})[value]
end,
emit=function(_,value)return k.lock.lock(value)end}),
g.cluster_attribute(257,nil,{name="nimly_lock",endpoint=11,write_only=true,
sender=function(a,_,value)return g.send_raw_cluster_command(a,257,value==1 and 0 or 1,"\0",11)end}),
g.battery{endpoint=11,scale=1,read_only=true,minimum_interval=3600,maximum_interval=65000,reportable_change=10,read_on_configure=false,
from_device=function(value)if value~=255 then return value end end},
g.cluster_attribute(1,32,{name="nimly_voltage",endpoint=11,data_type=c.Uint8,read_only=true,minimum_interval=3600,maximum_interval=65000,reportable_change=0,read_on_configure=false,scale=10,emit=h.voltage()}),g.cluster_attribute(257,256,{name="nimly_code_action",endpoint=11,data_type=c.Uint32,read_only=true,
read_on_configure=false,handler=function(a,value)bY(value,a)end}),
g.cluster_attribute(257,257,{name="nimly_code_lastPin",endpoint=11,data_type=c.OctetString,read_only=true,read_on_configure=false,from_device=bA,emit=h.nimlyCodeLastPin()}),g.cluster_attribute(257,36,{name="nimly_code_sound_volume",endpoint=11,data_type=c.Uint8,read_on_configure=true,
from_device=function(value)
value=type(value)=="table"and value.value or value
return({[0]="silent_mode","low_volume","high_volume"})[value]
end,
to_device=function(value)return({silent_mode=0,low_volume=1,high_volume=2})[value]end,emit=h.nimlyCodeSoundVolume()}),
g.cluster_attribute(257,35,{name="nimly_code_auto_relock",endpoint=11,data_type=c.Uint32,read_on_configure=true,
from_device=function(value)return value==0 and"OFF"or"ON"end,
to_device=function(value)return value=="ON"and 1 or 0 end,emit=h.nimlyCodeAutoRelock()}),
g.cluster_attribute(257,35,{name="nimly_code_relock_time",endpoint=11,data_type=c.Uint32,read_on_configure=true,emit=h.nimlyCodeRelockTime()}),g.cluster_attribute(257,nil,{name="nimly_code_pin",endpoint=11,write_only=true,suppress_optimistic_state=true,sender=bG})}}for _,field in ipairs{{18,"PinCapacity",c.Uint16},{24,"MinPinLength",c.Uint8},{23,"MaxPinLength",c.Uint8}}do
am.zcl_clusters[#am.zcl_clusters+1]=g.cluster_attribute(257,field[1],{name="nimly_code_"..field[2]:sub(1,1):lower()..field[2]:sub(2),endpoint=11,data_type=field[3],read_only=true,read_on_configure=true,
handler=field[1]==24 and function(a,value)if value>0 then a:set_field("nimly_min_pin_length",value)end end or nil,
emit=h["nimlyCode"..field[2]]()})end
for _,command in ipairs{5,7,32,33}do
am.zcl_clusters[#am.zcl_clusters+1]=g.cluster_attribute(257,nil,{name="nimly_response_"..command,endpoint=11,read_only=true,command_id=command,command_extractor=command<32 and bo(command)or bn(command==33)})end
d(am,{e.create_fingerprint("Onesti Products AS","NimlyCodePRO")})
local function al(_,value)
return(value&0xF03C0F)~=0 and k.batteryLevel.battery.critical()or k.batteryLevel.battery.normal()
end
local function an(value,_,U)
if U.raw_value~=255 then return value end
end
local aA={profile="buttons-samjin-button",button_actions={"pushed","double","held"},zcl_clusters={g.cluster_attribute(1280,nil,{name="samjin_button_action",endpoint=1,read_only=true,command_id=0,
command_extractor=function(rx,a)
local action=({[0]="off",[1]="single",[2]="double",[3]="hold"})[rx.body.zcl_body.zone_status.value]if not action then return end
local A=h.samjinButtonAction()(a,action)A.state_change=true
a:emit_event(A)local aa=({single="pushed",double="double",hold="held"})[action]if aa then a:emit_event(k.button.button(aa,{state_change=true}))end
end
}),g.temperature{endpoint=1,data_type=c.Int16,read_only=true,configure_reporting=false,read_on_configure=false,read_on_refresh=false,reporting_defaults={minimum_interval=10,maximum_interval=3600,reportable_change=100}},g.battery{endpoint=1,data_type=c.Uint8,read_only=true,configure_reporting=false,read_on_configure=false,read_on_refresh=false,from_device=an},g.battery_voltage{endpoint=1,data_type=c.Uint8,read_only=true,configure_reporting=false,read_on_configure=false,read_on_refresh=false,from_device=an,reporting_defaults={minimum_interval=3600,maximum_interval=65000,reportable_change=0}},g.cluster_attribute(1,62,{name="samjin_button_alarm",endpoint=1,data_type=c.Bitmap32,read_only=true,read_on_configure=false,read_on_refresh=false,emit=al})}}
aA.configure=function(r,a)
for _,t in ipairs{1026,1}do g.bind_cluster(a,t,r.environment_info.hub_zigbee_eui,1)end
for _,z in ipairs(aA.zcl_clusters)do
local M=z.reporting_defaults
if M then g.configure_reporting(a,{cluster=z.cluster_id,attribute=z.attribute_id,data_type=z.data_type,minimum_interval=M.minimum_interval,maximum_interval=M.maximum_interval,reportable_change=M.reportable_change},1,{defer_on_override=true})end
end
g.read_attribute(a,1,32,1)
end
d(aA,{e.create_fingerprint("Samjin","button")})
local function aP(rx,a)
if J.duplicate_transaction(a,1,rx.body.zcl_header.seqno.value,"__iris3460_transactions")then return end
local cl=rx.body.zcl_header.cmd.value==1
local A=h.iris3460Action()(a,cl and"on"or"off")A.state_change=true
a:emit_event(A)local bf=rx.address_header.dest_addr.value
if bf>=1 and bf<=65527 then
local bt=h.iris3460Group()(a,bf)bt.state_change=true
a:emit_event(bt)end
local cF=require"cosock.socket"local cE=cF.gettime()if cl then a:set_field("__iris3460_pressed_at",cE,{persist=false})else
local cr=a:get_field"__iris3460_pressed_at"a:set_field("__iris3460_pressed_at",nil,{persist=false})if cr and cE-cr<10 then
a:emit_event(k.button.button(cE-cr<1 and"pushed"or"held",{state_change=true}))end
end
end
local bx={profile="buttons-iris-3460l",button_actions={"pushed","held"},zcl_clusters={g.cluster_attribute(6,nil,{name="iris3460_on",endpoint=1,read_only=true,command_id=1,command_extractor=aP}),g.cluster_attribute(6,nil,{name="iris3460_off",endpoint=1,read_only=true,command_id=0,command_extractor=aP}),g.cluster_attribute(1,32,{name="iris3460_voltage",endpoint=1,data_type=c.Uint8,read_only=true,configure_reporting=false,read_on_configure=false,read_on_refresh=false,reporting_defaults={minimum_interval=3600,maximum_interval=65000,reportable_change=0},
emit=function(_,value)
if value==255 then return end
local I=math.floor(math.min(100,math.max(0,235-370000/(value*100+1)))+0.5)return{k.battery.battery(I),k.voltageMeasurement.voltage{value=value/10,unit="V"}}
end
}),g.temperature{endpoint=1,data_type=c.Int16,read_only=true,configure_reporting=false,read_on_configure=false,read_on_refresh=false,reporting_defaults={minimum_interval=10,maximum_interval=3600,reportable_change=100}},g.cluster_attribute(1,62,{name="iris3460_alarm",endpoint=1,data_type=c.Bitmap32,read_only=true,read_on_configure=false,read_on_refresh=false,emit=al})}}
bx.configure=function(r,a)
for _,t in ipairs{6,1,1026}do g.bind_cluster(a,t,r.environment_info.hub_zigbee_eui,1)end
for _,z in ipairs(bx.zcl_clusters)do
local M=z.reporting_defaults
if M then
g.configure_reporting(a,{cluster=z.cluster_id,attribute=z.attribute_id,data_type=z.data_type,minimum_interval=M.minimum_interval,maximum_interval=M.maximum_interval,reportable_change=M.reportable_change},1,{defer_on_override=true})if z.attribute_id==32 then g.read_attribute(a,1,32,1)end
end
end
end
d(bx,{e.create_fingerprint("CentraLite","3460-L")})g.attach_reporting_capabilities(au,{{2,"rpt-aes"},{4,"rpt-tcpu"},{5,"rpt-cwf"},{7,"rpt-brz"},{8,"rpt-bzx"},{11,"rpt-bic"},{13,"rpt-sgys",{zr000600003="Switch",zr000600007="SwitchTwo"}},{14,"rpt-sbl",{zr000600003="Switch",zr000600007="SwitchTwo"}},{15,"rpt-zjz"},{16,"rpt-zny"},{18,"rpt-nnm"},{19,"rpt-bfn"},{20,"rpt-zuf"}})return{id="zcl.controls.z2m_absorption",registrations=au}

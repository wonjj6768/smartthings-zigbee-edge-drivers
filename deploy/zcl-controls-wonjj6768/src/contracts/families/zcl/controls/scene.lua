local k,f,Q,v,n=require"protocol.zcl",require"contracts.helpers.family",require"capabilities.events.all",require"st.capabilities",require"st.zigbee.device_management"local t,c=f.definition_registry()local o,G,a,h,C=65283,16389,"__candeo_previous_rotation_event","__candeo_previous_direction",Q.remote_action()


local function j(V)
if type(V)~="number"then
return V
end
local T=math.floor((((V-2.0)/1.0)*100)+0.5)if T<0 then
return 0
end
if T>100 then
return 100
end
return T
end
local U={profile="buttons-button-4-battery-voltage-remote-action",button_actions={"pushed"},advanced_remote=true,button_count=4,tuya_action_map={[1]="scene_1",[2]="scene_2",[3]="scene_3",[4]="scene_4"},tuya_action_components={[1]="main",[2]="button2",[3]="button3",[4]="button4"},tuya_action_button_events={[1]="pushed",[2]="pushed",[3]="pushed",[4]="pushed"},zcl_clusters={k.tuya_magic_packet(),k.battery(),k.cluster_attribute(k.CLUSTER_POWER_CONFIGURATION,k.ATTR_BATTERY_VOLTAGE,{name="battery",endpoint=1,emit=Q.battery(),scale=10,from_device=j,read_on_configure=true}),k.cluster_attribute(k.CLUSTER_POWER_CONFIGURATION,k.ATTR_BATTERY_VOLTAGE,{name="battery_voltage",endpoint=1,emit=Q.voltage(),scale=10})},
configure=function(w,b)
for _,aa in ipairs{k.CLUSTER_ON_OFF,k.CLUSTER_LEVEL_CONTROL}do
b:send(n.build_bind_request(b,aa,w.environment_info.hub_zigbee_eui,1))end
end
}
local function i(z,...)
local af=z and z.body and z.body.zcl_body or nil
if type(af)~="table"then
return nil
end
for _,ag in ipairs{...}do
local r=af[ag]if type(r)=="table"and r.value~=nil then
return r.value
end
if r~=nil then
return r
end
end
return nil
end
local function p(b,m,ab)
if ab==nil then
return
end
if m=="main"then
b:emit_event(ab)else
b:emit_component_event({id=m},ab)end
end
local function y(u)
return({[1]="main",[2]="button2",[4]="button3",[8]="button4",[16]="button5"})[u]
end
local function L(u)
return({[1]="button_1",[2]="button_2",[4]="button_3",[8]="button_4",[16]="centre_button"})[u]
end
local function E(Y)
return({[1]="click",[2]="double_click",[3]="hold",[4]="release"})[Y]
end
local function H(action)
return({click="pushed",double_click="double",hold="held"})[action]
end
local function d(g,action)
g[#g+1]={action=action,component="main"}
end
local function s(l,b)
if type(l)~="table"then
return nil
end
local g={}if l.field1==1 then
local W,O,action_name=y(l.field3),L(l.field3),E(l.field4)if W~=nil and O~=nil and action_name~=nil then
g[1]={action=O .."_"..action_name,component=W,button_event=H(action_name)}end
elseif l.field1==3 then
local D=({[1]="started_",[2]="stopped_",[3]="continued_"})[l.field3]if D=="stopped_"then
local previous_direction=b:get_field(h)if type(previous_direction)=="string"then
d(g,"stopped_"..previous_direction)end
b:set_field(a,"stopped_",{persist=false})elseif D~=nil then
local direction=({[1]="rotating_right",[2]="rotating_left"})[l.field2]if direction~=nil then
local q,P=b:get_field(a),type(l.field4)=="number"and math.max(1,l.field4)or 1
if q=="stopped_"then
d(g,"started_"..direction)b:set_field(a,"started_",{persist=false})for _=2,P do
d(g,"continued_"..direction)b:set_field(a,"continued_",{persist=false})end
elseif q=="started_"or q=="continued_"then
for _=1,P do
d(g,"continued_"..direction)end
b:set_field(a,"continued_",{persist=false})end
b:set_field(h,direction,{persist=false})end
end
end
return g[1]~=nil and g or nil
end
local function I(b,g)
if type(g)~="table"then
return
end
for _,ac in ipairs(g)do
local m,Z=ac.component or"main",C(b,ac.action)p(b,m,Z)local A=ac.button_event and v.button and v.button.button[ac.button_event]or nil
if type(A)=="function"then
p(b,m,A{state_change=true})k.schedule_battery_refresh_after_button(b)end
end
end
local function B()
return k.cluster_attribute(o,1,{name="candeo_rotary_action",command_id=1,
command_extractor=function(z)
return{field1=i(z,"field1"),field2=i(z,"field2"),field3=i(z,"field3"),field4=i(z,"field4")}
end,
from_device=s,handler=I})
end
local F={profile="buttons-button-5-battery-remote-action",button_actions={"pushed","double","held"},button_count=5,zcl_clusters={k.battery(),B()},
configure=function(w,b)
b:send(n.build_bind_request(b,o,w.environment_info.hub_zigbee_eui,1))
end
}local ad={profile="controllers-dimming-remote-action",advanced_remote=true,accept_basic_write_attributes=true,button_count=1,unprefixed_remote_actions=true,zcl_clusters={k.cluster_attribute(0,G,{name="remote_action",emit=Q.remote_action(),
from_device=function(r)
if type(r)=="number"and r>=1 and r<=10 then
return"scene_"..tostring(r)end
end
})}}local S={profile="controllers-zone-8-battery-voltage-remote-action",advanced_remote=true,button_count=8,unprefixed_remote_actions=true,tuya_action_name="switch_scene",group_component_map={[101]="main",[102]="button2",[103]="button3",[104]="button4",[105]="button5",[106]="button6",[107]="button7",[108]="button8"},zcl_clusters={k.tuya_magic_packet(),k.battery(),k.cluster_attribute(k.CLUSTER_POWER_CONFIGURATION,k.ATTR_BATTERY_VOLTAGE,{name="battery",endpoint=1,emit=Q.battery(),scale=10,from_device=j}),k.cluster_attribute(k.CLUSTER_POWER_CONFIGURATION,k.ATTR_BATTERY_VOLTAGE,{name="battery_voltage",endpoint=1,emit=Q.voltage(),scale=10})},
configure=function(w)
for ae=101,108 do
w:add_hub_to_zigbee_group(ae)end
end
}
local function x(b)
b:emit_event(v.button.button.pushed{state_change=true})k.schedule_battery_refresh_after_button(b)
end
local function e(R,action)
return k.cluster_attribute(64640,61440+R-240,{name="heiman_scene_"..action,command_id=R,
command_extractor=function()
return action
end,
emit=Q.remote_action(),handler=x,mfg_code=4619})
end
local J={profile="buttons-heiman-scene-battery-remote-action",button_actions={"pushed"},advanced_remote=true,button_count=1,unprefixed_remote_actions=true,zcl_clusters={k.battery(),e(240,"cinema"),e(241,"at_home"),e(242,"sleep"),e(243,"go_out"),e(244,"repast")},
configure=function(w,b)
b:send(n.build_bind_request(b,64640,w.environment_info.hub_zigbee_eui,1))
end
}c(U,f.create_fingerprints("TS1002",{"_TZ3000_etufnltx"}))c(F,{f.create_fingerprint("Candeo","C-ZB-SR5BR")})c(ad,{f.create_fingerprint("MLI","Remote Control")})c(S,f.create_fingerprints("TS1002",{"_TZ3000_xwh1e22x","_TZ3000_zwszqdpy"}))c(J,{f.create_fingerprint("HEIMAN","SceneSwitch-EM-3.0"),f.create_fingerprint("HEIMAN","SceneSwitch-EF-3.0")})k.attach_reporting_capabilities(t,{{1,"rpt-tyu"},{2,"rpt-cyz"},{4,"rpt-tsz"},{5,"rpt-tfs"}})return{id="zcl.controls.scene",registrations=t}

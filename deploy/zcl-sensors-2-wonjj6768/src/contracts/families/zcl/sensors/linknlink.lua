local h,e,g=require"protocol.zcl",require"contracts.helpers.family",require"st.zigbee.device_management"local c,n=e.definition_registry()
local function i(k,d,a)
if d==h.CLUSTER_ON_OFF then
local l=({[0]="off",[1]="on",[2]="toggle",[64]="off"})[a]return l,"main",l~=nil
end
if d~=h.CLUSTER_LEVEL_CONTROL then return nil,nil,false end
if a==0 or a==4 then
return"brightness_move_to_level","main",true
end
local f=k and k.body and k.body.zcl_body or nil
if a==1 or a==5 then
local b=f and(f.move_mode or f.movemode or f.mode)or nil
b=type(b)=="table"and b.value or b
if b==0 then return"brightness_move_up","main",true end
if b==1 then return"brightness_move_down","main",true end
return nil,nil,true
end
if a==2 or a==6 then
local b=f and(f.step_mode or f.stepmode or f.mode)or nil
b=type(b)=="table"and b.value or b
if b==0 then return"brightness_step_up","main",true end
if b==1 then return"brightness_step_down","main",true end
return nil,nil,true
end
if a==3 or a==7 then
return"brightness_stop","main",true
end
return nil,nil,false
end
local j={profile="sensors-linknlink-emotion-air",advanced_remote=true,unprefixed_remote_actions=true,remote_action_emit_name="linknLinkEmotionAirAction",standard_action_metadata_emit_names={action_group="linknLinkEmotionAirActionGroup",action_level="linknLinkEmotionAirActionLevel",action_transition_time="linknAirActionTransition",action_rate="linknLinkEmotionAirActionRate",action_step_size="linknAirActionStepSize"},standard_command_action_resolver=i,zcl_clusters={h.temperature{minimum_interval=10,maximum_interval=3600,reportable_change=100},h.humidity{minimum_interval=10,maximum_interval=3600,reportable_change=100},h.illuminance{minimum_interval=10,maximum_interval=3600,reportable_change=5,read_on_configure=true},h.occupancy{minimum_interval=0,maximum_interval=3600,reportable_change=0,read_on_configure=true},h.battery{minimum_interval=3600,maximum_interval=65000,reportable_change=10}},
configure=function(o,m)
for _,d in ipairs{h.CLUSTER_ON_OFF,h.CLUSTER_LEVEL_CONTROL}do
m:send(g.build_bind_request(m,d,o.environment_info.hub_zigbee_eui,1))end
end
}n(j,{e.create_fingerprint("LinknLink","eMotion Air")})h.attach_reporting_capabilities(c,{{1,"rpt-enc"}})return{id="zcl.sensors.linknlink",registrations=c}

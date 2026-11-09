local a,x,e,y,t,h=require"protocol.tuya",require"protocol.zcl",require"st.zigbee.defaults.switch_defaults",require"log",require"capabilities.events.all",require"contracts.helpers.family"local j=a.converter
local i,c=h.definition_registry()
local function g(capability_id)
return assert(t[capability_id],"missing Fingerbot Plus emitter: "..capability_id)()
end
local f=t.switch()
local function o(b,_,w,u)
local command=w and"on"or"off"y.info("Fingerbot SDK Lua "..command .."; native handling disabled")e[command](nil,b,{component=u.component_id or"main",capability="switch",command=command},false)return true
end
local s=x.switch{read_only=false,emit=f,sender=o}
local function d(b,m)
local k=m.address_header
if k.profile.value~=260 or k.cluster.value~=6 or k.src_endpoint.value~=1 then
return
end
local r=m.body.zcl_header
local l=r.frame_ctrl
if l:is_cluster_specific_set()or l:is_mfg_specific_set()or l:get_direction()~=1
or r.cmd.value~=11 then
return
end
e.default_response_handler(nil,b,m,false)
end
local q={profile="controls-tuya-fingerbot-plus",package_group="finger-robot",magic_packet=false,zcl_configure=false,query_on_configure=false,refresh_state_query=false,initial_custom_state_query=false,time_start="off",zigbee_message_handler=d,
runtime_start=function(b,v)
b:remove_configured_attribute(6,0)b:remove_monitored_attribute(6,0)if not b:supports_capability_by_id("concertmirror08464.tuyaFingerbotUpperLimitV2","main")then
b:try_update_metadata{profile=v.profile}end
end,
datapoints={a.dp_enum(101,{name="tuya_fingerbot_mode",command_id=a.SEND_DATA,transaction=256,converter=j.lookup_from_to{click=0,switch=1,program=2},emit=g"tuyaFingerbotMode"}),a.dp_numeric(102,{name="tuya_fingerbot_lower_limit",command_id=a.SEND_DATA,transaction=256,emit=g"tuyaFingerbotLowerLimit"}),a.dp_numeric(103,{name="tuya_fingerbot_delay",command_id=a.SEND_DATA,transaction=256,emit=g"tuyaFingerbotDelay"}),a.dp_enum(104,{name="tuya_fingerbot_reverse",command_id=a.SEND_DATA,transaction=256,converter=j.lookup_from_to{ON=1,OFF=0},emit=g"tuyaFingerbotReverse"}),a.dp_battery(105,{name="battery",read_only=true,emit=t.battery()}),a.dp_numeric(106,{name="tuya_fingerbot_upper_limit",command_id=a.SEND_DATA,transaction=256,emit=g"tuyaFingerbotUpperLimitV2"}),a.dp_binary(107,{name="tuya_fingerbot_touch",command_id=a.SEND_DATA,transaction=256,converter=j.lookup_from_to{ON=true,OFF=false},emit=g"tuyaFingerbotTouch"})},zcl_clusters={s}}c(q,h.create_fingerprints("TS0001",{"_TZ3210_dse8ogfy","_TZ3210_j4pdtz9v","_TZ3210_7vgttna6","_TZ3210_a04acm9s","_TZ3210_cm9mbpr1"}))x.attach_reporting_capabilities(i,{{1,"rpt-txr"}})return{id="ef00.controls.tuya_fingerbot_plus",registrations=i}

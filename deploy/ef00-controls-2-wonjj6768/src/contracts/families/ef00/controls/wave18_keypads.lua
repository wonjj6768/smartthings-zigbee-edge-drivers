local a,C,n,u=require"protocol.tuya",require"capabilities.events.all",require"contracts.helpers.family",require"st.capabilities"local v,h=n.definition_registry()local k="__wave18_daewoo_ack_frame"
local function c(capability_id)
return assert(C[capability_id],"missing Wave18 keypad emitter: "..capability_id)()
end
local function r(capability_id)
local E=c(capability_id)
return function(...)
local w=E(...)if w~=nil then w.state_change=true end
return w
end
end
local function m(value)
if type(value)=="string"then
return value
end
if type(value)=="number"then
return tostring(value)end
return nil
end
local function j(b,B,w)
if w~=nil then
b:emit_component_event({id=B},w)end
end
local function t()
local value=os.date"%Y-%m-%dT%H:%M:%S.000%z"if value:match"[+-]%d%d%d%d$"then
return value:sub(1,-3)..":"..value:sub(-2)end
return value
end
local g=r"immaxKeypadAction"local H={profile="controls-wave18-immax-07505l",package_group="wave18-keypad",magic_packet=true,query_on_configure=false,time_start="off",datapoints={a.dp_numeric(3,{name="battery",read_only=true,transaction=1,emit=C.battery()}),a.dp_raw(24,{name="tamper",read_only=true,transaction=1,
converter=a.converter.from_only(function(value)return value==1 end),
emit=C.tamper()}),a.dp_raw(26,{name="immax_keypad_action",read_only=true,transaction=1,converter=a.converter.from_only(a.converter.constant"disarm"),emit=g}),a.dp_raw(27,{name="immax_keypad_action",read_only=true,transaction=1,converter=a.converter.from_only(a.converter.constant"arm_away"),emit=g}),a.dp_raw(28,{name="immax_keypad_action",read_only=true,transaction=1,converter=a.converter.from_only(a.converter.constant"arm_home"),emit=g}),a.dp_raw(29,{name="immax_keypad_action",read_only=true,transaction=1,converter=a.converter.from_only(a.converter.constant"sos"),emit=g}),a.dp_string(108,{name="immax_keypad_admin_code",read_only=true,transaction=1,converter=a.converter.from_only(m),emit=c"immaxKeypadAdminCode"}),a.dp_string(109,{name="immax_keypad_last_added_user_code",read_only=true,transaction=1,converter=a.converter.from_only(m),emit=c"immaxKeypadLastAddedUserCode"}),a.dp_numeric(103,{name="immax_keypad_arm_delay_time",transaction=1,emit=c"immaxKeypadArmDelayTime"}),a.dp_binary(104,{name="immax_keypad_beep_sound_enabled",transaction=1,converter=a.converter.lookup_from_to{ON=true,OFF=false},emit=c"immaxKeypadBeepSoundEnabled"}),a.dp_binary(105,{name="immax_keypad_quick_home_enabled",transaction=1,converter=a.converter.lookup_from_to{ON=true,OFF=false},emit=c"immaxKeypadQuickHomeEnabled"}),a.dp_binary(106,{name="immax_keypad_quick_disarm_enabled",transaction=1,converter=a.converter.lookup_from_to{ON=true,OFF=false},emit=c"immaxKeypadQuickDisarmEnabled"}),a.dp_binary(107,{name="immax_keypad_quick_arm_enabled",transaction=1,converter=a.converter.lookup_from_to{ON=true,OFF=false},emit=c"immaxKeypadQuickArmEnabled"}),a.dp_binary(111,{name="immax_keypad_arm_delay_beep_sound",transaction=1,converter=a.converter.lookup_from_to{ON=true,OFF=false},emit=c"immaxKeypadArmDelayBeepSound"}),a.dp_string(112,{name="immax_keypad_user_id",read_only=true,transaction=1,converter=a.converter.from_only(m),emit=c"immaxKeypadUserId"})}}h(H,n.create_fingerprints("TS0601",{"_TZE200_moycceze","_TZE200_n9clpsht","_TZE200_nyvavzbj"}))local d={action=r"daewooWkeAction",arm_mode=c"daewooWkeArmMode",armed=c"daewooWkeArmed",user_id=c"daewooWkeUserId",user_last_seen=c"daewooWkeUserLastSeen",last_added_user_code=c"daewooWkeLastAddedUserCode",admin_code=c"daewooWkeAdminCode",arm_delay_time=c"daewooWkeArmDelayTime"}
local function l(b)
j(b,"main",d.user_last_seen(b,t()))
end
local function q(b,i)
local A=i and i.frame or nil
if A~=nil and b:get_field(k)==A then
return
end
if A~=nil then
b:set_field(k,A,{persist=false})end
a.send_datapoint(b,23,a.DP_TYPE_BOOL,true,a.SET_DATA,false,1)
end
local function f(y)
return function(b,_,_,i)
if y=="arm_away"or y=="arm_home"then
q(b,i)j(b,"main",d.armed(b,"true"))elseif y=="sos"then
j(b,"main",u.panicAlarm.panicAlarm.panic())elseif y=="disarm"then
j(b,"main",u.panicAlarm.panicAlarm.clear())end
l(b)
end
end
local function s(b)
l(b)
end
local o={{104,"concertmirror08464.daewooWkeBeepSoundEnabled","beepSoundEnabled"},{105,"concertmirror08464.daewooWkeQuickHomeEnabled","quickHomeEnabled"},{106,"concertmirror08464.daewooWkeQuickDisarmEnabled","quickDisarmEnabled"},{107,"concertmirror08464.daewooWkeQuickArmEnabled","quickArmEnabled"},{110,"concertmirror08464.daewooWkeQuickSosEnabled","quickSosEnabled"}}
local function z(b)
a.send_datapoint(b,101,a.DP_TYPE_BOOL,true,a.SET_DATA,false,1)for _,G in ipairs(o)do
local state=b:get_latest_state("main",G[2],G[3])if state=="ON"or state=="OFF"then
a.send_datapoint(b,G[1],a.DP_TYPE_BOOL,state=="ON",a.SET_DATA,false,1)end
end
return true
end
local function x(_,b)
a.send_magic_packet(b)a.send_datapoint(b,101,a.DP_TYPE_BOOL,true,a.SET_DATA,false,1)
end
local F={profile="controls-wave18-daewoo-wke502z",package_group="wave18-keypad",magic_packet=true,query_on_configure=false,time_start="off",configure=x,announce_handler=z,datapoints={a.dp_numeric(23,{name="daewoo_wke_armed_report",read_only=true,transaction=1,
converter=a.converter.from_only(function(value)
return(value==true or value==1)and"true"or"false"
end),
emit=d.armed}),a.dp_numeric(23,{name="daewoo_wke_armed",write_only=true,transaction=1,
converter=a.converter.to_only(function(value)return value=="true"and 1 or 0 end)
}),a.dp_numeric(3,{name="battery",read_only=true,transaction=1,emit=C.battery()}),a.dp_raw(24,{name="tamper",read_only=true,transaction=1,
converter=a.converter.from_only(function(value)return value==true or value==1 end),
emit=C.tamper()}),a.dp_enum(25,{name="daewoo_wke_arm_mode",read_only=true,transaction=1,
converter=a.converter.from_only(function(value)return tostring(value)end),
emit=d.arm_mode}),a.dp_raw(26,{name="daewoo_wke_action",read_only=true,transaction=1,converter=a.converter.from_only(a.converter.constant"disarm"),handler=f"disarm",emit=d.action}),a.dp_raw(27,{name="daewoo_wke_action",read_only=true,transaction=1,converter=a.converter.from_only(a.converter.constant"arm_away"),handler=f"arm_away",emit=d.action}),a.dp_raw(28,{name="daewoo_wke_action",read_only=true,transaction=1,converter=a.converter.from_only(a.converter.constant"arm_home"),handler=f"arm_home",emit=d.action}),a.dp_raw(29,{name="daewoo_wke_action",read_only=true,transaction=1,converter=a.converter.from_only(a.converter.constant"sos"),handler=f"sos",emit=d.action}),a.dp_numeric(103,{name="daewoo_wke_arm_delay_time",transaction=1,emit=d.arm_delay_time}),a.dp_binary(104,{name="daewoo_wke_beep_sound_enabled",transaction=1,converter=a.converter.lookup_from_to{ON=true,OFF=false},emit=c"daewooWkeBeepSoundEnabled"}),a.dp_binary(105,{name="daewoo_wke_quick_home_enabled",transaction=1,converter=a.converter.lookup_from_to{ON=true,OFF=false},emit=c"daewooWkeQuickHomeEnabled"}),a.dp_binary(106,{name="daewoo_wke_quick_disarm_enabled",transaction=1,converter=a.converter.lookup_from_to{ON=true,OFF=false},emit=c"daewooWkeQuickDisarmEnabled"}),a.dp_binary(107,{name="daewoo_wke_quick_arm_enabled",transaction=1,converter=a.converter.lookup_from_to{ON=true,OFF=false},emit=c"daewooWkeQuickArmEnabled"}),a.dp_string(108,{name="daewoo_wke_admin_code",transaction=1,
converter=a.converter.from_to(m,function(value)return value end),
emit=d.admin_code}),a.dp_string(109,{name="daewoo_wke_last_added_user_code",read_only=true,transaction=1,converter=a.converter.from_only(m),emit=d.last_added_user_code}),a.dp_binary(110,{name="daewoo_wke_quick_sos_enabled",transaction=1,converter=a.converter.lookup_from_to{ON=true,OFF=false},emit=c"daewooWkeQuickSosEnabled"}),a.dp_binary(111,{name="daewoo_wke_arm_delay_beep_sound",transaction=1,converter=a.converter.lookup_from_to{ON=true,OFF=false},emit=c"daewooWkeArmDelayBeepSound"}),a.dp_numeric(112,{name="daewoo_wke_user_id",read_only=true,transaction=1,
converter=a.converter.from_only(function(value)return tostring(value)end),
handler=s,emit=d.user_id}),a.dp_binary(101,{name="daewoo_hub_mode",write_only=true,transaction=1})}}h(F,n.create_fingerprints("TS0601",{"_TZE200_rt5dklro"}))return{id="ef00.controls.wave18_keypads",registrations=v}

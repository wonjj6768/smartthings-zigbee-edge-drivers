local b,d,j=require"protocol.tuya",require"capabilities.events.all",require"contracts.helpers.family"local c=b.converter
local f,a=j.definition_registry()local h,e=c.lookup_from_to{off=0,on_auto=1,button_locked=2,on_manual_app=3,on_manual_button=4},c.lookup_from_to{LOCK=true,UNLOCK=false}local g=c.from_to(
function()return"idle"end,
function(l)return l=="refresh"end
)
local i=c.from_only(function(l)
return(tonumber(l)or 0)~=0
end)
local k={profile="valves-neo-nas-wv03b2",time_start="2000",initial_custom_state_query=false,refresh_state_query=false,b.dp_on_off(1,{name="switch",emit=d.switch()}),b.dp_enum(3,{name="neo_nas_two_status",read_only=true,emit=d.neoNasTwoStatus(),converter=h}),b.dp_numeric(5,{name="neo_nas_two_countdown",emit=d.neoNasTwoCountdown()}),b.dp_numeric(6,{name="neo_nas_two_countdown_left",read_only=true,emit=d.neoNasTwoCountdownLeft()}),b.dp_battery(11,{read_only=true,emit=d.battery()}),b.dp_bitmap(19,{name="fault",read_only=true,emit=d.hardware_fault(),converter=i}),b.dp_numeric(101,{name="neo_nas_two_on_countdown",emit=d.neoNasTwoOnCountdown()}),b.dp_binary(104,{name="neo_nas_two_child_lock",emit=d.neoNasTwoChildLock(),converter=e}),b.dp_numeric(106,{name="neo_nas_two_last_duration",read_only=true,emit=d.neoNasTwoLastDuration()}),b.dp_binary(107,{name="neo_nas_two_refresh",emit=d.neoNasTwoRefresh(),converter=g})}a(k,{{manufacturer="_TZE204_a9ojznj8",model="TS0601"},{manufacturer="_TZE284_a9ojznj8",model="TS0601"}})return{id="neo.nas_wv03b2",registrations=f}

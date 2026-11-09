local c,o,f,l=require"protocol.tuya",require"capabilities.events.all",require"contracts.helpers.family",require"st.capabilities"local h,b=f.definition_registry()
local function e(capability_id)
return assert(o[capability_id],"missing Wave17 CZF02 emitter: "..capability_id)()
end
local a=e"lincukooCzfSwitchStates"
local function g(i,_,r,j)
local p=a(i,"idle",r,j)if p~=nil then
i:emit_event(p)end
end
local function d(n,i)
if n~="SWITCH"then
return nil
end
local q=i:get_latest_state("main",l.switch.ID,"switch")if q=="on"then
return false
end
if q=="off"then
return true
end
return nil
end
local m={profile="controls-wave17-lincukoo-czf02",package_group="finger-robot",magic_packet=true,query_on_configure=true,time_start="off",datapoints={c.dp_on_off(1,{name="switch",component="main",transaction=1,handler=g,emit=o.switch()}),c.dp_enum(2,{name="lincukoo_czf_mode",transaction=1,converter=c.converter.lookup_from_to{button=0,switch=1},emit=e"lincukooCzfMode"}),c.dp_numeric(3,{name="lincukoo_czf_button_hold_duration",transaction=1,converter=c.converter.divide_by_pair(10),emit=e"lincukooCzfButtonHoldDuration"}),c.dp_numeric(5,{name="lincukoo_czf_arm_end_position",transaction=1,emit=e"lincukooCzfArmEndPosition"}),c.dp_numeric(6,{name="lincukoo_czf_arm_start_position",transaction=1,emit=e"lincukooCzfArmStartPosition"}),c.dp_battery(8,{name="battery",read_only=true,transaction=1,emit=o.battery()}),c.dp_binary(101,{name="lincukoo_czf_auto_adjustment",transaction=1,converter=c.converter.from_to(
function()return"idle"end,
function(n)return n=="START"end
),emit=e"lincukooCzfAutoAdjustment"}),c.dp_binary(102,{name="lincukoo_czf_switch_states",transaction=1,converter=c.converter.from_to(
function()return"idle"end,
d),emit=a})}}b(m,f.create_fingerprints("TS0601",{"_TZE284_gw05grph","_TZE284_chcnj5st","_TZE284_pislt0wa","_TZE2841000000_gw05grph","_TZE2841000000_chcnj5st","_TZE2841000000_pislt0wa"}))return{id="ef00.controls.wave17_fingerbot",registrations=h}

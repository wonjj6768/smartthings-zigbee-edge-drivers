local c,e,b,aF,aw,ao=require"protocol.tuya",require"capabilities.events.all",require"contracts.helpers.family",require"protocol.zcl",require"st.zigbee.zcl.clusters",require"st.zigbee.device_management"local d=c.converter
local S,a=b.definition_registry()
local function f()
return d.from_only(function(g)
local p=tonumber(g)if p==nil then
return nil
end
if p<=0 then
return"closed"end
if p>=100 then
return"open"end
return"partially open"
end)
end
local function i()
return d.from_only(function(g)
local p=tonumber(g)if p==nil then
return nil
end
p=100-p
if p<=0 then
return"closed"end
if p>=100 then
return"open"end
return"partially open"
end)
end
local h=d.lookup_from_to{open=0,stop=1,close=2}
local n=d.from_only(function(g)
return({[0]="open",[1]="partially open",[2]="closed",[3]="partially open"})[tonumber(g)]
end)
local t,y,B,X,Q,R,U,o,l,aB,I=d.lookup_from_to{open=0,close=1,stop=2},d.lookup_from_to{open=2,stop=1,close=0},d.lookup_from_to{open=1,close=0,stop=2},d.lookup_from_to{open=2,stop=0,close=1},{profile="covers-cover-switch-1",c.dp_enum(1,{name="cover_state",converter=h,write_only=true}),c.dp_cover_position(2,{emit=e.shade_level()}),c.dp_numeric(2,{name="window_shade_state",emit=e.shade_state(),converter=f(),read_only=true}),c.dp_on_off(101,{name="switch",component="switch2"})},{profile="covers-cover-switch-2",c.dp_enum(1,{name="cover_state",converter=h,write_only=true}),c.dp_cover_position(2,{emit=e.shade_level()}),c.dp_numeric(2,{name="window_shade_state",emit=e.shade_state(),converter=f(),read_only=true}),c.dp_on_off(101,{name="switch",component="switch2"}),c.dp_on_off(102,{name="switch",component="switch3"})},{profile="covers-cover-switch-2-trwaxi57",datapoints={c.dp_enum(1,{name="cover_state",converter=h,write_only=true}),c.dp_cover_position(2,{emit=e.shade_level()}),c.dp_numeric(2,{name="window_shade_state",emit=e.shade_state(),converter=f(),read_only=true}),c.dp_enum(3,{name="calibration",emit=e.trwaxi57Calibration(),converter=d.lookup_from_to{start=0,["end"]=1}}),c.dp_backlight_mode_off_on(7,{name="backlight_mode",emit=e.trwaxi57Backlight(),converter=d.lookup_from_to{off=false,on=true}}),c.dp_enum(8,{name="motor_steering",emit=e.trwaxi57MotorSteering(),converter=d.lookup_from_to{forward=0,backward=1}}),c.dp_child_lock(102,{name="child_lock",emit=e.trwaxi57ChildLock(),converter=d.lookup_from_to{off=false,on=true}}),c.dp_on_off(108,{name="switch",component="switch2"}),c.dp_on_off(107,{name="switch",component="switch3"})},query_on_configure=true},{c.dp_enum(1,{name="cover_state",converter=h,write_only=true}),c.dp_cover_position(2,{emit=e.shade_level()}),c.dp_numeric(2,{name="window_shade_state",emit=e.shade_state(),converter=f(),read_only=true})},{c.dp_enum(1,{name="cover_state",converter=h,write_only=true}),c.dp_cover_position_inverted(2,{emit=e.shade_level()}),c.dp_numeric(2,{name="window_shade_state",emit=e.shade_state(),converter=i(),read_only=true})},{profile="covers-cover-six",magic_packet=true,mcu_version_request_on_configure=true,time_start="off",c.dp_enum(1,{name="cover_state",converter=h,write_only=true}),c.dp_enum(1,{name="cover_action_report",converter=n,emit=e.shade_state(),read_only=true}),c.dp_cover_position_inverted(2,{emit=e.shade_level()}),c.dp_numeric(2,{name="window_shade_state",converter=i(),emit=e.shade_state(),read_only=true}),c.dp_cover_position_inverted(3,{name="position_report",emit=e.shade_level(),read_only=true}),c.dp_numeric(3,{name="window_shade_report",converter=i(),emit=e.shade_state(),read_only=true}),c.dp_enum(4,{name="cover_six_opening",converter=d.lookup_from_to{tilt=0,lift=1},emit=e.coverSixOpening()}),c.dp_enum(7,{name="cover_six_work_state",converter=d.lookup_from_to{standby=0,success=1,learning=2},emit=e.coverSixWorkState(),read_only=true}),c.dp_battery(13,{emit=e.battery(),read_only=true}),c.dp_enum(101,{name="cover_six_direction",converter=d.lookup_from_to{left=0,right=1},emit=e.coverSixDirection()}),c.dp_enum(102,{name="cover_six_upper_limit",converter=d.lookup_from_to{start=1,stop=0},emit=e.coverSixUpperLimit()}),c.dp_numeric(104,{name="cover_six_illumination",emit=e.coverSixIllumination(),read_only=true})},{c.dp_enum(1,{name="cover_state",converter=h,write_only=true}),c.dp_cover_position_inverted(8,{emit=e.shade_level()}),c.dp_numeric(8,{name="window_shade_state",emit=e.shade_state(),converter=i(),read_only=true})}
local function ac(g,j)
return j.preferences.reverse==true and(100-g)or g
end
local L={from=ac,to=ac}
local T=d.from_only(function(g,j)
local position=ac(g,j)return position<=0 and"closed"or position>=100 and"open"or"partially open"
end)
local al,W={c.dp_enum(2,{name="cover_state",converter=h,write_only=true}),c.dp_cover_position(7,{converter=L,emit=e.shade_level()}),c.dp_numeric(7,{name="window_shade_state",emit=e.shade_state(),converter=T,read_only=true}),c.dp_cover_position(8,{name="cover_position_report",converter=L,emit=e.shade_level(),read_only=true}),c.dp_numeric(8,{name="window_shade_state_report",emit=e.shade_state(),converter=T,read_only=true})},{c.dp_enum(1,{name="cover_state",converter=h,write_only=true}),c.dp_cover_position(9,{write_only=true}),c.dp_cover_position(8,{name="cover_position_report",emit=e.shade_level(),read_only=true}),c.dp_numeric(8,{name="window_shade_state",emit=e.shade_state(),converter=f(),read_only=true})}local as={profile="covers-ts130f-xbexmf8h",datapoints={c.dp_enum(1,{name="cover_state",converter=h,write_only=true}),c.dp_enum(1,{name="cover_action_state",emit=e.shade_state(),converter=n,read_only=true}),c.dp_cover_position(2,{emit=e.shade_level()}),c.dp_numeric(2,{name="window_shade_state",emit=e.shade_state(),converter=f(),read_only=true}),c.dp_enum(3,{name="calibration",emit=e.ts130fXbCalibration(),converter=d.lookup_from_to{on=0,off=1}}),c.dp_enum(8,{name="motor_direction",emit=e.ts130fXbDirection(),converter=d.lookup_from_to{normal=0,reversed=1},
from_device=function(g)
if type(g)=="string"then return g=="back"and"reversed"or"normal"end
return({[0]="normal",[1]="reversed"})[g]
end
}),c.dp_numeric(10,{name="calibration_time",emit=e.ts130fXbCalibTime(),converter=d.from_only(d.pipe(d.wrap_signed(4294967296,0x7FFFFFFF).from,d.divide_by(10))),read_only=true}),c.dp_enum(12,{name="switch_type",converter=d.lookup_from_to{momentary=0,toggle=1}}),c.dp_enum(14,{name="backlight_mode",emit=e.ts130fXbBacklight(),converter=d.lookup_from_to{on=0,off=1}})},query_on_configure=false,initial_custom_state_query=false,time_start="off"}local an={profile="covers-cover-zsm01",c.dp_enum(1,{name="cover_state",converter=h,write_only=true}),c.dp_cover_position(9,{write_only=true}),c.dp_numeric(8,{name="cover_position_state",emit=e.shade_level(),read_only=true}),c.dp_numeric(8,{name="window_shade_state",emit=e.shade_state(),converter=f(),read_only=true}),c.dp_enum(11,{name="control_back_mode",emit=e.zsm01ControlBackMode(),converter=d.lookup_from_to{forward=0,back=1},
from_device=function(g)
if type(g)=="string"then return g=="back"and"back"or"forward"end
return({[0]="forward",[1]="back"})[g]
end
}),c.dp_numeric(19,{name="position_best",emit=e.zsm01PositionBest()}),c.dp_enum(20,{name="click_control",emit=e.zsm01ClickControl(),converter=d.lookup_from_to{up=0,down=1}})}local Z,ay,ah,az={c.dp_enum(1,{name="cover_state",converter=X,write_only=true}),c.dp_cover_position(2,{emit=e.shade_level()}),c.dp_numeric(2,{name="window_shade_state",emit=e.shade_state(),converter=f(),read_only=true})},{profile="covers-cover-zb-sm",c.dp_enum(1,{name="cover_state",converter=h,write_only=true}),c.dp_cover_position(2,{emit=e.shade_level()}),c.dp_numeric(2,{name="window_shade_state",emit=e.shade_state(),converter=f(),read_only=true}),c.dp_numeric(3,{name="arrived_position"}),c.dp_enum(5,{name="motor_direction",emit=e.motorDirectionZbSmNormalRev(),converter=d.lookup_from_to{normal=0,reversed=1}}),c.dp_numeric(10,{name="cycle_time",read_only=true,emit=e.zbSmCycleTime()}),c.dp_enum(101,{name="motor_type",read_only=true,emit=e.zbSmMotorType(),converter=d.from_only(d.lookup_value{[0]="",[1]="AM0/6-28R-Sm",[2]="AM0/10-19R-Sm",[3]="AM1/10-13R-Sm",[4]="AM1/20-13R-Sm",[5]="AM1/30-13R-Sm"})}),c.dp_numeric(102,{name="cycle_count",read_only=true,emit=e.zbSmCycleCount()}),c.dp_enum(103,{name="bottom_limit",emit=e.zbSmBottomLimit(),converter=d.lookup_from_to{set=0,clear=1}}),c.dp_enum(104,{name="top_limit",emit=e.zbSmTopLimit(),converter=d.lookup_from_to{set=0,clear=1}}),c.dp_numeric(109,{name="active_power",read_only=true,emit=e.zbSmActivePower()}),c.dp_cover_position(115,{name="favorite_position",emit=e.favoritePositionZbSm()}),c.dp_enum(121,{name="motor_state",read_only=true,emit=e.zbSmMotorState(),converter=d.from_only(d.lookup_value{[0]="opening",[1]="stopped",[2]="closing"})})},{c.dp_enum(1,{name="cover_state",converter=y,write_only=true}),c.dp_cover_position(2,{emit=e.shade_level()}),c.dp_numeric(2,{name="window_shade_state",emit=e.shade_state(),converter=f(),read_only=true})},{profile="covers-cover-battery",magic_packet=true,mcu_version_request_on_configure=true,time_start="off",query_on_configure=true,query_on_announce=true,query_interval_seconds=86400,c.dp_enum(1,{name="cover_state",converter=h,write_only=true}),c.dp_enum(1,{name="cover_action_report",converter=n,emit=e.shade_state(),read_only=true}),c.dp_cover_position_inverted(2,{emit=e.shade_level()}),c.dp_numeric(2,{name="window_shade_state",converter=i(),emit=e.shade_state(),read_only=true}),c.dp_cover_position_inverted(3,{name="position_report",emit=e.shade_level(),read_only=true}),c.dp_numeric(3,{name="window_shade_report",converter=i(),emit=e.shade_state(),read_only=true}),c.dp_battery(13,{emit=e.battery(),read_only=true})}a(az,b.create_fingerprints("TS0601",{"_TZE284_koxaopnk"}))local aC={magic_packet=true,mcu_version_request_on_configure=true,time_start="off",c.dp_enum(1,{name="cover_state",converter=y,write_only=true}),c.dp_enum(1,{name="cover_action_report",read_only=true,emit=e.shade_state(),
from_device=function(g)return({[0]="closed",[1]="partially open",[2]="open"})[g]end}),
c.dp_cover_position(2,{emit=e.shade_level()}),c.dp_numeric(2,{name="window_shade_state",converter=f(),emit=e.shade_state(),read_only=true}),c.dp_numeric(3,{name="position_report",emit=e.shade_level(),read_only=true}),c.dp_numeric(3,{name="window_shade_report",converter=f(),emit=e.shade_state(),read_only=true})}local ar={c.dp_enum(1,{name="cover_state",converter=h,write_only=true}),c.dp_cover_position(2,{emit=e.shade_level()}),c.dp_numeric(2,{name="window_shade_moving_state",emit=e.shade_state(),converter=f(),read_only=true}),c.dp_numeric(3,{name="cover_position_state",emit=e.shade_level(),read_only=true}),c.dp_numeric(3,{name="window_shade_state",emit=e.shade_state(),converter=f(),read_only=true})}local ag={profile="covers-cover-pims3028",c.dp_enum(1,{name="cover_state",converter=d.lookup_from_to{open=0,stop=1,close=2,lock=3,unlock=4},write_only=true}),c.dp_cover_position(2,{emit=e.shade_level()}),c.dp_numeric(2,{name="window_shade_state",emit=e.shade_state(),converter=f(),read_only=true}),c.dp_cover_position_inverted(3,{name="position_inverted",emit=e.shade_level(),read_only=true}),c.dp_numeric(3,{name="window_shade_state_report",emit=e.shade_state(),converter=i(),read_only=true}),c.dp_enum(4,{name="mode",emit=e.pims3028Mode(),converter=d.lookup_from_to{up=0,up_delete=1,remove_up_down=2}}),c.dp_enum(5,{name="control_back",emit=e.pims3028ControlBack(),converter=d.lookup_from_to{forward=0,back=1}}),c.dp_binary(6,{name="auto_power",emit=e.pims3028AutoPower(),converter=d.lookup_from_to{off=false,on=true}}),c.dp_enum(7,{name="work_state",emit=e.coverWorkPimsActual(),converter=d.from_only(d.lookup_value{[0]="opening",[1]="closing",[2]="value_123"})}),c.dp_numeric(10,{name="time_total",read_only=true,emit=e.pims3028TimeTotal()}),c.dp_enum(11,{name="situation_set",read_only=true,emit=e.pims3028SituationSet(),converter=d.from_only(d.lookup_value{[0]="fully_open",[1]="fully_close"})}),c.dp_binary(12,{name="fault",read_only=true,emit=e.pims3028Fault(),
converter=d.from_only(function(g)
return g and"fault"or"normal"
end)
}),c.dp_enum(16,{name="border",emit=e.pims3028BorderV2(),converter=d.lookup_from_to{set_up=0,set_down=1,delete_up=2,delete_down=3,delete_both=4}}),c.dp_numeric(19,{name="position_best",emit=e.pims3028PositionBestV2()}),c.dp_numeric(21,{name="angle_horizontal",emit=e.pims3028AngleHorizontal()}),c.dp_enum(101,{name="calibration",emit=e.coverCalibrationPims3028StartEnd(),converter=d.lookup_from_to{start=0,["end"]=1}}),c.dp_numeric(102,{name="quick_calibration",emit=e.pims3028QuickCalibration()}),c.dp_binary(103,{name="best_position_trigger",emit=e.pims3028BestTrigger(),converter=d.lookup_from_to{off=false,on=true}}),c.dp_enum(104,{name="reset",emit=e.pims3028Reset(),converter=d.lookup_from_to{reset=0}})}local at={profile="covers-cover-battery-rm28-le",c.dp_enum(1,{name="cover_state",converter=h,write_only=true}),c.dp_cover_position(2,{emit=e.shade_level()}),c.dp_numeric(2,{name="window_shade_state",emit=e.shade_state(),converter=f(),read_only=true}),c.dp_numeric(3,{name="position_report",emit=e.coverPositionReportRm28Le()}),c.dp_enum(4,{name="mode",emit=e.rm28leMode(),converter=d.lookup_from_to{morning=0,night=1}}),c.dp_enum(5,{name="reverse_direction",converter=d.lookup_from_to{forward=0,back=1}}),c.dp_binary(6,{name="auto_power",emit=e.rm28leAutoPower(),converter=d.lookup_from_to{off=false,on=true}}),c.dp_enum(7,{name="work_state",emit=e.coverWorkRmOpeningClosing(),converter=d.from_only(d.lookup_value{[0]="closing",[1]="opening"})}),c.dp_enum(8,{name="countdown",emit=e.rm28leCountdown(),converter=d.lookup_from_to{cancel=0,["1h"]=1,["2h"]=2,["3h"]=3,["4h"]=4}}),c.dp_numeric(9,{name="countdown_left",read_only=true,emit=e.rm28leCountdownLeft()}),c.dp_numeric(10,{name="time_total",read_only=true,emit=e.rm28leTimeTotal()}),c.dp_enum(11,{name="situation_set",read_only=true,emit=e.rm28leSituationSet(),converter=d.from_only(d.lookup_value{[0]="fully_open",[1]="fully_close"})}),c.dp_numeric(12,{name="motor_fault",read_only=true,emit=e.rm28leMotorFault(),
converter=d.from_only(function(g)
return(tonumber(g)or 0)~=0 and"fault"or"normal"
end)
}),c.dp_battery(13,{emit=e.battery()}),c.dp_enum(16,{name="border",emit=e.rm28leBorder(),converter=d.lookup_from_to{up=0,down=1,up_delete=2,down_delete=3,remove_top_bottom=4}}),c.dp_numeric(19,{name="position_best",emit=e.rm28lePositionBest()}),c.dp_enum(20,{name="click_control",emit=e.rm28leClickControl(),converter=d.lookup_from_to{up=0,down=1}})}local ax={profile="covers-cover-battery-cover-three",c.dp_enum(1,{name="cover_state",converter=h,write_only=true}),c.dp_cover_position(2,{emit=e.shade_level()}),c.dp_numeric(2,{name="window_shade_state",emit=e.shade_state(),converter=f(),read_only=true}),c.dp_cover_position(3,{name="position_report",emit=e.shade_level()}),c.dp_numeric(3,{name="window_shade_state_report",emit=e.shade_state(),converter=f(),read_only=true}),c.dp_enum(5,{name="reverse_direction",emit=e.coverThreeReverseDirection(),converter=d.lookup_from_to{forward=0,back=1}}),c.dp_numeric(12,{name="motor_fault",read_only=true,emit=e.coverThreeMotorFault(),
converter=d.from_only(function(g)
return(tonumber(g)or 0)~=0 and"fault"or"normal"
end)
}),c.dp_battery(13,{emit=e.battery()}),c.dp_enum(16,{name="cover_limit",emit=e.coverThreeLimit(),converter=d.lookup_from_to{set_up=0,set_down=1,delete_up=2,delete_down=3,delete_both=4}}),c.dp_enum(20,{name="click_control",emit=e.coverThreeClickControl(),converter=d.lookup_from_to{up=0,down=1}})}local x,s="cover_one_position_invert","cover_one_raw_position"
local function u(g,j)
g=tonumber(g)if g==nil or g<0 or g>100 then return nil end
return j:get_field(x)=="inverted"and(100-g)or g
end
local function E(g,j)
if u(g,j)==nil then return nil end
if j:get_field(s)~=g then
j:set_field(s,g,{persist=true})end
return u(g,j)
end
local v=d.from_to(E,u)
local J=d.from_only(function(g,j)
local position=E(g,j)if position==nil then return nil end
return position==0 and"closed"or position==100 and"open"or"partially open"
end)
local function O(j,g)
if g~="normal"and g~="inverted"then return false end
local M=j:get_field(s)if M==nil then
M=j:get_latest_state("main","windowShadeLevel","shadeLevel")if M~=nil and j:get_field(x)=="inverted"then M=100-M end
end
j:set_field(x,g,{persist=true})local position=u(M,j)if position~=nil then
j:set_field(s,M,{persist=true})j:emit_component_event({id="main"},e.shade_level()(j,position))j:emit_component_event({id="main"},e.shade_state()(j,position==0 and"closed"or position==100 and"open"or"partially open"))end
return true
end
local aj={profile="covers-cover-cover-one",protocol_writers={cover_one_position_invert=O},
runtime_start=function(j)
j:emit_component_event({id="main"},e.coverOnePositionInvert()(j,j:get_field(x)or"normal"))
end,
c.dp_enum(1,{name="cover_state",converter=h,write_only=true}),c.dp_cover_position(2,{emit=e.shade_level(),converter=v}),c.dp_numeric(2,{name="window_shade_state",emit=e.shade_state(),converter=J,read_only=true}),c.dp_cover_position(3,{name="position_report",emit=e.shade_level(),converter=v}),c.dp_numeric(3,{name="window_shade_state_report",emit=e.shade_state(),converter=J,read_only=true}),c.dp_enum(5,{name="reverse_direction",emit=e.coverOneReverseDirection(),converter=d.lookup_from_to{forward=0,back=1}}),c.dp_numeric(105,{name="motor_speed",emit=e.coverOneMotorSpeed()})}
local function H(g,j)
return j.preferences.invertCover and(100-g)or g
end
local A=d.from_to(H,H)
local P=d.from_only(function(g,j)
local position=H(g,j)return position<=0 and"closed"or position>=100 and"open"or"partially open"
end)
local ak=d.lookup_from_to{normal=0,reversed=1}local aG={profile="covers-tuya-cover15",magic_packet=true,mcu_version_request_on_configure=true,time_start="off",query_on_configure=false,query_on_announce=false,initial_custom_state_query=false,c.dp_enum(1,{name="cover_state",converter=h,write_only=true}),c.dp_enum(1,{name="cover_action_report",converter=n,emit=e.shade_state(),read_only=true}),c.dp_cover_position(2,{emit=e.shade_level(),converter=A}),c.dp_numeric(2,{name="window_shade_state",emit=e.shade_state(),converter=P,read_only=true}),c.dp_cover_position(3,{name="position_report",emit=e.shade_level(),converter=A,read_only=true}),c.dp_numeric(3,{name="window_shade_state_report",emit=e.shade_state(),converter=P,read_only=true}),c.dp_enum(5,{name="cover15_motor_direction",converter=ak,emit=e.cover15MotorDirection()}),c.dp_string(5,{name="cover15_motor_direction_string",emit=e.cover15MotorDirection(),
read_only=true,converter=d.from_only(function(g)
if type(g)~="string"then return nil end
return g=="back"and"reversed"or"normal"
end)}),
c.dp_binary(6,{name="cover15_auto_power",emit=e.cover15AutoPower(),converter=d.lookup_from_to{disabled=false,enabled=true}}),c.dp_enum(7,{name="cover15_motor_state",emit=e.cover15MotorState(),read_only=true,converter=d.lookup_from_to{opening=0,closing=1,stopped=2}})}
local function V(g,j)
return j.preferences.invertCover and(100-g)or g
end
local r=d.from_to(V,V)
local z=d.from_only(function(g,j)
local position=V(g,j)return position==0 and"closed"or position==100 and"open"or"partially open"
end)
local aA={profile="covers-rinn-wser40",magic_packet=true,mcu_version_request_on_configure=true,query_on_configure=false,query_on_announce=false,initial_custom_state_query=false,refresh_state_query=false,time_start="off",datapoints={c.dp_enum(1,{name="cover_state",write_only=true,converter=t}),c.dp_enum(1,{name="cover_action_state",read_only=true,emit=e.shade_state(),
converter=d.from_only(function(g)
return({[0]="open",[1]="closed",[2]="partially open"})[g]
end)}),
c.dp_cover_position(102,{emit=e.shade_level(),converter=r}),c.dp_numeric(102,{name="window_shade_state",read_only=true,emit=e.shade_state(),converter=z}),c.dp_cover_position(103,{name="position_report",read_only=true,emit=e.shade_level(),converter=r}),c.dp_numeric(103,{name="window_shade_state_report",read_only=true,emit=e.shade_state(),converter=z})}}
local function G(aJ,aD)
local aI={d.lookup_from_to(aJ),d.lookup_from_to(aD)}
return d.from_to(function(g,j)
return aI[j.preferences.invertCover and 2 or 1].from(g)
end,function(g,j)
return aI[j.preferences.invertCover and 2 or 1].to(g)
end)
end
local Y=d.lookup_from_to{normal=0,reversed=1}local aK={profile="covers-zm25rx",magic_packet=true,mcu_version_request_on_configure=true,query_on_configure=false,query_on_announce=false,initial_custom_state_query=false,refresh_state_query=false,time_start="off",datapoints={c.dp_enum(1,{name="cover_state",write_only=true,converter=G({open=0,stop=1,close=2},{open=2,stop=1,close=0})}),c.dp_cover_position(2,{emit=e.shade_level(),converter=r}),c.dp_numeric(2,{name="window_shade_state",read_only=true,emit=e.shade_state(),converter=z}),c.dp_cover_position(3,{name="position_report",read_only=true,emit=e.shade_level(),converter=r}),c.dp_numeric(3,{name="window_shade_state_report",read_only=true,emit=e.shade_state(),converter=z}),c.dp_enum(5,{name="zm25rx_motor_direction",emit=e.zm25rxMotorDirection(),receive_datatypes={4,3},
converter=d.from_to(function(g)
if type(g)=="string"then return g=="back"and"reversed"or"normal"end
return Y.from(g)
end,Y.to)}),
c.dp_enum(7,{name="zm25rx_motor_state",read_only=true,emit=e.zm25rxMotorState(),converter=G({opening=0,closing=1,stopped=2},{opening=1,closing=0,stopped=2})}),c.dp_battery(13,{read_only=true,emit=e.battery()}),c.dp_enum(101,{name="zm25rx_program",write_only=true,suppress_optimistic_state=true,converter=G({set_bottom=1,set_upper=0,reset=4},{set_bottom=0,set_upper=1,reset=4})}),c.dp_enum(101,{name="zm25rx_click_control",write_only=true,suppress_optimistic_state=true,converter=G({upper=2,upper_micro=5,lower=3,lower_micro=6},{upper=3,upper_micro=6,lower=2,lower_micro=5})}),c.dp_battery(103,{name="battery_report",read_only=true,emit=e.battery()})}}local w={
from=function(g)
local position=g%256
if position<=100 then return position end
end,
to=function(g)return g end
}
local C=d.from_only(function(g)
local position=w.from(g)if position==nil then return nil end
return position==0 and"closed"or position==100 and"open"or"partially open"
end)
local ap={profile="covers-dream-blinds-tilt",magic_packet=false,mcu_version_request_on_configure=false,query_on_configure=false,query_on_announce=false,initial_custom_state_query=false,refresh_state_query=false,time_start="off",datapoints={c.dp_enum(1,{name="cover_state",write_only=true,converter=h}),c.dp_cover_position(2,{emit=e.shade_level(),converter=w}),c.dp_numeric(2,{name="window_shade_state",read_only=true,emit=e.shade_state(),converter=C}),c.dp_cover_position(3,{name="position_report",read_only=true,emit=e.shade_level(),converter=w}),c.dp_numeric(3,{name="window_shade_state_report",read_only=true,emit=e.shade_state(),converter=C}),c.dp_enum(5,{name="dream_blinds_reverse_direction",write_only=true,emit=e.dreamBlindsReverseDirection(),converter=d.lookup_from_to{forward=0,back=1}}),c.dp_numeric(105,{name="dream_blinds_motor_speed",emit=e.dreamBlindsMotorSpeed()}),c.dp_numeric(21,{name="cover_tilt",emit=e.shade_tilt_level(),converter={
from=function(g)return math.floor(math.min(180,g)*100/180+0.5)end,
to=function(g)return math.min(180,math.max(0,math.floor(g*180/100+0.5)))end
}}),c.dp_numeric(21,{name="dream_blinds_flip_angle",emit=e.dreamBlindsFlipAngle(),converter={
from=function(g)return math.min(180,g)end,
to=function(g)return math.min(180,math.max(0,math.floor(g+0.5)))end
}})}}local af,ad,am,av={profile="covers-cover-zm79e-dt",c.dp_enum(1,{name="cover_state",converter=h,write_only=true}),c.dp_cover_position_inverted(2,{emit=e.shade_level()}),c.dp_numeric(2,{name="window_shade_state",emit=e.shade_state(),converter=i(),read_only=true}),c.dp_cover_position_inverted(3,{name="position_report",emit=e.coverPositionReportZm79eDt()}),c.dp_enum(4,{name="opening_mode",emit=e.zm79eOpeningMode(),converter=d.lookup_from_to{tilt=0,lift=1}}),c.dp_enum(7,{name="work_state",emit=e.coverWorkStateZm79eDtLearning(),converter=d.from_only(d.lookup_value{[0]="standby",[1]="success",[2]="learning"})}),c.dp_enum(101,{name="motor_direction",emit=e.motorDirectionZm79eDtLeftRight(),converter=d.lookup_from_to{left=0,right=1}}),c.dp_enum(102,{name="set_upper_limit",emit=e.zm79eSetUpperLimit(),converter=d.lookup_from_to{stop=0,start=1}}),c.dp_enum(107,{name="factory_reset",emit=e.zm79eFactoryReset(),converter=d.lookup_from_to{set=0}})},{profile="covers-cover-bx82-tyz1",respond_to_mcu_version_response=true,c.dp_enum(1,{name="cover_state",converter=y,write_only=true}),c.dp_cover_position(2,{emit=e.shade_level()}),c.dp_numeric(2,{name="window_shade_state",emit=e.shade_state(),converter=f(),read_only=true}),c.dp_numeric(3,{name="position_report",emit=e.coverPositionReportBx82Tyz1()}),c.dp_enum(5,{name="motor_direction",emit=e.motorDirectionBxTyzNormalRev(),converter=d.lookup_from_to{normal=0,reversed=1}})},{profile="covers-cover-battery-mb60l",c.dp_enum(1,{name="cover_state",converter=h,write_only=true}),c.dp_cover_position_inverted(9,{emit=e.shade_level()}),c.dp_numeric(9,{name="window_shade_state",emit=e.shade_state(),converter=i(),read_only=true}),c.dp_enum(11,{name="motor_direction",emit=e.motorDirectionMbNormalRev(),converter=d.lookup_from_to{normal=0,reversed=1}}),c.dp_battery(13,{emit=e.battery()}),c.dp_enum(16,{name="set_limits",emit=e.mb60lSetLimits(),converter=d.lookup_from_to{up=0,down=1,reset=2}}),c.dp_binary(101,{name="child_lock",emit=e.mb60lChildLock(),converter=d.lookup_from_to{off=false,on=true}}),c.dp_binary(103,{name="tilt_mode",emit=e.tiltModeMb60l(),converter=d.lookup_from_to{on=true,off=false}})},{profile="covers-cover-battery-epj-zb",c.dp_numeric(102,{name="cover_state",converter=t,command_id=c.SEND_DATA,write_only=true}),c.dp_cover_position(104,{command_id=c.SEND_DATA,emit=e.shade_level()}),c.dp_numeric(104,{name="window_shade_state",emit=e.shade_state(),converter=f(),read_only=true}),c.dp_battery(4,{emit=e.battery()}),c.dp_binary(105,{name="charge_state"}),c.dp_numeric(106,{name="manual_mode",command_id=c.SEND_DATA,emit=e.manualModeEpjZbEnableDisable(),converter=d.lookup_from_to{enable=0,disable=1}}),c.dp_enum(107,{name="fault",converter=d.lookup_from_to{Normal=0,None=1,Fault=2}}),c.dp_numeric(108,{name="countdown"}),c.dp_numeric(109,{name="motor_direction",command_id=c.SEND_DATA,emit=e.motorDirectionEpjZbSide(),converter=d.lookup_from_to{right_side=0,left_side=1}}),c.dp_enum(110,{name="mode",converter=d.lookup_from_to{Disable=0,Enable=1}}),c.dp_enum(112,{name="fixed_window_sash",converter=d.lookup_from_to{Down=0,Up=1}}),c.dp_enum(114,{name="window_detection",read_only=true,emit=e.windowDetectionEpjZbStateV2(),converter=d.lookup_from_to{opened=0,closed=1,pending=2}})}
local N=d.from_to(function(g,j)
return j.preferences.reverse==true and(100-g)or g
end,function(g,j)
return j.preferences.reverse==true and(100-g)or g
end)
local K=d.from_only(function(g,j)
local position=N.from(g,j)if position<=0 then return"closed"end
if position>=100 then return"open"end
return"partially open"
end)
local aq={profile="covers-ts0301-one",query_on_configure=false,time_start="off",c.dp_enum(1,{name="cover_state",converter=h,write_only=true}),c.dp_enum(1,{name="cover_action_state",converter=n,read_only=true,emit=e.shade_state()}),c.dp_cover_position(2,{emit=e.shade_level(),converter=N}),c.dp_numeric(2,{name="window_shade_command_state",converter=K,read_only=true,emit=e.shade_state()}),c.dp_numeric(3,{name="cover_position_state",converter=N,read_only=true,emit=e.shade_level()}),c.dp_numeric(3,{name="window_shade_state",converter=K,read_only=true,emit=e.shade_state()}),c.dp_enum(5,{name="ts0301_direction",converter=d.lookup_from_to{forward=0,back=1},emit=e.ts0301Direction()}),c.dp_battery(13,{emit=e.battery()})}
local function D(m,M,j)
if type(M)=="table"then M=M.value end
if M>100 then return end
if m=="shade2"then return M<50 and 0 or(M-50)*2 end
if m=="shade3"then
local aL=M>50 and 0 or M*2
return j.preferences.invertTopRail==true and 100-aL or aL
end
return M
end
local function F(m)
return function(j,_,g)
local ae=aw.WindowCovering.server.commands
if g=="stop"then j:send(ae.Stop(j):to_endpoint(1));return true end
if m=="main"and type(g)=="string"then
if g=="open"then j:send(ae.UpOrOpen(j):to_endpoint(1))elseif g=="close"then j:send(ae.DownOrClose(j):to_endpoint(1))else return false end
return true
end
if g=="open"then g=100 elseif g=="close"then g=0 end
if type(g)~="number"then return false end
local aE=g
if m=="shade2"then aE=g==0 and 0 or 50+g/2
elseif m=="shade3"then aE=(j.preferences.invertTopRail==true and 100-g or g)/2 end
j:send(ae.GoToLiftPercentage(j,math.floor(math.max(0,math.min(100,aE))+0.5)):to_endpoint(1))return true
end
end
local q={profile="covers-ts0301-combined-rail",magic_packet=false,query_on_configure=false,time_start="off",zcl_clusters={aF.battery{read_only=true}},
configure=function(aH,j)
j:send(ao.build_bind_request(j,258,aH.environment_info.hub_zigbee_eui,1))
end
}
local function aa(j,M)
for _,m in ipairs{"main","shade2","shade3"}do
local position=D(m,M,j)if position~=nil then
j:emit_component_event(j.profile.components[m],e.shade_level()(j,position))j:emit_component_event(j.profile.components[m],e.shade_state()(j,position==0 and"closed"or"open"))end
end
end
for _,m in ipairs{"main","shade2","shade3"}do
local au=function(g,j)return D(m,g,j)end
q.zcl_clusters[#q.zcl_clusters+1]=aF.cover_position{endpoint=1,component=m,sender=F(m),from_device=au,emit=aa,read_only=false,write_only=m~="main",read_on_configure=false,minimum_interval=1,maximum_interval=65000,reportable_change=1}q.zcl_clusters[#q.zcl_clusters+1]=aF.cover_state{endpoint=1,component=m,sender=F(m),read_only=false}end
local ai,ab={profile="covers-cover",c.dp_enum(1,{name="cover_state",converter=h,write_only=true}),c.dp_cover_position(2,{write_only=true}),c.dp_numeric(3,{name="cover_position_state",emit=e.shade_level(),read_only=true}),c.dp_numeric(3,{name="window_shade_state",emit=e.shade_state(),converter=f(),read_only=true})},{profile="covers-ts0301-dual-rail",query_on_configure=false,time_start="off",c.dp_battery(13,{emit=e.battery()}),c.dp_enum(109,{name="cover_state",component="main",converter=t,write_only=true}),c.dp_cover_position_inverted(101,{component="main",emit=e.shade_level()}),c.dp_numeric(102,{name="cover_position_state",component="main",emit=e.shade_level(),converter=d.cover_position_inverted(),read_only=true}),c.dp_numeric(102,{name="window_shade_state",component="main",emit=e.shade_state(),converter=i(),read_only=true}),c.dp_enum(1,{name="cover_state",component="shade2",converter=B,write_only=true}),c.dp_cover_position(2,{component="shade2",emit=e.shade_level()}),c.dp_numeric(3,{name="cover_position_state",component="shade2",emit=e.shade_level(),read_only=true}),c.dp_numeric(3,{name="window_shade_state",component="shade2",emit=e.shade_state(),converter=f(),read_only=true})}a(aj,b.create_fingerprints("TS0601",{"_TZE200_bqcqqjpb","_TZE200_gaj531w3","_TZE284_gaj531w3","_TZE200_en3wvcbx","_TZE200_g5wdnuow","_TZE200_udank5zs","_TZE200_nv6nxo0c","_TZE200_3ylew7b4","_TZE200_llm0epxg","_TZE200_n1aauwb4","_TZE204_guvc7pdy","_TZE204_57hjqelq","_TZE204_vvvtcehj","_TZE28C1000000_vvvtcehj","_TZE200_axgvo9jh","_TZE200_zxxfv8wi","_TZE204_lh3arisb","_TZE204_zuq5xxib","_TZE284_zuq5xxib","_TZE200_nueqqe6k","_TZE200_1fuxihti","_TZE204_1fuxihti","_TZE284_1fuxihti","_TZE28C1000000_1fuxihti","_TZE200_5zbp6j0u","_TZE200_nkoabg8w","_TZE200_4vobcgd3","_TZE284_4vobcgd3","_TZE200_m6lwazh9","_TZE200_swlgvdlh","_TZE200_fdtjuw7u","_TZE200_rmymn92d","_TZE200_feolm6rk","_TZE200_tvrvdj6o","_TZE200_b2u1drdv","_TZE200_ol5jlkkr","_TZE204_a2jcoyuk","_TZE200_yia0p3tr","_TZE200_rsj5pu8y","_TZE200_yrugsphv","_TZE204_yrugsphv","_TZE200_odlldrxx","_TZE204_odlldrxx","_TZE200_7shyddj3","_TZE284_udank5zs","_TZE284_b7kbnl6q","_TZE204_dpqsvdbi","_TZE204_ic7jtutb","_TZE204_m1wl5fvq","_TZE204_nladmfvf","_TZE204_tgl8i2np","_TZE200_2jwrgrro"}))a(aj,{b.create_fingerprint("HOBEIAN","ZG-301Z-MOTO"),{manufacturer="_TYST11_fzo2pocs",model="zo2pocs"..string.char(0)},{manufacturer="_TYST11_udank5zs",model="dank5zs"..string.char(0)}})a(aj,{b.create_fingerprint("Yushun","YS-MT750"),b.create_fingerprint("Yushun","YS-MT750L"),b.create_fingerprint("Zemismart","ZM79E-DT"),b.create_fingerprint("Binthen","BCM100D"),b.create_fingerprint("Binthen","CV01A"),b.create_fingerprint("Zemismart","M515EGB"),b.create_fingerprint("Oz Smart Things","ZM85EL-1Z"),b.create_fingerprint("Tuya","M515EGZT"),b.create_fingerprint("Tuya","DT82LEMA-1.2N"),b.create_fingerprint("Tuya","ZD82TN"),b.create_fingerprint("Larkkey","ZSTY-SM-1SRZG-EU"),b.create_fingerprint("Zemismart","AM43"),b.create_fingerprint("A-OK","AM25"),b.create_fingerprint("Alutech","AM/R-Sm"),b.create_fingerprint("Roximo","CRTZ01"),b.create_fingerprint("Quoya","AT8510-TY"),b.create_fingerprint("Somgoms","ZSTY-SM-1DMZG-US-W_1"),b.create_fingerprint("HUARUI","CMD900LE"),b.create_fingerprint("Novato","WPK"),b.create_fingerprint("Zemismart","ZMS1-TYZ")})a(o,b.create_fingerprints("TS0601",{"_TZE200_eegnwoyw","_TZE200_fu14oapz"}))a(o,b.create_fingerprints("TS0105",{"_TZE600_ogyg1y6b"}))a(ax,b.create_fingerprints("TS0601",{"_TZE200_68nvbio9","_TZE200_pw7mji0l","_TZE200_cf1sl3tj","_TZE200_nw1r9hp6","_TZE200_9p5xmj5r","_TZE200_eevqq1uv","_TZE204_ejh6owwz","_TZE200_ba69l9ol","_TZE200_68nvbi09","_TZE284_n73badib","_TZE200_vexa5o82","_TZE200_sfqyhvpv"}))a(o,{b.create_fingerprint("Zemismart","ZM16EL-03/33"),b.create_fingerprint("Zemismart","ZM25EL"),b.create_fingerprint("Zemismart","ZM85EL-2Z"),b.create_fingerprint("Hiladuo","B09M3R35GC"),b.create_fingerprint("Tuya","MYQ-RM25-1.3/25-BZ"),b.create_fingerprint("Shaman","25EB-1/30-TYZ")})a(o,b.create_fingerprints("TS0601",{"_TZE200_zah67ekd","_TZE200_icka1clh"}))a(as,b.create_fingerprints("TS130F",{"_TZE20C_xbexmf8h"}))a(o,{b.create_fingerprint("Moes","AM43-0.45/40-ES-EB")})a(o,b.create_fingerprints("TS0601",{"_TZE200_5sbebbzs","_TZE200_hsgrhjpf","_TZE200_ergbiejo","_TZE200_nhyj64w2","_TZE200_127x7wnl","_TZE204_5slehgeo","_TZE284_5slehgeo","_TZE200_fctwhugx","_TZE200_p6vz3wzt","_TZE204_p6vz3wzt","_TZE284_uqfph8ah","_TZE284_waa352qv"}))a(o,{b.create_fingerprint("Homeetec","37022483")})a(aB,b.create_fingerprints("TS0601",{"_TZE200_cpbo62rn","_TZE200_libht6ua","_TZE284_libht6ua"}))a(o,b.create_fingerprints("TS0601",{"_TZE200_zvo63cmo"}))a(l,b.create_fingerprints("TS0601",{"_TZE204_r0jdjrvi","_TZE200_r0jdjrvi","_TZE200_g5xqosu7","_TZE204_g5xqosu7","_TZE200_fzo2pocs","_TZE284_fzo2pocs","_TZE200_9vpe3fl1","_TZE28C1000000_alh14edn"}))a(l,{b.create_fingerprint("Tuya","TS0601_alh14edn")})a(aK,b.create_fingerprints("TS0601",{"_TZE200_7eue9vhc","_TZE200_bv1jcqqu","_TZE200_wehza30a"}))a(o,b.create_fingerprints("TS0601",{"_TZE200_p2qzzazi"}))a(l,b.create_fingerprints("TS0601",{"_TZE204_xu4a5rhj","_TZE200_xu4a5rhj","_TZE204_q9xty0ad"}))a(o,b.create_fingerprints("TS0601",{"_TZE200_1vxgqfba","_TZE200_wdfurkoa","_TZE200_sq6affpe","_TZE284_wdfurkoa","_TZE284_6fopvb6v"}))a(o,b.create_fingerprints("TS0601",{"_TZE200_gubdgai2","_TZE200_vdiuwbkq"}))a(o,b.create_fingerprints("TS0601",{"_TZE200_yenbr4om","_TZE204_bdblidq3","_TZE200_bdblidq3"}))a(o,b.create_fingerprints("TS0601",{"_TZE200_mlglxwp3"}))a(al,b.create_fingerprints("TS0601",{"_TZE200_a8z0g46u","_TZE204_a8z0g46u"}))a(W,b.create_fingerprints("TS0601",{"_TZE284_3mzb0sdz","_TZE2841000000_3mzb0sdz"}))a(an,b.create_fingerprints("TS0601",{"_TZE284_zofmmt9s"}))a(l,b.create_fingerprints("TS0601",{"_TZE200_2odrmqwq","_TZE200_hojryzzd"}))a(aC,b.create_fingerprints("TS0601",{"_TZE200_clm4gdw4","_TZE200_2vfxweng","_TZE200_gnw1rril","_TZE204_ycke4deo","_TZE284_clm4gdw4"}))a(ah,b.create_fingerprints("TS0601",{"_TZE200_cowvfni3"}))a(Z,b.create_fingerprints("TS0601",{"_TZE200_rddyvrci"}))a(I,b.create_fingerprints("TS0601",{"_TZE284_r3szw0xr"}))a(l,b.create_fingerprints("TS0601",{"_TZE200_wmcdj3aq","_TZE200_xuzcvlku","_TZE200_xaabybja","_TZE200_zuz7f94z","_TZE200_3i3exuay","_TZE200_nogaemzt","_TZE200_dng9fn0k","_TZE200_zpzndjez"}))a(Q,b.create_fingerprints("TS0601",{"_TZE200_jhkttplm"}))a(Q,{b.create_fingerprint("Homeetec","37022493")})a(R,b.create_fingerprints("TS0601",{"_TZE200_5nldle7w"}))a(R,{b.create_fingerprint("Homeetec","37022173")})a(U,b.create_fingerprints("TS0601",{"_TZE204_trwaxi57"}))a(ar,b.create_fingerprints("TS0601",{"_TZE200_iossyxra","_TZE200_cxu0jkjk"}))a(ag,b.create_fingerprints("TS0601",{"_TZE200_eqpaxqdv"}))a(at,b.create_fingerprints("TS0601",{"_TZE200_fodv6bkr"}))a(av,{b.create_fingerprint("_TZ3210_emqmwtym","TS0601")})a(af,b.create_fingerprints("TS0601",{"_TZE200_ax8a8ahx"}))a(ad,b.create_fingerprints("TS0601",{"_TZE204_2rvvqjoa"}))a(am,b.create_fingerprints("TS0601",{"_TZE284_2gi1hy8s","_TZE2841000000_2gi1hy8s"}))a(ay,b.create_fingerprints("TS0601",{"_TZE200_zyrdrmno","_TZE200_osmxri8y"}))a(aq,b.create_fingerprints("TS0301",{"_TZE210_m6lwazh9"}))a(q,b.create_fingerprints("TS0301",{"_TZE200_eatmkx5j"}))a(ai,{b.create_fingerprint("Yoolax","Day-Night Shade")})a(ab,b.create_fingerprints("TS0301",{"_TZE210_inpjmc0h","_TZE210_yqwse3h5"}))a(ap,{b.create_fingerprint("_TZE204_wzre8hu2","TS0601")})a(aA,{b.create_fingerprint("_TZE200_pk0sfzvr","TS0601")})a(aG,b.create_fingerprints("TS0601",{"_TZE200_bjzrowv2","_TZE204_bjzrowv2","_TZE284_bjzrowv2"}))aF.attach_reporting_capabilities(S,{{48,"rpt-trw"}})return{id="ef00.covers",registrations=S}

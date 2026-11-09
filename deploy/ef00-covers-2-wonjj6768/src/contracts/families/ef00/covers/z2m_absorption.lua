local b,f,j,A=require"protocol.tuya",require"capabilities.events.all",require"contracts.helpers.family",require"protocol.zcl"local d=b.converter
local v,c=j.definition_registry()
local function e()
return d.from_only(function(a)
local i=tonumber(a)if i==nil then
return nil
end
i=100-i
if i<=0 then
return"closed"end
if i>=100 then
return"open"end
return"partially open"
end)
end
local g=d.lookup_from_to{open=0,stop=1,close=2}
local h=d.from_only(function(a)
return({[0]="open",[1]="partially open",[2]="closed",[3]="partially open"})[tonumber(a)]
end)
local function n(r)
return type(r)=="table"and type(r.preferences)=="table"and r.preferences.reverse==true
end
local k=d.from_to(
function(a,r)
local i=tonumber(a)if i==nil then return nil end
return n(r)and(100-i)or i
end,
function(a,r)
local i=tonumber(a)if i==nil then return nil end
return n(r)and(100-i)or i
end
)
local l=d.from_only(function(a,r)
local w=k.from(a,r)if w==nil then return nil end
if w<=0 then return"closed"end
if w>=100 then return"open"end
return"partially open"
end)
local t={profile="covers-cover-gm25teq",b.dp_enum(1,{name="cover_state",converter=g,write_only=true}),b.dp_enum(1,{name="cover_action_state",emit=f.shade_state(),converter=h,read_only=true}),b.dp_cover_position_inverted(9,{emit=f.shade_level()}),b.dp_numeric(9,{name="window_shade_state_command_position",emit=f.shade_state(),converter=e(),read_only=true}),b.dp_cover_position_inverted(8,{name="cover_position_state",emit=f.shade_level(),read_only=true}),b.dp_numeric(8,{name="window_shade_state",emit=f.shade_state(),converter=e(),read_only=true}),b.dp_numeric(11,{name="motor_direction",emit=f.gm25TeqMotorDirection(),
converter=d.from_to(function(a)
return(a==1 or a=="back"or a=="reversed")and"reversed"or"normal"
end,function(a)
return({normal=0,reversed=1})[a]
end)
}),query_on_configure=false,time_start="off"}local p={profile="covers-cover-moes-zs-sf-euc-wh-ms",query_on_configure=false,initial_custom_state_query=false,time_start="off",b.dp_enum(3,{name="moes_sf_calibration",emit=f.moesSfCalibration(),converter=d.lookup_from_to{start=0,["end"]=1}}),b.dp_binary(7,{name="moes_sf_backlight",emit=f.moesSfBacklight(),converter=d.lookup_from_to{on=true,off=false}}),b.dp_enum(8,{name="moes_sf_direction",emit=f.moesSfDirection(),converter=d.lookup_from_to{normal=0,reversed=1},
from_device=function(a)
if type(a)=="string"then return a=="back"and"reversed"or"normal"end
return({[0]="normal",[1]="reversed"})[a]
end
}),b.dp_numeric(10,{name="moes_sf_travel_time",emit=f.moesSfTravelTimeV2(),converter=d.from_to(d.wrap_signed(4294967296,0x7FFFFFFF).from,
function(a)
if type(a)=="number"and a%1==0 and a>=10 and a<=180 then return a end
end)
}),b.dp_enum(1,{name="cover_state",converter=g,write_only=true}),b.dp_enum(1,{name="cover_action_state",emit=f.shade_state(),converter=h,read_only=true}),b.dp_cover_position(2,{name="cover_position",emit=f.shade_level(),converter=k}),b.dp_numeric(2,{name="window_shade_state",emit=f.shade_state(),converter=l,read_only=true})}c(t,j.create_fingerprints("TS0601",{"_TZE204_xtrnjaoz","_TZE200_xtrnjaoz","_TZE284_8whfphjv"}))c(p,j.create_fingerprints("TS0601",{"_TZE284_upt8lzi0","_TZE28C1000000_i8sdouy0"}))local q={profile="covers-nova-zcmr1-core",package_group="covers",magic_packet=true,mcu_version_request_on_configure=true,query_on_configure=true,named_datapoints=true,time_start="off",datapoints={b.dp_enum(1,{name="cover_state",converter=g,write_only=true,transaction=1}),b.dp_enum(1,{name="cover_action_state",converter=h,read_only=true,transaction=1,emit=f.shade_state()}),b.dp_cover_position(2,{name="cover_position",transaction=1,emit=f.shade_level()}),b.dp_numeric(2,{name="cover_position_shade_state",
converter=d.from_only(function(a)
if a<=0 then return"closed"end
if a>=100 then return"open"end
return"partially open"
end),
read_only=true,transaction=1,emit=f.shade_state()}),b.dp_cover_position(3,{name="cover_position_report",read_only=true,transaction=1,emit=f.shade_level()}),b.dp_numeric(3,{name="cover_position_report_shade_state",
converter=d.from_only(function(a)
if a<=0 then return"closed"end
if a>=100 then return"open"end
return"partially open"
end),
read_only=true,transaction=1,emit=f.shade_state()})}}c(q,{j.create_fingerprint("_TZE204_dqy15zxy","TS0601")})local s={profile="covers-tuya-limited-switch",magic_packet=true,mcu_version_request_on_configure=true,query_on_configure=false,query_on_announce=false,time_start="off",datapoints={b.dp_enum(1,{name="cover_state",converter=g,write_only=true}),b.dp_enum(1,{name="cover_action_state",converter=h,emit=f.shade_state(),read_only=true}),b.dp_on_off(7,{name="switch",component="main"}),b.dp_enum(8,{name="limited_cover_motor_direction",emit=f.limitedCoverMotorDirection(),receive_datatypes={4,3},converter=d.lookup_from_to{normal=0,reversed=1},
from_device=function(a)
if type(a)=="string"then return a=="back"and"reversed"or"normal"end
return({[0]="normal",[1]="reversed"})[a]
end
})}}c(s,{j.create_fingerprint("_TZE204_pxbjch8m","TS0601")})
local m=d.from_to(function(a)
if type(a)=="string"then return a=="back"and"reversed"or"normal"end
return({[0]="normal",[1]="reversed"})[a]
end,function(a)
return({normal=0,reversed=1})[a]
end)
local y={profile="covers-tuya-cover5-px",magic_packet=true,mcu_version_request_on_configure=true,query_on_configure=false,query_on_announce=false,refresh_state=false,refresh_state_query=false,time_start="off",datapoints={b.dp_enum(1,{name="cover_state",converter=g,write_only=true}),b.dp_enum(1,{name="cover_action_state",emit=f.shade_state(),read_only=true,
converter=d.from_only(function(a)
return({[0]="open",[1]="partially open",[2]="closed"})[a]
end)
}),b.dp_cover_position(2,{emit=f.shade_level(),converter=k}),b.dp_numeric(2,{name="window_shade_state",emit=f.shade_state(),converter=l,read_only=true}),b.dp_enum(3,{name="cover5_px_calibration",emit=f.cover5PxCalibration(),converter=d.lookup_from_to{START=0,END=1}}),b.dp_binary(7,{name="cover5_px_backlight",emit=f.cover5PxBacklight(),converter=d.lookup_from_to{ON=true,OFF=false}}),b.dp_enum(8,{name="cover5_px_motor_direction",emit=f.cover5PxMotorDirection(),converter=m,receive_datatypes={4,3}}),b.dp_binary(103,{name="cover5_px_child_lock",emit=f.cover5PxChildLock(),converter=d.lookup_from_to{ON=true,OFF=false}})}}c(y,{j.create_fingerprint("_TZE284_pxwixtky","TS0601")})
local o=d.from_only(function(a)
if a<=0 then return"closed"end
if a>=100 then return"open"end
return"partially open"
end)
local x={profile="covers-tuya-cover14-a0",magic_packet=true,mcu_version_request_on_configure=true,query_on_configure=false,query_on_announce=false,refresh_state=false,refresh_state_query=false,time_start="off",datapoints={b.dp_enum(1,{name="cover_state",converter=g,write_only=true}),b.dp_enum(1,{name="cover_action_state",converter=h,emit=f.shade_state(),read_only=true}),b.dp_cover_position(2,{emit=f.shade_level()}),b.dp_numeric(2,{name="window_shade_state",emit=f.shade_state(),converter=o,read_only=true}),b.dp_cover_position(3,{name="cover_position_report",emit=f.shade_level(),read_only=true}),b.dp_numeric(3,{name="window_shade_state_report",emit=f.shade_state(),converter=o,read_only=true}),b.dp_enum(5,{name="cover14_a0_motor_direction",emit=f.cover14A0MotorDirection(),converter=m,receive_datatypes={4,3}}),b.dp_enum(7,{name="cover14_a0_motor_state",emit=f.cover14A0MotorState(),read_only=true,converter=d.lookup_from_to{opening=0,closing=1,stopped=2}}),b.dp_numeric(10,{name="cover14_a0_total_time",emit=f.cover14A0TotalTime(),read_only=true}),b.dp_enum(11,{name="cover14_a0_situation_set",emit=f.cover14A0SituationSet(),converter=d.lookup_from_to{fully_close=0,fully_open=1}}),b.dp_numeric(19,{name="cover14_a0_favorite_position",emit=f.cover14A0FavoritePosition()})}}c(x,{j.create_fingerprint("_TZE284_a0hirjnh","TS0601")})local z={profile="covers-moes-fwjz-16eb",magic_packet=true,mcu_version_request_on_configure=true,query_on_configure=false,query_on_announce=false,refresh_state=false,refresh_state_query=false,time_start="off",datapoints={b.dp_enum(1,{name="cover_state",converter=g,write_only=true}),b.dp_enum(1,{name="cover_action_state",converter=h,emit=f.shade_state(),read_only=true}),b.dp_cover_position(9,{emit=f.shade_level(),converter=k}),b.dp_numeric(9,{name="window_shade_state",emit=f.shade_state(),converter=l,read_only=true}),b.dp_cover_position(8,{name="cover_position_report",emit=f.shade_level(),converter=k,read_only=true}),b.dp_numeric(8,{name="window_shade_state_report",emit=f.shade_state(),converter=l,read_only=true}),b.dp_enum(11,{name="fwjz_16eb_motor_direction",emit=f.fwjz16ebMotorDirection(),converter=m,receive_datatypes={4,3}}),b.dp_raw(13,{name="battery",read_only=true,receive_datatypes={0,2},emit=f.battery(),
from_device=function(a)
if type(a)=="number"then return a end
if type(a)=="string"and #a>=4 then return string.unpack(">I4",a)end
end
}),b.dp_enum(16,{name="fwjz_16eb_cover_limit",emit=f.fwjz16ebCoverLimit(),converter=d.lookup_from_to{set_up=0,set_down=1,delete_up=2,delete_down=3}})},zcl_clusters={A.cluster_attribute(1,33,{name="battery",endpoint=1,read_only=true,scale=2,emit=f.battery()})}}c(z,{j.create_fingerprint("_TZE2841000000_u68q868h","TS0601")})local u={profile="covers-eway-vertical",magic_packet=true,query_on_configure=false,query_on_announce=false,refresh_state=false,refresh_state_query=false,time_start="off",datapoints={b.dp_enum(1,{name="cover_state",converter=g,write_only=true}),b.dp_cover_position_inverted(2,{emit=f.shade_level()}),b.dp_numeric(2,{name="window_shade_state",emit=f.shade_state(),converter=e(),read_only=true}),b.dp_cover_position_inverted(3,{name="cover_position_report",emit=f.shade_level(),read_only=true}),b.dp_numeric(3,{name="window_shade_state_report",emit=f.shade_state(),converter=e(),read_only=true})}}c(u,{j.create_fingerprint("_TZE200_cs05mqku","TS0601")})return{id="ef00.covers.z2m_absorption",registrations=v}

local g,s,e=require"protocol.tuya",require"capabilities.events.all",require"contracts.helpers.family"local f,c=e.definition_registry()
local function n(capability_id)
return assert(s[capability_id],"missing Wave16 Lincukoo siren emitter: "..capability_id)()
end
local function h(j,capability_id)
return{name=j,emit=n(capability_id),transaction=1}
end
local function l(r,j,capability_id,k)
local b=h(j,capability_id)b.converter=g.converter.lookup_from_to(k)return g.dp_numeric(r,b)
end
local function o(r,j,capability_id,k)
local b=h(j,capability_id)b.converter=g.converter.lookup_from_to(k)return g.dp_enum(r,b)
end
local d={profile="safety-wave16-lincukoo-a08-z10t",package_group="siren",magic_packet=true,query_on_configure=false,time_start="off",datapoints={}}
local function m(b)
d.datapoints[#d.datapoints+1]=b
end
m(l(1,"a_zero_eight_alarm_state","aZeroEightAlarmState",{alarm_sound=0,alarm_light=1,alarm_sound_light=2,normal=3}))m(o(5,"a_zero_eight_alarm_volume","aZeroEightAlarmVolume",{low=0,middle=1,high=2,mute=3}))m(g.dp_numeric(7,{name="a_zero_eight_alarm_time",emit=n"aZeroEightAlarmTime",transaction=1}))local p=h("a_zero_eight_mute","aZeroEightMute")p.converter=g.converter.lookup_from_to{ON=true,OFF=false}m(g.dp_binary(16,p))local i={}for index=1,27 do
i["ringtone_"..index]=index-1
end
m(o(21,"a_zero_eight_alarm_ringtone","aZeroEightAlarmRingtone",i))c(d,e.create_fingerprints("TS0601",{"_TZE204_l4daccga","_TZE28C1000000_l4daccga"}))return{id="ef00.safety.wave16_lincukoo_siren",registrations=f}

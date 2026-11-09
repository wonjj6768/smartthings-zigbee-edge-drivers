local c,d,E,H=require"protocol.tuya",require"capabilities.events.all",require"contracts.helpers.family",require"contracts.helpers.ef00"local e=c.converter
local g,j,p,s,m,l,x,q,o,r=e.lookup_from_to{low=0,medium=1,high=2},e.lookup_from_to{["10"]=0,["30"]=1,["60"]=2,["120"]=3},e.lookup_from_to{high=0,low=1},e.lookup_from_to{arm=0,silent=1,disarm=2},e.lookup_from_to{speed_priority=0,normal_priority=1,accuracy_priority=2},e.lookup_from_to{sensitive=0,normal=1,cautious=2},e.lookup_from_to{general_model=0,temporaty_stay=1,basic_detection=2,sensor_test=3},e.lookup_from_to{ON=0,OFF=1},e.lookup_from_to{low=0,middle=1,high=2},e.from_only(e.lookup_value{[0]="presence",[1]="none",[2]="presence_5min",[3]="presence_30min",[4]="none_5min",[5]="none_30min"})local A,a=E.definition_registry()
local function G(h)
local f={}if type(h)=="table"then
for U,S in pairs(h)do
f[U]=S
end
end
return f
end
local function C(h,L,O)
local f=G(h)f.name=f.name or L
f.emit=f.emit or O
return f
end
local function t(h)
return h.converter~=nil or h.from_device~=nil or h.to_device~=nil or h.lookup~=nil
end
local function u(K,L,D,v)
return function(W,h)
local f=C(h,L,D())if v~=nil and not t(f)then
f.converter=v
end
return K(W,f)
end
end
local y,z=u(c.dp_numeric,"presence_delay",d.presence_delay),u(c.dp_numeric,"presence_time",d.presence_time)
local function w(Q,P,T,M)
local N={minimum=Q,maximum=P,step=T}if type(M)=="string"and M~=""then
N.unit=M
end
return N
end
local b,V=H.ts0601_fingerprints,{profile="safety-motion-pir-illuminance-battery",datapoints={c.dp_occupancy(1,{emit=d.motion(),read_only=true}),c.dp_battery(4,{emit=d.battery(),read_only=true}),c.dp_illuminance(101,{emit=d.illuminance(),read_only=true})},query_on_configure=false,respond_to_mcu_version_response=true}
local n=b{"_TZE200_f1pvdgoh","_TZE200_me6wtiqs"}n[#n+1]={manufacturer="_TZE200_f1pvdgoh",model=string.char(0).."B"}a(V,n)local F={profile="safety-motion-pir-illuminance",datapoints={c.dp_occupancy(1,{emit=d.motion(),read_only=true}),c.dp_illuminance(101,{emit=d.illuminance(),read_only=true})},query_on_configure=false,respond_to_mcu_version_response=true}a(F,b{"_TZE200_ghynnvos"})local B={profile="safety-motion-zg204zl-keep-illuminance-battery",datapoints={c.dp_occupancy(1,{emit=d.motion(),read_only=true}),c.dp_battery(4,{emit=d.battery(),read_only=true}),c.dp_enum(9,{name="sensitivity",emit=d.zg204zlSensitivity(),converter=g}),c.dp_enum(10,{name="keep_time",emit=d.zg204zlKeepTime(),converter=j}),c.dp_illuminance(12,{emit=d.illuminance(),read_only=true}),c.dp_numeric(102,{name="illuminance_interval",emit=d.zg204zlIlluminanceInterval()})},query_on_configure=false}a(B,b{"_TZE200_3towulqd","_TZE200_1ibpyhdc","_TZE200_bh3n6gk8","_TZE200_ttcovulf","_TZE200_gjldowol","_TZE200_jxyhl4eq","_TZE200_qxyh4r7g","_TZE200_na5qlzow"})local k={profile="safety-motion-zg204zl-keep-illuminance-battery",datapoints={c.dp_occupancy(1,{emit=d.motion(),read_only=true}),c.dp_battery(4,{emit=d.battery(),read_only=true}),c.dp_enum(9,{name="sensitivity",emit=d.zg204zlSensitivity(),converter=g}),c.dp_enum(10,{name="keep_time",emit=d.zg204zlKeepTime(),converter=j}),c.dp_illuminance(101,{emit=d.illuminance(),read_only=true}),c.dp_numeric(102,{name="illuminance_interval",emit=d.zg204zlIlluminanceInterval()})},query_on_configure=false}a(k,b{"_TZE200_s6hzw8g2"})local i={c.dp_occupancy(1,{emit=d.motion(),read_only=true}),c.dp_battery(4,{emit=d.battery(),read_only=true}),c.dp_illuminance(101,{emit=d.illuminance(),read_only=true})}a({profile="safety-motion-zpir10-illuminance-battery",datapoints=i,query_on_configure=false},b{"_TZE200_ppuj1vem"})a({profile="safety-motion-zpir10-illuminance-battery",datapoints=i,query_on_configure=false,respond_to_mcu_version_response=true},b{"_TZE200_oc7xqqbs"})local J={profile="safety-motion-pir-solar-battery",datapoints={c.dp_occupancy(1,{emit=d.motion(),read_only=true}),c.dp_battery(4,{emit=d.battery(),read_only=true}),c.dp_numeric(9,{name="pir_sensitivity",emit=d.tre6haifPirSensitivity(),converter=p}),c.dp_numeric(101,{name="alarm_time",emit=d.tre6haifAlarmTime()}),c.dp_enum(102,{name="alarm_mode",emit=d.tre6haifAlarmMode(),converter=s})},query_on_configure=false}a(J,b{"_TZE284_tre6haif"})local I={profile="safety-motion-legacy-illuminance",datapoints={c.dp_occupancy(1,{emit=d.motion(),converter=e.true_false1(),read_only=true}),c.dp_enum(101,{name="v_sensitivity",emit=d.auin8mzrVSensitivity(),converter=m}),c.dp_enum(102,{name="o_sensitivity",emit=d.auin8mzrOSensitivity(),converter=l}),c.dp_numeric(103,{name="vacancy_delay",emit=d.auin8mzrVacancyDelay()}),c.dp_enum(104,{name="mode",emit=d.auin8mzrMode(),converter=x}),c.dp_numeric(105,{name="vacant_confirm_time",emit=d.auin8mzrVacantConfirmTime(),read_only=true}),c.dp_numeric(106,{name="reference_luminance",emit=d.auin8mzrReferenceLuminance(),read_only=true}),c.dp_numeric(107,{name="light_on_luminance_prefer",emit=d.auin8mzrLightOnLuminance()}),c.dp_numeric(108,{name="light_off_luminance_prefer",emit=d.auin8mzrLightOffLuminance()}),c.dp_numeric(109,{name="luminance_level",emit=d.auin8mzrLuminanceLevel(),read_only=true}),c.dp_enum(110,{name="led_status",emit=d.auin8mzrLedStatus(),converter=q})},magic_packet=false,query_on_configure=false}a(I,b{"_TZE200_auin8mzr"})local R={profile="safety-motion-bed-time-illuminance-battery",datapoints={c.dp_occupancy(1,{emit=d.motion(),read_only=true}),c.dp_battery(4,{emit=d.battery(),read_only=true}),c.dp_enum(9,{name="sensitivity",emit=d.seq9cm6uSensitivity(),converter=o}),c.dp_illuminance(12,{emit=d.illuminance(),read_only=true}),c.dp_numeric(101,{name="interval_time",emit=d.seq9cm6uIntervalTime()}),y(102),z(103),c.dp_enum(104,{name="work_state",emit=d.seq9cm6uWorkState(),converter=r,read_only=true})},presence_capability_ranges={presence_delay=w(0,3600,1,"s"),presence_time=w(0,3600,1,"s")},query_on_configure=false}a(R,b{"_TZE200_seq9cm6u"})return{id="ef00.motion.pir",registrations=A}

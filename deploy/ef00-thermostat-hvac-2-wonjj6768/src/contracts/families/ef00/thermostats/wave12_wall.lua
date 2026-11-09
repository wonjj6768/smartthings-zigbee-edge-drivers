local e,h,S,m,i,a=require"protocol.tuya",require"capabilities.events.all",require"contracts.helpers.family",require"contracts.helpers.ef00",require"contracts.helpers.ef00_thermostat_metadata",require"contracts.helpers.ef00_thermostat_wave12"local d=e.converter
local B,b=S.definition_registry()
local function D(field_prefix)
local G,O="__wave12_"..field_prefix.."_power","__wave12_"..field_prefix.."_mode"
local function F(g,j)
local ae=g==true or g==1
j:set_field(G,ae,{persist=false})if not ae then return"off"end
return j:get_field(O)or"heat"
end
local function J(g,j)
local at=({[0]="heat",[1]="cool"})[tonumber(g)]or"heat"j:set_field(O,at,{persist=false})if j:get_field(G)==false then return"off"end
return at
end
local function av(_,g)
if g=="off"then
return{{dp=1,datatype=e.DP_TYPE_BOOL,value=false}}end
local ay=({heat=0,cool=1})[g]if ay==nil then return nil end
return{{dp=1,datatype=e.DP_TYPE_BOOL,value=true},{dp=2,datatype=e.DP_TYPE_ENUM,value=ay}}
end
return F,J,av
end
local N,U,M=D"engo_eone_djurk"local ah={profile="thermostats-wave12-engo-eone",package_group="wall-2",query_on_configure=false,time_start="1970",force_time_updates=true,e.dp_binary(1,{name="system_mode",from_device=N,read_only=true,emit=h.thermostat_mode()}),e.dp_enum(2,{name="system_mode",from_device=U,read_only=true,emit=h.thermostat_mode()}),e.dp_running_state(3,{name="running_state",read_only=true,
converter=d.from_only(function(g)
return({[1]="heating",[3]="cooling"})[tonumber(g)]or"idle"
end),
emit=h.thermostat_operating_state()}),e.dp_current_heating_setpoint(16,{scale=10,emit=h.heating_setpoint"C"}),a.numeric(19,"engo_eone_wave12_max_temperature","engoEoneDjurkMaxTemperature",10,false),e.dp_local_temperature(24,{scale=10,read_only=true,emit=h.temperature"C"}),a.numeric(26,"engo_eone_wave12_min_temperature","engoEoneDjurkMinTemperature",10,false),a.numeric(27,"engo_eone_wave12_temp_calibration","engoEoneDjurkTempCalibration",1,false,{signed=true}),a.numeric(32,"engo_eone_wave12_holiday_temperature","engoEoneDjurkHolidayTemperature",10,false),a.numeric(33,"engo_eone_wave12_holiday_days","engoEoneDjurkHolidayDays",1,false),e.dp_numeric(34,{name="humidity",read_only=true,emit=h.humidity()}),e.dp_battery(35,{read_only=true,emit=h.battery()}),a.binary(40,"engo_eone_wave12_child_lock","engoEoneDjurkChildLock",{LOCK=true,UNLOCK=false}),a.enum(43,"engo_eone_wave12_sensor_choose","engoEoneDjurkSensorChoose",{internal=0,floor=1,external=2,occupancy=3}),a.numeric(44,"engo_eone_wave12_brightness","engoEoneDjurkBrightness",1,false),a.enum(58,"engo_eone_wave12_preset","engoEoneDjurkPreset",{manual=0,schedule=1,holiday=2,temporary=3,occupancy_off=4,frost=5}),a.enum(101,"engo_eone_wave12_control_algorithm","engoEoneDjurkControlAlgorithm",{TPI_UFH=0,TPI_RAD=1,TPI_ELE=2,HIS_02=3,HIS_04=4,HIS_06=5,HIS_08=6,HIS_10=7,HIS_20=8,HIS_30=9,HIS_40=10}),a.numeric(106,"engo_eone_wave12_frost_set","engoEoneDjurkFrostSet",10,false),a.binary(107,"engo_eone_wave12_valve_protection","engoEoneDjurkValveProtection",{ON=true,OFF=false}),a.enum(118,"engo_eone_wave12_warm_floor","engoEoneDjurkWarmFloor",{OFF=0,["7_min"]=1,["11_min"]=2,["15_min"]=3,["19_min"]=4,["23_min"]=5}),a.enum(120,"engo_eone_wave12_sensor_error","engoEoneDjurkSensorError",{Normal=0,E1=1,E2=2},true)}a.add_day_schedules(ah,"engo_eone_wave12","engoEoneDjurk",109,6,false)a.override_named_writer(ah,"system_mode",M)i.attach(ah,{"off","heat","cool"},5,45,0.5)b(ah,m.ts0601_fingerprints{"_TZE204_djurk6p5"})local aw={profile="thermostats-wave12-engo-e25-230",package_group="wall-2",query_on_configure=false,e.dp_on_off(1,{name="switch",emit=h.switch()}),e.dp_system_mode(2,{name="system_mode",converter=d.lookup_from_to{heat=0,cool=1},emit=h.thermostat_mode()}),e.dp_running_state(3,{name="running_state",read_only=true,converter=d.from_only(d.lookup_value{[2]="heating",[3]="cooling",[4]="idle",[5]="idle"}),emit=h.thermostat_operating_state()}),e.dp_current_heating_setpoint(16,{scale=10,emit=h.heating_setpoint"C"}),a.numeric(19,"engo_e25_max_temperature","engoE25MaxTemperature",10,false),e.dp_local_temperature(24,{scale=10,read_only=true,emit=h.temperature"C"}),a.numeric(26,"engo_e25_min_temperature","engoE25MinTemperature",10,false),a.numeric(27,"engo_e25_temp_calibration","engoE25TempCalibration",10,false,{signed=true}),a.binary(40,"engo_e25_child_lock","engoE25ChildLock",{LOCK=true,UNLOCK=false}),a.numeric(44,"engo_e25_backlight","engoE25Backlight",1,false),a.enum(58,"engo_e25_preset","engoE25Preset",{Manual=0,Frost=3}),a.enum(101,"engo_e25_control_algorithm","engoE25ControlAlgorithm",{TPI_UFH=0,TPI_RAD=1,TPI_ELE=2,HIS_04=3,HIS_08=4,HIS_12=5,HIS_16=6,HIS_20=8,HIS_30=9,HIS_40=10}),a.numeric(106,"engo_e25_frost_set","engoE25FrostSet",10,false),a.binary(107,"engo_e25_valve_protection","engoE25ValveProtection",{ON=true,OFF=false}),a.enum(108,"engo_e25_relay_mode","engoE25RelayMode",{NO=0,NC=1,OFF=2})}i.attach(aw,{"heat","cool"},5,35,0.5)b(aw,m.ts0601_fingerprints{"_TZE204_cmyc8g5i"})local T={profile="thermostats-wave12-engo-e25-batb",package_group="wall-2",query_on_configure=false,e.dp_on_off(1,{name="switch",emit=h.switch()}),e.dp_system_mode(2,{name="system_mode",converter=d.lookup_from_to{heat=0,cool=1},emit=h.thermostat_mode()}),e.dp_running_state(3,{name="running_state",read_only=true,
converter=d.from_only(function(g)
return({[2]="heating",[3]="cooling"})[tonumber(g)]or"idle"
end),emit=h.thermostat_operating_state()
}),e.dp_current_heating_setpoint(16,{scale=10,emit=h.heating_setpoint"C"}),a.numeric(19,"engo_e25_bat_max_temperature","engoE25BatbMaxTemperature",10,false),e.dp_local_temperature(24,{scale=10,read_only=true,emit=h.temperature"C"}),a.numeric(26,"engo_e25_bat_min_temperature","engoE25BatbMinTemperature",10,false),a.numeric(27,"engo_e25_bat_temp_calibration","engoE25BatbTempCalibration",10,false,{signed=true}),e.dp_battery(35,{read_only=true,emit=h.battery()}),a.binary(40,"engo_e25_bat_child_lock","engoE25BatbChildLock",{LOCK=true,UNLOCK=false}),a.numeric(44,"engo_e25_bat_backlight","engoE25BatbBacklight",1,false),a.enum(58,"engo_e25_bat_preset","engoE25BatbPreset",{manual=0,schedule=1,["frost protection"]=3}),a.enum(101,"engo_e25_bat_control_type","engoE25BatbControlType",{TPI_UFH=0,TPI_RAD=1,TPI_ELE=2,HIS_02=3,HIS_04=4,HIS_08=5,HIS_12=6,HIS_16=7,HIS_20=8,HIS_30=9,HIS_40=10}),a.numeric(102,"engo_e25_bat_delta_algorithm","engoE25BatbDeltaAlgorithm",10,false),a.enum(103,"engo_e25_bat_pair_state","engoE25BatbPairState",{none=0,commutation_center=1,trv=2},true),a.numeric(106,"engo_e25_bat_frost_set","engoE25BatbFrostSet",10,false),a.binary(107,"engo_e25_bat_valve_protection","engoE25BatbValveProtection",{ON=true,OFF=false}),a.numeric(123,"engo_e25_bat_trv_work_state","engoE25BatbTrvWorkState",1,true),a.numeric(136,"engo_e25_bat_latest_firmware","engoE25BatbLatestFirmware",10,true),a.numeric(137,"engo_e25_bat_current_firmware","engoE25BatbCurrentFirmware",1,true)}a.add_day_schedules(T,"engo_e25_bat","engoE25Batb",109,6,false)i.attach(T,{"heat","cool"},5,35,0.5)b(T,m.ts0601_fingerprints{"_TZE204_cg8hdnjv"})local I={profile="thermostats-wave12-engo-eone-batb",package_group="wall-2",query_on_configure=true,time_start="1970",e.dp_on_off(1,{name="switch",emit=h.switch()}),e.dp_system_mode(2,{name="system_mode",converter=d.lookup_from_to{heat=0,cool=1},emit=h.thermostat_mode()}),e.dp_running_state(3,{name="running_state",read_only=true,converter=d.from_only(d.lookup_value{[1]="heating",[2]="idle"}),emit=h.thermostat_operating_state()}),e.dp_current_heating_setpoint(16,{scale=10,emit=h.heating_setpoint"C"}),a.numeric(19,"engo_eone_bat_max_temperature","engoEoneBatMaxTemperature",10,false),e.dp_local_temperature(24,{scale=10,read_only=true,emit=h.temperature"C"}),a.numeric(26,"engo_eone_bat_min_temperature","engoEoneBatMinTemperature",10,false),a.numeric(27,"engo_eone_bat_temp_calibration","engoEoneBatTempCalibration",10,false,{signed=true}),a.numeric(32,"engo_eone_bat_holiday_temperature","engoEoneBatHolidayTemperature",10,false),a.numeric(33,"engo_eone_bat_holiday_days","engoEoneBatHolidayDays",1,false),e.dp_numeric(34,{name="humidity",read_only=true,emit=h.humidity()}),e.dp_battery(35,{read_only=true,emit=h.battery()}),a.binary(40,"engo_eone_bat_child_lock","engoEoneBatChildLock",{LOCK=true,UNLOCK=false}),a.enum(43,"engo_eone_bat_sensor_choose","engoEoneBatSensorChoose",{internal=0,floor_temp=1,external=2,external_on_off=3}),a.numeric(44,"engo_eone_bat_backlight","engoEoneBatBacklight",1,false),a.enum(58,"engo_eone_bat_preset","engoEoneBatPreset",{manual=0,schedule=1,holiday=2,frost=5}),a.enum(101,"engo_eone_bat_control_algorithm","engoEoneBatControlAlgorithm",{TPI_UFH=0,TPI_RAD=1,TPI_ELE=2,HIS_02=3,HIS_04=4,HIS_06=5,HIS_08=6,HIS_10=7,HIS_20=8,HIS_30=9,HIS_40=10}),a.numeric(102,"engo_eone_bat_max_floor_heating","engoEoneBatMaxFloorHeating",10,false),a.numeric(103,"engo_eone_bat_min_floor_heating","engoEoneBatMinFloorHeating",10,false),a.numeric(104,"engo_eone_bat_max_floor_cooling","engoEoneBatMaxFloorCooling",10,false),a.numeric(106,"engo_eone_bat_frost_set","engoEoneBatFrostSet",10,false),a.enum(108,"engo_eone_bat_valve_protection","engoEoneBatValveProtection",{off=0,on=1,anti_stop=2}),a.numeric(116,"engo_eone_bat_floor_temperature","engoEoneBatFloorTemperature",10,true),a.enum(117,"engo_eone_bat_temp_resolution","engoEoneBatTempResolution",{one=0,five=1}),a.enum(118,"engo_eone_bat_comfort_floor","engoEoneBatComfortFloor",{OFF=0,LEVEL1=1,LEVEL2=2,LEVEL3=3,LEVEL4=4,LEVEL5=5}),a.enum(120,"engo_eone_bat_sensor_error","engoEoneBatSensorError",{normal=0,E1=1,E2=2},true)}a.add_day_schedules(I,"engo_eone_bat","engoEoneBat",109,4,true)i.attach(I,{"heat","cool"},5,45,0.5)b(I,m.ts0601_fingerprints{"_TZE200_gtouvmvl"})local o,n="__wave12_sthree_schedule_weekday","__wave12_sthree_schedule_holiday"
local function p(g,an,L,j,w)
if type(g)~="string"or #g<32 then return nil end
local Y={}for s=an,an+L-1 do
local P=s*4+1
local C,y,aA,aB=string.byte(g,P,P+3)Y[#Y+1]=string.format("%02d:%02d/%.1f°C",C,y,(aA*256+aB)/10)end
local au=table.concat(Y," ")j:set_field(w,au,{persist=false})return au
end
local function u(ag,holiday)
if type(ag)~="string"or type(holiday)~="string"then return nil end
local l,L={},0
for ak in string.gmatch(ag.." "..holiday,"%S+")do
local al,ab,K=ak:match"^(%d+):(%d+)/([%d%.%-]+)"local C,y,r=tonumber(al),tonumber(ab),tonumber(K)if C==nil or y==nil or r==nil
or C<0 or C>=24 or y<0 or y>=60
or r<5 or r>=35 then return nil end
local af=math.floor(r*10+0.5)l[#l+1]=C
l[#l+1]=y
l[#l+1]=math.floor(af/256)%256
l[#l+1]=af%256
L=L+1
end
if L~=8 then return nil end
return string.char(table.unpack(l))
end
local function v(w,ac,ai)
return function(j,g)
j:set_field(w,g,{persist=false})local ao=j:get_field(ac)local l=ai and u(g,ao)or u(ao,g)if l==nil then return nil end
return{{dp=109,datatype=e.DP_TYPE_RAW,value=l}}
end
end
local R={profile="thermostats-wave12-moes-zht-s03",package_group="wall-2",query_on_configure=false,time_start="1970",e.dp_binary(1,{name="system_mode",read_only=true,
converter=d.from_only(function(g)return g==true and"heat"or"off"end),
emit=h.thermostat_mode()}),a.enum(2,"moes_zht_sthree_preset","moesZhtSthreePreset",{schedule=0,manual=1}),a.binary(10,"moes_zht_sthree_frost_protection","moesZhtSthreeFrostProtection",{ON=true,OFF=false}),e.dp_current_heating_setpoint(16,{scale=10,emit=h.heating_setpoint"C"}),e.dp_local_temperature(24,{scale=10,read_only=true,emit=h.temperature"C"}),a.enum(31,"moes_zht_sthree_working_day","moesZhtSthreeWorkingDay",{mon_fri=0,mon_sat=1,mon_sun=2}),e.dp_running_state(36,{name="running_state",read_only=true,converter=d.from_only(d.lookup_value{[0]="idle",[1]="heating",[2]="cooling"}),emit=h.thermostat_operating_state()}),a.binary(40,"moes_zht_sthree_child_lock","moesZhtSthreeChildLock",{LOCK=true,UNLOCK=false}),
e.dp_raw(67,{read_only=true,from_device=function(g,j)
p(g,0,6,j,o)p(g,6,2,j,n)return nil
end}),
a.raw(67,"moes_zht_sthree_schedule_weekday","moesZhtSthreeScheduleWeekday",d.from_only(function(g,j)
return p(g,0,6,j,o)
end),true),
a.raw(68,"moes_zht_sthree_schedule_holiday","moesZhtSthreeScheduleHoliday",d.from_only(function(g,j)
return p(g,6,2,j,n)
end),true),
a.numeric(109,"moes_zht_sthree_temp_calibration","moesZhtSthreeTempCalibration",10,false,{signed=true}),a.numeric(112,"moes_zht_sthree_temperature_delta","moesZhtSthreeTemperatureDelta",10,false)}local z=e.build_named_map(R,"name")z.moes_zht_sthree_schedule_weekday=v(o,n,true)z.moes_zht_sthree_schedule_holiday=v(n,o,false)R.named_mapping={named_mappings=z}i.attach(R,{"off","heat"},5,35,0.5)b(R,m.ts0601_fingerprints{"_TZE204_zxkwaztm"})local V=d.from_to(
function(g)
local k=tonumber(g)if k==nil then return nil end
return k>200 and k-256 or k
end,
function(g)
local k=tonumber(g)if k==nil then return nil end
return k<0 and 256+k or k
end
)local sr={profile="thermostats-wave12-moes-zht-sr",package_group="wall-2",query_on_configure=false,time_start="1970",e.dp_binary(1,{name="system_mode",converter=d.lookup_from_to{off=false,heat=true},emit=h.thermostat_mode()}),a.enum(2,"moes_zht_sr_preset","moesZhtSrPreset",{Manual=0,["Temporary manual"]=1,Program=2,Eco=3},false,true),e.dp_local_temperature(16,{scale=10,read_only=true,emit=h.temperature"C"}),a.numeric(18,"moes_zht_sr_min_limit","moesZhtSrMinLimit",10,false),a.enum(32,"moes_zht_sr_sensor_mode","moesZhtSrSensorMode",{IN=0,AL=1,OU=2},true,true),a.numeric(34,"moes_zht_sr_max_limit","moesZhtSrMaxLimit",10,false),a.binary(39,"moes_zht_sr_child_lock","moesZhtSrChildLock",{LOCK=true,UNLOCK=false}),e.dp_running_state(47,{name="running_state",read_only=true,converter=d.from_only(d.lookup_value{[0]="heating",[1]="idle"}),emit=h.thermostat_operating_state()}),a.numeric(48,"moes_zht_sr_backlight","moesZhtSrBacklight",1,false),e.dp_current_heating_setpoint(50,{scale=10,emit=h.heating_setpoint"C"}),a.numeric(101,"moes_zht_sr_temp_calibration","moesZhtSrTempCalibration",1,false,{converter=V}),a.numeric(109,"moes_zht_sr_floor_temperature","moesZhtSrFloorTemperature",10,true),a.numeric(110,"moes_zht_sr_deadzone","moesZhtSrDeadzone",10,false),a.numeric(111,"moes_zht_sr_high_protection","moesZhtSrHighProtection",10,false),a.numeric(112,"moes_zht_sr_low_protection","moesZhtSrLowProtection",10,false),a.numeric(113,"moes_zht_sr_eco_temperature","moesZhtSrEcoTemperature",10,false),a.enum(114,"moes_zht_sr_screen_time","moesZhtSrScreenTime",{["10_seconds"]=0,["20_seconds"]=1,["30_seconds"]=2,["40_seconds"]=3,["50_seconds"]=4,["60_seconds"]=5},false,true),a.binary(115,"moes_zht_sr_rgb_light","moesZhtSrRgbLight",{ON=true,OFF=false})}i.attach(sr,{"off","heat"},5,45,0.5)b(sr,m.ts0601_fingerprints{"_TZE204_lpedvtvr"})local ad,X={standby=0,comfort=1,comfort_1=2,comfort_2=3,eco=4,antifrost=5,program=6,thermostat=7},{off=0,comfort=1,comfort_1=2,comfort_2=3,eco=4,antifrost=5,program=6,thermostat=7}local ap={profile="thermostats-wave12-moes-pilot",package_group="wall-2",query_on_configure=false,time_start="1970",a.enum(2,"moes_pilot_mode","moesPilotMode",ad),e.dp_system_mode(2,{name="system_mode",read_only=true,converter=d.from_only(d.lookup_value{[0]="off",[6]="auto",[7]="heat"}),emit=h.thermostat_mode()}),a.enum(2,"moes_pilot_preset","moesPilotPreset",X),e.dp_local_temperature(16,{scale=10,read_only=true,emit=h.temperature"C"}),a.enum(17,"moes_pilot_window_open","moesPilotWindowOpen",{close=0,open=1},true),a.numeric(18,"moes_pilot_lower_temperature","moesPilotLowerTemperature",10,false),a.numeric(19,"moes_pilot_temp_calibration","moesPilotTempCalibration",10,false,{signed=true}),a.binary(29,"moes_pilot_window_detection","moesPilotWindowDetection",{ON=true,OFF=false}),a.numeric(34,"moes_pilot_upper_temperature","moesPilotUpperTemperature",10,false),a.binary(39,"moes_pilot_child_lock","moesPilotChildLock",{LOCK=true,UNLOCK=false}),a.enum(46,"moes_pilot_temp_unit","moesPilotTempUnit",{c=0,f=1}),e.dp_current_heating_setpoint(50,{scale=10,emit=h.heating_setpoint"C"}),a.numeric(102,"moes_pilot_boost_duration","moesPilotBoostDuration",1,false),a.numeric(103,"moes_pilot_electricity","moesPilotElectricity",10,true),a.numeric(104,"moes_pilot_daily_energy","moesPilotDailyEnergy",1,true),a.numeric(105,"moes_pilot_monthly_energy","moesPilotMonthlyEnergy",1,true),a.numeric(106,"moes_pilot_yearly_energy","moesPilotYearlyEnergy",1,true),a.numeric(110,"moes_pilot_window_keep_time","moesPilotWindowKeepTime",1,false),a.enum(113,"moes_pilot_running_mode","moesPilotRunningMode",{standby=0,comfort=1,comfort_1=2,comfort_2=3,eco=4,antifrost=5},true)}i.attach(ap,{"off","heat","auto"},5,30,0.5)b(ap,m.ts0601_fingerprints{"_TZE204_x9usygq1"})local W={weekday={{6,0,20},{8,0,16},{11,30,20},{12,30,16},{17,0,20},{22,0,16}},weekend={{8,0,20},{23,0,16}}}
local function t(q,s,w)
return string.format("__wave12_sone_%s_%d_%s",q,s,w)
end
local function E(j)
local l={}for _,q in ipairs{"weekday","weekend"}do
for s,H in ipairs(W[q])do
local C,y,r=j:get_field(t(q,s,"hour")),j:get_field(t(q,s,"minute")),j:get_field(t(q,s,"temp"))l[#l+1]=math.floor(tonumber(C)or H[1])l[#l+1]=math.floor(tonumber(y)or H[2])l[#l+1]=math.floor(tonumber(r)or H[3])end
end
return string.char(table.unpack(l))
end
local function A(q,s,w,aa)
local ax=t(q,s,w)return d.from_to(
function(g,j)
if type(g)~="string"or #g<24 then return nil end
local k=string.byte(g,aa)j:set_field(ax,k,{persist=false})return k
end,
function(g,j)
local k=tonumber(g)if k==nil then return nil end
j:set_field(ax,k,{persist=false})return E(j)
end
)
end
local function aj(g)
local k=math.floor(tonumber(g)or 0)if k==0 then return"none"end
local x={}if k%2>=1 then x[#x+1]="e1"end
if math.floor(k/2)%2>=1 then x[#x+1]="e2"end
if math.floor(k/4)%2>=1 then x[#x+1]="e3"end
return #x>0 and table.concat(x,"_")or"none"
end
local Z={profile="thermostats-wave12-moes-zht-s01",package_group="wall-2",query_on_configure=false,time_start="1970",force_time_updates=true,e.dp_binary(1,{name="system_mode",converter=d.lookup_from_to{off=false,heat=true},emit=h.thermostat_mode()}),a.enum(2,"moes_zht_sone_preset","moesZhtSonePreset",{auto=0,manual=1,eco=2}),a.enum(3,"moes_zht_sone_backlight","moesZhtSoneBacklight",{off=0,low=1,medium=2,high=3}),a.numeric(19,"moes_zht_sone_temp_calibration","moesZhtSoneTempCalibration",1,false,{signed=true}),a.enum(20,"moes_zht_sone_fault_alarm","moesZhtSoneFaultAlarm",{none=0,e1=1,e2=2,e3=4,e1_e2=3,e1_e3=5,e2_e3=6,e1_e2_e3=7},true,true),a.enum(32,"moes_zht_sone_sensor","moesZhtSoneSensor",{internal=0,external=1,both=2}),a.binary(39,"moes_zht_sone_child_lock","moesZhtSoneChildLock",{LOCK=true,UNLOCK=false}),a.enum(46,"moes_zht_sone_temperature_scale","moesZhtSoneTemperatureScale",{celsius=0,fahrenheit=1}),e.dp_running_state(47,{name="running_state",read_only=true,converter=d.from_only(d.lookup_value{[0]="heating",[1]="idle"}),emit=h.thermostat_operating_state()}),a.enum(47,"moes_zht_sone_valve_state","moesZhtSoneValveState",{OPEN=0,CLOSED=1},true),a.numeric(101,"moes_zht_sone_floor_temperature","moesZhtSoneFloorTemperature",10,true),a.binary(103,"moes_zht_sone_antifreeze","moesZhtSoneAntifreeze",{ON=true,OFF=false}),a.enum(104,"moes_zht_sone_program_mode","moesZhtSoneProgramMode",{off=0,weekend=1,single_break=2,no_day_off=3}),a.numeric(106,"moes_zht_sone_deadzone","moesZhtSoneDeadzone",10,false),a.numeric(107,"moes_zht_sone_eco_temperature","moesZhtSoneEcoTemperature",1,false),e.dp_current_heating_setpoint(111,{scale=10,emit=h.heating_setpoint"C"}),a.numeric(114,"moes_zht_sone_max_limit","moesZhtSoneMaxLimit",10,false),a.numeric(116,"moes_zht_sone_min_limit","moesZhtSoneMinLimit",10,false),e.dp_local_temperature(117,{scale=10,read_only=true,emit=h.temperature"C"})}Z[5].from_device=aj
local Q={{key="weekday",words={"One","Two","Three","Four","Five","Six"},count=6,base=1},{key="weekend",words={"One","Two"},count=2,base=19}}for _,q in ipairs(Q)do
for s=1,q.count do
local word,az=q.words[s],q.base+(s-1)*3
for P,w in ipairs{"hour","minute","temp"}do
local title=w=="hour"and"Hour"or w=="minute"and"Minute"or"Temp"Z[#Z+1]=a.raw(108,string.format("moes_zht_sone_%s_%d_%s",q.key,s,w),"moesZhtSone"..(q.key=="weekday"and"Weekday"or"Weekend")..word ..title,A(q.key,s,w,az+P-1),false)end
end
end
i.attach(Z,{"off","heat"},5,35,0.5)b(Z,m.ts0601_fingerprints{"_TZE284_rlytpmij"})local am={profile="thermostats-wave12-namron-touch",package_group="wall-2",query_on_configure=false,time_start="2000",e.dp_binary(1,{name="system_mode",converter=d.lookup_from_to{off=false,heat=true},emit=h.thermostat_mode()}),a.enum(2,"namron_touch_preset","namronTouchPreset",{manual=0,home=1,away=2}),e.dp_current_heating_setpoint(16,{scale=1,emit=h.heating_setpoint"C"}),e.dp_local_temperature(24,{scale=1,read_only=true,emit=h.temperature"C"}),a.numeric(28,"namron_touch_temp_calibration","namronTouchTempCalibration",1,false,{signed=true}),a.binary(30,"namron_touch_child_lock","namronTouchChildLock",{LOCK=true,UNLOCK=false}),a.numeric(101,"namron_touch_floor_temperature","namronTouchFloorTemperature",1,true),a.enum(102,"namron_touch_sensor","namronTouchSensor",{air_sensor=0,floor_sensor=1,both=2}),a.numeric(103,"namron_touch_hysteresis","namronTouchHysteresis",1,false),e.dp_binary(104,{name="running_state",read_only=true,
converter=d.from_only(function(g)return g==true and"heating"or"idle"end),
emit=h.thermostat_operating_state()}),a.binary(106,"namron_touch_window_detection","namronTouchWindowDetection",{ON=true,OFF=false}),a.numeric(107,"namron_touch_max_protection","namronTouchMaxProtection",1,false),a.enum(108,"namron_touch_mode","namronTouchMode",{regulator=0,thermostat=1}),a.enum(109,"namron_touch_regulator_period","namronTouchRegulatorPeriod",{["15min"]=0,["30min"]=1,["45min"]=2,["60min"]=3,["90min"]=4}),a.numeric(110,"namron_touch_regulator_setpoint","namronTouchRegulatorSetpoint",1,false),e.dp_numeric(120,{name="current",converter=d.divide_by_pair(10),read_only=true,emit=h.current()}),e.dp_numeric(121,{name="voltage",read_only=true,emit=h.voltage()}),e.dp_numeric(122,{name="power",read_only=true,emit=h.power()}),e.dp_numeric(123,{name="energy",converter=d.divide_by_pair(100),read_only=true,emit=h.energy()})}i.attach(am,{"off","heat"},5,35,1)b(am,m.ts0601_fingerprints{"_TZE204_p3lqqy2r"})local ar={profile="thermostats-wave12-beca-bht209",package_group="wall-2",query_on_configure=false,time_start="1970",force_time_updates=true,e.dp_on_off(1,{name="switch",emit=h.switch()}),e.dp_current_heating_setpoint(16,{scale=10,emit=h.heating_setpoint"C"}),a.numeric(18,"beca_bht_deadzone","becaBhtDeadzone",1,false),e.dp_local_temperature(24,{scale=10,read_only=true,emit=h.temperature"C"}),a.numeric(27,"beca_bht_temp_calibration","becaBhtTempCalibration",1,false,{signed=true}),a.numeric(34,"beca_bht_max_limit","becaBhtMaxLimit",1,false),e.dp_numeric(36,{name="running_state",read_only=true,converter=d.from_only(d.lookup_value{[0]="heating",[1]="idle"}),emit=h.thermostat_operating_state()}),a.binary(40,"beca_bht_child_lock","becaBhtChildLock",{LOCK=true,UNLOCK=false}),a.binary(104,"beca_bht_heating_mode","becaBhtHeatingMode",{ON=true,OFF=false})}a.attach_setpoint_range(ar,5,45,0.5)b(ar,m.ts0601_fingerprints{"_TZE284_4cgmagba"})return{id="ef00.thermostats.wave12_wall",registrations=B}

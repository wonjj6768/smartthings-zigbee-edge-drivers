local as,d,e,Z,J=require"st.capabilities",require"protocol.tuya",require"capabilities.events.all",require"contracts.helpers.family",require"contracts.helpers.ef00_thermostat_metadata"local c=d.converter
local af,r=Z.definition_registry()
local function w(ar)
return Z.create_fingerprints("TS0601",ar)
end
local function H(al,az,ay,aK)
al.heating_setpoint_range={minimum=az,maximum=ay,step=aK,unit="C"}
al.runtime_start=function(i)
i:emit_component_event({id="main"},as.thermostatHeatingSetpoint.heatingSetpointRange{value={minimum=az,maximum=ay,step=aK},unit="C"})
end
end
local function z(b)
local f=tonumber(b)if f==nil then
return nil
end
return math.floor(f+0.5)
end
local function ah(b)
local l,L={},1
while true do
local ag=string.find(b,"  ",L,true)if ag==nil then
l[#l+1]=string.sub(b,L)break
end
l[#l+1]=string.sub(b,L,ag-1)L=ag+2
end
return l
end
local function E(b)
if type(b)~="string"then
return nil
end
local aN,aE=b:match"^%s*([%+%-]?)(%d+)"if aE==nil then
return nil
end
local f=tonumber(aE)if aN=="-"then
f=-f
end
return f
end
local function O()
local function D(b)
if type(b)~="string"or #b<36 then
return nil
end
local l={}for R=0,11 do
local aF=1+R*3
local q,minute,I=string.byte(b,aF,aF+2)if q==nil or minute==nil or I==nil then
return nil
end
local a=I/2
local k=a%1==0 and tostring(math.floor(a))or string.format("%.1f",a)l[#l+1]=string.format("%02d:%02d/%s°C",q,minute,k)end
return table.concat(l,"  ")
end
local function M(b)
if type(b)~="string"then
return nil
end
local l=ah(b)if #l<12 then
return nil
end
local p={}for R=1,12 do
local an=l[R]local ap,k=an:match"^([^/]*)/([^/]*)"local V,minute_text
if ap~=nil then
V,minute_text=ap:match"^([^:]*):([^:]*)"end
local q,minute,a=E(V),E(minute_text),E(k)if q==nil or minute==nil or a==nil then
return nil
end
if q<0 or q>=24 or minute<0 or minute>=60
or a<5 or a>=35 then
return nil
end
p[#p+1]=math.floor(q)p[#p+1]=math.floor(minute)p[#p+1]=a*2
end
return string.char(table.unpack(p))
end
return c.from_to(D,M)
end
local o,s,n,C,Y="__wave9_moes_local_temperature","__wave9_moes_temperature_calibration",c.signed_number_pair(1),e.moesBrtTempCalibration(),e.temperature"C"
local function F(i,aL,aq,am)
local b=i:get_field(aL)if b==nil and type(i.get_latest_state)=="function"then
b=i:get_latest_state("main",aq,am)end
return tonumber(b)
end
local function B(b,i)
local f=tonumber(b)if f==nil then
return nil
end
local a=f/10
i:set_field(o,a,{persist=false})return a
end
local function v(b,i,ai,j)
local K=n.from(b,i,ai,j)if K==nil then
return nil
end
local av,a=F(i,s,"concertmirror08464.moesBrtTempCalibration","tempCalibration"),F(i,o,"temperatureMeasurement","temperature")if av~=nil and a~=nil and type(j)=="table"then
j.moes_adjusted_temperature=a+K-av
end
i:set_field(s,K,{persist=false})return K
end
local function x(i,b,ai,j)
local aa,P={},C(i,b,ai,j)if P~=nil then
aa[#aa+1]=P
end
local ak=type(j)=="table"and j.moes_adjusted_temperature or nil
if ak~=nil then
i:set_field(o,ak,{persist=false})local Q=Y(i,ak,ai,j)if Q~=nil then
aa[#aa+1]=Q
end
end
return #aa>0 and aa or nil
end
local aJ={profile="thermostats-wave9-moes-brt100",package_group="trv",query_on_configure=false,time_start="1970",force_time_updates=true,ota_disabled_reason="Frozen Z2M records that the available OTA bricks this device",d.dp_enum(1,{name="moes_brt_preset",converter=c.lookup_from_to{programming=0,manual=1,temporary_manual=2,holiday=3},emit=e.moesBrtPreset()}),d.dp_current_heating_setpoint(2,{scale=1,to_device=z,emit=e.heating_setpoint"C"}),d.dp_local_temperature(3,{from_device=B,read_only=true,emit=e.temperature"C"}),d.dp_binary(4,{name="moes_brt_boost_heating",converter=c.lookup_from_to{ON=true,OFF=false},emit=e.moesBrtBoostHeating()}),d.dp_numeric(5,{name="moes_brt_boost_countdown",read_only=true,emit=e.moesBrtBoostCountdown()}),d.dp_binary(7,{name="running_state",read_only=true,
converter=c.from_only(function(b)
return(b==true or b==1)and"idle"or"heating"
end),
emit=e.thermostat_operating_state()}),d.dp_binary(7,{name="moes_brt_valve_state",read_only=true,
converter=c.from_only(function(b)
return(b==true or b==1)and"CLOSED"or"OPEN"
end),
emit=e.moesBrtValveState()}),d.dp_binary(8,{name="moes_brt_window_detection",converter=c.lookup_from_to{ON=true,OFF=false},emit=e.moesBrtWindowDetection()}),d.dp_binary(9,{name="moes_brt_window",read_only=true,
converter=c.from_only(function(b)
return(b==true or b==1)and"CLOSED"or"OPEN"
end),
emit=e.moesBrtWindow()}),d.dp_child_lock(13,{name="moes_brt_child_lock",converter=c.lookup_from_to{LOCK=true,UNLOCK=false},emit=e.moesBrtChildLock()}),d.dp_battery(14,{read_only=true,emit=e.battery()}),d.dp_raw(101,{name="moes_brt_programming_mode",converter=O(),emit=e.moesBrtProgrammingMode()}),d.dp_numeric(103,{name="moes_brt_boost_time_setting",emit=e.moesBrtBoostTimeSetting()}),d.dp_numeric(104,{name="moes_brt_position",read_only=true,emit=e.moesBrtPosition()}),d.dp_local_temperature_calibration(105,{name="moes_brt_temp_calibration",converter=n,from_device=v,emit=x}),d.dp_binary(106,{name="moes_brt_eco_mode",converter=c.lookup_from_to{ON=true,OFF=false},emit=e.moesBrtEcoMode()}),d.dp_numeric(107,{name="moes_brt_eco_temperature",to_device=z,emit=e.moesBrtEcoTemperature()}),d.dp_numeric(108,{name="moes_brt_max_temperature",to_device=z,emit=e.moesBrtMaxTemperature()}),d.dp_numeric(109,{name="moes_brt_min_temperature",to_device=z,emit=e.moesBrtMinTemperature()})}H(aJ,0,35,1)r(aJ,w{"_TZE200_b6wax7g0","_TZE200_qsoecqlk","_TZE200_6y7kyjga"})local u="__wave9_lidl_setpoint_raw"
local function A(b)
local f=tonumber(b)if f==nil then
return nil
end
local ac=math.floor(f*2+0.5)if ac<=0 then
return 1
end
if ac>=60 then
return 59
end
return ac
end
local function S(b,i)
local ac=tonumber(b)if ac==nil then
return nil
end
if ac>0 and ac<60 then
i:set_field(u,ac,{persist=false})end
return ac/2
end
local function U(b,i)
local ac=A(b)if ac~=nil then
i:set_field(u,ac,{persist=false})end
return ac
end
local function t()
return c.from_to(
function(b)
local f=tonumber(b)return f~=nil and f/2 or nil
end,
A)
end
local function N()
return c.from_to(
function(b)
local f=tonumber(b)if f==nil then
return nil
end
if f>55 then
f=f-4294967296
end
return f/10
end,
function(b)
local f=tonumber(b)if f==nil then
return nil
end
return f*10
end
)
end
local function W(i,b)
if b=="off"then
return{{dp=2,datatype=d.DP_TYPE_ENUM,value=1},{dp=16,datatype=d.DP_TYPE_VALUE,value=0}}end
if b=="auto"then
return{{dp=2,datatype=d.DP_TYPE_ENUM,value=0}}end
if b=="heat"then
return{{dp=2,datatype=d.DP_TYPE_ENUM,value=1},{dp=16,datatype=d.DP_TYPE_VALUE,value=i:get_field(u)or 43}}end
return nil
end
local function aj(i,b)
if b=="boost"then
return{{dp=2,datatype=d.DP_TYPE_ENUM,value=1},{dp=16,datatype=d.DP_TYPE_VALUE,value=60}}end
local aw=({schedule=0,manual=1,holiday=2})[b]if aw==nil then
return nil
end
local at={{dp=2,datatype=d.DP_TYPE_ENUM,value=aw}}if b=="manual"then
at[#at+1]={dp=16,datatype=d.DP_TYPE_VALUE,value=i:get_field(u)or 43}end
return at
end
local function ae()
local function D(b)
if type(b)~="string"or #b<8 then
return nil
end
local T,G,day,q,minute,m,aD,aH=
string.byte(b,1,8)return string.format("%02d-%02d-%02d %02d:%02d/%.1f/%d",T,G,day,q,minute,m/2,aD*256+aH)
end
local function M(b)
if type(b)~="string"then
return nil
end
local T,G,day,q,minute,a,days=
b:match"^(%d+)%-(%d+)%-(%d+) (%d+):(%d+)/([%d%.%-]+)/(%d+)$"T,G,day=tonumber(T),tonumber(G),tonumber(day)q,minute=tonumber(q),tonumber(minute)a,days=tonumber(a),tonumber(days)if T==nil or G==nil or day==nil or q==nil or minute==nil
or a==nil or days==nil then
return nil
end
if T<17 or T>99 then
T=17
else
T=math.floor(T+0.5)end
if G<1 or G>12 then
G=1
else
G=math.floor(G+0.5)end
day=day<1 and 1 or math.floor(day+0.5)%256
if q<0 or q>23 then
q=0
else
q=math.floor(q+0.5)end
if minute<0 or minute>59 then
minute=0
else
minute=math.floor(minute+0.5)end
if a<0.5 or a>29.5 then
a=17
end
if days<1 or days>9999 then
days=1
end
local m=math.floor(a*2+0.5)days=math.floor(days+0.5)return string.char(T,G,day,q,minute,m,math.floor(days/256)%256,days%256)
end
return c.from_to(D,M)
end
local function g(aB)
local function D(b)
if type(b)~="string"or #b<18 then
return nil
end
local l={}for R=1,9 do
local m=string.byte(b,2+(R-1)*2)if m==nil then
return nil
end
if R<9 then
local y=string.byte(b,3+(R-1)*2)if y==nil then
return nil
end
local q,minute=math.floor(y/4),(y%4)*15
l[#l+1]=string.format("%02d:%02d/%.1f",q,minute,m/2)else
l[#l+1]=string.format("END/%.1f",m/2)end
end
return table.concat(l," ")
end
local function M(b)
if type(b)~="string"then
return nil
end
local l={}for an in string.gmatch(b,"%S+")do
l[#l+1]=an
end
if #l~=9 then
return nil
end
local p={aB}for R,an in ipairs(l)do
local a
if R<9 then
local V,minute_text,k=
an:match"^(%d+):(%d+)/([%d%.%-]+)$"local q,minute=tonumber(V),tonumber(minute_text)a=tonumber(k)if q==nil or minute==nil or a==nil
or q<0 or q>24
or(minute~=0 and minute~=15 and minute~=30 and minute~=45)then
return nil
end
if a<0.5 or a>29.5 then
a=17
end
p[#p+1]=math.floor(a*2+0.5)local y=q*4+minute/15
if y<1 then y=1 end
if y>96 then y=96 end
p[#p+1]=math.floor(y+0.5)else
local k=an:match"^END/([%d%.%-]+)$"a=tonumber(k)if a==nil then
return nil
end
if a<0.5 or a>29.5 then
a=17
end
p[#p+1]=math.floor(a*2+0.5)end
end
return string.char(table.unpack(p))
end
return c.from_to(D,M)
end
local function ab(aA,aG)
local au=d.build_named_map(aA,"name")for aM,aI in pairs(aG)do
au[aM]=aI
end
return au
end
local aC={profile="thermostats-wave9-lidl-368308",package_group="trv",query_on_configure=false,time_start="1970",force_time_updates=true,bind_basic_on_configure=true,d.dp_system_mode(2,{name="system_mode",read_only=true,converter=c.from_only(c.lookup_value{[0]="auto",[1]="heat",[2]="auto"}),emit=e.thermostat_mode()}),d.dp_enum(2,{name="lidl_trv_preset",read_only=true,converter=c.from_only(c.lookup_value{[0]="schedule",[1]="manual",[2]="holiday"}),emit=e.lidlTrvPreset()}),d.dp_enum(2,{name="lidl_trv_away_mode",read_only=true,
converter=c.from_only(function(b)
return tonumber(b)==2 and"ON"or"OFF"
end),
emit=e.lidlTrvAwayMode()}),d.dp_current_heating_setpoint(16,{from_device=S,to_device=U,emit=e.heating_setpoint"C"}),d.dp_numeric(16,{name="system_mode_setpoint_sentinel",read_only=true,
from_device=function(b)
local f=tonumber(b)if f==0 then return"off"end
if f==60 then return"heat"end
return nil
end,
emit=e.thermostat_mode()}),d.dp_numeric(16,{name="lidl_trv_preset_setpoint_sentinel",read_only=true,
from_device=function(b)
return tonumber(b)==60 and"boost"or nil
end,
emit=e.lidlTrvPreset()}),d.dp_local_temperature(24,{scale=10,read_only=true,emit=e.temperature"C"}),d.dp_numeric(35,{name="lidl_trv_battery_voltage",read_only=true,converter=c.from_only(c.multiply_by(10)),emit=e.lidlTrvBatteryVoltage()}),d.dp_child_lock(40,{name="lidl_trv_child_lock",converter=c.lookup_from_to{LOCK=true,UNLOCK=false},emit=e.lidlTrvChildLock()}),d.dp_numeric(101,{name="lidl_trv_comfort_temperature",converter=c.divide_by_pair(2),emit=e.lidlTrvComfortTemperature()}),d.dp_numeric(102,{name="lidl_trv_eco_temperature",converter=c.divide_by_pair(2),emit=e.lidlTrvEcoTemperature()}),d.dp_raw(103,{name="lidl_trv_away_setting",converter=ae(),emit=e.lidlTrvAwaySetting()}),d.dp_local_temperature_calibration(104,{name="lidl_trv_temp_calibration",converter=N(),emit=e.lidlTrvTempCalibration()}),d.dp_numeric(105,{name="lidl_trv_auto_setpoint",converter=t(),emit=e.lidlTrvAutoSetpoint()}),d.dp_raw(109,{name="lidl_trv_schedule_monday",converter=g(1),emit=e.lidlTrvScheduleMonday()}),d.dp_raw(110,{name="lidl_trv_schedule_tuesday",converter=g(2),emit=e.lidlTrvScheduleTuesday()}),d.dp_raw(111,{name="lidl_trv_schedule_wednesday",converter=g(3),emit=e.lidlTrvScheduleWednesday()}),d.dp_raw(112,{name="lidl_trv_schedule_thursday",converter=g(4),emit=e.lidlTrvScheduleThursday()}),d.dp_raw(113,{name="lidl_trv_schedule_friday",converter=g(5),emit=e.lidlTrvScheduleFriday()}),d.dp_raw(114,{name="lidl_trv_schedule_saturday",converter=g(6),emit=e.lidlTrvScheduleSaturday()}),d.dp_raw(115,{name="lidl_trv_schedule_sunday",converter=g(7),emit=e.lidlTrvScheduleSunday()}),d.dp_numeric(116,{name="lidl_trv_window_temperature",converter=t(),emit=e.lidlTrvWindowTemperature()}),d.dp_numeric(117,{name="lidl_trv_window_time",emit=e.lidlTrvWindowTime()})}aC.named_mapping={named_mappings=ab(aC,{system_mode=W,lidl_trv_preset=aj})}J.attach(aC,{"off","heat","auto"},0.5,29.5,0.5)r(aC,w{"_TZE200_chyvmhay","_TZE200_uiyqstza"})local ax={profile="thermostats-wave9-evanell-ez200",package_group="trv",query_on_configure=false,time_start="2000",bind_basic_on_configure=true,d.dp_system_mode(2,{name="system_mode",converter=c.lookup_from_to{auto=0,heat=2,off=3},emit=e.thermostat_mode()}),d.dp_current_heating_setpoint(4,{scale=10,emit=e.heating_setpoint"C"}),d.dp_local_temperature(5,{scale=10,read_only=true,emit=e.temperature"C"}),d.dp_battery(6,{read_only=true,emit=e.battery()}),d.dp_child_lock(8,{name="evanell_ez_child_lock",converter=c.lookup_from_to{LOCK=true,UNLOCK=false},emit=e.evanellEzChildLock()})}J.attach(ax,{"off","heat","auto"},5,30,0.5)r(ax,w{"_TZE200_dmfguuli","_TZE200_rxypyjkw"})return{id="ef00.thermostats.wave9_legacy",registrations=af}

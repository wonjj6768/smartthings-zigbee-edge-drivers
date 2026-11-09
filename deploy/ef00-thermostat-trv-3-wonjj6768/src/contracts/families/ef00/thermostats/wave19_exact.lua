local b,t,p,o=require"protocol.tuya",require"capabilities.events.all",require"contracts.helpers.family",require"contracts.helpers.ef00_thermostat_metadata"local c=b.converter
local z,k=p.definition_registry()
local function f(capability_id)
return assert(t[capability_id],"missing Wave19 thermostat emitter: "..capability_id)()
end
local function K(a)
local d=tonumber(a)if d==nil then return nil end
return math.floor(d+0.5)
end
local function ai(a,ad,ac)
local d=tonumber(a)if d==nil then return nil end
return math.max(ad,math.min(ac,d))
end
local function ag(a)
return a==true or a==1
end
local function j(a)
if type(a)~="string"then return nil end
local L={}for B=1,#a do L[#L+1]=tostring(string.byte(a,B))end
return table.concat(L,",")
end
local function v(i,W)
local N=b.build_named_map(i,"name")for am,ab in pairs(W)do N[am]=ab end
return N
end
local function H(ae,i)
i.profile=ae
i.package_group="wave19-thermostat"i.magic_packet=true
i.query_on_configure=true
i.named_datapoints=true
i.time_start="2000"return i
end
local D={[101]="monday",[102]="tuesday",[103]="wednesday",[104]="thursday",[105]="friday",[106]="saturday",[107]="away_or_vacation"}
local function aa(a)
local d=math.floor(tonumber(a)or 0)return string.char(math.floor(d/256)%256,d%256)
end
local function g(dp)
return function(a)
if type(a)~="string"or #a<16 then return nil end
local h={}for B=0,3 do
local V=B*4+1
local O,R,U,X=string.byte(a,V,V+3)h[#h+1]={time=O*256+R,heating_setpoint=string.format("%.1f",(U*256+X)/10)}end
return{days={D[dp]},transitions=h}
end
end
local function A(_,a)
if type(a)~="table"then return nil end
local M={}for _,s in pairs(a)do
if type(s)~="table"then return nil end
local Z,ak,T,h=tonumber(s.dayofweek),tonumber(s.numoftrans),tonumber(s.mode),s.transitions
if Z==nil or Z<1 or Z>7 or T~=1 or type(h)~="table"or ak~=#h or #h<1 or #h>4 then
return nil
end
local q={}for B=1,#h do q[B]=h[B]end
while #q<4 do q[#q+1]=q[#q]end
local u={}for _,E in ipairs(q)do
local S,ah=tonumber(E.transitionTime),tonumber(E.heatSetpoint)if S==nil or ah==nil then return nil end
u[#u+1]=aa(S)u[#u+1]=aa(math.floor(ah*10))end
M[#M+1]={dp=100+Z,datatype=b.DP_TYPE_RAW,value=table.concat(u),transaction=1}end
return M
end
local function y(l,T)
if T=="off"then
return{dp=1,datatype=b.DP_TYPE_BOOL,value=false,transaction=1}end
local r=({heat=0,auto=2})[T]if r==nil then return nil end
if b.send_datapoint(l,1,b.DP_TYPE_BOOL,true,b.SET_DATA,false,1)==nil then return nil end
l.thread:call_with_delay(0.5,function()
b.send_datapoint(l,4,b.DP_TYPE_ENUM,r,b.SET_DATA,false,1)
end,"Wave19 Immax system mode DP delay")
return nil
end
local function x(l,a)
if a=="OFF"then
return{dp=4,datatype=b.DP_TYPE_ENUM,value=0,transaction=1}end
if a~="ON"then return nil end
if b.send_datapoint(l,1,b.DP_TYPE_BOOL,true,b.SET_DATA,false,1)==nil then return nil end
l.thread:call_with_delay(0.5,function()
b.send_datapoint(l,4,b.DP_TYPE_ENUM,1,b.SET_DATA,false,1)
end,"Wave19 Immax away mode DP delay")
return nil
end
local function n(al,af,aj)
return c.from_only(function(a)
return bit32.band(tonumber(a)or 0,al)~=0 and af or aj
end)
end
local J=H("thermostats-wave19-immax-07703l",{b.dp_binary(1,{name="immax_trv_power_mode_report",read_only=true,
from_device=function(a)return ag(a)and nil or"off"end,
emit=t.thermostat_mode()}),b.dp_bitmap(13,{name="immax_trv_high_temperature",read_only=true,converter=n(1,"ON","OFF")}),b.dp_bitmap(13,{name="immax_trv_low_temperature",read_only=true,converter=n(2,"ON","OFF")}),b.dp_bitmap(13,{name="immax_trv_internal_sensor_error",read_only=true,converter=n(4,"ON","OFF")}),b.dp_bitmap(13,{name="immax_trv_external_sensor_error",read_only=true,converter=n(8,"ON","OFF")}),b.dp_bitmap(13,{name="immaxTrv_battery_low",read_only=true,converter=n(16,"low","normal"),emit=f"immaxTrvBatteryLow"}),b.dp_bitmap(13,{name="immax_trv_device_offline",read_only=true,converter=n(32,"ON","OFF")}),b.dp_child_lock(7,{name="immaxTrv_child_lock",converter=c.lookup_from_to{LOCK=true,UNLOCK=false},emit=f"immaxTrvChildLock"}),b.dp_current_heating_setpoint(2,{scale=10,emit=t.heating_setpoint"C"}),b.dp_local_temperature(3,{scale=10,read_only=true,emit=t.temperature"C"}),b.dp_enum(4,{name="system_mode",read_only=true,
converter=c.from_only(function(a)return({[0]="heat",[1]="heat",[2]="auto"})[tonumber(a)]end),
emit=t.thermostat_mode()}),b.dp_enum(4,{name="immaxTrv_away_mode",read_only=true,
converter=c.from_only(function(a)
return({[0]="OFF",[1]="ON",[2]="OFF"})[tonumber(a)]
end),
emit=f"immaxTrvAwayMode"}),b.dp_enum(4,{name="immax_trv_preset",read_only=true,
converter=c.from_only(function(a)
return({[0]="none",[1]="away",[2]="none"})[tonumber(a)]
end)
}),b.dp_binary(14,{name="running_state",read_only=true,
converter=c.from_only(function(a)return ag(a)and"heating"or"idle"end),
emit=t.thermostat_operating_state()}),b.dp_raw(101,{name="immax_weekly_monday",read_only=true,converter=c.from_only(g(101))}),b.dp_raw(102,{name="immax_weekly_tuesday",read_only=true,converter=c.from_only(g(102))}),b.dp_raw(103,{name="immax_weekly_wednesday",read_only=true,converter=c.from_only(g(103))}),b.dp_raw(104,{name="immax_weekly_thursday",read_only=true,converter=c.from_only(g(104))}),b.dp_raw(105,{name="immax_weekly_friday",read_only=true,converter=c.from_only(g(105))}),b.dp_raw(106,{name="immax_weekly_saturday",read_only=true,converter=c.from_only(g(106))}),b.dp_raw(107,{name="immax_weekly_day_seven",read_only=true,converter=c.from_only(g(107))})})J.named_mapping={named_mappings=v(J,{system_mode=y,immaxTrv_away_mode=x,weekly_schedule=A})}o.attach(J,{"off","heat","auto"},5,35,0.5)k(J,{p.create_fingerprint("_TZE200_wlosfena","TS0601")})local m=c.from_to(
function(a)local d=tonumber(a);return d and tonumber(string.format("%.1f",d/2))or nil end,
function(a)
local d=ai(a,0,30)return d and K(d*2)or nil
end
)local P=c.from_to(
function(a)local d=tonumber(a);return d and tonumber(string.format("%.1f",d/10))or nil end,
function(a)
local d=tonumber(a)return d and K(d*10)or nil
end
)local C=c.from_to(
function(a)local d=tonumber(a);return d and tonumber(string.format("%.1f",d/10))or nil end,
function(a)
local d=tonumber(a)if d==nil then return nil end
if d<0 then d=d+4096 end
return K(d*10)
end
)
local function G(l,a)
local r,Y=({auto=0,heat=1})[a],({auto=220,heat=170})[a]if r==nil then return nil end
if b.send_datapoint(l,2,b.DP_TYPE_ENUM,r,b.SET_DATA,false,1)==nil then return nil end
return{dp=119,datatype=b.DP_TYPE_VALUE,value=Y,transaction=1}
end
local function F(l,a)
if a=="ON"then
return{dp=2,datatype=b.DP_TYPE_ENUM,value=2,transaction=1}end
if b.send_datapoint(l,2,b.DP_TYPE_ENUM,0,b.SET_DATA,false,1)==nil then return nil end
return{dp=119,datatype=b.DP_TYPE_VALUE,value=220,transaction=1}
end
local function w(_,a)
local d=tonumber(a)if d==nil then return nil end
return{dp=119,datatype=b.DP_TYPE_VALUE,value=K(d*10),transaction=1}
end
local function e()return nil end
local Q=H("thermostats-wave19-woox-r7067",{b.dp_enum(2,{name="system_mode",read_only=true,
converter=c.from_only(function(a)
return({[0]="auto",[1]="heat",[2]="auto"})[tonumber(a)]or"off"
end),
emit=t.thermostat_mode()}),b.dp_enum(2,{name="wooxTrv_away_mode",read_only=true,
converter=c.from_only(function(a)return tonumber(a)==2 and"ON"or"OFF"end),
emit=f"wooxTrvAwayMode"}),b.dp_numeric(16,{name="woox_manual_setpoint_report",read_only=true,converter=m,emit=t.heating_setpoint"C"}),b.dp_numeric(105,{name="woox_auto_setpoint_report",read_only=true,converter=m,emit=t.heating_setpoint"C"}),b.dp_numeric(24,{name="local_temperature",read_only=true,converter=P,emit=t.temperature"C"}),b.dp_numeric(104,{name="wooxTrv_temperature_calibration",converter=C,emit=f"wooxTrvTemperatureCalibration"}),b.dp_raw(107,{name="wooxTrv_window_detection",read_only=true,
converter=c.from_only(function(a)
if type(a)~="string"or #a<1 then return nil end
return string.byte(a,1)~=0 and"OPEN"or"CLOSED"
end),
emit=f"wooxTrvWindowDetection"}),b.dp_numeric(116,{name="wooxTrv_window_temperature",converter=m,emit=f"wooxTrvWindowTemperature"}),b.dp_numeric(117,{name="wooxTrv_window_time",emit=f"wooxTrvWindowTime"}),b.dp_binary(30,{name="wooxTrv_child_lock",converter=c.lookup_from_to{LOCK=true,UNLOCK=false},emit=f"wooxTrvChildLock"}),b.dp_numeric(34,{name="woox_hidden_battery",read_only=true}),b.dp_numeric(34,{name="woox_hidden_battery_low",read_only=true,
from_device=function(a)return(tonumber(a)or 0)<30 and 1 or 0 end
}),b.dp_numeric(118,{name="wooxTrv_boost_time",read_only=true,emit=f"wooxTrvBoostTime"}),b.dp_numeric(102,{name="wooxTrv_eco_temperature",converter=m,emit=f"wooxTrvEcoTemperature"}),b.dp_numeric(101,{name="wooxTrv_comfort_temperature",converter=m,emit=f"wooxTrvComfortTemperature"}),b.dp_binary(106,{name="wooxTrv_boost_heating",converter=c.lookup_from_to{ON=true,OFF=false},emit=f"wooxTrvBoostHeating"}),b.dp_numeric(45,{name="wooxTrv_error_status",read_only=true,emit=f"wooxTrvErrorStatus"}),b.dp_raw(103,{name="wooxTrv_holidays_schedule",read_only=true,converter=c.from_only(j),emit=f"wooxTrvHolidaysSchedule"}),b.dp_raw(109,{name="wooxTrv_monday_schedule",read_only=true,converter=c.from_only(j),emit=f"wooxTrvMondaySchedule"}),b.dp_raw(110,{name="wooxTrv_tuesday_schedule",read_only=true,converter=c.from_only(j),emit=f"wooxTrvTuesdaySchedule"}),b.dp_raw(111,{name="wooxTrv_wednesday_schedule",read_only=true,converter=c.from_only(j),emit=f"wooxTrvWednesdaySchedule"}),b.dp_raw(112,{name="wooxTrv_thursday_schedule",read_only=true,converter=c.from_only(j),emit=f"wooxTrvThursdaySchedule"}),b.dp_raw(113,{name="wooxTrv_friday_schedule",read_only=true,converter=c.from_only(j),emit=f"wooxTrvFridaySchedule"}),b.dp_raw(114,{name="wooxTrv_saturday_schedule",read_only=true,converter=c.from_only(j),emit=f"wooxTrvSaturdaySchedule"}),b.dp_raw(115,{name="wooxTrv_sunday_schedule",read_only=true,converter=c.from_only(j),emit=f"wooxTrvSundaySchedule"})})Q.bind_basic_on_configure=true
Q.named_mapping={named_mappings=v(Q,{current_heating_setpoint=w,system_mode=G,wooxTrv_away_mode=F,wooxTrv_holidays_schedule=e,wooxTrv_monday_schedule=e,wooxTrv_tuesday_schedule=e,wooxTrv_wednesday_schedule=e,wooxTrv_thursday_schedule=e,wooxTrv_friday_schedule=e,wooxTrv_saturday_schedule=e,wooxTrv_sunday_schedule=e})}o.attach(Q,{"auto","heat"},0,30,0.5)k(Q,{p.create_fingerprint("_TZE200_wnvhlcgl","TS0601")})return{id="ef00.thermostats.wave19.exact",registrations=z}

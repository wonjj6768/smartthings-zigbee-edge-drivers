local g,h,e=require"protocol.tuya",require"capabilities.events.all",require"contracts.helpers.family"local u=g.converter
local S,c=e.definition_registry()
local function m(j,q)
local aa=type(q)=="table"and q.frame or nil
local P=type(aa)=="table"and aa.datapoints or nil
return type(P)~="table"or P[1]==j
end
local function i(Y)
return u.from_only(function(b,N,j,q)
if not m(j,q)then return nil end
return Y(b,N,j,q)
end)
end
local function l(R,V)
return u.from_to(
function(b,N,j,q)
if not m(j,q)then return nil end
return R(b,N,j,q)
end,
V)
end
local function d(b)
if type(b)=="number"then return b end
return nil
end
local function x(b)
if type(b)~="string"or #b~=1 then return nil end
return string.byte(b,1)
end
local function f(b)
local a=d(b)if a~=nil then return a end
return x(b)
end
local function B(b)
local a=x(b)if a==nil then return nil end
if a>=128 then return a-256 end
return a
end
local function C(b)
if b==true then return true end
if b==false then return false end
local a=d(b)if a~=nil then return a~=0 end
return nil
end
local function t(b,_,j)
if type(j)=="table"and type(j.signed_value)=="number"then
return j.signed_value
end
local a=d(b)if a~=nil and a>0x7FFFFFFF then
return a-4294967296
end
return a
end
local function o(b,N,j)
if type(b)=="string"then
return B(b)end
return t(b,N,j)
end
local function Z(b)
local a=tonumber(b)if a==nil then return nil end
return string.char(math.floor(a)%256)
end
local F=i(function(b)
local a=d(b)if a==nil then return nil end
return a>0 and a<5
end)
local p=i(d)local L=l(
function(b)
local a=f(b)if a==1 then return"enabled"end
if a==0 then return"disabled"end
return nil
end,
function(b)
if b=="enabled"then return string.char(1)end
if b=="disabled"then return string.char(0)end
return nil
end
)local y=l(
function(b)
local a=f(b)if a==nil or a<0 or a>7 then return nil end
return tostring(math.floor(a))
end,
function(b)
local a=tonumber(b)if a==nil or a<0 or a>7 then return nil end
return string.char(math.floor(a))
end
)local n={[25]="25",[50]="50",[75]="75",[100]="100"}local w=l(
function(b)
return n[f(b)]
end,
function(b)
local a=tonumber(b)if n[a]==nil then return nil end
return string.char(a)
end
)local v=l(o,Z)
local function D(T,ac,Q)
return{profile="safety-wave19-javis-microwave",named_datapoints=true,magic_packet=false,query_on_configure=false,time_start="off",datapoints={g.dp_enum(1,{name="motion",endpoint=1,transaction=1,read_only=true,converter=F,emit=h.motion()}),g.dp_numeric(101,{name="illuminance_primary",endpoint=1,transaction=1,read_only=true,converter=p,emit=h.illuminance()}),g.dp_numeric(104,{name="illuminance_secondary",endpoint=1,transaction=1,read_only=true,converter=p,emit=h.illuminance()}),g.dp_raw(2,{name="javis_mc_sensitivity",endpoint=1,transaction=1,converter=w,emit=h.javisMcSensitivity()}),g.dp_raw(T,{name="javis_mc_keep_time",endpoint=1,transaction=1,converter=y,emit=h.javisMcKeepTime()}),g.dp_raw(ac,{name="javis_mc_led_enable",endpoint=1,transaction=1,converter=L,emit=h.javisMcLedEnable()}),g.dp_raw(Q,{name="javis_mc_illuminance_calibration",endpoint=1,transaction=1,converter=v,emit=h.javisMcIlluminanceCalibration()})}}
end
c(D(102,103,105),{e.create_fingerprint("_TZE200_i0b1dbqu","TS0601"),e.create_fingerprint("_TZE200_lgstepha","TS0601")})c(D(106,107,102),{e.create_fingerprint("_TZE200_kagkgk0i","TS0601")})local G,O={[0]="battery_full",[1]="battery_high",[2]="battery_medium",[3]="battery_low",[4]="usb"},{[0]="over_temperature",[1]="over_humidity",[2]="below_min_temperature",[3]="below_min_humdity",[4]="off"}
local J=i(function(b)
local ab=C(b)return ab
end)
local E=i(function(b)
return G[d(b)]
end)
local z=i(function(b)
local a=d(b)if a==nil then return nil end
return a==3 and"low"or"normal"
end)
local K=i(C)
local A=i(function(b)
local a=d(b)if a==nil then return nil end
return a/10
end)
local r,k=l(d,d),l(t,d)
local M=i(function(b)
return O[d(b)]
end)
local s=l(
function(b)
local X=C(b)if X==nil then return nil end
return X and"celsius"or"fahrenheit"
end,
function(b)
if b=="celsius"then return true end
if b=="fahrenheit"then return false end
return nil
end
)local U={profile="safety-wave19-neo-nas-pd07",named_datapoints=true,magic_packet=true,query_on_configure=false,mcu_version_request_on_configure=true,time_start="off",datapoints={g.dp_binary(101,{name="motion",endpoint=1,transaction=1,read_only=true,converter=J,emit=h.motion()}),g.dp_enum(102,{name="neo_nas_pd_seven_power_type",endpoint=1,transaction=1,read_only=true,converter=E,emit=h.neoNasPdSevenPowerType()}),g.dp_enum(102,{name="neo_nas_pd_seven_battery_low",endpoint=1,transaction=1,read_only=true,converter=z,emit=h.neoNasPdSevenBatteryLow()}),g.dp_binary(103,{name="tamper",endpoint=1,transaction=1,read_only=true,converter=K,emit=h.tamper()}),g.dp_numeric(104,{name="temperature",endpoint=1,transaction=1,read_only=true,converter=A,emit=h.temperature()}),g.dp_numeric(105,{name="humidity",endpoint=1,transaction=1,read_only=true,converter=i(d),emit=h.humidity()}),g.dp_numeric(107,{name="neo_nas_pd_seven_minimum_temperature",endpoint=1,transaction=1,signed=true,converter=k,emit=h.neoNasPdSevenTemperatureMin()}),g.dp_numeric(108,{name="neo_nas_pd_seven_maximum_temperature",endpoint=1,transaction=1,signed=true,converter=k,emit=h.neoNasPdSevenTemperatureMax()}),g.dp_binary(106,{name="neo_nas_pd_seven_temperature_scale",endpoint=1,transaction=1,converter=s,emit=h.neoNasPdSevenTemperatureScale()}),g.dp_numeric(109,{name="neo_nas_pd_seven_minimum_humidity",endpoint=1,transaction=1,converter=r,emit=h.neoNasPdSevenHumidityMin()}),g.dp_numeric(110,{name="neo_nas_pd_seven_maximum_humidity",endpoint=1,transaction=1,converter=r,emit=h.neoNasPdSevenHumidityMax()}),g.dp_enum(113,{name="neo_nas_pd_seven_alarm",endpoint=1,transaction=1,read_only=true,converter=M,emit=h.neoNasPdSevenAlarm()})}}c(U,{e.create_fingerprint("_TZE200_7hfcudw5","TS0601")})local W={profile="safety-presence-mw833p-core",query_on_configure=false,time_start="off",datapoints={g.dp_enum(1,{name="presence",read_only=true,converter=u.true_false1(),emit=h.presence()}),g.dp_illuminance(103,{read_only=true,emit=h.illuminance()})}}c(W,{e.create_fingerprint("_TZE200_ops9sidw","TS0601")})local I={profile="safety-presence-r12z20-core",query_on_configure=false,time_start="off",datapoints={g.dp_enum(1,{name="presence",read_only=true,converter=u.true_false0(),emit=h.presence()}),g.dp_illuminance(101,{read_only=true,emit=h.illuminance()})}}c(I,e.create_fingerprints("TS0601",{"_TZE284_h7oalfxa","_TZE2841000000_h7oalfxa"}))local H={profile="safety-presence-b08lrt-core",query_on_configure=false,time_start="off",datapoints={g.dp_enum(1,{name="presence",read_only=true,converter=u.true_false0(),emit=h.presence()}),g.dp_illuminance(101,{read_only=true,emit=h.illuminance()}),g.dp_temperature(22,{read_only=true,emit=h.temperature()}),g.dp_humidity(23,{scale=1,read_only=true,emit=h.humidity()})}}c(H,e.create_fingerprints("TS0601",{"_TZE284_cipobaav","_TZE2841000000_cipobaav"}))return{id="ef00.presence.wave19.sensors",registrations=S}

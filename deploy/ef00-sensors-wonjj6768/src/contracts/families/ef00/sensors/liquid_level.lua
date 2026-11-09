local f,e,k=require"protocol.tuya",require"capabilities.events.all",require"contracts.helpers.family"local d=f.converter
local M,o=k.definition_registry()
local function g(m,A)
if type(m)=="table"then
local U={}for an,n in pairs(m)do
U[an]=n
end
if U.query_on_configure==nil then
U.query_on_configure=true
end
o(U,A)return
end
o({datapoints=m,query_on_configure=true},A)
end
local N={profile="sensors-liquid-level-872wz",force_time_updates=true,time_start="1970",datapoints={f.dp_enum(1,{name="liquid_state",emit=e.liquid_state(),read_only=true,converter=d.from_only(d.lookup_value{[0]="normal",[1]="low",[2]="high"})}),f.dp_numeric(2,{name="liquid_depth",emit=e.wls872LiquidDepth(),read_only=true,converter=d.divide_by_pair(100)}),f.dp_numeric(7,{name="max_set",emit=e.wls872MaximumPercent()}),f.dp_numeric(8,{name="min_set",emit=e.wls872MinimumPercent()}),f.dp_binary(9,{name="silent_mode",emit=e.wls872SilentMode(),converter=d.lookup_from_to{on=true,off=false}}),f.dp_numeric(19,{name="installation_height",emit=e.wls872InstallationHeight(),converter=d.divide_by_pair(100)}),f.dp_numeric(21,{name="liquid_depth_max",emit=e.wls872MaximumDepth(),converter=d.divide_by_pair(100)}),f.dp_numeric(22,{name="liquid_level_percent",emit=e.liquid_level_percent(),read_only=true}),f.dp_numeric(27,{name="alarm_time",emit=e.wls872AlarmDuration()})},query_on_configure=true}g(N,{k.create_fingerprint("_TZE204_7yyuo8sr","TS0601")})local j,p,R,q,l,W="__me201wz_candidate","__me201wz_pending_state",2,{persist=false},{persist=true},{[0]="normal",[1]="low",[2]="high"}

local function w(i)
if i.datatype==R then
return i.signed_value
end
return i.value
end
local function r(b,u)
local ac=u.frame
if ac.me201wz==nil then
ac.me201wz={state={liquid_depth=b:get_field"liquid_depth",liquid_level_percent=b:get_field"liquid_level_percent",liquid_state=b:get_field"liquid_state",installation_height=b:get_field"installation_height",liquid_depth_max=b:get_field"liquid_depth_max",min_set=b:get_field"min_set",max_set=b:get_field"max_set"}}end
return ac.me201wz
end
local function X(b,a,K)
local O,Q,z,ag,C,E=a.liquid_depth,a.liquid_level_percent,K.liquid_depth,K.installation_height,K.liquid_depth_max,false


if O~=nil then
if O<0 or(ag~=nil and O>ag)then
E=true
elseif z~=nil and math.abs(O-z)>0.05 then
local L,al=b:get_field(j),math.floor(require"cosock.socket".gettime()*1000)if L~=nil and math.abs(O-L.depth)<=0.03 then
E=al-L.since<43200000
else
b:set_field(j,{depth=O,since=al},q)E=true
end
end
if not E then
b:set_field(j,nil,q)end
elseif Q~=nil and z~=nil and C~=nil and C~=0 then
E=math.abs(Q-math.min(100,z/C*100))>5/C
end
if E then
a.liquid_depth,a.liquid_level_percent,a.liquid_state=nil,nil,nil
return a
end
local T,S,G=K.min_set,K.max_set,Q

if G==nil then G=K.liquid_level_percent end
if T==nil or S==nil or G==nil then return a end
local function Z(n)
return(n=="low"and G<=T+1)or(n=="high"and G>=S-1)or(n=="normal"and G>=T-1 and G<=S+1)
end
if a.liquid_state~=nil and not Z(a.liquid_state)then
b:set_field(p,a.liquid_state,q)a.liquid_state=nil
elseif a.liquid_state==nil and Q~=nil then
local P=b:get_field(p)if P~=nil and P~=K.liquid_state and Z(P)then
a.liquid_state=P
end
end
if a.liquid_state~=nil then
b:set_field(p,nil,q)end
return a
end
local function h(_,b,_,u)
local F=r(b,u)if F.result==nil then
local B={}for _,i in ipairs(u.frame.datapoints)do
if i.dp==1 or i.dp==2 or i.dp==22 then
B[i.dp]=w(i)end
end
local a={}if B[1]~=nil then a.liquid_state=W[B[1]]end
if B[2]~=nil then a.liquid_depth=B[2]/100 end
if B[22]~=nil then a.liquid_level_percent=B[22]end
F.result=X(b,a,F.state)end
return F.result
end
local function v(ad,aa,Y)
return function(b,a,_,u)
local F=r(b,u)if F.emitted then return end
F.emitted=true
local x={}if a.liquid_state~=nil then
b:set_field("liquid_state",a.liquid_state,l)x[#x+1]=ad(b,a.liquid_state)end
if a.liquid_depth~=nil then
b:set_field("liquid_depth",a.liquid_depth,l)x[#x+1]=aa(b,a.liquid_depth)end
if a.liquid_level_percent~=nil then
b:set_field("liquid_level_percent",a.liquid_level_percent,l)x[#x+1]=Y(b,a.liquid_level_percent)end
if #x>0 then return x end
end
end
local function c(dp,ak,ab,aj,ai,V)
local function af(n)
if type(n)~="number"or n~=n or n<aj or n>ai then return end
if V==1 and n%1~=0 then return end
local ah=n*V
local D=math.floor(ah+0.5)if math.abs(ah-D)>0.0000001 then return end
return D
end
return f.dp_numeric(dp,{name=ak,emit=ab,persist=true,
from_device=function(_,b,i,u)
r(b,u)return w(i)/V
end,
to_device=af,
optimistic_value=function(n,b)
local D=af(n)if D==nil then return end
local ae=D/V
b:set_field(ak,ae,l)return ae
end
})
end
local function y(_,_,i)
return w(i)/10
end
local s,t=v(e.me201LiquidState(),e.me201DepthV2(),e.me201LevelPercent()),v(e.me202LiquidState(),e.me202DepthV2(),e.me202LevelPercent())local H={profile="sensors-liquid-level-me201wz",force_time_updates=true,time_start="off",datapoints={f.dp_enum(1,{name="liquid_state",field=false,emit=s,read_only=true,from_device=h}),f.dp_numeric(2,{name="liquid_depth",field=false,emit=s,read_only=true,from_device=h}),f.dp_numeric(5,{name="voltage",emit=e.voltage(),read_only=true,from_device=y}),c(7,"max_set",e.me201MaximumPercentV2(),0,100,1),c(8,"min_set",e.me201MinimumPercentV2(),0,100,1),c(19,"installation_height",e.me201InstallationHeightV2(),0.1,5,100),c(21,"liquid_depth_max",e.me201MaximumDepthV2(),0.1,5,100),f.dp_numeric(22,{name="liquid_level_percent",field=false,emit=s,read_only=true,from_device=h}),f.dp_binary(24,{name="relay_switch",emit=e.me201RelaySwitch(),converter=d.lookup_from_to{on=true,off=false}}),f.dp_binary(101,{name="pump_mode",emit=e.me201PumpMode(),converter=d.lookup_from_to{supply=true,drainage=false}}),f.dp_binary(102,{name="pump_control",emit=e.me201PumpControl(),converter=d.lookup_from_to{auto=true,manual=false}}),f.dp_string(103,{name="version",emit=e.me201Version(),read_only=true})},query_on_configure=true}g(H,{k.create_fingerprint("_TZE284_kyyu8rbj","TS0601")})local J={profile="sensors-liquid-level-tlc2206",force_time_updates=true,time_start="1970",datapoints={f.dp_enum(1,{name="liquid_state",emit=e.liquid_state(),read_only=true,converter=d.from_only(d.lookup_value{[0]="normal",[1]="low",[2]="high"})}),f.dp_numeric(2,{name="liquid_depth",emit=e.tlc2206LiquidDepth(),read_only=true,converter=d.divide_by_pair(100)}),f.dp_numeric(7,{name="max_set",emit=e.tlc2206MaximumPercent()}),f.dp_numeric(8,{name="min_set",emit=e.tlc2206MinimumPercent()}),f.dp_numeric(19,{name="installation_height",emit=e.tlc2206InstallationHeight(),converter=d.divide_by_pair(1000)}),f.dp_numeric(21,{name="liquid_depth_max",emit=e.tlc2206MaximumDepth(),converter=d.divide_by_pair(1000)}),f.dp_numeric(22,{name="liquid_level_percent",emit=e.liquid_level_percent(),read_only=true})},query_on_configure=true}g(J,{k.create_fingerprint("_TZE200_lvkk0hdg","TS0601")})local I={profile="sensors-liquid-level-me202wz",force_time_updates=true,time_start="off",datapoints={f.dp_enum(1,{name="liquid_state",field=false,emit=t,read_only=true,from_device=h}),f.dp_numeric(2,{name="liquid_depth",field=false,emit=t,read_only=true,from_device=h}),f.dp_numeric(5,{name="voltage",emit=e.voltage(),read_only=true,from_device=y}),c(7,"max_set",e.me202MaximumPercentV2(),0,100,1),c(8,"min_set",e.me202MinimumPercentV2(),0,100,1),c(21,"liquid_depth_max",e.me202MaximumDepthV2(),0.1,10,100),f.dp_numeric(22,{name="liquid_level_percent",field=false,emit=t,read_only=true,from_device=h}),f.dp_binary(24,{name="relay_switch",emit=e.me202RelaySwitch(),converter=d.lookup_from_to{on=true,off=false}}),f.dp_binary(101,{name="pump_mode",emit=e.me202PumpMode(),converter=d.lookup_from_to{supply=true,drainage=false}}),f.dp_binary(102,{name="pump_control",emit=e.me202PumpControl(),converter=d.lookup_from_to{auto=true,manual=false}}),f.dp_string(103,{name="version",emit=e.me202Version(),read_only=true})},query_on_configure=true}g(I,{k.create_fingerprint("_TZE284_mxujdmxo","TS0601")})return{id="ef00.sensors.liquid_level",registrations=M}

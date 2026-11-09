local n,Z,J,ah,aw=require"protocol.tuya",require"capabilities.events.all",require"contracts.helpers.family",require"st.zigbee.device_management",require"st.zigbee.zcl.clusters"local m=n.converter
local ae,A=J.definition_registry()
local function F(capability_id)
return assert(Z[capability_id],"missing Wave19 valve emitter: "..capability_id)()
end
local function o(am,aM)
am.datapoints[#am.datapoints+1]=aM
end
local function B(dp,aa,capability_id,M)
return n.dp_numeric(dp,{name=aa,emit=F(capability_id),read_only=M==true,transaction=1})
end
local function aD(dp,aa,capability_id,aR,M,aH,Q)
return n.dp_enum(dp,{name=aa,emit=F(capability_id),converter=m.lookup_from_to(aR),read_only=M==true,write_only=aH==true,suppress_optimistic_state=Q==true,transaction=1})
end
local function X(dp,aa,capability_id,M)
return n.dp_binary(dp,{name=aa,emit=F(capability_id),converter=m.lookup_from_to{ON=true,OFF=false},read_only=M==true,transaction=1})
end
local d={profile="valves-wave19-frankever-fk-bv05",package_group="wave19-valve",magic_packet=true,query_on_configure=false,time_start="off",datapoints={}}o(d,n.dp_on_off(1,{name="switch",emit=Z.switch(),transaction=1}))o(d,B(2,"frank_bv_five_threshold","frankBvFiveThreshold",false))o(d,B(3,"frank_bv_five_position","frankBvFivePosition",true))o(d,n.dp_numeric(5,{name="frank_bv_last_volume",emit=Z.frankBvLastVolume"L",
converter=m.from_only(function(b)return b/10 end),
read_only=true,transaction=1}))o(d,n.dp_bitmap(4,{name="frank_bv_fault",emit=Z.frankBvFault(),read_only=true,
converter=m.from_only(function(b)return b==0 and"clear"or"detected"end)
}))o(d,n.dp_binary(114,{name="frank_bv_temp_alarm",emit=Z.frankBvTempAlarm(),read_only=true,converter=m.lookup_from_to{clear=false,detected=true}}))o(d,n.dp_binary(115,{name="frank_bv_water_alarm",emit=Z.frankBvWaterAlarm(),read_only=true,converter=m.lookup_from_to{clear=false,detected=true}}))o(d,B(6,"frank_bv_five_water_total","frankBvFiveWaterTotal",true))o(d,aD(10,"frank_bv_five_weather_delay","frankBvFiveWeatherDelay",{cancel=0,["24h"]=1,["48h"]=2,["72h"]=3},false))o(d,B(11,"frank_bv_five_countdown","frankBvFiveCountdown",false))o(d,n.dp_numeric(22,{name="water_temperature",emit=Z.temperature"C",read_only=true,transaction=1}))o(d,aD(101,"frank_bv_five_leak_state","frankBvFiveLeakState",{water_leakage_yes=0,water_leakage_no=1},true))o(d,X(102,"frank_bv_five_single_limit_enabled","frankBvFiveSingleLimitEnabled",false))o(d,B(103,"frank_bv_five_single_limit_volume","frankBvFiveSingleLimitVolume",false))o(d,X(104,"frank_bv_five_daily_limit_enabled","frankBvFiveDailyLimitEnabled",false))o(d,B(105,"frank_bv_five_daily_limit_volume","frankBvFiveDailyLimitVolume",false))o(d,X(106,"frank_bv_five_volume_alarm_enabled","frankBvFiveVolumeAlarmEnabled",false))o(d,B(107,"frank_bv_five_volume_alarm","frankBvFiveVolumeAlarm",false))o(d,X(108,"frank_bv_five_temp_alarm_enabled","frankBvFiveTempAlarmEnabled",false))o(d,B(109,"frank_bv_five_temp_alarm_max","frankBvFiveTempAlarmMax",false))o(d,aD(110,"frank_bv_five_power_off_state","frankBvFivePowerOffState",{off=0,on=1,maintain=2},false))o(d,X(112,"frank_bv_five_creep_enabled","frankBvFiveCreepEnabled",false))o(d,B(113,"frank_bv_five_temp_alarm_min","frankBvFiveTempAlarmMin",false))A(d,{J.create_fingerprint("_TZE200_nbqnmkee","TS0601")})
local function ai(a)
if type(a)~="table"then return nil end
a.__wave19_lidl_fields=a.__wave19_lidl_fields or{}return a.__wave19_lidl_fields
end
local function c(a,aI,b,aN)
if type(a)=="table"and type(a.set_field)=="function"then
a:set_field(aI,b,{persist=aN==true})else
local af=ai(a)if af~=nil then af[aI]=b end
end
end
local function g(a,aI)
if type(a)=="table"and type(a.get_field)=="function"then
local b=a:get_field(aI)if b~=nil then return b end
end
local af=ai(a)return af~=nil and af[aI]or nil
end
local function v(b,W)
if type(b)=="string"then return string.byte(b,W)end
if type(b)=="table"then
local ak=b[W]if type(ak)=="table"and ak.value~=nil then ak=ak.value end
return tonumber(ak)end
return nil
end
local function al(b,aC,aB)
b=tonumber(b)if b==nil then return nil end
if b<aC then return aC end
if b>aB then return aB end
return b
end
local S,j,l,u,i,z="__wave19_lidl_state","__wave19_lidl_time_left","__wave19_lidl_schedule_mode","__wave19_lidl_schedule_periodic","__wave19_lidl_schedule_timer","__wave19_lidl_initial_frost_reset_scheduled"
local function C(day)
return"__wave19_lidl_weekday_"..day
end
local function f(k,aE)
return string.format("__wave19_lidl_slot_%d_%s",k,aE)
end
local V,day_capability_suffix,slot_words={"monday","tuesday","wednesday","thursday","friday","saturday","sunday"},{"Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"},{"One","Two","Three","Four","Five","Six"}
local function O(a)
local t=g(a,i)if t~=nil and type(t.cancel)=="function"then t:cancel()end
c(a,i,nil,false)
end
local function Y(a,b)
if type(a)~="table"or type(a.emit_event)~="function"then return end
local aL=F"lidlPsbzsTimeLeft"(a,b)if aL~=nil then a:emit_event(aL)end
end
local function U(a,R)
O(a)if type(a)~="table"or type(a.thread)~="table"or type(a.thread.call_with_delay)~="function"or R<=1 then return end
local N=R
local function aQ()
N=N-1
if N<=0 then
c(a,j,0,false)c(a,i,nil,false)return
end
c(a,j,N,false)Y(a,N)local t=a.thread:call_with_delay(60,aQ,"Lidl watering schedule time left")c(a,i,t,false)
end
local t=a.thread:call_with_delay(60,aQ,"Lidl watering schedule time left")c(a,i,t,false)
end
local function ag(a)
if g(a,l)=="OFF"then return nil end
local aS=os.date"*t"for k=1,6 do
if g(a,f(k,"enabled"))=="ON"and g(a,f(k,"start_hour"))==aS.hour
and g(a,f(k,"start_minute"))==aS.min then
return k
end
end
return nil
end
local av,I=Z.switch(),F"lidlPsbzsTimeLeft"
local function ad(a,b,aq,ap)
local x,aK=b==true or tonumber(b)==1,g(a,S)
c(a,S,x,false)local L,aj={},av(a,x,aq,ap)if aj~=nil then L[#L+1]=aj end
if not x then
O(a)c(a,j,0,false)local at=I(a,0,aq,ap)if at~=nil then L[#L+1]=at end
elseif aK~=true and(g(a,j)or 0)==0 then
local k=ag(a)if k~=nil then
local R=g(a,f(k,"timer"))or 1
c(a,j,R,false)local at=I(a,R,aq,ap)if at~=nil then L[#L+1]=at end
U(a,R)end
end
return L[1]~=nil and L or nil
end
local D={profile="valves-wave19-lidl-psbzs-a-one",package_group="wave19-valve",magic_packet=true,query_on_configure=false,force_time_updates=true,time_start="1970",datapoints={}}o(D,n.dp_binary(1,{name="switch",emit=ad,suppress_optimistic_state=true,transaction=1}))o(D,B(5,"lidl_psbzs_timer","lidlPsbzsTimer",false))o(D,n.dp_numeric(6,{name="lidl_psbzs_time_left",read_only=true,transaction=1,
converter=m.from_only(function(b,a)
local e=tonumber(b)if e~=nil then c(a,j,e,false)end
return e
end),
emit=I}))o(D,n.dp_numeric(11,{name="battery",read_only=true,transaction=1,emit=Z.battery()}))o(D,X(108,"lidl_psbzs_frost_lock","lidlPsbzsFrostLock",true))o(D,aD(109,"lidl_psbzs_reset_frost_lock","lidlPsbzsResetFrostLock",{RESET=0},false,true,true))o(D,n.dp_binary(108,{name="lidl_psbzs_frost_reset_internal",write_only=true,converter=m.lookup_from_to{OFF=false},transaction=1}))
local function G(b,a)
local aF,y=v(b,1),v(b,2)if aF==nil or y==nil then return nil end
local P=aF==0
local ac=y==0 and"OFF"or(P and"WEEKDAY"or"PERIODIC")c(a,l,ac,false)c(a,u,P and 0 or y,false)for W,day in ipairs(V)do
local x=P and bit32.band(y,2 ^(W-1))~=0
c(a,C(day),x and"ON"or"OFF",false)end
return{mode=ac,periodic=P and 0 or y}
end
o(D,n.dp_raw(107,{name="lidl_psbzs_schedule_mode",read_only=true,
converter=m.from_only(function(b,a)
local w=G(b,a)return w~=nil and w.mode or nil
end),
emit=F"lidlPsbzsScheduleMode"}))o(D,n.dp_raw(107,{name="lidl_psbzs_schedule_periodic",
converter=m.from_only(function(b,a)
local w=G(b,a)return w~=nil and w.periodic or nil
end),
emit=F"lidlPsbzsSchedulePeriodic"}))for W,day in ipairs(V)do
local current_day,capability_id=day,"lidlPsbzs"..day_capability_suffix[W]
o(D,n.dp_raw(107,{name="lidl_psbzs_"..current_day,
converter=m.from_only(function(b,a)
if G(b,a)==nil then return nil end
return g(a,C(current_day))
end),
emit=F(capability_id)}))end
local an={{field="enabled",capability="Enabled",kind="enum"},{field="start_hour",capability="StartHour",kind="numeric"},{field="start_minute",capability="StartMinute",kind="numeric"},{field="timer",capability="Timer",kind="numeric"},{field="pause",capability="Pause",kind="numeric"},{field="iterations",capability="Iterations",kind="numeric"}}
local function ay(b,a,k)
if v(b,10)==nil then return nil end
local w={enabled=v(b,1)==1 and"ON"or"OFF",start_hour=al(v(b,2),0,23),start_minute=al(v(b,3),0,59),timer=al((v(b,4)or 0)*60+(v(b,5)or 0),1,599),pause=al((v(b,7)or 0)*60+(v(b,8)or 0),0,599),iterations=al(v(b,10),1,9)}for aE,ak in pairs(w)do c(a,f(k,aE),ak,false)end
return w
end
for k=1,6 do
for _,spec in ipairs(an)do
local E,ab=k,spec.field

local au,capability_id=string.format("lidl_psbzs_slot_%s_%s",string.lower(slot_words[E]),ab),"lidlPsbzsSlot"..slot_words[E]..spec.capability
o(D,n.dp_raw(100+E,{name=au,
converter=m.from_only(function(b,a)
local w=ay(b,a,E)return w~=nil and w[ab]or nil
end),
emit=F(capability_id)}))end
end
local function T(a,b)
local e=tonumber(b)if e==nil or e<0 or e>7 then return nil end
e=math.floor(e)local aF=e>0 and 1 or 0
c(a,u,e,false)c(a,l,e>0 and"PERIODIC"or"OFF",false)return{{dp=107,datatype=n.DP_TYPE_RAW,value=string.char(aF,e)}}
end
local function ar(day)
return function(a,b)
if b~="ON"and b~="OFF"then return nil end
c(a,C(day),b,false)local mask=0
for W,aa in ipairs(V)do
if g(a,C(aa))=="ON"then mask=mask+2 ^(W-1)end
end
c(a,l,mask==0 and"OFF"or"WEEKDAY",false)return{{dp=107,datatype=n.DP_TYPE_RAW,value=string.char(0,mask)}}
end
end
local function az(k,q)
return function(a,b)
local x,s,start_minute,t,K,iterations=g(a,f(k,"enabled"))or"OFF",g(a,f(k,"start_hour"))or 23,g(a,f(k,"start_minute"))or 59,g(a,f(k,"timer"))or 1,g(a,f(k,"pause"))or 0,g(a,f(k,"iterations"))or 1




if q=="enabled"then x=b
elseif q=="start_hour"then s=tonumber(b)elseif q=="start_minute"then start_minute=tonumber(b)elseif q=="timer"then t=tonumber(b)elseif q=="pause"then K=tonumber(b)elseif q=="iterations"then iterations=tonumber(b)end
if(x~="ON"and x~="OFF")or s==nil or s<0 or s>23
or start_minute==nil or start_minute<0 or start_minute>59
or t==nil or t<1 or t>599
or K==nil or K<0 or K>599
or iterations==nil or iterations<1 or iterations>9
or(iterations>1 and K==0)then return nil end
s,start_minute=math.floor(s),math.floor(start_minute)t,K,iterations=math.floor(t),math.floor(K),math.floor(iterations)c(a,f(k,"enabled"),x,false)c(a,f(k,"start_hour"),s,false)c(a,f(k,"start_minute"),start_minute,false)c(a,f(k,"timer"),t,false)c(a,f(k,"pause"),K,false)c(a,f(k,"iterations"),iterations,false)return{{dp=100+k,datatype=n.DP_TYPE_RAW,value=string.char(x=="ON"and 1 or 0,s,start_minute,math.floor(t/60),t%60,0,math.floor(K/60),K%60,0,iterations)}}
end
end
local H=n.build_named_map(D.datapoints,"name")H.lidl_psbzs_schedule_periodic=T
for _,day in ipairs(V)do H["lidl_psbzs_"..day]=ar(day)end
for k=1,6 do
for _,spec in ipairs(an)do
local aa=string.format("lidl_psbzs_slot_%s_%s",string.lower(slot_words[k]),spec.field)H[aa]=az(k,spec.field)end
end
D.named_mapping={named_mappings=H}
D.configure=function(aP,a)
a:send(ah.build_bind_request(a,6,aP.environment_info.hub_zigbee_eui,1))a:send(aw.OnOff.attributes.OnOff:configure_reporting(a,0,65535):to_endpoint(1))if not g(a,z)and type(a.thread)=="table"and type(a.thread.call_with_delay)=="function"then
c(a,z,true,true)
a.thread:call_with_delay(10,function()
n.send_datapoint(a,109,n.DP_TYPE_BOOL,false,n.SET_DATA,false,1)n.send_named_mapping(a,H,"lidl_psbzs_frost_reset_internal","OFF")
end,"Lidl frost state initialization")
end
end
A(D,{J.create_fingerprint("_TZE200_htnnfasr","TS0601")})return{id="ef00.valves.wave19",registrations=ae}

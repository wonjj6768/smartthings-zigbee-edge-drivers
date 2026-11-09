local k,d,i=require"protocol.tuya",require"capabilities.events.all",require"contracts.helpers.family"local g=k.converter
local z,b=i.definition_registry()local q,r,B,w,f,x=g.lookup_from_to{open=true,closed=false},946684800,8*60*60,2147483647,"giex_qt06_two_irrigation_mode",g.lookup_from_to{duration=false,capacity=true}



local function C(K)
local v,p=os.date("*t",K),os.date("!*t",K)local N=os.difftime(os.time(v),os.time(p))return K+N
end
local function D(t,K)
local p=K or os.time()return k.send_time(t,p,C(p))
end
local function A(t)
return D(t)
end
local function m()
local v,p=os.date("*t",r),os.date("!*t",r)return os.difftime(os.time(v),os.time(p))
end
local s=m()-B
local function o(j)
if j=="--:--:--"then return j end
local P,M,O=j:match"^(%d%d):(%d%d):(%d%d)$"local E=(tonumber(P)*60*60+tonumber(M)*60+tonumber(O)+
s)%(24*60*60)local J,H,I=math.floor(E/(60*60)),math.floor((E%(60*60))/60),E%60
return string.format("%02d:%02d:%02d",J,H,I)
end
local function n(j)
return j:match"^[^,]*"
end
local function l(j)
return math.min(j,w)
end
local function c(j,t)
local L=t:get_field(f)if L==nil and type(t.get_latest_state)=="function"then
L=t:get_latest_state("main","concertmirror08464.giexQtTwoMode","giexQtTwoMode")end
if j>0 and j<10 and L=="duration"then return 10 end
return j
end
local function e(a)
local h=a.mapping_prefix
return{profile=a.profile,time_start="1970",time_handler=A,force_time_updates=true,initial_custom_state_query=false,refresh_state_query=false,k.dp_binary(1,{name=h.."irrigation_mode",field=a.mode_field,emit=a.mode_emit,converter=x}),k.dp_on_off(2,{name=h.."state",emit=d.valve(),converter=q}),k.dp_string(101,{name=h.."irrigation_start_time",read_only=true,emit=a.start_time_emit,converter=a.time_converter}),k.dp_string(102,{name=h.."irrigation_end_time",read_only=true,emit=a.end_time_emit,converter=a.time_converter}),k.dp_numeric(103,{name=h.."cycle_irrigation_num_times",emit=a.cycle_count_emit}),k.dp_numeric(104,{name=h.."irrigation_target",emit=a.target_emit,converter=a.target_converter,optimistic_value=a.target_optimistic_value}),k.dp_numeric(105,{name=h.."cycle_irrigation_interval",emit=a.cycle_interval_emit}),k.dp_numeric(106,{name=h.."current_temperature_ignored",read_only=true}),k.dp_battery(108,{name=h.."battery",read_only=true,emit=d.battery()}),k.dp_numeric(111,{name=h.."water_consumed",read_only=true,emit=a.water_consumed_emit,converter=g.from_only(l)}),k.dp_string(114,{name=h.."last_irrigation_duration",read_only=true,emit=a.last_duration_emit,converter=g.from_only(n)})}
end
local F=e{profile="valves-giex-qt06-one",mapping_prefix="giex_qt06_one_",mode_field="giex_qt06_one_irrigation_mode",mode_emit=d.giexQtOneMode(),target_emit=d.giexQtOneTarget(),cycle_count_emit=d.giexQtOneCycleCount(),cycle_interval_emit=d.giexQtOneCycleInterval(),start_time_emit=d.giexQtOneStartTime(),end_time_emit=d.giexQtOneEndTime(),last_duration_emit=d.giexQtOneLastDuration(),water_consumed_emit=d.giexQtOneWaterConsumed(),time_converter=g.from_only(o)}b(F,i.create_fingerprints("TS0601",{"_TZE200_sh1btabb"}))local G=e{profile="valves-giex-qt06-two",mapping_prefix="giex_qt06_two_",mode_field=f,mode_emit=d.giexQtTwoMode(),target_emit=d.giexQtTwoTarget(),cycle_count_emit=d.giexQtTwoCycleCount(),cycle_interval_emit=d.giexQtTwoCycleInterval(),start_time_emit=d.giexQtTwoStartTime(),end_time_emit=d.giexQtTwoEndTime(),last_duration_emit=d.giexQtTwoLastDuration(),water_consumed_emit=d.giexQtTwoWaterConsumed(),target_converter=g.to_only(c),target_optimistic_value=c}b(G,i.create_fingerprints("TS0601",{"_TZE200_a7sghmms","_TZE204_a7sghmms","_TZE204_7ytb3h8u","_TZE200_7ytb3h8u","_TZE284_7ytb3h8u"}))
local u=g.from_only(function(j)
return j~=0
end)
local y={profile="valves-iotperfect-pf-pm02d",query_on_configure=true,k.dp_on_off(1,{name="switch",emit=d.switch()}),k.dp_bitmap(26,{name="fault",read_only=true,emit=d.hardware_fault(),converter=u})}b(y,i.create_fingerprints("TS0601",{"_TZE200_vrjkcam9","_TZE200_d0ypnbvn","_TZE204_v5xjyphj","_TZE28C1000000_v5xjyphj","_TZE204_d0ypnbvn","_TZE284_v5xjyphj","_TZE284_d0ypnbvn"}))return{id="ef00.valves.z2m_absorption",registrations=z}

local c,aq,I,o,S,C=require"protocol.tuya",require"protocol.zcl",require"capabilities.events.all",require"contracts.helpers.family",require"contracts.helpers.ef00_din_rail",require"st.capabilities"local L,j=o.definition_registry()local f,x,s,ah=c.converter,S.emit_metric_bundle,S.circuit_breaker_faults_converter,"concertmirror08464."



local function b(capability_id)
return assert(I[capability_id],"missing Wave19 energy emitter: "..capability_id)()
end
local function U(g,capability_id,ai,ar)
local a=g:get_latest_state("main",ah ..capability_id,ai)if a==nil then return ar end
return a
end
local function P(a,u)
local ab,aj=string.byte(a,u,u+1)if ab==nil or aj==nil then return nil end
return ab*256+aj
end
local function ap(a,u)
local ab,ak,aj=string.byte(a,u,u+2)if ab==nil or ak==nil or aj==nil then return nil end
return ab*65536+ak*256+aj
end
local N=f.from_only(function(a)
if type(a)~="string"or #a<8 then return nil end
return{voltage=P(a,1)/10,current=ap(a,3)/1000,power=ap(a,6)}
end)
local M=f.from_only(function(a)
if type(a)~="string"or #a<10 then return nil end
return{voltage=P(a,3)/10,current=P(a,6)/1000,power=P(a,9)}
end)
local as={ON=true,OFF=false}local i=f.lookup_from_to(as)local ad={profile="meters-wave19-moes-zm6lt1",package_group="wave19-energy",magic_packet=true,query_on_configure=true,query_interval_seconds=60,named_datapoints=true,time_start="off",datapoints={c.dp_energy(1,{name="energy",scale=100,read_only=true,transaction=1,emit=I.energy()}),c.dp_numeric(2,{name="moes_zm_six_reverse_energy",read_only=true,transaction=1,converter=f.divide_by_pair(100),emit=b"moesZmSixReverseEnergy"}),c.dp_raw(6,{name="phase",read_only=true,transaction=1,fields={voltage=true,current=true,power=true},converter=M,emit=x{voltage=true,current=true,power=true}}),c.dp_numeric(10,{name="moes_zm_six_fault",read_only=true,transaction=1,emit=b"moesZmSixFault"}),c.dp_raw(17,{name="moes_zm_six_alarm_set_two",read_only=true,transaction=1}),c.dp_binary(20,{name="moes_zm_six_clear_event",transaction=1,converter=i,emit=b"moesZmSixClearEvent"}),c.dp_enum(44,{name="moes_zm_six_online_state",read_only=true,transaction=1,converter=f.lookup_from_to{offline=0,online=1},emit=b"moesZmSixOnlineState"}),c.dp_numeric(49,{name="moes_zm_six_ac_frequency",read_only=true,transaction=1,converter=f.divide_by_pair(100),emit=b"moesZmSixAcFrequency"}),c.dp_numeric(51,{name="moes_zm_six_active_energy",read_only=true,transaction=1,converter=f.divide_by_pair(100),emit=b"moesZmSixActiveEnergy"}),c.dp_numeric(101,{name="moes_zm_six_countdown",transaction=1,emit=b"moesZmSixCountdown"}),c.dp_binary(104,{name="moes_zm_six_device_restart",write_only=true,transaction=1,converter=i,emit=b"moesZmSixDeviceRestart"})}}j(ad,{o.create_fingerprint("_TZE284_2fnssffc","TS0601")})
local function w(g,T)
if T==nil then return end
if type(T)=="table"and T[1]~=nil then
for _,R in ipairs(T)do g:emit_event(R)end
return
end
g:emit_event(T)
end
local k,F=b"nousDFiveCountdown",b"nousDFiveStatus"
local function z(g,a,ae,D)
local aa,an=a and"on"or"off",g:get_latest_state("main",C.switch.ID,"switch")if not a then
w(g,C.currentMeasurement.current{value=0,unit="A"})w(g,C.powerMeter.power{value=0,unit="W"})w(g,F(g,"off",ae,D))end
if an~=aa then
w(g,k(g,0,ae,D))end
end
local function p(a)
local v={}if type(a)~="string"then return v end
for u=1,#a-3,4 do
local Y,G=string.byte(a,u,u+1)local X=P(a,u+2)if Y~=nil and G~=nil and X~=nil then
v[Y]={enabled=G,value=X}end
end
return v
end
local function O(a,au)
local al=tonumber(a)if al==nil then return nil end
local am=math.floor(al*(au or 1)+0.5)if am<0 then am=0 end
if am>65535 then am=65535 end
return am
end
local d={one={dp=17,shadow="_wave19_d5z_alarm_set_one_raw",order={4,5},records={[4]={enabled={capability="nousDFiveLeakageAlarm",attribute="leakageAlarm"},value={capability="nousDFiveLeakageThreshold",attribute="leakageThreshold",scale=1}},[5]={enabled={capability="nousDFiveTemperatureAlarm",attribute="temperatureAlarm"},value={capability="nousDFiveTemperatureThreshold",attribute="temperatureThreshold",scale=1}}}},two={dp=18,shadow="_wave19_d5z_alarm_set_two_raw",order={1,2,3,4,5,7,8,9},records={[1]={enabled={capability="nousDFiveOverCurrentAlarm",attribute="overCurrentAlarm"},value={capability="nousDFiveOverCurrentThreshold",attribute="overCurrentThreshold",scale=10}},[2]={},[3]={enabled={capability="nousDFiveOverVoltageAlarm",attribute="overVoltageAlarm"},value={capability="nousDFiveOverVoltageThreshold",attribute="overVoltageThreshold",scale=1}},[4]={enabled={capability="nousDFiveUnderVoltageAlarm",attribute="underVoltageAlarm"},value={capability="nousDFiveUnderVoltageThreshold",attribute="underVoltageThreshold",scale=1}},[5]={},[7]={},[8]={},[9]={}}},three={dp=126,shadow="_wave19_d5z_alarm_set_three_raw",order={3},records={[3]={enabled={capability="nousDFiveLostFlowAlarm",attribute="lostFlowAlarm"},value={capability="nousDFiveLostFlowThreshold",attribute="lostFlowThreshold",scale=10}}}}}
local function y(g,R)
if R==nil then return nil end
return U(g,R.capability,R.attribute,nil)
end
local function H(r,Y,q,a)
local l=p(a)[Y]if l==nil then return nil end
if q=="enabled"then
if l.enabled==1 then return"ON"end
if l.enabled==0 then return"OFF"end
return nil
end
local R=r.records[Y].value
return l.value/(R.scale or 1)
end
local function E(r,Y,q,a,g)
local v,n=p(g:get_field(r.shadow)),r.records[Y]local m=v[Y]or{}if q=="enabled"then
if a~="ON"and a~="OFF"then return nil end
m.enabled=a=="ON"and 1 or 0
else
m.value=O(a,n.value.scale)end
if m.enabled==nil then
local G=y(g,n.enabled)if G~=nil then m.enabled=G=="ON"and 1 or 0 end
end
if m.value==nil and n.value~=nil then
m.value=O(y(g,n.value),n.value.scale)end
if m.enabled==nil or(n.value~=nil and m.value==nil)then return nil end
if m.value==nil then m.value=0 end
v[Y]=m
local Z={}for _,W in ipairs(r.order)do
local l=v[W]if l~=nil and l.enabled~=nil and l.value~=nil then
Z[#Z+1]=string.char(W,l.enabled,math.floor(l.value/256)%256,l.value%256)end
end
if #Z==0 then return nil end
return table.concat(Z)
end
local function B(r,ac)
return c.dp_raw(r.dp,{name=ac,field=r.shadow,read_only=true,transaction=1})
end
local function e(r,Y,q,ac,V)
return c.dp_raw(r.dp,{name=ac,transaction=1,converter=f.from_to(
function(a)return H(r,Y,q,a)end,
function(a,g)return E(r,Y,q,a,g)end
),emit=V})
end
local h={state={capability="nousDFiveInchingState",attribute="inchingState",default="OFF"},minutes={capability="nousDFiveInchingMinutes",attribute="inchingMinutes",default=1},seconds={capability="nousDFiveInchingSeconds",attribute="inchingSeconds",default=0}}
local function K(q,a)
if type(a)~="string"or #a<3 then return nil end
if q=="state"then return string.byte(a,1)==1 and"ON"or"OFF"end
local A=P(a,2)if q=="minutes"then return math.floor(A/60)end
return A%60
end
local function Q(q,a,g)
local aa,af,ag=U(g,h.state.capability,h.state.attribute,h.state.default),U(g,h.minutes.capability,h.minutes.attribute,h.minutes.default),U(g,h.seconds.capability,h.seconds.attribute,h.seconds.default)if q=="state"then aa=a end
if q=="minutes"then af=a end
if q=="seconds"then ag=a end
local A=math.max(1,(tonumber(af)or 0)*60+(tonumber(ag)or 0))if A>65535 then A=65535 end
A=math.floor(A+0.5)return string.char(aa=="ON"and 1 or 0,math.floor(A/256),A%256)
end
local function t(q,ac,V)
return c.dp_raw(109,{name=ac,transaction=1,converter=f.from_to(
function(a)return K(q,a)end,
function(a,g)return Q(q,a,g)end
),emit=V})
end
local at={profile="meters-wave19-nous-d5z",package_group="wave19-energy",magic_packet=true,query_on_configure=true,named_datapoints=true,time_start="off",datapoints={c.dp_energy(1,{name="energy",scale=100,read_only=true,transaction=1,emit=I.energy()}),c.dp_raw(6,{name="phase",read_only=true,transaction=1,fields={voltage=true,current=true,power=true},converter=N,emit=x{voltage=true,current=true,power=true}}),c.dp_numeric(9,{name="nous_d_five_faults",read_only=true,transaction=1,converter=s,emit=b"nousDFiveFaults"}),c.dp_binary(11,{name="nous_d_five_prepayment",transaction=1,converter=i,emit=b"nousDFivePrepayment"}),c.dp_binary(12,{name="nous_d_five_energy_balance_reset",transaction=1,converter=f.from_to(
function()return"idle"end,
function(a)if a=="RESET"then return false end end
),emit=b"nousDFiveEnergyBalanceReset"}),c.dp_numeric(13,{name="nous_d_five_energy_balance",read_only=true,transaction=1,converter=f.divide_by_pair(100),emit=b"nousDFiveEnergyBalance"}),c.dp_numeric(14,{name="nous_d_five_energy_balance_add",transaction=1,converter=f.from_to(
function()return 0 end,
function(a)return math.floor((tonumber(a)or 0)*100+0.5)end
),emit=b"nousDFiveEnergyBalanceAdd"}),c.dp_numeric(15,{name="nous_d_five_leakage_current",read_only=true,transaction=1,emit=b"nousDFiveLeakageCurrent"}),c.dp_on_off(16,{name="switch",component="main",transaction=1,handler=z,emit=I.switch()}),B(d.one,"nous_d_five_alarm_set_one_raw"),e(d.one,4,"enabled","nous_d_five_leakage_alarm",b"nousDFiveLeakageAlarm"),e(d.one,4,"value","nous_d_five_leakage_threshold",b"nousDFiveLeakageThreshold"),e(d.one,5,"enabled","nous_d_five_temperature_alarm",b"nousDFiveTemperatureAlarm"),e(d.one,5,"value","nous_d_five_temperature_threshold",b"nousDFiveTemperatureThreshold"),B(d.two,"nous_d_five_alarm_set_two_raw"),e(d.two,1,"enabled","nous_d_five_over_current_alarm",b"nousDFiveOverCurrentAlarm"),e(d.two,1,"value","nous_d_five_over_current_threshold",b"nousDFiveOverCurrentThreshold"),e(d.two,3,"enabled","nous_d_five_over_voltage_alarm",b"nousDFiveOverVoltageAlarm"),e(d.two,3,"value","nous_d_five_over_voltage_threshold",b"nousDFiveOverVoltageThreshold"),e(d.two,4,"enabled","nous_d_five_under_voltage_alarm",b"nousDFiveUnderVoltageAlarm"),e(d.two,4,"value","nous_d_five_under_voltage_threshold",b"nousDFiveUnderVoltageThreshold"),c.dp_numeric(102,{name="nous_d_five_reclosing_count",transaction=1,emit=b"nousDFiveReclosingCount"}),c.dp_temperature(103,{name="temperature",scale=1,read_only=true,transaction=1,emit=I.temperature"C"}),c.dp_binary(104,{name="nous_d_five_reclosing",transaction=1,converter=i,emit=b"nousDFiveReclosing"}),c.dp_numeric(105,{name="nous_d_five_countdown",transaction=1,emit=k}),c.dp_raw(106,{name="nous_d_five_cycle_schedule",read_only=true,transaction=1}),c.dp_numeric(107,{name="nous_d_five_reclosing_delay",transaction=1,emit=b"nousDFiveReclosingDelay"}),c.dp_numeric(108,{name="nous_d_five_random_timing",read_only=true,transaction=1}),t("state","nous_d_five_inching_state",b"nousDFiveInchingState"),t("minutes","nous_d_five_inching_minutes",b"nousDFiveInchingMinutes"),t("seconds","nous_d_five_inching_seconds",b"nousDFiveInchingSeconds"),c.dp_energy(110,{name="nous_d_five_produced_energy",scale=100,read_only=true,transaction=1,emit=b"nousDFiveProducedEnergy"}),c.dp_numeric(119,{name="nous_d_five_power_on_delay",read_only=true,transaction=1}),c.dp_numeric(124,{name="nous_d_five_over_current_time",transaction=1,emit=b"nousDFiveOverCurrentTime"}),c.dp_numeric(125,{name="nous_d_five_lost_flow_time",transaction=1,emit=b"nousDFiveLostFlowTime"}),B(d.three,"nous_d_five_alarm_set_three_raw"),e(d.three,3,"enabled","nous_d_five_lost_flow_alarm",b"nousDFiveLostFlowAlarm"),e(d.three,3,"value","nous_d_five_lost_flow_threshold",b"nousDFiveLostFlowThreshold"),c.dp_enum(127,{name="nous_d_five_status",read_only=true,transaction=1,converter=f.lookup_from_to{off=0,consumption=1,production=2},emit=b"nousDFiveStatus"}),c.dp_enum(134,{name="nous_d_five_power_on_behavior",transaction=1,converter=f.lookup_from_to{off=0,on=1,previous=2},emit=b"nousDFivePowerOnBehavior"})}}j(at,{o.create_fingerprint("_TZE204_t9ffmdin","TS0601")})local ao={profile="meters-wave19-qa-qaszp",package_group="wave19-energy",magic_packet=true,query_on_configure=false,named_datapoints=true,time_start="off",datapoints={c.dp_energy(17,{name="energy",scale=1000,read_only=true,command_id=c.SEND_DATA,transaction=1,emit=I.energy()}),c.dp_current(18,{name="current",scale=1000,read_only=true,command_id=c.SEND_DATA,transaction=1,emit=I.current()}),c.dp_numeric(19,{name="power",read_only=true,command_id=c.SEND_DATA,transaction=1,converter=f.divide_by_pair(10),emit=I.power()}),c.dp_voltage(20,{name="voltage",scale=10,read_only=true,command_id=c.SEND_DATA,transaction=1,emit=I.voltage()}),c.dp_numeric(101,{name="qa_qaszp_reactive_power_threshold",command_id=c.SEND_DATA,transaction=1,converter=f.divide_by_pair(10),emit=b"qaQaszpReactivePowerThreshold"}),c.dp_numeric(102,{name="qa_qaszp_max_effective_power",command_id=c.SEND_DATA,transaction=1,converter=f.divide_by_pair(10),emit=b"qaQaszpMaxEffectivePower"}),c.dp_binary(104,{name="qa_qaszp_status_report",command_id=c.SEND_DATA,transaction=1,converter=i,emit=b"qaQaszpStatusReport"}),c.dp_binary(105,{name="qa_qaszp_switch_status",read_only=true,command_id=c.SEND_DATA,transaction=1,converter=i,emit=b"qaQaszpSwitchStatus"})},zcl_clusters={aq.voltage{endpoint=1,read_only=true,configure_reporting=false,read_on_configure=false,poll_interval=60},aq.current{endpoint=1,read_only=true,configure_reporting=false,read_on_configure=false,poll_interval=60},aq.power{endpoint=1,read_only=true,configure_reporting=false,read_on_configure=false,poll_interval=60},aq.energy{endpoint=1,read_only=true,configure_reporting=false,read_on_configure=false,poll_interval=0}}}j(ao,{o.create_fingerprint("_TZ3218_kwht8j5m","TS011F")})return{id="ef00.din_rail.wave19_energy",registrations=L}

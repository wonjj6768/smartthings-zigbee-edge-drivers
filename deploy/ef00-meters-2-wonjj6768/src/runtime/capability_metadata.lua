local a,H={},{"ON","OFF","kWh","s","off","mA","A","V","W","on","previous","countdown","zwpm16DailyEnergy","zwpm16TwoDailyEnergyL1","zwpm16TwoDailyEnergyL2","moesZmSixAcFrequency","moesZmSixReverseEnergy","moesZmSixActiveEnergy","moesZmSixFault","moesZmSixCountdown","nousDFiveCountdown","nousDFiveInchingMinutes","nousDFiveInchingSeconds","nousDFiveProducedEnergy","nousDFiveLeakageCurrent","nousDFiveReclosingDelay","nousDFiveReclosingCount","nousDFiveEnergyBalance","nousDFiveEnergyBalanceAdd","nousDFiveLeakageThreshold","nousDFiveTemperatureThreshold","nousDFiveOverCurrentTime","nousDFiveOverCurrentThreshold","nousDFiveOverVoltageThreshold","nousDFiveUnderVoltageThreshold","nousDFiveLostFlowThreshold","nousDFiveLostFlowTime","qaQaszpReactivePowerThreshold","qaQaszpMaxEffectivePower","zot60Countdown","zot60Energy","moesZmSixClearEvent","moesZmSixOnlineState","offline","online","moesZmSixDeviceRestart","nousDFivePowerOnBehavior","nousDFiveInchingState","nousDFiveStatus","consumption","production","nousDFiveReclosing","nousDFivePrepayment","nousDFiveEnergyBalanceReset","RESET","idle","nousDFiveLeakageAlarm","nousDFiveTemperatureAlarm","nousDFiveOverCurrentAlarm","nousDFiveOverVoltageAlarm","nousDFiveUnderVoltageAlarm","nousDFiveLostFlowAlarm","qaQaszpStatusReport","qaQaszpSwitchStatus","zot60PowerBehavior","zot60BacklightMode","lastPowerResponseTime","nousDFiveFaults"}
local function b(g)
if type(g)=="number"then return H[g]end
return g
end
local function p(g)local suffix=b(g);if suffix==nil then return nil end;return"concertmirror08464."..suffix end
local t={}
local function q(k)
if type(k)~="number"then return{}end
local x=t[k]if x~=nil then return x end
local n={}t[k]=n
return n
end
local function s(D,k)
if type(D)~="table"then return nil end
local n=q(k)for A,g in ipairs(D)do n[A]=b(g)end
return n
end
local function i(g,E)
if g==nil then return E end
if g==0 then return nil end
return b(g)
end
local function m(attribute_name)
if type(attribute_name)~="string"or attribute_name==""then return nil end
return"set"..attribute_name:sub(1,1):upper()..attribute_name:sub(2)
end
local function J(g)
if type(g)~="table"then return nil end
local n=q(g[6])n.minimum=g[1]n.maximum=g[2]n.step=g[3]n.unit=b(g[4])n.allowed_values=s(g[5],g[7])return n
end
local function w(j,k)
if j==nil and k==nil then return nil end
local n=q(k)n.allowed_values=j
return n
end
local function G(f)
local attribute_name=b(f[4])return{kind="numeric",emit_name=b(f[1]),range_key=b(f[2]),capability_id=p(f[3]),attribute_name=attribute_name,range_attribute_name=b(f[5]),command_name=i(f[6],m(attribute_name)),argument_name=i(f[7],attribute_name),mapping_name=b(f[8]),label=b(f[9]),default_range=J(f[10]),event_minimum=f[11],event_maximum=f[12],event_unit=b(f[13])}
end
local function K(f)
local attribute_name,u,r=b(f[4]),s(f[10],f[12]),s(f[11],f[14])local d=w(r,f[13])return{kind="enum",emit_name=b(f[1]),range_key=b(f[2]),capability_id=p(f[3]),attribute_name=attribute_name,supported_attribute_name=b(f[5]),command_name=i(f[6],m(attribute_name)),argument_name=i(f[7],attribute_name),mapping_name=b(f[8]),label=b(f[9]),supported_values=u,default_range=d}
end
local function M(f)
local attribute_name=b(f[3])return{kind="text",emit_name=b(f[1]),capability_id=p(f[2]),attribute_name=attribute_name,command_name=i(f[4],m(attribute_name)),argument_name=i(f[5],attribute_name),mapping_name=b(f[6]),label=b(f[7]),maximum_length=f[8]}
end
local function z(L,F)
local n={}for _,f in ipairs(L)do n[#n+1]=F(f)end
return n
end
a.numeric=z({{13,nil,13,"zwpmOneSixDailyEnergy",nil,0,0,"daily_energy","Zwpm16Daily Energy",{nil,nil,nil,3,nil,1},nil,nil,3},{14,nil,14,"zwpmOneSixTwoDailyEnergyLOne",nil,0,0,"daily_energy_l1","Zwpm16Two Daily Energy L1",{nil,nil,nil,3,nil,2},nil,nil,3},{15,nil,15,"zwpmOneSixTwoDailyEnergyLTwo",nil,0,0,"daily_energy_l2","Zwpm16Two Daily Energy L2",{nil,nil,nil,3,nil,3},nil,nil,3},{16,nil,16,"acFrequency",nil,0,0,"moes_zm_six_ac_frequency","Moes Zm Six Ac Frequency",{nil,nil,nil,"Hz",nil,4},nil,nil,"Hz"},{17,nil,17,"reverseEnergy",nil,0,0,"moes_zm_six_reverse_energy","Moes Zm Six Reverse Energy",{nil,nil,nil,3,nil,5},nil,nil,3},{18,nil,18,"activeEnergy",nil,0,0,"moes_zm_six_active_energy","Moes Zm Six Active Energy",{nil,nil,nil,3,nil,6},nil,nil,3},{19,nil,19,"fault",nil,0,0,"moes_zm_six_fault","Moes Zm Six Fault",{nil,nil,nil,nil,nil,7}},{20,nil,20,12,nil,nil,nil,"moes_zm_six_countdown","Moes Zm Six Countdown",{0,2000,1,4,nil,8},nil,nil,4},{21,nil,21,12,nil,nil,nil,"nous_d_five_countdown","Nous DFive Countdown",{0,86400,1,4,nil,9},nil,nil,4},{22,nil,22,"inchingMinutes",nil,nil,nil,"nous_d_five_inching_minutes","Nous DFive Inching Minutes",{0,1440,1,"m",nil,10},nil,nil,"m"},{23,nil,23,"inchingSeconds",nil,nil,nil,"nous_d_five_inching_seconds","Nous DFive Inching Seconds",{0,59,1,4,nil,11},nil,nil,4},{24,nil,24,"producedEnergy",nil,0,0,"nous_d_five_produced_energy","Nous DFive Produced Energy",{nil,nil,nil,3,nil,12},nil,nil,3},{25,nil,25,"leakageCurrent",nil,0,0,"nous_d_five_leakage_current","Nous DFive Leakage Current",{nil,nil,nil,6,nil,13},nil,nil,6},{26,nil,26,"reclosingDelay",nil,nil,nil,"nous_d_five_reclosing_delay","Nous DFive Reclosing Delay",{1,99,1,4,nil,14},nil,nil,4},{27,nil,27,"reclosingCount",nil,nil,nil,"nous_d_five_reclosing_count","Nous DFive Reclosing Count",{0,30,1,nil,nil,15}},{28,nil,28,"energyBalance",nil,0,0,"nous_d_five_energy_balance","Nous DFive Energy Balance",{nil,nil,nil,3,nil,16},nil,nil,3},{29,nil,29,"energyBalanceAdd",nil,nil,nil,"nous_d_five_energy_balance_add","Nous DFive Energy Balance Add",{0,999999,0.01,3,nil,17},nil,nil,3},{30,nil,30,"leakageThreshold",nil,nil,nil,"nous_d_five_leakage_threshold","Nous DFive Leakage Threshold",{1,99,1,6,nil,18},nil,nil,6},{31,nil,31,"temperatureThreshold",nil,nil,nil,"nous_d_five_temperature_threshold","Nous DFive Temperature Threshold",{10,85,1,"°C",nil,19},nil,nil,"°C"},{32,nil,32,"overCurrentTime",nil,nil,nil,"nous_d_five_over_current_time","Nous DFive Over Current Time",{0,999,1,4,nil,20},nil,nil,4},{33,nil,33,"overCurrentThreshold",nil,nil,nil,"nous_d_five_over_current_threshold","Nous DFive Over Current Threshold",{1,80,0.1,7,nil,21},nil,nil,7},{34,nil,34,"overVoltageThreshold",nil,nil,nil,"nous_d_five_over_voltage_threshold","Nous DFive Over Voltage Threshold",{120,300,1,8,nil,22},nil,nil,8},{35,nil,35,"underVoltageThreshold",nil,nil,nil,"nous_d_five_under_voltage_threshold","Nous DFive Under Voltage Threshold",{80,210,1,8,nil,23},nil,nil,8},{36,nil,36,"lostFlowThreshold",nil,nil,nil,"nous_d_five_lost_flow_threshold","Nous DFive Lost Flow Threshold",{1,100,0.1,7,nil,24},nil,nil,7},{37,nil,37,"lostFlowTime",nil,nil,nil,"nous_d_five_lost_flow_time","Nous DFive Lost Flow Time",{0,999,1,4,nil,25},nil,nil,4},{38,nil,38,"reactivePowerThreshold",nil,nil,nil,"qa_qaszp_reactive_power_threshold","Qa Qaszp Reactive Power Threshold",{3,30,0.1,9,nil,26},nil,nil,9},{39,nil,39,"maxEffectivePower",nil,nil,nil,"qa_qaszp_max_effective_power","Qa Qaszp Max Effective Power",{0,4800,1,9,nil,27},nil,nil,9},{40,nil,40,12,nil,nil,nil,"zot60_countdown","Zot60Countdown",{0,43200,1,4,nil,28},nil,nil,4},{41,nil,41,"energy",nil,nil,nil,"zot60_energy","Zot60Energy",{0,100000,0.1,3,nil,29},nil,nil,3}},G)a.enum=z({{42,nil,42,"clearEvent",nil,nil,nil,"moes_zm_six_clear_event","Moes Zm Six Clear Event",{1,2},{1,2},30,31,30},{43,nil,43,"onlineState",nil,0,0,"moes_zm_six_online_state","Moes Zm Six Online State",{44,45},{44,45},32,33,32},{46,nil,46,"deviceRestart",nil,nil,nil,"moes_zm_six_device_restart","Moes Zm Six Device Restart",{1,2},{1,2},34,35,34},{47,nil,47,"powerOnBehavior",nil,nil,nil,"nous_d_five_power_on_behavior","Nous DFive Power On Behavior",{5,10,11},{5,10,11},36,37,36},{48,nil,48,"inchingState",nil,nil,nil,"nous_d_five_inching_state","Nous DFive Inching State",{1,2},{1,2},38,39,38},{49,nil,49,"status",nil,0,0,"nous_d_five_status","Nous DFive Status",{5,50,51},{5,50,51},40,41,40},{52,nil,52,"reclosing",nil,nil,nil,"nous_d_five_reclosing","Nous DFive Reclosing",{1,2},{1,2},42,43,42},{53,nil,53,"prepayment",nil,nil,nil,"nous_d_five_prepayment","Nous DFive Prepayment",{1,2},{1,2},44,45,44},{54,nil,54,"energyBalanceReset",nil,nil,nil,"nous_d_five_energy_balance_reset","Nous DFive Energy Balance Reset",{55,56},{55,56},46,47,46},{57,nil,57,"leakageAlarm",nil,nil,nil,"nous_d_five_leakage_alarm","Nous DFive Leakage Alarm",{1,2},{1,2},48,49,48},{58,nil,58,"temperatureAlarm",nil,nil,nil,"nous_d_five_temperature_alarm","Nous DFive Temperature Alarm",{1,2},{1,2},50,51,50},{59,nil,59,"overCurrentAlarm",nil,nil,nil,"nous_d_five_over_current_alarm","Nous DFive Over Current Alarm",{1,2},{1,2},52,53,52},{60,nil,60,"overVoltageAlarm",nil,nil,nil,"nous_d_five_over_voltage_alarm","Nous DFive Over Voltage Alarm",{1,2},{1,2},54,55,54},{61,nil,61,"underVoltageAlarm",nil,nil,nil,"nous_d_five_under_voltage_alarm","Nous DFive Under Voltage Alarm",{1,2},{1,2},56,57,56},{62,nil,62,"lostFlowAlarm",nil,nil,nil,"nous_d_five_lost_flow_alarm","Nous DFive Lost Flow Alarm",{1,2},{1,2},58,59,58},{63,nil,63,"statusReport",nil,nil,nil,"qa_qaszp_status_report","Qa Qaszp Status Report",{1,2},{1,2},60,61,60},{64,nil,64,"switchStatus",nil,0,0,"qa_qaszp_switch_status","Qa Qaszp Switch Status",{1,2},{1,2},62,63,62},{65,nil,65,"powerBehavior",nil,nil,nil,"zot60_power_behavior","Zot60Power Behavior",{5,10,11},{5,10,11},64,65,64},{66,nil,66,"backlightMode",nil,nil,nil,"zot60_backlight_mode","Zot60Backlight Mode",{1,2},{1,2},66,67,66}},K)a.text=z({{"last_power_response_time",67,67,0,0,nil,"Last power response time",64},{68,68,"faults",0,0,"nous_d_five_faults","Nous DFive Faults",256}},M)a.driver_message={attribute_name="driverMessage",capability_id="concertmirror08464.driverMessage",emit_name="driver_message",label="Driver message",maximum_length=512}a.by_range_key={}a.by_emit_name={}a.by_capability_id={}
local function o(y)
for _,e in ipairs(y)do
a.by_emit_name[e.emit_name]=e
if type(e.capability_id)=="string"and e.capability_id~=""then a.by_capability_id[e.capability_id]=e end
if type(e.range_key)=="string"and e.range_key~=""then a.by_range_key[e.range_key]=e end
end
end
o(a.numeric)o(a.enum)o(a.text)a.by_emit_name[a.driver_message.emit_name]=a.driver_message
a.by_capability_id[a.driver_message.capability_id]=a.driver_message
local function l(j)
if type(j)~="table"then return nil end
local B={}for A,g in ipairs(j)do B[A]=g end
return B
end
function a.resolve_range(v,e)
if type(e)~="table"then return nil end
local d,C=type(e.default_range)=="table"and e.default_range or nil,type(v)=="table"and v.presence_capability_ranges or nil

local h=type(C)=="table"and C[e.range_key]or nil
if type(h)~="table"then h=d end
if type(h)~="table"then return nil end
return{minimum=type(h.minimum)=="number"and h.minimum or(d and d.minimum or nil),maximum=type(h.maximum)=="number"and h.maximum or(d and d.maximum or nil),step=type(h.step)=="number"and h.step or(d and d.step or nil),unit=type(h.unit)=="string"and h.unit or(d and d.unit or nil),allowed_values=type(h.allowed_values)=="table"and l(h.allowed_values)or l(d and d.allowed_values or nil)}
end
return a

local a,H={},{"off","on","inactive","toggle","normal","active","%","s","previous","action","clear","prealarm","critical_alarm","smoke_active","co_active","gas_active","heat_active","stop","smoke_siren","co_siren","alarm","powerOnBehavior","zgZvHoldTime","holdTime","zgZvMotionSensitivity","motionSensitivity","zgZvThHoldTime","zgZvThMotionSensitivity","zgDualFadingTime","zgDualZoneOneMotion","zgDualZoneOneStill","zgDualZoneTwoMotion","zgDualZoneTwoStill","zgDualZoneThreeMotion","zgDualZoneThreeStill","zgDualRadarScans","zgDualIlluminanceRaw","zgDualIlluminance","hmS1MBatteryPercent","batteryPercent","hmS1MHumidity","hmS1MSmokeLevel","hmS1MShieldingTime","hmS1MTempOffset","tempOffset","hmS1MHumidityOffset","hmS1MReportedCount","reportedCount","hmS1MRejoinCount","rejoinCount","hmS1MRebootCount","rebootCount","hmC1MBatteryPercent","hmC1MCoPpm","hmC1MTempOffset","hmC1MReportedCount","hmC1MRejoinCount","hmC1MRebootCount","zgZvPowerOnBehavior","zgZvAction","zgZvThPowerOnBehavior","zgZvThAction","sbdw302HandlePosition","closed","tilted","open","sbdw302BatteryLow","zgDualPowerOn","zgDualPresenceState","motion","presence","motion_and_presence","zgDualAction","hmS1MTestState","testState","hmS1MAlarmState","alarmState","alarmed","hmS1MInterconnectable","interconnectable","hmS1MSmokeUnit","dB/m","%ft OBS","hmS1MChamberState","light_contamination","medium_contamination","critical_contamination","hmS1MLinkState","linkState","hmS1MSirenMode","sirenMode","hmC1MTestState","hmC1MLifeState","expires_soon","expired","hmC1MAlarmState","warning_alarm","hmC1MPreheatState","preheating","hmC1MInterconnectable","hmC1MSirenMode","hmC1MLinkState","mirSr100Alarm","mirSr100SwitchAction","somfyOpenAlarm","lastPowerResponseTime","hmS1MFaultState","faultState","hmS1MMuteState","muteState","hmC1MFaultState","hmC1MMuteState"}
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
a.numeric=z({{23,nil,23,24,nil,nil,nil,"zgzv_hold_time","Zg Zv Hold Time",{0,524,1,8,nil,1},nil,nil,8},{25,nil,25,26,nil,nil,nil,"zgzv_motion_sensitivity","Zg Zv Motion Sensitivity",{1,254,1,nil,nil,2}},{27,nil,27,24,nil,nil,nil,"zgzv_th_hold_time","Zg Zv Th Hold Time",{0,524,1,8,nil,3},nil,nil,8},{28,nil,28,26,nil,nil,nil,"zgzv_th_motion_sensitivity","Zg Zv Th Motion Sensitivity",{1,254,1,nil,nil,4}},{29,nil,29,"fadingTime",nil,nil,nil,"zg_dual_FadingTime","Zg Dual Fading Time",{nil,nil,nil,8,nil,5},nil,nil,8},{30,nil,30,"zoneOneMotionThreshold",nil,nil,nil,"zg_dual_ZoneOneMotion","Zg Dual Zone One Motion",{nil,nil,nil,nil,nil,6}},{31,nil,31,"zoneOneStillThreshold",nil,nil,nil,"zg_dual_ZoneOneStill","Zg Dual Zone One Still",{nil,nil,nil,nil,nil,7}},{32,nil,32,"zoneTwoMotionThreshold",nil,nil,nil,"zg_dual_ZoneTwoMotion","Zg Dual Zone Two Motion",{nil,nil,nil,nil,nil,8}},{33,nil,33,"zoneTwoStillThreshold",nil,nil,nil,"zg_dual_ZoneTwoStill","Zg Dual Zone Two Still",{nil,nil,nil,nil,nil,9}},{34,nil,34,"zoneThreeMotionThreshold",nil,nil,nil,"zg_dual_ZoneThreeMotion","Zg Dual Zone Three Motion",{nil,nil,nil,nil,nil,10}},{35,nil,35,"zoneThreeStillThreshold",nil,nil,nil,"zg_dual_ZoneThreeStill","Zg Dual Zone Three Still",{nil,nil,nil,nil,nil,11}},{36,nil,36,"radarTriggerScans",nil,nil,nil,"zg_dual_RadarScans","Zg Dual Radar Scans",{nil,nil,nil,nil,nil,12}},{37,nil,37,"illuminanceRaw",nil,0,0,"zg_dual_illuminance_raw","Zg Dual Illuminance Raw",{nil,nil,nil,nil,nil,13}},{38,nil,38,"illuminance",nil,0,0,"zg_dual_illuminance","Zg Dual Illuminance",{nil,nil,nil,"lx",nil,14},nil,nil,"lx"},{39,nil,39,40,nil,0,0,"hm_s1_m_battery","Hm S1MBattery Percent",{nil,nil,nil,7,nil,15},nil,nil,7},{41,nil,41,"humidity",nil,0,0,"hm_s1_m_humidity","Hm S1MHumidity",{nil,nil,nil,7,nil,16},nil,nil,7},{42,nil,42,"smokeLevel",nil,0,0,"hm_s1_m_smoke_level","Hm S1MSmoke Level",{nil,nil,nil,nil,nil,17}},{43,nil,43,"shieldingTime",nil,nil,nil,"hm_s1_m_shielding_sensor_detection","Hm S1MShielding Time",{nil,nil,nil,"min",nil,18},nil,nil,"min"},{44,nil,44,45,nil,nil,nil,"hm_s1_m_temperature_offset","Hm S1MTemp Offset",{nil,nil,nil,"C",nil,19},nil,nil,"C"},{46,nil,46,"humidityOffset",nil,nil,nil,"hm_s1_m_humidity_offset","Hm S1MHumidity Offset",{nil,nil,nil,7,nil,20},nil,nil,7},{47,nil,47,48,nil,0,0,"hm_s1_m_reported_packages","Hm S1MReported Count",{nil,nil,nil,nil,nil,21}},{49,nil,49,50,nil,0,0,"hm_s1_m_rejoin_count","Hm S1MRejoin Count",{nil,nil,nil,nil,nil,22}},{51,nil,51,52,nil,0,0,"hm_s1_m_reboot_count","Hm S1MReboot Count",{nil,nil,nil,nil,nil,23}},{53,nil,53,40,nil,0,0,"hm_c1_m_battery","Hm C1MBattery Percent",{nil,nil,nil,7,nil,24},nil,nil,7},{54,nil,54,"coPpm",nil,0,0,"hm_c1_m_co","Hm C1MCo Ppm",{nil,nil,nil,"ppm",nil,25},nil,nil,"ppm"},{55,nil,55,45,nil,nil,nil,"hm_c1_m_temperature_offset","Hm C1MTemp Offset",{nil,nil,nil,"C",nil,26},nil,nil,"C"},{56,nil,56,48,nil,0,0,"hm_c1_m_reported_packages","Hm C1MReported Count",{nil,nil,nil,nil,nil,27}},{57,nil,57,50,nil,0,0,"hm_c1_m_rejoin_count","Hm C1MRejoin Count",{nil,nil,nil,nil,nil,28}},{58,nil,58,52,nil,0,0,"hm_c1_m_reboot_count","Hm C1MReboot Count",{nil,nil,nil,nil,nil,29}}},G)a.enum=z({{59,nil,59,22,nil,nil,nil,"zgzv_power_on_behavior","Zg Zv Power On Behavior",{1,2,4,9},{1,2,4,9},30,31,30},{60,nil,60,10,nil,0,0,"zgzv_action","Zg Zv Action",{2,1,4},{2,1,4},32,33,32},{61,nil,61,22,nil,nil,nil,"zgzv_th_power_on_behavior","Zg Zv Th Power On Behavior",{1,2,4,9},{1,2,4,9},34,35,34},{62,nil,62,10,nil,0,0,"zgzv_th_action","Zg Zv Th Action",{2,1,4},{2,1,4},36,37,36},{63,nil,63,"handlePosition",nil,0,0,"sbdw302_handle_position","Sbdw302Handle Position",{64,65,66},{64,65,66},38,39,38},{67,nil,67,"batteryLow",nil,0,0,"sbdw302_battery_low","Sbdw302Battery Low",{5,"low"},{5,"low"},40,41,40},{68,nil,68,22,nil,nil,nil,"zg_dual_PowerOn","Zg Dual Power On",{1,2,4,9},{1,2,4,9},42,43,42},{69,nil,69,"presenceState",nil,0,0,"zg_dual_PresenceState","Zg Dual Presence State",{11,70,71,72},{11,70,71,72},44,45,44},{73,nil,73,10,nil,0,0,"zg_dual_Action","Zg Dual Action",{2,1,4},{2,1,4},46,47,46},{74,nil,74,75,nil,0,0,"hm_s1_m_test","Hm S1MTest State",{3,6},{3,6},48,49,48},{76,nil,76,77,nil,0,0,"hm_s1_m_alarm_state","Hm S1MAlarm State",{5,12,78,13},{5,12,78,13},50,51,50},{79,nil,79,80,nil,0,0,"hm_s1_m_interconnectable","Hm S1MInterconnectable",{3,6},{3,6},52,53,52},{81,nil,81,"smokeUnit",nil,0,0,"hm_s1_m_smoke_unit","Hm S1MSmoke Unit",{82,83},{82,83},54,55,54},{84,nil,84,"chamberState",nil,0,0,"hm_s1_m_chamber_contamination","Hm S1MChamber State",{5,85,86,87},{5,85,86,87},56,57,56},{88,nil,88,89,nil,0,0,"hm_s1_m_link_available","Hm S1MLink State",{3,14,15,16,17},{3,14,15,16,17},58,59,58},{90,nil,90,91,nil,nil,nil,"hm_s1_m_siren_for_automation_only","Hm S1MSiren Mode",{18,19,20},{18,19,20},60,61,60},{92,nil,92,75,nil,0,0,"hm_c1_m_test","Hm C1MTest State",{3,6},{3,6},62,63,62},{93,nil,93,"lifeState",nil,0,0,"hm_c1_m_endoflife","Hm C1MLife State",{5,94,95},{5,94,95},64,65,64},{96,nil,96,77,nil,0,0,"hm_c1_m_alarm_state","Hm C1MAlarm State",{5,12,97,13},{5,12,97,13},66,67,66},{98,nil,98,"preheatState",nil,0,0,"hm_c1_m_preheating","Hm C1MPreheat State",{5,99},{5,99},68,69,68},{100,nil,100,80,nil,0,0,"hm_c1_m_interconnectable","Hm C1MInterconnectable",{3,6},{3,6},70,71,70},{101,nil,101,91,nil,nil,nil,"hm_c1_m_siren_for_automation_only","Hm C1MSiren Mode",{18,19,20},{18,19,20},72,73,72},{102,nil,102,89,nil,0,0,"hm_c1_m_link_available","Hm C1MLink State",{3,14,15,16,17},{3,14,15,16,17},74,75,74},{103,nil,103,21,nil,0,0,"mir_sr100_alarm","Mir Sr100Alarm",{11,21},{11,21},76,77,76},{104,nil,104,10,nil,0,0,"mir_sr100_switch_action","Mir Sr100Switch Action",{2,1},{2,1},78,79,78},{105,nil,105,21,nil,0,0,"somfy_open_alarm","Somfy Open Alarm",{6,3},{6,3},80,81,80}},K)a.text=z({{"last_power_response_time",106,106,0,0,nil,"Last power response time",64},{107,107,108,0,0,"hm_s1_m_fault_state","Hm S1MFault State",66},{109,109,110,0,0,"hm_s1_m_muted","Hm S1MMute State",87},{111,111,108,0,0,"hm_c1_m_fault_state","Hm C1MFault State",66},{112,112,110,0,0,"hm_c1_m_muted","Hm C1MMute State",87}},M)a.driver_message={attribute_name="driverMessage",capability_id="concertmirror08464.driverMessage",emit_name="driver_message",label="Driver message",maximum_length=512}a.by_range_key={}a.by_emit_name={}a.by_capability_id={}
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

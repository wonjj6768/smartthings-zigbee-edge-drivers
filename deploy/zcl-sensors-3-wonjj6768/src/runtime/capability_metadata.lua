local a,H={},{"lx","low","bright","medium","high","dark","twilight","normal","s","off","on","darkThreshold","brightThreshold","shellyBluDoorHandlePosition","shellyBluMotionLightLevel","shellyBluDoorLightLevel","shellyBluDisplayLightLevel","batteryLow","identify","sonoffSafetyOccupancyTimeout","sonoffSafetyAlarmDuration","zg303zSoilMoisture","airCubeEquivalentCo2","airCubeVocLevel","shellyDoorDarkThreshold","shellyDoorBrightThreshold","shellyMotionDarkThresholdV2","shellyMotionBrightThresholdV2","shellyDisplayDarkThresholdV2","shellyDisplayBrightThresholdV2","open","closed","tilted","sonoffSafetyOccupancySensitivity","sonoffSafetyIllumination","sonoffSafetyAlarmSoundEnable","sonoffSafetyAlarmLightEnable","sonoffSafetyAlarmSoundType","siren_classic","siren_steady","siren_rising","siren_warning","siren_rapid","siren_emergency","tone_chirp","tone_hi_lo","tone_intermittent","tone_pulse","sonoffSafetyAlarmVolume","shellyBluSensitivity","trust808BatteryLow","besisMs01Identify","shellyDoorBatteryLow","shellyMotionBatteryLow","lastPowerResponseTime"}
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
a.numeric=z({{20,nil,20,"occupancyTimeout",nil,nil,nil,"sonoff_safety_occupancy_timeout","Sonoff Safety Occupancy Timeout",{15,65535,1,9,nil,1},nil,nil,9},{21,nil,21,"alarmDuration",nil,nil,nil,"sonoff_safety_alarm_duration","Sonoff Safety Alarm Duration",{1,900,1,9,nil,2},nil,nil,9},{22,nil,22,"soilMoisture",nil,0,0,"zg303z_soil_moisture","Zg303z Soil Moisture",{0,100,0.01,"%",nil,3},nil,nil,"%"},{23,nil,23,"equivalentCarbonDioxide",nil,0,0,"aircube_equivalent_co2","Air Cube Equivalent Co2",{400,8192,1,"ppm",nil,4},nil,nil,"ppm"},{24,nil,24,"vocLevel",nil,0,0,"aircube_voc_level","Air Cube Voc Level",{0,500,1,nil,nil,5}},{25,nil,25,12,nil,nil,nil,"shelly_blu_door_dark_threshold","Shelly Door Dark Threshold",{nil,nil,nil,1,nil,6},nil,nil,1},{26,nil,26,13,nil,nil,nil,"shelly_blu_door_bright_threshold","Shelly Door Bright Threshold",{nil,nil,nil,1,nil,7},nil,nil,1},{27,nil,27,12,nil,nil,nil,"shelly_blu_motion_dark_threshold","Shelly Motion Dark Threshold V2",{nil,nil,nil,1,nil,8},nil,nil,1},{28,nil,28,13,nil,nil,nil,"shelly_blu_motion_bright_threshold","Shelly Motion Bright Threshold V2",{nil,nil,nil,1,nil,9},nil,nil,1},{29,nil,29,12,nil,nil,nil,"shelly_blu_display_dark_threshold","Shelly Display Dark Threshold V2",{nil,nil,nil,1,nil,10},nil,nil,1},{30,nil,30,13,nil,nil,nil,"shelly_blu_display_bright_threshold","Shelly Display Bright Threshold V2",{nil,nil,nil,1,nil,11},nil,nil,1}},G)a.enum=z({{14,nil,14,14,nil,0,0,"shelly_handle_position","Shelly Blu Door Handle Position",{31,32,33},{31,32,33},12,13,12},{34,nil,34,"occupancySensitivity",nil,nil,nil,"sonoff_safety_occupancy_sensitivity","Sonoff Safety Occupancy Sensitivity",{2,4,5},{2,4,5},14,15,14},{35,nil,35,"illumination",nil,0,0,"sonoff_safety_illumination","Sonoff Safety Illumination",{"dim",3},{"dim",3},16,17,16},{36,nil,36,"alarmSoundEnable",nil,nil,nil,"sonoff_safety_alarm_sound_enable","Sonoff Safety Alarm Sound Enable",{10,11},{10,11},18,19,18},{37,nil,37,"alarmLightEnable",nil,nil,nil,"sonoff_safety_alarm_light_enable","Sonoff Safety Alarm Light Enable",{10,11},{10,11},20,21,20},{38,nil,38,"alarmSoundType",nil,nil,nil,"sonoff_safety_alarm_sound_type","Sonoff Safety Alarm Sound Type",{39,40,41,42,43,44,45,46,47,48},{39,40,41,42,43,44,45,46,47,48},22,23,22},{49,nil,49,"alarmVolume",nil,nil,nil,"sonoff_safety_alarm_volume","Sonoff Safety Alarm Volume",{2,4,5,"max"},{2,4,5,"max"},24,25,24},{50,nil,50,"sensitivity",nil,nil,nil,"shelly_blu_motion_sensitivity","Shelly Blu Sensitivity",{2,4,5},{2,4,5},26,27,26},{15,nil,15,15,nil,0,0,"shelly_blu_motion_light_level","Shelly Blu Motion Light Level",{6,7,3},{6,7,3},28,29,28},{16,nil,16,16,nil,0,0,"shelly_blu_door_light_level","Shelly Blu Door Light Level",{6,7,3},{6,7,3},30,31,30},{17,nil,17,17,nil,0,0,"shelly_blu_display_light_level","Shelly Blu Display Light Level",{6,7,3},{6,7,3},32,33,32},{51,nil,51,18,nil,0,0,"trust808_battery_low","Trust808Battery Low",{8,2},{8,2},34,35,34},{52,nil,52,19,nil,nil,nil,"besis_ms01_identify","Besis Ms01Identify",{19},{19},36,37,36},{53,nil,53,18,nil,0,0,"shelly_door_battery_low","Shelly Door Battery Low",{8,2},{8,2},38,39,38},{54,nil,54,18,nil,0,0,"shelly_motion_battery_low","Shelly Motion Battery Low",{8,2},{8,2},40,41,40}},K)a.text=z({{"last_power_response_time",55,55,0,0,nil,"Last power response time",64}},M)a.driver_message={attribute_name="driverMessage",capability_id="concertmirror08464.driverMessage",emit_name="driver_message",label="Driver message",maximum_length=512}a.by_range_key={}a.by_emit_name={}a.by_capability_id={}
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

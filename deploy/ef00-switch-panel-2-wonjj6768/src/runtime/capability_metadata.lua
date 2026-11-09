local a,H={},{"on","off","panelName","previous","switch","scene","smart_light","curtain","powerMemory","groupId","rawBrightness","rawColorTemperature","power_on_behavior","switchMode","curtainSwitch","dimmerSwitch","thermostat","m9proGroupOne","m9proBrightnessOne","m9proColorTempOne","m9proGroupTwo","m9proBrightnessTwo","m9proColorTempTwo","m9proGroupThree","m9proBrightnessThree","m9proColorTempThree","m9proGroupFour","m9proBrightnessFour","m9proColorTempFour","m9proSetpoint","m9proFan","m9proWeatherTemp","powerOnBehavior","m9proModeOne","m9proModeTwo","m9proModeThree","m9proModeFour","m9proShowWeather","m9proScreen","motion","on_press","m9proPowerMemory","m9proPowerOne","m9proPowerTwo","m9proPowerThree","m9proPowerFour","m9proBacklight","backlight","m9proScene","switch_1","switch_2","switch_3","switch_4","switch_5","switch_6","switch_7","switch_8","switch_9","m9proCurtainOne","m9proCurtainTwo","m9proCurtainThree","m9proCurtainFour","m9proDimmerOne","m9proDimmerTwo","m9proDimmerThree","m9proDimmerFour","m9proThermostat","m9proWeatherCondition","sunny","heavy_rain","cloudy","sandstorm","light_snow","snow","freezing_fog","rainstorm","shower","dust","spit","sleet","freezing_rain","rain","heavy_shower","heavy_snow","heavy_downpour","blizzard","hailstone","snow_shower","haze","thunder_shower","lastPowerResponseTime","m9proSwitchOneName","m9proSwitchTwoName","m9proSwitchThreeName","m9proSwitchFourName","m9proSceneOneName","m9proSceneTwoName","m9proSceneThreeName","m9proSceneFourName","m9proDimmerOneName","m9proDimmerTwoName","m9proDimmerThreeName","m9proDimmerFourName","m9proCurtainOneName","m9proCurtainTwoName","m9proCurtainThreeName","m9proCurtainFourName","m9proThermostatName"}
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
a.numeric=z({{18,nil,18,10,nil,nil,nil,"group_id_l1","M9pro Group One",{1,10000,1,nil,nil,1}},{19,nil,19,11,nil,0,0,"brightness_l1","M9pro Brightness One",{0,255,1,nil,nil,2}},{20,nil,20,12,nil,0,0,"color_temp_l1","M9pro Color Temp One",{0,65535,1,nil,nil,3}},{21,nil,21,10,nil,nil,nil,"group_id_l2","M9pro Group Two",{1,10000,1,nil,nil,4}},{22,nil,22,11,nil,0,0,"brightness_l2","M9pro Brightness Two",{0,255,1,nil,nil,5}},{23,nil,23,12,nil,0,0,"color_temp_l2","M9pro Color Temp Two",{0,65535,1,nil,nil,6}},{24,nil,24,10,nil,nil,nil,"group_id_l3","M9pro Group Three",{1,10000,1,nil,nil,7}},{25,nil,25,11,nil,0,0,"brightness_l3","M9pro Brightness Three",{0,255,1,nil,nil,8}},{26,nil,26,12,nil,0,0,"color_temp_l3","M9pro Color Temp Three",{0,65535,1,nil,nil,9}},{27,nil,27,10,nil,nil,nil,"group_id_l4","M9pro Group Four",{1,10000,1,nil,nil,10}},{28,nil,28,11,nil,0,0,"brightness_l4","M9pro Brightness Four",{0,255,1,nil,nil,11}},{29,nil,29,12,nil,0,0,"color_temp_l4","M9pro Color Temp Four",{0,65535,1,nil,nil,12}},{30,nil,30,"rawHeatingSetpoint",nil,0,0,"current_heating_setpoint","M9pro Setpoint",{0,255,1,nil,nil,13}},{31,nil,31,"rawFanMode",nil,0,0,"fan_mode","M9pro Fan",{0,255,1,nil,nil,14}},{32,nil,32,"forecastTemperature",nil,nil,nil,"temperature_1","M9pro Weather Temp",{-65,99,nil,nil,nil,15}}},G)a.enum=z({{13,13,33,33,"supportedPowerOnBehaviors",nil,nil,13,"Power on behavior",{2,1,4},{2,1,4},16,17,16},{34,nil,34,14,nil,nil,nil,"mode_l1","M9pro Mode One",{5,6,7,8},{5,6,7,8},18,19,18},{35,nil,35,14,nil,nil,nil,"mode_l2","M9pro Mode Two",{5,6,7,8},{5,6,7,8},20,21,20},{36,nil,36,14,nil,nil,nil,"mode_l3","M9pro Mode Three",{5,6,7,8},{5,6,7,8},22,23,22},{37,nil,37,14,nil,nil,nil,"mode_l4","M9pro Mode Four",{5,6,7,8,17},{5,6,7,8,17},24,25,24},{38,nil,38,"weatherDisplay",nil,nil,nil,"show_weather","M9pro Show Weather",{2,1},{2,1},26,27,26},{39,nil,39,"screenMode",nil,nil,nil,"show_screen","M9pro Screen",{40,41,1},{40,41,1},28,29,28},{42,nil,42,9,nil,nil,nil,13,"M9pro Power Memory",{2,1,4},{2,1,4},30,31,30},{43,nil,43,9,nil,nil,nil,"power_on_behavior_l1","M9pro Power One",{2,1,4},{2,1,4},32,33,32},{44,nil,44,9,nil,nil,nil,"power_on_behavior_l2","M9pro Power Two",{2,1,4},{2,1,4},34,35,34},{45,nil,45,9,nil,nil,nil,"power_on_behavior_l3","M9pro Power Three",{2,1,4},{2,1,4},36,37,36},{46,nil,46,9,nil,nil,nil,"power_on_behavior_l4","M9pro Power Four",{2,1,4},{2,1,4},38,39,38},{47,nil,47,48,nil,nil,nil,48,"M9pro Backlight",{2,1},{2,1},40,41,40},{49,nil,49,"sceneSwitch",nil,nil,nil,"scene_switch","M9pro Scene",{50,51,52,53,54,55,56,57,58},{50,51,52,53,54,55,56,57,58},42,43,42},{59,nil,59,15,nil,nil,nil,"curtain_switch_l1","M9pro Curtain One",{2,1},{2,1},44,45,44},{60,nil,60,15,nil,nil,nil,"curtain_switch_l2","M9pro Curtain Two",{2,1},{2,1},46,47,46},{61,nil,61,15,nil,nil,nil,"curtain_switch_l3","M9pro Curtain Three",{2,1},{2,1},48,49,48},{62,nil,62,15,nil,nil,nil,"curtain_switch_l4","M9pro Curtain Four",{2,1},{2,1},50,51,50},{63,nil,63,16,nil,nil,nil,"dimmer_switch_l1","M9pro Dimmer One",{2,1},{2,1},52,53,52},{64,nil,64,16,nil,nil,nil,"dimmer_switch_l2","M9pro Dimmer Two",{2,1},{2,1},54,55,54},{65,nil,65,16,nil,nil,nil,"dimmer_switch_l3","M9pro Dimmer Three",{2,1},{2,1},56,57,56},{66,nil,66,16,nil,nil,nil,"dimmer_switch_l4","M9pro Dimmer Four",{2,1},{2,1},58,59,58},{67,nil,67,"thermostatSwitch",nil,nil,nil,17,"M9pro Thermostat",{2,1},{2,1},60,61,60},{68,nil,68,"weatherCondition",nil,nil,nil,"condition_1","M9pro Weather Condition",{69,70,71,72,73,74,75,76,77,78,79,80,"yin",81,82,"fog",83,84,85,86,87,88,89,90},{69,70,71,72,73,74,75,76,77,78,79,80,"yin",81,82,"fog",83,84,85,86,87,88,89,90},62,63,62}},K)a.text=z({{"last_power_response_time",91,91,0,0,nil,"Last power response time",64},{92,92,3,nil,nil,"name_l1","M9pro Switch One Name"},{93,93,3,nil,nil,"name_l2","M9pro Switch Two Name"},{94,94,3,nil,nil,"name_l3","M9pro Switch Three Name"},{95,95,3,nil,nil,"name_l4","M9pro Switch Four Name"},{96,96,3,nil,nil,"scene_name_l1","M9pro Scene One Name"},{97,97,3,nil,nil,"scene_name_l2","M9pro Scene Two Name"},{98,98,3,nil,nil,"scene_name_l3","M9pro Scene Three Name"},{99,99,3,nil,nil,"scene_name_l4","M9pro Scene Four Name"},{100,100,3,nil,nil,"dimmer_name_l1","M9pro Dimmer One Name"},{101,101,3,nil,nil,"dimmer_name_l2","M9pro Dimmer Two Name"},{102,102,3,nil,nil,"dimmer_name_l3","M9pro Dimmer Three Name"},{103,103,3,nil,nil,"dimmer_name_l4","M9pro Dimmer Four Name"},{104,104,3,nil,nil,"curtain_name_l1","M9pro Curtain One Name"},{105,105,3,nil,nil,"curtain_name_l2","M9pro Curtain Two Name"},{106,106,3,nil,nil,"curtain_name_l3","M9pro Curtain Three Name"},{107,107,3,nil,nil,"curtain_name_l4","M9pro Curtain Four Name"},{108,108,3,nil,nil,"thermostat_name","M9pro Thermostat Name"}},M)a.driver_message={attribute_name="driverMessage",capability_id="concertmirror08464.driverMessage",emit_name="driver_message",label="Driver message",maximum_length=512}a.by_range_key={}a.by_emit_name={}a.by_capability_id={}
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

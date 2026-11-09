local a,H={},{"off","on","toggle","stop","action","open","close","s","actionGroup","previous","switch","scene","operation_mode","command","event","disarm","arm_all_zones","emergency","single","double","brightness_step_up","brightness_step_down","battery_low","power_on_behavior","switch_mode","switchMode","operationMode","learn_ir_code","security_remote_action","heiman_rc_partial_security_action","tsfKnobStep","tsfKnobBrightnessDelta","mired","tsfKnobColorDelta","tsfKnobTransition","tsfKnobRate","shellyRcGroup","shellyRcLevel","shellyRcRate","shellyRcStep","shellyRcTransition","ysiaOneGroup","ysiaFiveGroup","situoFourGroup","batteryLow","normal","powerOnBehavior","learnIrCode","start","securityRemoteAction","arm_day_zones","arm_night_zones","exit_delay","heimanRcPartialSecurityAction","arm_partial_zones","shellyOneSwitchType","momentary","candeoRd1pRemAction","pressed","double_pressed","held","released","started_rotating_left","started_rotating_right","rotating_right","rotating_left","stopped_rotating","ts0726FourScenePowerBehavior","ts0726FourSceneSwitchMode","tsfKnobAction","hold","rotate_left","rotate_right","color_temperature_step_up","color_temperature_step_down","hue_move","hue_down","hue_stop","tsfKnobMode","shellyRcAction","brightness_move_to_level","brightness_move_up","brightness_move_down","brightness_stop","shellyToughAction","triple","single_long","double_long","triple_long","ysiaOneAction","ysiaFiveAction","situoFourAction","lastPowerResponseTime","remoteAction","learnedIrCode","irCodeToSend"}
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
a.numeric=z({{31,nil,31,"stepSize",nil,0,0,"action_step_size","Tsf Knob Step",{0,255,1,nil,nil,1}},{32,nil,32,"brightnessDelta",nil,0,0,"action_brightness_delta","Tsf Knob Brightness Delta",{-255,255,1,nil,nil,2}},{34,nil,34,"colorDelta",nil,0,0,"action_color_temperature_delta","Tsf Knob Color Delta",{-65535,65535,1,33,nil,3},nil,nil,33},{35,nil,35,"transitionTime",nil,0,0,"action_transition_time","Tsf Knob Transition",{0,6553.5,0.1,8,nil,4},nil,nil,8},{36,nil,36,"rate",nil,0,0,"action_rate","Tsf Knob Rate",{0,255,1,nil,nil,5}},{37,nil,37,9,nil,0,0,"shelly_rc_group","Shelly Rc Group",{1,65527,1,nil,nil,6}},{38,nil,38,"actionLevel",nil,0,0,"shelly_rc_level","Shelly Rc Level",{0,255,1,nil,nil,7}},{39,nil,39,"actionRate",nil,0,0,"shelly_rc_rate","Shelly Rc Rate",{0,255,1,nil,nil,8}},{40,nil,40,"actionStepSize",nil,0,0,"shelly_rc_step","Shelly Rc Step",{0,255,1,nil,nil,9}},{41,nil,41,"actionTransitionTime",nil,0,0,"shelly_rc_transition","Shelly Rc Transition",{0,6553.5,0.1,8,nil,10},nil,nil,8},{42,nil,42,9,nil,0,0,"ysia_one_group","Ysia One Group",{1,65527,1,nil,nil,11}},{43,nil,43,9,nil,0,0,"ysia_five_group","Ysia Five Group",{1,65527,1,nil,nil,12}},{44,nil,44,9,nil,0,0,"situo_four_group","Situo Four Group",{1,65527,1,nil,nil,13}}},G)a.enum=z({{23,23,45,45,nil,0,0,23,"Battery low",{46,"low"},{46,"low"},14,15,14},{24,24,47,47,"supportedPowerOnBehaviors",nil,nil,24,"Power on behavior",{1,2,10},{1,2,10},16,17,16},{25,25,26,26,"supportedSwitchModes",nil,nil,25,"Switch mode",{11,12},{11,12},18,19,18},{13,13,27,27,"supportedOperationModes",nil,nil,13,"Operation mode",{14,15},{14,15},20,21,20},{28,28,48,48,"supportedLearnIrCodes",nil,nil,28,"Learn IR code",{49,4},{49,4},22,23,22},{29,29,50,50,"supportedSecurityRemoteActions",0,0,29,"Security remote action",{16,51,52,17,53,18},{16,51,52,17,53,18},24,25,24},{30,30,54,54,nil,0,0,30,"HEIMAN RC partial security action",{16,55,17,18},{16,55,17,18},26,27,26},{56,nil,56,"switchType",nil,nil,nil,"shelly_one_switch_type","Shelly One Switch Type",{3,57},{3,57},28,29,28},{58,nil,58,"candeoRdOnepRemAction",nil,0,0,"candeo_rd1p_rem_action","Candeo Rd1p Rem Action",{59,60,61,62,63,64,65,66,67},{59,60,61,62,63,64,65,66,67},30,31,30},{68,nil,68,"powerBehavior",nil,nil,nil,"ts0726_four_scene_power_behavior","Ts0726Four Scene Power Behavior",{1,2,10},{1,2,10},32,33,32},{69,nil,69,26,nil,nil,nil,"ts0726_four_scene_switch_mode","Ts0726Four Scene Switch Mode",{11,12},{11,12},34,35,34},{70,nil,70,5,nil,0,0,"tsf_knob_action","Tsf Knob Action",{19,20,71,72,73,3,21,22,74,75,76,77,78},{19,20,71,72,73,3,21,22,74,75,76,77,78},36,37,36},{79,nil,79,27,nil,nil,nil,13,"Tsf Knob Mode",{14,15},{14,15},38,39,38},{80,nil,80,5,nil,0,0,"shelly_rc_action","Shelly Rc Action",{2,1,3,21,22,81,82,83,84},{2,1,3,21,22,81,82,83,84},40,41,40},{85,nil,85,5,nil,0,0,"shelly_tough_action","Shelly Tough Action",{19,20,86,87,88,89},{19,20,86,87,88,89},42,43,42},{90,nil,90,5,nil,0,0,"ysia_one_action","Ysia One Action",{2,1,3,6,7,4},{2,1,3,6,7,4},44,45,44},{91,nil,91,5,nil,0,0,"ysia_five_action","Ysia Five Action",{2,1,3,6,7,4},{2,1,3,6,7,4},46,47,46},{92,nil,92,5,nil,0,0,"situo_four_action","Situo Four Action",{2,1,3,6,7,4},{2,1,3,6,7,4},48,49,48}},K)a.text=z({{"last_power_response_time",93,93,0,0,nil,"Last power response time",64},{"remote_action",94,94,0,0,nil,"Remote action",128},{"learned_ir_code",95,95,0,0,nil,"Learned IR code",2048},{"ir_code_to_send",96,96,nil,nil,nil,"IR code to send",2048}},M)a.driver_message={attribute_name="driverMessage",capability_id="concertmirror08464.driverMessage",emit_name="driver_message",label="Driver message",maximum_length=512}a.by_range_key={}a.by_emit_name={}a.by_capability_id={}
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

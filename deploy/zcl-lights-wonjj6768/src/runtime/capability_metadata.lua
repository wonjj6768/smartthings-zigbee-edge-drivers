local a,H={},{"previous","off","on","toggle","s","enabled","disabled","blink","breathe","okay","channel_change","finish_effect","stop_effect","colorloop","stop_colorloop","powerOnBehavior","initial","customized","power_poll_interval","countdownTsOneTenHours","countdownTsOneTenHalfMinute","minBrightnessZclThousand","minimumBrightnessTsOneTenMax","maxBrightnessTsOneTenMax","power_on_behavior","switch_type","light_type","fanModeSequenceAcController","effect","countdown_timer","min_brightness","candeoRd1pDpmOnLevel","candeoRd1pDpmStartupLevel","candeoRd1pDpmOnTransitionTime","candeoRd1pDpmOffTransitionTime","mired","ikea1624ColorMired","ikea1624StartLevel","switchType","state","momentary","lightType","incandescent","halogen","low_medium_high","low_high","on_auto","candeoRd1pDpmAction","pressed","double_pressed","held","released","started_rotating_left","started_rotating_right","rotating_right","rotating_left","stopped_rotating","candeoRd1pDpmPowerBehavior","tsFanBacklight","red_when_on","pink_when_on","red_on_blue_off","pink_on_blue_off","lonD2PowerOne","lonD2PowerTwo","livarnoEffect","livarnoDoNotDisturb","doNotDisturb","livarnoColorPowerBehavior","colorPowerBehavior","ts0505bTwoEffect","ts0505bTwoDoNotDisturb","ts0505bTwoColorPowerBehavior","ledvanceA60PowerBehavior","ledvanceA60Effect","ikea1624PowerOn","ikea1624LevelOff","ikea1624ColorOff","lastPowerResponseTime"}
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
a.numeric=z({{19,19,"powerPollIntervalV2","powerPollInterval","powerPollIntervalRange",nil,nil,19,"Power poll interval",{5,3600,5,5,nil,1},5,3600,5},{20,nil,20,20,nil,nil,nil,30,"Countdown Ts One Ten Hours",{0,43200,1,5,nil,2},nil,nil,5},{21,nil,21,21,nil,nil,nil,30,"Countdown Ts One Ten Half Minute",{0,43200,30,5,nil,3},nil,nil,5},{22,nil,22,22,nil,nil,nil,31,"Min Brightness Zcl Thousand",{0,1000,1,nil,nil,4}},{23,nil,23,23,nil,nil,nil,31,"Minimum Brightness Ts One Ten Max",{1,255,1,nil,nil,5}},{24,nil,24,24,nil,nil,nil,"max_brightness","Max Brightness Ts One Ten Max",{1,255,1,nil,nil,6}},{32,nil,32,"onLevel",nil,nil,nil,"candeo_rd1p_dpm_on_level","Candeo Rd1p Dpm On Level",{0,255,1,nil,nil,7}},{33,nil,33,"startupLevel",nil,nil,nil,"candeo_rd1p_dpm_startup_level","Candeo Rd1p Dpm Startup Level",{0,255,1,nil,nil,8}},{34,nil,34,"onTransitionTime",nil,nil,nil,"candeo_rd1p_dpm_on_transition_time","Candeo Rd1p Dpm On Transition Time",{0,6553.5,0.1,5,nil,9},nil,nil,5},{35,nil,35,"offTransitionTime",nil,nil,nil,"candeo_rd1p_dpm_off_transition_time","Candeo Rd1p Dpm Off Transition Time",{0,6553.5,0.1,5,nil,10},nil,nil,5},{37,nil,37,"colorMired",nil,nil,nil,"ikea1624_color_mired","Ikea1624Color Mired",{nil,nil,nil,36,nil,11},nil,nil,36},{38,nil,38,"startLevel",nil,nil,nil,"ikea1624_start_level","Ikea1624Start Level",{nil,nil,nil,nil,nil,12}}},G)a.enum=z({{25,25,16,16,"supportedPowerOnBehaviors",nil,nil,25,"Power on behavior",{2,3,1},{2,3,1},13,14,13},{26,26,39,39,"supportedSwitchTypes",nil,nil,26,"Switch type",{4,40,41},{4,40,41},15,16,15},{27,27,42,42,"supportedLightTypes",nil,nil,27,"Light type",{"led",43,44},{"led",43,44},17,18,17},{28,nil,28,28,nil,nil,nil,"fan_mode_sequence","Fan Mode Sequence Ac Controller",{45,46,47},{45,46,47},19,20,19},{48,nil,48,"dpmAction",nil,0,0,"candeo_rd1p_dpm_action","Candeo Rd1p Dpm Action",{49,50,51,52,53,54,55,56,57},{49,50,51,52,53,54,55,56,57},21,22,21},{58,nil,58,16,nil,nil,nil,"candeo_rd1p_dpm_power_on_behavior","Candeo Rd1p Dpm Power Behavior",{2,3,4,1},{2,3,4,1},23,24,23},{59,nil,59,"backlightMode",nil,nil,nil,"ts_fan_backlight","Ts Fan Backlight",{60,61,62,63},{60,61,62,63},25,26,25},{64,nil,64,16,nil,nil,nil,"lon_d_two_power_one","Lon D2Power One",{2,3,4,1},{2,3,4,1},27,28,27},{65,nil,65,16,nil,nil,nil,"lon_d_two_power_two","Lon D2Power Two",{2,3,4,1},{2,3,4,1},29,30,29},{66,nil,66,29,nil,nil,nil,"livarno_effect","Livarno Effect",{8,9,10,11,12,13,14,15},{8,9,10,11,12,13,14,15},31,32,31},{67,nil,67,68,nil,nil,nil,"livarno_do_not_disturb","Livarno Do Not Disturb",{6,7},{6,7},33,34,33},{69,nil,69,70,nil,nil,nil,"livarno_color_power_on_behavior","Livarno Color Power Behavior",{17,1,18},{17,1,18},35,36,35},{71,nil,71,29,nil,nil,nil,"ts0505b_two_effect","Ts0505b Two Effect",{8,9,10,11,12,13,14,15},{8,9,10,11,12,13,14,15},37,38,37},{72,nil,72,68,nil,nil,nil,"ts0505b_two_do_not_disturb","Ts0505b Two Do Not Disturb",{6,7},{6,7},39,40,39},{73,nil,73,70,nil,nil,nil,"ts0505b_two_color_power_on_behavior","Ts0505b Two Color Power Behavior",{17,1,18},{17,1,18},41,42,41},{74,nil,74,"powerBehavior",nil,nil,nil,"ledvance_a60_power_behavior","Ledvance A60Power Behavior",{2,3,4,1},{2,3,4,1},43,44,43},{75,nil,75,29,nil,nil,nil,"ledvance_a60_effect","Ledvance A60Effect",{8,9,10,11,12,13,14,15},{8,9,10,11,12,13,14,15},45,46,45},{76,nil,76,"powerOn",nil,nil,nil,"ikea1624_power_on","Ikea1624Power On",{2,3,4,1},{2,3,4,1},47,48,47},{77,nil,77,"levelOff",nil,nil,nil,"ikea1624_level_off","Ikea1624Level Off",{7,6},{7,6},49,50,49},{78,nil,78,"colorOff",nil,nil,nil,"ikea1624_color_off","Ikea1624Color Off",{7,6},{7,6},51,52,51}},K)a.text=z({{"last_power_response_time",79,79,0,0,nil,"Last power response time",64}},M)a.driver_message={attribute_name="driverMessage",capability_id="concertmirror08464.driverMessage",emit_name="driver_message",label="Driver message",maximum_length=512}a.by_range_key={}a.by_emit_name={}a.by_capability_id={}
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
